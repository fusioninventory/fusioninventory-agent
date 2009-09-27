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

    my $downloadBaseDir = $config->{vardir}.'/download';
    my $targetDir = $downloadBaseDir.'/'.$orderId;

    $logger->fault("no orderId") unless $orderId;
    return unless -d $targetDir;


    my $level = [

    # Level 0
    # only clean the run directory.
    sub {
        foreach (glob("$targetDir/*.part")) {
            if (!unlink($_)) {
                $logger->error("Failed to clean $_ up");
            }
        }
    },

    # Level 1
    # only clean the run directory.
    sub {
        if (-d "$targetDir/run" && !rmtree("$targetDir/run")) {
            $logger->error("Failed to clean $targetDir/run up");
        }
    },

    # Level 2
    # clean the final file
    sub {
        if (-f "$targetDir/final" && !unlink("$targetDir/final")) {
            $logger->error("Failed to clean $targetDir/final up");
        }
    },

    # Level 3
    # clean the PACK
    sub {
        foreach (glob("$targetDir/*-*")) {
            if (!unlink($_)) {
                $logger->error("Failed to clean $_ up");
            }
        }
    },


    ];

}

sub downloadAndExtract {
    my $params = shift;

    use Data::Dumper;
#    print Dumper($params);
    my $config = $params->{config};
    my $logger = $params->{logger};
    my $orderId = $params->{orderId};
    my $storage = $params->{storage};

    my $order = $storage->{byId}->{$orderId};

    my $downloadBaseDir = $config->{vardir}.'/download';
    my $targetDir = $downloadBaseDir.'/'.$orderId;
    if (!-d $targetDir && !mkdir ($targetDir)) {
        $logger->error("Failed to create $targetDir");
    }


    if (!-f "$targetDir/run" && mkpath("$targetDir/run")) {
        $logger->error("Failed to create $targetDir/run");
        return;
    }


    if (!$order->{FRAGS}) {
        $logger->info("No files to download/extract");
    } else {


        $logger->fault("order not correctly initialised") unless $order;
        $logger->fault("config not correctly initialised") unless $config;

        $logger->debug("processing ".$orderId);


        my $baseUrl = ($order->{PROTO} =~ /^HTTP$/i)?"http://":"";
        $baseUrl .= $order->{PACK_LOC};
        $baseUrl .= '/' if $order->{PACK_LOC} !~ /\/$/;
        $baseUrl .= $orderId;

        $logger->info("Download the file(s)");
        # TODO randomise the order
        foreach my $fragID (1..$order->{FRAGS}) {
            my $frag = $orderId.'-'.$fragID;

            my $remoteFile = $baseUrl.'/'.$frag;
            my $localFile = $targetDir.'/'.$frag;

            next if -f $localFile; # Local file already here

            my $rc = LWP::Simple::getstore($remoteFile, $localFile.'.part');
            if (is_success($rc) && move($localFile.'.part', $localFile."/")) {
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
        $logger->info("Construct the archive");
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
                    $logger->error("Failed to open $localFile");
                    close FINALFILE;
                    $logger->error("Failed to remove $baseUrl") unless unlink $baseUrl;
                    return;
                }
            }
            close FRAG;
        }
        close FINALEFILE; # TODO catch the ret code

        
        # Turns debug mode on if needed
        #$Archive::Extract::DEBUG=1 if $config->{debug};
        # Prefere local binaries
        $Archive::Extract::PREFER_BIN=1;

        my $success = 0;
        foreach my $type (qw/tgz zip tar tbz/) {
            my $archive = Archive::Extract->new(
                archive => "$targetDir/final",
                type => $type);
            if ($archive && $archive->extract(to => "$targetDir/run")) {
                $logger->debug("Archive is type: $type");
                $logger->info("Files extracted in $targetDir/run");
                $success = 1; 
                last;
            }
        }

        if (!$success) {
            $logger->error("Failed to extract $targetDir/final");
            return;
        }
    } # No attach file to download/extract


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

        $logger->debug("Launching $cmd...");
        if (!-f "$targetDir/run/$cmd") {
            $logger->error("$targetDir/run/$cmd not found");
            return;
        }

        if (chmod(0755, "$targetDir/run/$cmd")) {
            $logger->debug("Cannot chmod: $!");
        }
        # TODO, add ./ only for non Windows OS.
        chdir("$targetDir/run");
        system( "./".$cmd );
        chdir($cwd);
        # TODO, return the exit code
    }
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
    if (!-f $downloadBaseDir && !mkpath($downloadBaseDir)) {
        $logger->error("Failed to create $downloadBaseDir");
    }

    foreach my $priority (0..10) {
        foreach my $orderId (keys %{$storage->{byPriority}->[$priority]}) {
            print $orderId."\n";
            next unless downloadAndExtract({
                    config => $config,
                    logger => $logger,
                    orderId => $orderId,
                    storage => $storage,
                });
        }
    }
}

1;

