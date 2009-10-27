package Ocsinventory::Agent::Backend::Download;

# TODO
# TIMEOUT="30" number of retry to do on a download
# CYCLE_LATENCY="60" time to wait between each different priority processing
# PERIOD_LENGTH="10" nbr of cylce during a period 
#
# DONE
# FRAG_LATENCY="10" time to wait between to frag
# PERIOD_LATENCY="1" time to wait between to package

#
# period()
#  for i in PERIOD_LENGTH
#    foreach priority
#      foreach package per priority
#         ' download each frags
#         ' sleep()FRAG_LATENCY
#      - then sleep(CYCLE_LATENCY)
#    - at the end sleep(PERIOD_LATENCY)
#
#
#
#

use strict;
use warnings;

use XML::Simple;
use File::Copy;
use File::Glob;
use LWP::Simple;
use File::Path;
use Digest::MD5 qw(md5);

use Data::Dumper;

use Archive::Extract;
use File::Copy::Recursive qw(dirmove);

use Cwd;

use Ocsinventory::Agent::XML::SimpleMessage;

sub new {
  my (undef, $params) = @_;

  my $self = {};
  
  $self->{accountconfig} = $params->{accountconfig};
  $self->{accountinfo} = $params->{accountinfo};
  $self->{config} = $params->{config};
  $self->{inventory} = $params->{inventory};
  my $logger = $self->{logger} = $params->{logger};
  $self->{network} = $params->{network};
  $self->{prologresp} = $params->{prologresp};

  bless $self;

}

sub clean {
    my ($this, $params) = @_;

    my $config = $this->{config};
    my $logger = $this->{logger};
    my $storage = $this->{storage};

    my $cleanUpLevel = $params->{cleanUpLevel};
    my $orderId = $params->{orderId};

    my $downloadBaseDir = $config->{vardir}.'/download';
    my $downloadTargetDir = $downloadBaseDir.'/'.$orderId;

    $logger->fault("no orderId") unless $orderId;
    return unless -d $downloadTargetDir;


    my $level = [

    # Level 0
    # only clean the part files
    sub {
        my @part = glob("$downloadTargetDir/*.part");
        return unless @part;

        $logger->debug("Clean the partially downloaded files for $orderId");
        foreach (glob("$downloadTargetDir/*.part")) {
            if (!unlink($_)) {
                $this->reportError($orderId, "Failed to clean $_ up");
            }
        }
    },

    # Level 1
    # only clean the run directory.
    sub {
        return unless -d "$downloadTargetDir/run";
        $logger->debug("Clean the $downloadTargetDir/run directory");
        if (!rmtree("$downloadTargetDir/run")) {
            $this->reportError($orderId, "Failed to clean $downloadTargetDir/run up");
        }
    },

    # Level 2
    # clean the final file
    sub {
        return unless -f "$downloadTargetDir/final";

        $logger->debug("Clean the $downloadTargetDir/file file");
        if (!unlink("$downloadTargetDir/final")) {
            $this->reportError($orderId, "Failed to clean $downloadTargetDir/final up");
        }
    },

    # Level 3
    # clean the PACK
    sub {
        return unless -d $downloadTargetDir;

        $logger->debug("Remove the fragment in $downloadTargetDir ");
        if (!rmtree("$downloadTargetDir/run")) {
            $this->reportError($orderId, "Failed to remove $downloadTargetDir");
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
    my ($this, $params) = @_;

    my $config = $this->{config};
    my $logger = $this->{logger};
    my $storage = $this->{storage};
    
    my $orderId = $params->{orderId};

    my $order = $storage->{byId}->{$orderId};

    my $downloadBaseDir = $config->{vardir}.'/download';
    my $downloadTargetDir = $downloadBaseDir.'/'.$orderId;

    $this->setErrorCode('ERR_EXECUTE'); # ERR_EXTRACT ?
    if (!open FILE, "<$downloadTargetDir/final") {
        $this->reportError($orderId, "Failed to open $downloadTargetDir/final: $!");
        return;
    }
    binmode(FILE);

    my $tmp;
    read(FILE, $tmp, 16);
    my $magicNumber = unpack("S<", $tmp);

    if (!$magicNumber) {
        $this->reportError($orderId, "Failed to read magic number for $downloadTargetDir/final");
        return;
    }



    my $type = {

        19280 => 'zip',
        35615 => 'tgz', # well gzip...

    };

    if (!$type->{$magicNumber}) {
        $this->reportError($orderId, "Unknow magic number $magicNumber! ".
            "Sorry I can't extract this archive ( $downloadTargetDir/final ). ".
            "If you think, your archive is valide, please submit a bug on ".
            "http://launchpad.net/ocsinventory with this message and the ".
            "archive.");
        return;
    }

    $Archive::Extract::DEBUG=$config->{debug}?1:0;
    my $archiveExtract = Archive::Extract->new(

        archive => "$downloadTargetDir/final",
        type => $type->{$magicNumber}

    );

    if (!$archiveExtract->extract(to => "$downloadTargetDir/run")) {
        $this->reportError($orderId, "Failed to extract archive $downloadTargetDir/run");
        return;
    }

    $logger->debug("Archive $downloadTargetDir/run extracted");

    1;
}

sub processOrderCmd {
    my ($this, $params) = @_;

    my $config = $this->{config};
    my $logger = $this->{logger};
    my $storage = $this->{storage};

    my $orderId = $params->{orderId};
    my $order = $storage->{byId}->{$orderId};

    my $downloadBaseDir = $config->{vardir}.'/download';
    my $downloadTargetDir = $downloadBaseDir.'/'.$orderId;

    $this->setErrorCode('ERR_EXECUTE');
    my $cwd = getcwd;
    if ($order->{ACT} eq 'STORE') {
        $logger->debug("Move extracted file in ".$order->{PATH});
        if (!-d $order->{PATH} && !mkpath($order->{PATH})) {
            $this->reportError($orderId, "Failed to create ".$order->{PATH});
            # TODO clean up
            return;
        }
        foreach (glob("$downloadTargetDir/run/*")) {
            if ((-d $_ && !dirmove($_, $order->{PATH}))
                &&
                (-f $_ && !move($_, $order->{PATH}))) {
                $this->reportError($orderId, "Failed to copy $_ in ".
                    $order->{PATH}." :$!");
            }
        }
    } elsif ($order->{ACT} =~ /^(LAUNCH|EXECUTE)$/) {

        my $cmd = $order->{'NAME'};
        if (!-f "$downloadTargetDir/run/$cmd") {
            $this->reportError($orderId, "$downloadTargetDir/run/$cmd not found");
            return;
        }


        if ($order->{ACT} eq 'LAUNCH') {
            if ($^O !~ /^MSWin/) {
                $cmd .= './' unless $cmd =~ /^\//;
                if (chmod(0755, "$downloadTargetDir/run/$cmd")) {
                    $this->reportError($orderId, "Cannot chmod: $!");
                    return;
                }
            }
        }

        $logger->debug("Launching $cmd...");

        if (!chdir("$downloadTargetDir/run")) {
            $this->reportError($orderId, "Failed to chdir to '$cwd'");
            return;
        }
        system( $cmd );
        if ($?) { # perldoc -f system :) 
            $this->reportError($orderId, "Failed to execute '$cmd'");
            return;
        } elsif ($? & 127) {
            my $msg = sprintf "'$cmd' died with signal %d, %s coredump\n", ($? & 127),  ($? & 128) ? 'with' : 'without';
            $this->reportError($orderId, $msg);
            return;
        } elsif ($order->{RET_VAL} != ($? >> 8)) {
            my $msg = sprintf "'$cmd' exited with value %d\n", $? >> 8;
            $this->reportError($orderId, $msg);
            return;
        }

        if (!chdir($cwd)) {
            $logger->fault("Failed to chdir to $cwd");
        }

    }
    $this->setErrorCode('CODE_SUCCESS');
    $this->reportError($orderId, "order processed");

    1;
}

sub downloadAndConstruct {
    my ($this, $params) = @_;

    my $config = $this->{config};
    my $logger = $this->{logger};
    my $storage = $this->{storage};

    my $orderId = $params->{orderId};
    my $order = $storage->{byId}->{$orderId};

    my $downloadBaseDir = $config->{vardir}.'/download';
    my $downloadTargetDir = $downloadBaseDir.'/'.$orderId;

    $this->setErrorCode("ERR_DOWNLOAD_PACK");


    $logger->fault("order not correctly initialised") unless $order;
    $logger->fault("config not correctly initialised") unless $config;

    $logger->debug("processing ".$orderId);

    my $fragLatency = $storage->{config}->{FRAG_LATENCY};
    $order->{ERROR_COUNT}=0 unless exists($order->{ERROR_COUNT});


    my $baseUrl = ($order->{PROTO} =~ /^HTTP$/i)?"http://":"";
    $baseUrl .= $order->{PACK_LOC};
    $baseUrl .= '/' if $order->{PACK_LOC} !~ /\/$/;
    $baseUrl .= $orderId;

    # Randomise the download order
    my @downloadToDo;
    foreach (1..($order->{FRAGS})) {
        my $frag = $orderId.'-'.$_;

        my $localFile = $downloadTargetDir.'/'.$frag;

        if (-f $localFile) {
            push (@downloadToDo, '0');
        } else {
            push (@downloadToDo, '1');
        }
    }

    if (@downloadToDo) {
        $logger->info("Will download ".
            int(grep (/1/, @downloadToDo)).
            " ".
            "fragments in a random order and wait `$fragLatency'".
            " second(s) between each of them");
    }
    while (grep (/1/, @downloadToDo)) {

        my $fragID = int(rand(@downloadToDo))+1; # pick a random frag
        next unless $downloadToDo[$fragID-1] == 1; # Already done?


        my $frag = $orderId.'-'.$fragID;

        my $remoteFile = $baseUrl.'/'.$frag;
        my $localFile = $downloadTargetDir.'/'.$frag;

        my $rc = LWP::Simple::getstore($remoteFile, $localFile.'.part');
        if (is_success($rc) && move($localFile.'.part', $localFile)) {
            # TODO to a md5sum/sha256 check here
            $order->{ERROR_COUNT}=0;
            $logger->debug($remoteFile.' -> '.$localFile.': success');
            $downloadToDo[$fragID-1] = 0;

            sleep ($fragLatency);

        } else {
            $logger->error($remoteFile.' -> '.$localFile.': failed');
            unlink ($localFile.'.part');
            unlink ($localFile);
            $order->{ERROR_COUNT}++;

            sleep ($fragLatency);
        }

        if ($order->{ERROR_COUNT}>30) {
            $this->reportError($orderId, "Max download error reached");
            return;
        }
    }


    ### Recreate the archive
    $this->setErrorCode('ERR_BUILD'); 
    $logger->info("Construct the archive in $downloadTargetDir/final");
    if (!open (FINALFILE, ">$downloadTargetDir/final")) {
        $logger->error("Failed to open $downloadTargetDir/final");
        return;
    }
    binmode(FINALFILE); # ...

    foreach my $fragID (1..$order->{FRAGS}) {
        my $frag = $orderId.'-'.$fragID;

        my $localFile = $downloadTargetDir.'/'.$frag;
        if (!open (FRAG, "<$localFile")) {
            $logger->error("Failed to open $localFile");

            close FINALFILE;
            return;
        }
        binmode(FRAG);

        foreach (<FRAG>) {
            if (!print FINALFILE) {
                close FINALFILE;
                $this->reportError($orderId, "Failed to write in $localFile: $!");
                return;
            }
        }
        close FRAG;
    }

    close FINALFILE;

    $this->setErrorCode("ERR_BAD_DIGEST");
    if ($order->{DIGEST_ALGO} ne 'MD5') {
        $this->reportError($orderId, "Digest '".$order->{DIGEST_ALGO}."' ".
            "not supported by the agent");

        return;
    }
    my $md5 = Digest::MD5->new;
    if (open (FINALFILE, "<$downloadTargetDir/final")) {
        binmode(FINALFILE); # ...
        $md5->add($_) while (<FINALFILE>);
        close FINALFILE;
    }
    if ($md5->hexdigest ne $order->{DIGEST}) {
        $this->reportError($orderId, "Failed to validated the MD5 of ".
            "the file : ".$md5->hexdigest." != ".$order->{DIGEST});
        return;
    }

    1;
}



=item setErrorCode

Set the ErrCode to report for the following code block in case of error.

=cut
sub setErrorCode {
    my ($this, $errorCode) = @_;

    my $logger = $this->{logger};

    $logger->fault('No $errorCode!') unless $errorCode;

    $this->{errorCode} = $errorCode;

}

=item reportError

Report error to the server and to the user throught the logger

=cut
sub reportError {
    my ($this, $orderId, $message) = @_;

    my $config = $this->{config};
    my $logger = $this->{logger};
    my $storage = $this->{storage};

    my $errorCode = $this->{errorCode};
    my $order = $storage->{byId}->{$orderId};

    $logger->fault('$errorCode is not set!') unless $errorCode;
    $logger->fault('$message should be set!') unless $message;


    $logger->error("$orderId> $message");

    my $xmlMsg = new Ocsinventory::Agent::XML::SimpleMessage({
       config => $config,
       logger => $logger,
       msg => {
           QUERY => 'DOWNLOAD',
           ID => $orderId,
           ERR => $errorCode,
       },
   });

    if (!$storage->{errorStack}) {
        $storage->{errorStack} = [];
    }

    push @{$storage->{errorStack}}, $xmlMsg;
    $order->{ERR} = $errorCode;
    $order->{ANWSER_DATE} = time;

    $this->pushErrorStack();
}

sub pushErrorStack {
    my ($this) = @_;


    my $logger = $this->{logger};
    my $network = $this->{network};
    my $storage = $this->{storage};


    if (!$storage->{errorStack}) {
        $storage->{errorStack} = [];
    }

    if (@{$storage->{errorStack}}) {
        my $message = $storage->{errorStack}->[0];
        if ($network->send({message => $message})) {
            shift(@{$storage->{errorStack}});
        } else {
            $logger->error("Failed to contact server!");
            return;
        }
    }

    1;
}


sub isInventoryEnabled {
    my $this = shift;

    my $prologresp = $this->{prologresp};
    my $config = $this->{config};
    my $logger = $this->{logger};
    my $storage = $this->{storage};

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
            my $orderId = $paramHash->{ID};
            if ($storage->{byId}{$orderId}{ERR}) {
                # ERR is set at the end of the process (SUCCESS or ERROR)
                $this->setErrorCode('ERR_ALREADY_SETUP');
                $this->reportError($orderId, "$orderId has already been".
                    "processed");
                next;
            }

            $this->setErrorCode('ERR_DOWNLOAD_INFO');
            # LWP doesn't support SSL cert check and
            # Net::SSLGlue::LWP is a workaround to fix that
            if (!$config->{unsecureSoftwareDeployment}) {
                eval 'use Net::SSLGlue::LWP SSL_ca_path => TODO';
                if ($@) {
                    $this->reportError($orderId, "Failed to load ".
                        "Net::SSLGlue::LWP, to validate the server ".
                        "SSL cert.");
                    next;
                }
            } else {
                $logger->info("--unsecure-software-deployment parameter".
                    "found. Don't check server identity!!!");
            }



            my $infoURI = 'https://'.$paramHash->{INFO_LOC}.'/'.$orderId.'/info';
            my $content = LWP::Simple::get($infoURI);
            if (!$content) {
                $this->reportError($orderId, "Failed to read info file `$infoURI'");
                next;
            }

            my $infoHash = XML::Simple::XMLin( $content );
            if (!$infoHash) {
                $this->reportError($orderId, "Failed to read info file `$infoURI'");
                next;
            }
            $infoHash->{RECEIVED_DATE} = time;

            if (
                !$orderId
                ||
                $orderId !~ /^\d+$/
                ||
                !$infoHash->{ACT}
                ||
                $infoHash->{PRI} !~ /^\d+$/
            ) {
                $this->reportError($orderId, "Incorrect content in info file `$infoURI'");
                next;
            }

            $storage->{byId}{$orderId} = $infoHash;
            foreach (keys %$paramHash) {
                $storage->{byId}{$orderId}{$_} = $paramHash->{$_};
            }

            $storage->{byPriority}->[$infoHash->{PRI}]->{$orderId} = $storage->{byId}{$orderId};

            $logger->debug("New download added in the queue. Info is `$infoURI'");
        }
    }

    # Just in case the server was down when when we tried to send the last
    # messages.
    $this->pushErrorStack();

    1;
}



sub doInventory {

  my $this = shift;
  my $inventory = $this->{inventory};
  my $storage = $this->{storage};

  # Just in case the stack is not empty
  $this->pushErrorStack();



  use Data::Dumper;
  print Dumper($storage);

  # Record in the Inventory the commands already recieved by the agent
  foreach (keys %{$storage->{byId}}) {
    $inventory->addSoftwareDeploymentPackage($_);
  }

}


sub doPostInventory {

    my $this = shift;

    my $prologresp = $this->{prologresp};
    my $config = $this->{config};
    my $network = $this->{network};
    my $logger = $this->{logger};
    my $storage = $this->{storage};

    my $downloadBaseDir = $config->{vardir}.'/download';
    if (!-d $downloadBaseDir && !mkpath($downloadBaseDir)) {
        $logger->error("Failed to create $downloadBaseDir");
    }

    # Just in case
    $this->pushErrorStack();



    use Data::Dumper;
    print Dumper($storage);

    # Try to imitate as much as I can the Windows agent
#    foreach (0..$storage->{config}->{PERIOD_LENGTH}) {
        foreach my $priority (1..10) {
            foreach my $orderId (keys %{$storage->{byPriority}->[$priority]}) {
                my $order = $storage->{byId}->{$orderId};

                # Already processed
                next if exists($order->{ERR});

                $this->clean({
                        cleanUpLevel => 2,
                        orderId => $orderId
                    });

                my $downloadTargetDir = $downloadBaseDir.'/'.$orderId;
                if (!-d "$downloadTargetDir/run" && !mkpath("$downloadTargetDir/run")) {
                    $logger->error("Failed to create $downloadTargetDir/run");
                    return;
                }


                # A file is attached to this order
                if ($order->{FRAGS}) {
                    next unless $this->downloadAndConstruct({
                            orderId => $orderId
                        });
                    next unless $this->extractArchive({
                            orderId => $orderId
                        });
                }

                next unless $this->processOrderCmd({
                        orderId => $orderId
                    });
                delete ($storage->{byPriority}->[$priority]->{$orderId});
                next unless $this->clean({
                        cleanUpLevel => 2,
                        orderId => $orderId
                    });
                $logger->debug("order $orderId processed, wait ".
                    $storage->{config}->{CYCLE_LATENCY}." seconds.");
                sleep ($storage->{config}->{CYCLE_LATENCY});
            }
        }
        $logger->debug("End of period...");
#        sleep($storage->{config}-> {PERIOD_LATENCY});
#    }

}

sub rpcCfg {
    my $self = shift;

    my $config = $self->{config};

    my $downloadBaseDir = $config->{vardir}.'/download';

    my $h = {
        files => {
            path => $downloadBaseDir
        },
#        download => {
#            handler => sub {
#                my ($req, $res, $params) = @_;
#
#                my $config = $params->{config};
#                my $uriParams = $params->{uriParams};
#                
#                my $orderId = $uriParams->{orderId};
#                my $fragId = $uriParams->{fragId};
#
#                my $downloadBaseDir = $config->{vardir}.'/download';
#                my $downloadTargetDir = $downloadBaseDir.'/'.$orderId;
#                my $targetFile = $downloadTargetDir.'/'.$orderId.'-'.$fragId;
#
#                if (!-f $targetFile) {
##                    $res->code(404);
#                    return 404;
#                }
#
#                print Dumper($uriParams);
#
#                if (!open FILE, "<".$targetFile) {
##                    $res->code(403);
#                    return 403;
#                }
#                binmode(FILE);
#
#                $res->header('Content-Type' => 'binary/octet-stream');
#                my $buff;
#                while(read(FILE, $buff, 512)) {
#                    $res->add_content($buff);
#                }
#
#                close FILE;
#            },
        }

    };
       
    return $h;
}

1;

