package Ocsinventory::Agent::Backend::Download;

use strict;
use warnings;

use XML::Simple;
use File::Copy;
use File::Glob;
use LWP::Simple;
use File::Path;

use Archive::Extract;
use File::Copy::Recursive qw(dirmove);

use Data::Dumper;
use Cwd;

sub clean {
    my $params = shift;

    my $config = $params->{config};
    my $logger = $params->{logger};
    my $orderId = $params->{orderId};
    my $storage = $params->{storage};

    my $cleanUpLevel = shift;

    my $downloadBaseDir = $config->{vardir}.'/download';
    my $targetDir = $downloadBaseDir.'/'.$orderId;

    $logger->fault("no orderId") unless $orderId;
    return unless -d $targetDir;


    my $level = [

    # Level 0
    # only clean the part files
    sub {
        my @part = glob("$targetDir/*.part");
        return unless @part;

        $logger->debug("Clean the partially downloaded files for $orderId");
        foreach (glob("$targetDir/*.part")) {
            if (!unlink($_)) {
                $logger->error("Failed to clean $_ up");
            }
        }
    },

    # Level 1
    # only clean the run directory.
    sub {
        return unless -d "$targetDir/run";
        $logger->debug("Clean the $targetDir/run directory");
        if (!rmtree("$targetDir/run")) {
            $logger->error("Failed to clean $targetDir/run up");
        }
    },

    # Level 2
    # clean the final file
    sub {
        return unless -f "$targetDir/final";

        $logger->debug("Clean the $targetDir/file file");
        if (!unlink("$targetDir/final")) {
            $logger->error("Failed to clean $targetDir/final up");
        }
    },

    # Level 3
    # clean the PACK
    sub {
        return unless -d $targetDir;

        $logger->debug("Remove the fragment in $targetDir ");
        if (!rmtree("$targetDir/run")) {
            $logger->error("Failed to remove $targetDir");
        }
    },


    ];

    if (!$cleanUpLevel || $cleanUpLevel >= @$level) {
        $cleanUpLevel = @$level - 1;
    }

    foreach (0..$cleanUpLevel) {
        $level->[$_]();
    }

}

sub extractArchive {
    my $params = shift;

    my $config = $params->{config};
    my $logger = $params->{logger};
    my $orderId = $params->{orderId};
    my $storage = $params->{storage};

    my $order = $storage->{byId}->{$orderId};

    my $downloadBaseDir = $config->{vardir}.'/download';
    my $targetDir = $downloadBaseDir.'/'.$orderId;

    if (!open FILE, "<$targetDir/final") {
        $logger->error("Failed to open $targetDir/final: $!");
        return;
    }

    my $tmp;
    read(FILE, $tmp, 16);
    my $magicNumber = unpack("S<", $tmp);

    if (!$magicNumber) {
        $logger->error("Failed to read magic number for $targetDir/final");
        return;
    }



    my $type = {

        19280 => 'zip',
        35615 => 'tgz', # well gzip...

    };

    if (!$type->{$magicNumber}) {
        $logger->error("Unknow magic number $magicNumber! ".
            "Sorry I can't extract this archive ( $targetDir/final ). ".
            "If you think, your archive is valide, please submit a bug on ".
            "http://launchpad.net/ocsinventory with this message and the ".
            "archive.");
        return;
    }

    $Archive::Extract::DEBUG=$config->{debug}?1:0;
    my $archiveExtract = Archive::Extract->new(

        archive => "$targetDir/final",
        type => $type->{$magicNumber}

    );

    if (!$archiveExtract->extract(to => "$targetDir/run")) {
        $logger->error("Failed to extract archive $targetDir/run");
        return;
    }

    $logger->debug("Archive $targetDir/run extracted");

}

sub processOrderCmd {
    my $params = shift;

    my $config = $params->{config};
    my $logger = $params->{logger};
    my $orderId = $params->{orderId};
    my $storage = $params->{storage};

    my $order = $storage->{byId}->{$orderId};

    my $downloadBaseDir = $config->{vardir}.'/download';
    my $targetDir = $downloadBaseDir.'/'.$orderId;

    my $cwd = getcwd;
    if ($order->{ACT} eq 'EXECUTE') {
        $logger->debug("Execute ".$order->{COMMAND});
        chdir("$targetDir/run");
        system($order->{COMMAND});
        chdir($cwd);

        # TODO, return the exit code
    } elsif ($order->{ACT} eq 'STORE') {
        $logger->debug("Move extracted file in ".$order->{PATH});
        if (!-d $order->{PATH} && !mkpath($order->{PATH})) {
            $logger->error("Failed to create ".$order->{PATH});
            # TODO clean up
            return;
        }
        foreach (glob("$targetDir/run/*")) {
            if ((-d $_ && !dirmove($_, $order->{PATH}))
                &&
                (-f $_ && !move($_, $order->{PATH}))) {
                $logger->error("Failed to copy $_ in ".
                    $order->{PATH}." :$!");
            }
        }
    } elsif ($order->{ACT} eq 'LAUNCH') {

        my $cmd = $order->{'NAME'};
        if (!-f "$targetDir/run/$cmd") {
            $logger->error("$targetDir/run/$cmd not found");
            return;
        }


        if ($^O !~ /^MSWin/) {
            $cmd .= './' unless $cmd =~ /^\//;
            if (chmod(0755, "$targetDir/run/$cmd")) {
                $logger->error("Cannot chmod: $!");
            }
        }

        $logger->debug("Launching $cmd...");

        # TODO, add ./ only for non Windows OS.
        if (!chdir("$targetDir/run")) {
            $logger->fault("Failed to chdir to $cwd");
        }
        system( $cmd );
        if (!chdir($cwd)) {
            $logger->fault("Failed to chdir to $cwd");
        }
        # TODO, return the exit code
    }


}

sub downloadAndConstruct {
    my $params = shift;

    my $config = $params->{config};
    my $logger = $params->{logger};
    my $orderId = $params->{orderId};
    my $storage = $params->{storage};

    my $order = $storage->{byId}->{$orderId};

    my $downloadBaseDir = $config->{vardir}.'/download';
    my $targetDir = $downloadBaseDir.'/'.$orderId;



    $logger->fault("order not correctly initialised") unless $order;
    $logger->fault("config not correctly initialised") unless $config;

    $logger->debug("processing ".$orderId);


    my $baseUrl = ($order->{PROTO} =~ /^HTTP$/i)?"http://":"";
    $baseUrl .= $order->{PACK_LOC};
    $baseUrl .= '/' if $order->{PACK_LOC} !~ /\/$/;
    $baseUrl .= $orderId;

    $logger->info("Download the file(s) if needed");


    # Randomise the download order
    my @downloadToDo;
    foreach (0..($order->{FRAGS})) {
        push (@downloadToDo, '1');
    }
    while (grep (/1/, @downloadToDo)) {

        my $fragID = int(rand(@downloadToDo)+1); # pick a random frag
        next unless $downloadToDo[$fragID-1]; # Already done?
        $downloadToDo[$fragID-1] = 0;



        my $frag = $orderId.'-'.$fragID;

        my $remoteFile = $baseUrl.'/'.$frag;
        my $localFile = $targetDir.'/'.$frag;

        next if -f $localFile; # Local file already here

        my $rc = LWP::Simple::getstore($remoteFile, $localFile.'.part');
        if (is_success($rc) && move($localFile.'.part', $localFile)) {
            # TODO to a md5sum/sha256 check here
            $logger->debug($remoteFile.' -> '.$localFile.': success');

        } else {
            $logger->error($remoteFile.' -> '.$localFile.': failed');
            unlink ($localFile.'.part');
            unlink ($localFile);
            # TODO Count the number of failure
            return;
        }
    }


    ### Recreate the archive
    $logger->info("Construct the archive in $targetDir/final");
    if (!open (FINALFILE, ">$targetDir/final")) {
        $logger->error("Failed to open $targetDir/final");
        return;
    }
    foreach my $fragID (1..$order->{FRAGS}) {
        my $frag = $orderId.'-'.$fragID;

        my $localFile = $targetDir.'/'.$frag;
        if (!open (FRAG, "<$localFile")) {
            $logger->error("Failed to open $localFile");
            close FINALFILE;
            $logger->error("Failed to remove $baseUrl") unless unlink $baseUrl;
            return;
        }

        foreach (<FRAG>) {
            if (!print FINALFILE) {
                # TODO, imagine a graceful clean up function
                $logger->error("Failed to write in $localFile: $!");
                clean(2);
                return;
            }
        }
        close FRAG;
    }
    close FINALFILE; # TODO catch the ret code


    return unless extractArchive({
            config => $config,
            logger => $logger,
            orderId => $orderId,

        });


}


sub check {
    my $params = shift;

    my $prologresp = $params->{prologresp};
    my $config = $params->{config};
    my $logger = $params->{logger};
    my $storage = $params->{storage};
#    print "Storage".Dumper($storage);

    if (!$storage) {
        $storage->{config} = {};
        $storage->{byId} = {};
        $storage->{byPriority} = [
        0  => {},
        1  => {},
        2  => {},
        4  => {},
        5  => {},
        5  => {},
        6  => {},
        7  => {},
        8  => {},
        9  => {},
        10 => {},
        ];
    }

    my $downloadBaseDir = $config->{vardir}.'/download';


    # The orders are send during the PROLOG. Since the prolog is
    # one of the arg of the check() function. We can process it.
    return unless $prologresp;
    my $conf = $prologresp->getOptionsInfoByName("DOWNLOAD");

    if (!@$conf) {
        $logger->debug("no DOWNLOAD options returned during PROLOG");
        return;
    }

    if (!$config->{vardir}) {
        $logger->error("vardir is not initialized!");
        return;
    }


    # The XML is ill formated and we have to run a loop to retriev
    # the different keys
    foreach my $paramHash (@$conf) {
        if ($paramHash->{TYPE} eq 'CONF') {
            # Save the config sent during the PROLOG
            $storage->{config} = $conf->[0];
        } elsif ($paramHash->{TYPE} eq 'PACK') {
            if ($storage->{byId}{$paramHash->{ID}}) {
                $logger->debug($paramHash->{ID}." already in the queue.");
                next;
            }

            my $infoURI = 'https://'.$paramHash->{INFO_LOC}.'/'.$paramHash->{ID}.'/info';
            my $content = LWP::Simple::get($infoURI);
            if (!$content) {
                $logger->error("Failed to read info file `$infoURI'");
            }

            my $infoHash = XML::Simple::XMLin( $content );
            if (!$infoHash) {
                $logger->error("Failed to parse info file `$infoURI'");
            }

            if (
                !$infoHash->{ID}
                ||
                $infoHash->{ID} !~ /^\d+$/
                ||
                !$infoHash->{ACT}
                ||
                $infoHash->{PRI} !~ /^\d+$/
            ) {
                $logger->error("Incorrect content in info file `$infoURI'");
                # TODO report the info the server
            } else {
                $storage->{byId}{$infoHash->{ID}} = $infoHash;
                foreach (keys %$paramHash) {
                    $storage->{byId}{$infoHash->{ID}}{$_} = $paramHash->{$_};
                }

                $storage->{byPriority}->[$infoHash->{PRI}]->{$infoHash->{ID}} = $storage->{byId}{$infoHash->{ID}};
                $logger->debug("New download added in the queue. Info is `$infoURI'");
            }
        }
    }

    1;
}

sub longRun {

    my $params = shift;

    my $prologresp = $params->{prologresp};
    my $config = $params->{config};
    my $logger = $params->{logger};
    my $storage = $params->{storage};
    print "Storage".Dumper($storage);

    my $downloadBaseDir = $config->{vardir}.'/download';
    if (!-d $downloadBaseDir && !mkpath($downloadBaseDir)) {
        $logger->error("Failed to create $downloadBaseDir");
    }

    foreach my $priority (0..10) {
        foreach my $orderId (keys %{$storage->{byPriority}->[$priority]}) {
            clean({
                    config => $config,
                    logger => $logger,
                    orderId => $orderId,
                    storage => $storage,
                }, 2);

            my $targetDir = $downloadBaseDir.'/'.$orderId;
            if (!-d "$targetDir/run" && !mkpath("$targetDir/run")) {
                $logger->error("Failed to create $targetDir/run");
                return;
            }
            my $order = $storage->{byId}->{$orderId};


            # A file is attached to this order
            if ($order->{FRAGS}) {
                downloadAndConstruct({
                        config => $config,
                        logger => $logger,
                        orderId => $orderId,
                        storage => $storage,
                    });
                extractArchive({
                        config => $config,
                        logger => $logger,
                        orderId => $orderId,
                        storage => $storage,
                    });
            }
            processOrderCmd({
                    config => $config,
                    logger => $logger,
                    orderId => $orderId,
                    storage => $storage,
                });
            clean({
                    config => $config,
                    logger => $logger,
                    orderId => $orderId,
                    storage => $storage,
                }, 2);
        }
    }
}

1;

