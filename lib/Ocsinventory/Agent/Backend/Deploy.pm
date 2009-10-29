package Ocsinventory::Agent::Backend::Deploy;

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
use LWP::Simple qw ($ua getstore is_success);
use File::Path;
use File::stat;
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

  if (!exists($self->{config}->{vardir})) {
      $logger->fault('No vardir in $config');
  }

  $self->{downloadBaseDir} = $self->{config}->{vardir}.'/download';
  $self->{runBaseDir} = $self->{config}->{vardir}.'/run';

  if (!-d $self->{downloadBaseDir} && !mkpath($self->{downloadBaseDir})) {
      $logger->error("Failed to create $self->{downloadBaseDir}");
  }



  bless $self;
 
  # Just in case
  $self->pushErrorStack();

  return $self;

}

sub clean {
    my ($self, $params) = @_;

    my $config = $self->{config};
    my $logger = $self->{logger};
    my $storage = $self->{storage};

    my $cleanUpLevel = $params->{cleanUpLevel} || 3;
    my $orderId = $params->{orderId};

    $logger->fault("orderId missing") unless $orderId;

    my $downloadDir = $self->{downloadBaseDir}.'/'.$orderId;
    my $runDir = $self->{downloadBaseDir}.'/'.$orderId;

    $logger->fault("no orderId") unless $orderId;
    return unless -d $downloadDir;


    my $level = [

    # Level 0
    # only clean the part files
    sub {
        my @part = glob("$downloadDir/*.part");
        return unless @part;

        $logger->debug("Clean the partially downloaded files for $orderId");
        foreach (glob("$downloadDir/*.part")) {
            if (!unlink($_)) {
                $self->reportError($orderId, "Failed to clean $_ up");
            }
        }
    },

    # Level 1
    # only clean the run directory.
    sub {
        return unless -d $runDir;
        $logger->debug("Clean the $runDir directory");
        if (!rmtree($runDir)) {
            $self->reportError($orderId, "Failed to clean $runDir up");
        }
    },

    # Level 2
    # clean the final file
    sub {
        return unless -f "$downloadDir/final";

        $logger->debug("Clean the $downloadDir/final file");
        if (!unlink("$downloadDir/final")) {
            $self->reportError($orderId, "Failed to clean $downloadDir/final up");
        }
    },

    # Level 3
    # clean the PACK
    sub {
        return unless -d $downloadDir;

        $logger->debug("Remove the fragment in $downloadDir ");
        if (!rmtree("$downloadDir/run")) {
            $self->reportError($orderId, "Failed to remove $downloadDir");
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
    my ($self, $params) = @_;

    my $config = $self->{config};
    my $logger = $self->{logger};
    my $storage = $self->{storage};
    
    my $orderId = $params->{orderId};

    my $order = $storage->{byId}->{$orderId};

    my $downloadDir = $self->{downloadBaseDir}.'/'.$orderId;
    my $runDir = $self->{runBaseDir}.'/'.$orderId;

    $self->setErrorCode('ERR_EXECUTE'); # ERR_EXTRACT ?
    if (!open FILE, "<$downloadDir/final") {
        $self->reportError($orderId, "Failed to open $downloadDir/final: $!");
        return;
    }
    binmode(FILE);

    my $tmp;
    read(FILE, $tmp, 16);
    my $magicNumber = unpack("S<", $tmp);

    if (!$magicNumber) {
        $self->reportError($orderId, "Failed to read magic number for $downloadDir/final");
        return;
    }



    my $type = {

        19280 => 'zip',
        35615 => 'tgz', # well gzip...

    };

    if (!$type->{$magicNumber}) {
        $self->reportError($orderId, "Unknow magic number $magicNumber! ".
            "Sorry I can't extract this archive ( $downloadDir/final ). ".
            "If you think, your archive is valide, please submit a bug on ".
            "http://launchpad.net/ocsinventory with this message and the ".
            "archive.");
        return;
    }

    $Archive::Extract::DEBUG=$config->{debug}?1:0;
    my $archiveExtract = Archive::Extract->new(

        archive => "$downloadDir/final",
        type => $type->{$magicNumber}

    );

    if (!$archiveExtract->extract(to => "$runDir")) {
        $self->reportError($orderId, "Failed to extract archive $downloadDir/run");
        return;
    }

    $logger->debug("Archive $downloadDir/run extracted");

    1;
}

sub processOrderCmd {
    my ($self, $params) = @_;

    my $config = $self->{config};
    my $logger = $self->{logger};
    my $storage = $self->{storage};

    my $orderId = $params->{orderId};
    my $order = $storage->{byId}->{$orderId};

    my $downloadDir = $self->{downloadBaseDir}.'/'.$orderId;
    my $runDir = $self->{runBaseDir}.'/'.$orderId;

    $self->setErrorCode('ERR_EXECUTE');
    my $cwd = getcwd;
    if ($order->{ACT} eq 'STORE') {
        $logger->debug("Move extracted file in ".$order->{PATH});
        if (!-d $order->{PATH} && !mkpath($order->{PATH})) {
            $self->reportError($orderId, "Failed to create ".$order->{PATH});
            # TODO clean up
            return;
        }
        foreach (glob("$runDir/*")) {
            if ((-d $_ && !dirmove($_, $order->{PATH}))
                &&
                (-f $_ && !move($_, $order->{PATH}))) {
                $self->reportError($orderId, "Failed to copy $_ in ".
                    $order->{PATH}." :$!");
            }
        }
    } elsif ($order->{ACT} =~ /^(LAUNCH|EXECUTE)$/) {

        my $cmd = $order->{'NAME'};
        if (!-f "$runDir/$cmd") {
            $self->reportError($orderId, "$runDir/$cmd not found");
            return;
        }


        if ($order->{ACT} eq 'LAUNCH') {
            if ($^O !~ /^MSWin/) {
                $cmd .= './' unless $cmd =~ /^\//;
                if (chmod(0755, "$runDir/$cmd")) {
                    $self->reportError($orderId, "Cannot chmod: $!");
                    return;
                }
            }
        }

        $logger->debug("Launching $cmd...");

        if (!chdir("$runDir/")) {
            $self->reportError($orderId, "Failed to chdir to '$runDir'");
            return;
        }
        system( $cmd );
        if ($?) { # perldoc -f system :) 
            $self->reportError($orderId, "Failed to execute '$cmd'");
            return;
        } elsif ($? & 127) {
            my $msg = sprintf "'$cmd' died with signal %d, %s coredump\n", ($? & 127),  ($? & 128) ? 'with' : 'without';
            $self->reportError($orderId, $msg);
            return;
        } elsif ($order->{RET_VAL} != ($? >> 8)) {
            my $msg = sprintf "'$cmd' exited with value %d\n", $? >> 8;
            $self->reportError($orderId, $msg);
            return;
        }

        if (!chdir($cwd)) {
            $logger->fault("Failed to chdir to $cwd");
        }

    }
    $self->setErrorCode('CODE_SUCCESS');
    $self->reportError($orderId, "order processed");

    1;
}

sub downloadAndConstruct {
    my ($self, $params) = @_;

    my $config = $self->{config};
    my $logger = $self->{logger};
    my $storage = $self->{storage};

    my $orderId = $params->{orderId};
    my $order = $storage->{byId}->{$orderId};

    my $downloadBaseDir = $config->{vardir}.'/download';
    my $downloadDir = $downloadBaseDir.'/'.$orderId;
    if (!-d $downloadDir && !mkpath($downloadDir)) {
        $logger->error("Failed to create $downloadDir");
    }

    $self->setErrorCode("ERR_DOWNLOAD_PACK");


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

        my $localFile = $downloadDir.'/'.$frag;

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

        my $remoteFile = $self->findMirror($orderId, $fragID);
        if (!$remoteFile) {
            # Can't find a mirror in my networks with the file, I grab it
            # directly from the main server
            $remoteFile = $baseUrl.'/'.$frag;
        }
        my $localFile = $downloadDir.'/'.$frag;

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
            $self->reportError($orderId, "Max download error reached");
            return;
        }
    }


    ### Recreate the archive
    $self->setErrorCode('ERR_BUILD'); 
    $logger->info("Construct the archive in $downloadDir/final");
    if (!open (FINALFILE, ">$downloadDir/final")) {
        $logger->error("Failed to open $downloadDir/final");
        return;
    }
    binmode(FINALFILE); # ...

    foreach my $fragID (1..$order->{FRAGS}) {
        my $frag = $orderId.'-'.$fragID;

        my $localFile = $downloadDir.'/'.$frag;
        if (!open (FRAG, "<$localFile")) {
            $logger->error("Failed to open $localFile");

            close FINALFILE;
            return;
        }
        binmode(FRAG);

        foreach (<FRAG>) {
            if (!print FINALFILE) {
                close FINALFILE;
                $self->reportError($orderId, "Failed to write in $localFile: $!");
                return;
            }
        }
        close FRAG;
    }

    close FINALFILE;

    $self->setErrorCode("ERR_BAD_DIGEST");
    if ($order->{DIGEST_ALGO} ne 'MD5') {
        $self->reportError($orderId, "Digest '".$order->{DIGEST_ALGO}."' ".
            "not supported by the agent");

        $self->clean({ orderId => $orderId });

        return;
    }
    my $md5 = Digest::MD5->new;
    if (open (FINALFILE, "<$downloadDir/final")) {
        binmode(FINALFILE); # ...
        $md5->add($_) while (<FINALFILE>);
        close FINALFILE;
    }
    if ($md5->hexdigest ne $order->{DIGEST}) {
        $self->reportError($orderId, "Failed to validated the MD5 of ".
            "the file : ".$md5->hexdigest." != ".$order->{DIGEST});
        
        $self->clean({ orderId => $orderId });

        return;
    }

    1;
}



=item setErrorCode

Set the ErrCode to report for the following code block in case of error.

=cut
sub setErrorCode {
    my ($self, $errorCode) = @_;

    my $logger = $self->{logger};

    $logger->fault('No $errorCode!') unless $errorCode;

    $self->{errorCode} = $errorCode;

}

=item reportError

Report error to the server and to the user throught the logger

=cut
sub reportError {
    my ($self, $orderId, $message) = @_;

    my $config = $self->{config};
    my $logger = $self->{logger};
    my $storage = $self->{storage};

    my $errorCode = $self->{errorCode};
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

    $self->pushErrorStack();
}

sub pushErrorStack {
    my ($self) = @_;


    my $logger = $self->{logger};
    my $network = $self->{network};
    my $storage = $self->{storage};


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
    my $self = shift;

    my $prologresp = $self->{prologresp};
    my $config = $self->{config};
    my $logger = $self->{logger};
    my $storage = $self->{storage};

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
                $self->setErrorCode('ERR_ALREADY_SETUP');
                $self->reportError($orderId, "$orderId has already been".
                    "processed");
                next;
            }

            $self->setErrorCode('ERR_DOWNLOAD_INFO');
            # LWP doesn't support SSL cert check and
            # Net::SSLGlue::LWP is a workaround to fix that
            if (!$config->{unsecureSoftwareDeployment}) {
                eval 'use Net::SSLGlue::LWP SSL_ca_path => TODO';
                if ($@) {
                    $self->reportError($orderId, "Failed to load ".
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
                $self->reportError($orderId, "Failed to read info file `$infoURI'");
                next;
            }

            my $infoHash = XML::Simple::XMLin( $content );
            if (!$infoHash) {
                $self->reportError($orderId, "Failed to read info file `$infoURI'");
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
                $self->reportError($orderId, "Incorrect content in info file `$infoURI'");
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
    $self->pushErrorStack();

    1;
}



sub doInventory {

  my $self = shift;
  my $inventory = $self->{inventory};
  my $storage = $self->{storage};

  # Just in case the stack is not empty
  $self->pushErrorStack();



  use Data::Dumper;
  print Dumper($storage);

  # Record in the Inventory the commands already recieved by the agent
  foreach (keys %{$storage->{byId}}) {
    $inventory->addSoftwareDeploymentPackage($_);
  }

}


sub doPostInventory {

    my $self = shift;

    my $prologresp = $self->{prologresp};
    my $config = $self->{config};
    my $network = $self->{network};
    my $logger = $self->{logger};
    my $storage = $self->{storage};


#    use Data::Dumper;
#    print Dumper($storage);

    # Try to imitate as much as I can the Windows agent
#    foreach (0..$storage->{config}->{PERIOD_LENGTH}) {
        foreach my $priority (1..10) {
            foreach my $orderId (keys %{$storage->{byPriority}->[$priority]}) {
                my $order = $storage->{byId}->{$orderId};

                # Already processed
                next if exists($order->{ERR});

                $self->clean({
                        cleanUpLevel => 2,
                        orderId => $orderId
                    });

                my $downloadDir = $self->{downloadBaseDir}.'/'.$orderId;
                my $runDir = $self->{runBaseDir}.'/'.$orderId;

                if (!-d "$downloadDir" && !mkpath("$downloadDir")) {
                    $logger->error("Failed to create $downloadDir");
                    return;
                }
                if (!-d "$runDir" && !mkpath("$runDir")) {
                    $logger->error("Failed to create $runDir");
                    return;
                }


                # A file is attached to this order
                if ($order->{FRAGS}) {
                    next unless $self->downloadAndConstruct({
                            orderId => $orderId
                        });
                    next unless $self->extractArchive({
                            orderId => $orderId
                        });
                }

                next unless $self->processOrderCmd({
                        orderId => $orderId
                    });
                delete ($storage->{byPriority}->[$priority]->{$orderId});
                next unless $self->clean({
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

    my $h = {
        files => {
            path => $self->{downloadBaseDir}
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
#                my $downloadDir = $downloadBaseDir.'/'.$orderId;
#                my $targetFile = $downloadDir.'/'.$orderId.'-'.$fragId;
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
#        }

    };
       
    return $h;
}

sub findMirror {
    my ($self, $orderId, $fragId) = @_;

    my $config = $self->{config};
    my $logger = $self->{logger};

    my @addresses;
    if ($^O =~ /^linux/) {
        foreach (`ifconfig`) {
            if (/inet\saddr:(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/) {
                my $address = $1;
                next if $address =~ /^127\./;
                push @addresses, $address;
                print $address."\n";
            }

        }
    }


    my $result;
    foreach my $address (@addresses) {

        my @IpToCheck;
        foreach (0..254) {
            $IpToCheck[$_]=1;
        }

        my $prefix;
        my $myAddNum;
        if ($address =~ /(\d{1,3}\.\d{1,3}\.\d{1,3}\.)(\d{1,3})/) {
            $prefix = $1;
            $IpToCheck[$2-1]=0; # Don't check my own address
        } else {
            $logger->error("Invalid address: $address");
            next;
        }

        $logger->debug("scanning $prefix"."0/24");

        foreach (grep (/1/, @IpToCheck)) {
            if (threads->list(threads::running) > 50) {
                sleep(1);
                next;
            }

            my $id = int(rand(@IpToCheck))+1;
            next unless $IpToCheck[$id-1] == 1; 
            $IpToCheck[$id-1] = 0; 

            my $ip = $prefix.$id;
            my $url =
            "http://$ip:62354/Ocsinventory::Agent::Backend::Download/$orderId/$orderId-$fragId";




            my $thr = threads->create( sub {

                    my $linkIsOk;

                    my $rand = int rand(0xffffffff);
                    my $tempFile = $self->{config}->{vardir}."/tmp.".$rand;

                    $ua->timeout(2);
                    eval {
                        local $SIG{ALRM} = sub { die "alarm\n" };
                        alarm 3;

                        my $rc = LWP::Simple::getstore($url, $tempFile);
                        if (is_success($rc)) {
                            $linkIsOk=1;
                        }

                        alarm 0;
                    };
                    my $sb = stat($tempFile);
                    if ($sb && $sb->size > 100000) {
                        $linkIsOk=1;
                        unlink $tempFile;
                        return ($url); 
                    }
                    unlink $tempFile;
                    return; 
                });

            foreach (threads->list(threads::joinable)) {
                my $tmp = $_->join();
                $result = $tmp if $tmp;
            }


        }
        foreach (threads->list(threads::joinable)) {
            my $tmp = $_->join();
            $result = $tmp if $tmp;
        }

        # We got a winner!
        if ($result) {
            $_->join foreach threads->list;
            return $result;
        }


    }
}

1;

