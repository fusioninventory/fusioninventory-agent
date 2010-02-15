package FusionInventory::Agent::Task::OcsDeploy;
use threads;
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

use Carp;
use XML::Simple;
use File::Copy;
use File::Glob;
use File::Path;
use File::stat;
use Digest::MD5 qw(md5);

use Archive::Extract;
use File::Copy::Recursive qw(dirmove);
use Time::HiRes;

use Cwd;

use FusionInventory::Logger;
use FusionInventory::Agent::Storage;
use FusionInventory::Agent::XML::Query::SimpleMessage;
use FusionInventory::Agent::XML::Response::Prolog;
use FusionInventory::Agent::Network;

sub main {
    my ( undef ) = @_;

    my $self = {};
    bless $self;

    my $storage = FusionInventory::Agent::Storage->new({
            target => {
                vardir => $ARGV[0],
            }
        });

    my $data = $storage->restore("FusionInventory::Agent");
    my $myData = $self->{myData} = $storage->restore(__PACKAGE__);

    my $config = $self->{config} = $data->{config};
    my $target = $self->{'target'} = $data->{'target'};
    my $logger = $self->{logger} = FusionInventory::Logger->new ({
            config => $self->{config}
        });
    $self->{prologresp} = $data->{prologresp};



    if ($target->{'type'} ne 'server') {
        $logger->debug("No server. Exiting...");
        exit(0);
    }

    my $network = $self->{network} = FusionInventory::Agent::Network->new ({

            logger => $logger,
            config => $config,
            target => $target,

        });


    if ( !exists( $self->{'target'}->{'vardir'} ) ) {
        $logger->fault('No vardir in $target');
    }

    $self->{downloadBaseDir} = $self->{'target'}->{'vardir'} . '/deploy';
    $self->{runBaseDir}      = $self->{target}->{vardir} . '/run';
    $self->{tmpBaseDir}      = $self->{target}->{vardir} . '/tmp';


    foreach (qw/downloadBaseDir runBaseDir tmpBaseDir/) {
        if ( !-d $self->{$_} && !mkpath( $self->{$_} ) ) {
            $logger->error("Failed to create $self->{$_}");
        }
    }

    $self->{hosts} = {};
    $self->{findMirrorThreads} = [];

    
    # Just in case some errors had not been sent
    # previously
    $self->pushErrorStack();

    $self->readProlog();

    # Try to imitate as much as I can the Windows agent
    #    foreach (0..$myData->{config}->{PERIOD_LENGTH}) {
    foreach my $priority ( 1 .. 10 ) {
        foreach my $orderId ( keys %{ $myData->{byPriority}->[$priority] } ) {
            my $order = $myData->{byId}->{$orderId};

            # Already processed
            next if exists( $order->{ERR} );

            $self->setErrorCode('ERR_CLEAN');
            $self->clean({ orderId => $orderId  }
            );

            my $downloadDir = $self->{downloadBaseDir} . '/' . $orderId;
            my $runDir      = $self->{runBaseDir} . '/' . $orderId;

            if ( !-d "$downloadDir" && !mkpath("$downloadDir") ) {
                $logger->error("Failed to create $downloadDir");
                next;
            }
            if ( !-d "$runDir" && !mkpath("$runDir") ) {
                $logger->error("Failed to create $runDir");
                next;
            }

            # A file is attached to this order
            if ( $order->{FRAGS} ) {
                next
                  unless $self->downloadAndConstruct( { orderId => $orderId } );
                next unless $self->extractArchive( { orderId => $orderId } );
            }

            next unless $self->processOrderCmd( { orderId => $orderId } );
            delete( $myData->{byPriority}->[$priority]->{$orderId} );
            next
              unless $self->clean(
                {
                    orderId      => $orderId
                }
              );
            $logger->debug( "order $orderId processed, wait "
                  . $myData->{config}->{CYCLE_LATENCY}
                  . " seconds." );
            sleep( $myData->{config}->{CYCLE_LATENCY} );
        }
    }
    $logger->debug("End of period...");
    foreach my $priority ( 0 .. 10 ) {
        foreach my $orderId ( keys %{ $myData->{byPriority}->[$priority] } ) {
            my $order = $myData->{byId}->{$orderId};

            # We keep the fragment 30 days. This should be a parameter. 
            if ($order->{ANWSER_DATE} < time - 3600*24*30) {

                $self->clean({
                        orderId      => $orderId,
                        purge        => 1 
                    });

            }
        }
    }


    if ($self->diskIsFull()) {

        $self->clean({ purge => 1 });

    }


    $storage->save($myData);

    exit(0);
}

sub diskIsFull {
    my ( $self, $params ) = @_;

    my $logger = $self->{logger};

    my $spaceFree;
    if ($^O =~ /^MSWin/) {
        $logger->fault("isDiskFull doesn't work on Windows");
    } else {
        my $dfFh;
        if (open($dfFh, '-|', "df", '-m', $self->{downloadBaseDir})) {
            foreach(<$dfFh>) {
                if (/^\S+\s+\S+\s+(\d+)/) {
                    $spaceFree = $1;
                }
            }
            close $dfFh
        } else {
            $logger->error("Failed to exec df");
        }
    }

    $logger->fault('$spaceFree is undef!') unless defined ($spaceFree);


    # 400MB Free, should be set by a config option
    return ($spaceFree < 400);
}

sub clean {
    my ( $self, $params ) = @_;

    my $config  = $self->{config};
    my $logger  = $self->{logger};
    my $myData = $self->{myData};

    my $orderId = $params->{orderId};
    my $purge = $params->{purge} || 0;

    my @dirToCleanUp;
    if ($orderId) {
        push (@dirToCleanUp, $self->{runBaseDir} . '/' . $orderId);
        push (@dirToCleanUp, $self->{tmpBaseDir});
        push (@dirToCleanUp, $self->{downloadBaseDir} . '/' . $orderId) if $purge;
    } else {
        push (@dirToCleanUp, $self->{runBaseDir});
        push (@dirToCleanUp, $self->{tmpBaseDir});
        push (@dirToCleanUp, $self->{downloadBaseDir}) if $purge;

    }

    foreach (@dirToCleanUp) {
        next unless -d;
        $logger->debug("Clean the $_ directory");
        if ( !rmtree($_) ) {
            $self->reportError( $orderId, "Failed to clean $_" );
        }
    }

    return;
}

sub extractArchive {
    my ( $self, $params ) = @_;

    my $config  = $self->{config};
    my $logger  = $self->{logger};
    my $myData = $self->{myData};

    my $orderId = $params->{orderId};

    my $order = $myData->{byId}->{$orderId};

    my $downloadDir = $self->{downloadBaseDir} . '/' . $orderId;
    my $runDir      = $self->{runBaseDir} . '/' . $orderId;

    $self->setErrorCode('ERR_EXECUTE');    # ERR_EXTRACT ?
    my $fileFd;
    if ( !open $fileFd, "<", "$downloadDir/final" ) {
        $self->reportError( $orderId, "Failed to open $downloadDir/final: $!" );
        return;
    }
    binmode($fileFd);

    my $tmp;
    read( $fileFd, $tmp, 16 );
    close($fileFd);
    my $magicNumber = unpack( "S<", $tmp );

    if ( !$magicNumber ) {
        $self->reportError( $orderId,
            "Failed to read magic number for $downloadDir/final" );
        return;
    }

    my $type = {

        19280 => 'zip',
        35615 => 'tgz',    # well gzip...

    };

    if ( !$type->{$magicNumber} ) {
        $self->reportError( $orderId,
                "Unknow magic number $magicNumber! "
              . "Sorry I can't extract this archive ( $downloadDir/final ). "
              . "If you think, your archive is valide, please submit a bug on "
              . "http://launchpad.net/ocsinventory with this message and the "
              . "archive." );
        return;
    }

    $Archive::Extract::DEBUG = $config->{debug} ? 1 : 0;
    my $archiveExtract = Archive::Extract->new(

        archive => "$downloadDir/final",
        type    => $type->{$magicNumber}

    );

    if ( !$archiveExtract->extract( to => "$runDir" ) ) {
        $self->reportError( $orderId,
            "Failed to extract archive $downloadDir/run" );
        return;
    }

    $logger->debug("Archive $downloadDir/run extracted");

    return 1;
}

sub processOrderCmd {
    my ( $self, $params ) = @_;

    my $config  = $self->{config};
    my $logger  = $self->{logger};
    my $myData = $self->{myData};

    my $orderId = $params->{orderId};
    my $order   = $myData->{byId}->{$orderId};

    my $downloadDir = $self->{downloadBaseDir} . '/' . $orderId;
    my $runDir      = $self->{runBaseDir} . '/' . $orderId;

    $self->setErrorCode('ERR_EXECUTE');
    my $cwd = getcwd;
    if ( $order->{ACT} eq 'STORE' ) {
        $logger->debug( "Move extracted file in " . $order->{PATH} );
        if ( !-d $order->{PATH} && !mkpath( $order->{PATH} ) ) {
            $self->reportError( $orderId,
                "Failed to create " . $order->{PATH} );

            $self->clean( { orderId => $orderId, purge => 1 } );
            return;
        }
        foreach ( glob("$runDir/*") ) {
            if (   ( -d $_ && !dirmove( $_, $order->{PATH} ) )
                && ( -f $_ && !move( $_, $order->{PATH} ) ) )
            {
                $self->reportError( $orderId,
                    "Failed to copy $_ in " . $order->{PATH} . " :$!" );
            }
        }
    }
    elsif ( $order->{ACT} =~ /^(LAUNCH|EXECUTE)$/x ) {

        my $cmd;

        if ( !-d $runDir ) {
            $logger->error( "$runDir not found" );
        }

        if ( $order->{ACT} eq 'LAUNCH' ) {
            $cmd = $order->{'NAME'};
            if ( $^O !~ /^MSWin/x ) {
# Mimic the old Download.pm agent...
                $cmd = './'.$cmd unless $cmd =~ /^\//x;
                print "chmod : $runDir/$cmd\n";
                if ( !-x "$runDir/$cmd" && chmod( 0755, "$runDir/$cmd" ) ) {
                    $self->reportError( $orderId, "Cannot chmod: $!" );
                    return;
                }
            }
        } elsif ($order->{ACT} eq 'EXECUTE') {
            $cmd = $order->{'COMMAND'};
        }

        $logger->debug("Launching $cmd in $runDir...");

        if ( !chdir($runDir) ) {
            $self->reportError( $orderId, "Failed to chdir to '$runDir'" );
            return;
        }
        system($cmd);
        if ($?) {    # perldoc -f system :)
            $self->reportError( $orderId, "Failed to execute '$cmd'" );
            return;
        }
        elsif ( $? & 127 ) {
            my $msg = sprintf "'$cmd' died with signal %d, %s coredump\n",
              ( $? & 127 ), ( $? & 128 ) ? 'with' : 'without';
            $self->reportError( $orderId, $msg );
            return;
        }
        # RET_VAL doesn't exist yet server side
        elsif ( $order->{RET_VAL} && $order->{RET_VAL} != ( $? >> 8 ) ) {
            my $msg = sprintf "'$cmd' exited with value %d\n", $? >> 8;
            $self->reportError( $orderId, $msg );
            return;
        }

        if ( !chdir($cwd) ) {
            $logger->fault("Failed to chdir to $cwd");
        }

    }
    $self->setErrorCode('CODE_SUCCESS');
    $self->reportError( $orderId, "order processed" );

    return 1;
}

sub downloadAndConstruct {
    my ( $self, $params ) = @_;

    my $config  = $self->{config};
    my $target  = $self->{target};
    my $logger  = $self->{logger};
    my $myData = $self->{myData};
    my $network = $self->{network};

    my $orderId = $params->{orderId};
    my $order   = $myData->{byId}->{$orderId};

    my $downloadBaseDir = $target->{vardir} . '/deploy';
    my $downloadDir     = $downloadBaseDir . '/' . $orderId;
    if ( !-d $downloadDir && !mkpath($downloadDir) ) {
        $logger->error("Failed to create $downloadDir");
    }

    $self->setErrorCode("ERR_DOWNLOAD_PACK");

    $logger->fault("order not correctly initialised")  unless $order;
    $logger->fault("config not correctly initialised") unless $config;

    $logger->debug( "processing " . $orderId );

    my $fragLatency = $myData->{config}->{FRAG_LATENCY};
    $order->{ERROR_COUNT} = 0 unless exists( $order->{ERROR_COUNT} );
    
    if ($order->{PACK_LOC} =~ /nana\.rulezlan\.org/x) {
        $order->{PROTO} = 'https';
    }
    my $baseUrl = ( $order->{PROTO} =~ /^HTTP$/ix ) ? "http://" : "";
    if ($order->{PACK_LOC} =~ /nana\.rulezlan\.org/x) {
        $baseUrl = 'https://';
    }

    $baseUrl .= $order->{PACK_LOC};
    $baseUrl .= '/' if $order->{PACK_LOC} !~ /\/$/x;
    $baseUrl .= $orderId;

    # Randomise the download order
    my @downloadToDo;
    foreach ( 1 .. ( $order->{FRAGS} ) ) {
        my $frag = $orderId . '-' . $_;

        my $localFile = $downloadDir . '/' . $frag;

        if ( -f $localFile ) {
            push( @downloadToDo, '0' );
        }
        else {
            push( @downloadToDo, '1' );
        }
    }

    if (@downloadToDo) {
        $logger->info( "Will download "
              . int( grep ( /1/, @downloadToDo ) ) . " "
              . "fragments in a random order and wait `$fragLatency'"
              . " second(s) between each of them" );
    }
    while ( grep ( /1/, @downloadToDo ) ) {

        my $fragID = int( rand(@downloadToDo) ) + 1;    # pick a random frag
        next unless $downloadToDo[ $fragID - 1 ] == 1;  # Already done?

        my $frag = $orderId . '-' . $fragID;

        my $remoteFile = $self->findMirror( $orderId, $fragID );
        if ( !$remoteFile ) {

            # Can't find a mirror in my networks with the file, I grab it
            # directly from the main server
            $remoteFile = $baseUrl . '/' . $frag;
            sleep($fragLatency);
        }
        my $localFile = $downloadDir . '/' . $frag;

        my $rc = $network->getStore({
                source => $remoteFile,
                target => $localFile . '.part'
                
            });
        
        if ( $network->isSuccess({code => $rc}) && move( $localFile . '.part', $localFile ) ) {

            # TODO to a md5sum/sha256 check here
            $order->{ERROR_COUNT} = 0;
            $logger->debug( $remoteFile . ' -> ' . $localFile . ': success' );
            $downloadToDo[ $fragID - 1 ] = 0;

        }
        else {

            $logger->error( $remoteFile . ' -> ' . $localFile . ': failed' );
            unlink( $localFile . '.part' );
            unlink($localFile);
            $order->{ERROR_COUNT}++;

        }

        if ( $order->{ERROR_COUNT} > 30 ) {
            $self->reportError( $orderId, "Max download error reached" );
            return;
        }
    }

    ### Recreate the archive
    $self->setErrorCode('ERR_BUILD');
    $logger->info("Construct the archive in $downloadDir/final");
    
    my $finaleFileFd;
    if ( !open $finaleFileFd, ">$downloadDir/final" ) {
        $logger->error("Failed to open $downloadDir/final");
        return;
    }
    binmode($finaleFileFd);    # ...

    foreach my $fragID ( 1 .. $order->{FRAGS} ) {
        my $frag = $orderId . '-' . $fragID;

        my $localFile = $downloadDir . '/' . $frag;
        my $fragFd;
        if (! open $fragFd, "<", "$localFile" ) {
            $logger->error("Failed to open $localFile");

            close $finaleFileFd;
            return;
        }
        binmode($fragFd);

        foreach (<$fragFd>) {
            if ( !print {$finaleFileFd} $_ ) {
                close $finaleFileFd;
                $self->reportError( $orderId,
                    "Failed to write in $localFile: $!" );
                return;
            }
        }
        close $fragFd;
    }

    close $finaleFileFd;

    $self->setErrorCode("ERR_BAD_DIGEST");
    if ( $order->{DIGEST_ALGO} ne 'MD5' ) {
        $self->reportError( $orderId,
                "Digest '"
              . $order->{DIGEST_ALGO} . "' "
              . "not supported by the agent" );

        $self->clean( { orderId => $orderId } );

        return;
    }
    my $md5 = Digest::MD5->new;
    if ( open( $finaleFileFd, "<", "$downloadDir/final" ) ) {
        binmode($finaleFileFd);    # ...
        $md5->add($_) while (<$finaleFileFd>);
        close $finaleFileFd;
    }
    if ( $md5->hexdigest ne $order->{DIGEST} ) {
        $self->reportError( $orderId,
                "Failed to validated the MD5 of "
              . "the file : "
              . $md5->hexdigest . " != "
              . $order->{DIGEST} );

        $self->clean( { orderId => $orderId } );

        return;
    }

    return 1;
}

=item setErrorCode

Set the ErrCode to report for the following code block in case of error.

=cut

sub setErrorCode {
    my ( $self, $errorCode ) = @_;

    my $logger = $self->{logger};

    $logger->fault('No $errorCode!') unless $errorCode;

    $self->{errorCode} = $errorCode;

    return 1;
}

=item reportError

Report error to the server and to the user throught the logger

=cut

sub reportError {
    my ( $self, $orderId, $message ) = @_;

    my $config  = $self->{config};
    my $logger  = $self->{logger};
    my $myData = $self->{myData};
    my $target  = $self->{target};

    my $errorCode = $self->{errorCode};
    my $order     = $myData->{byId}->{$orderId};

    $logger->fault('$errorCode is not set!')  unless $errorCode;
    $logger->fault('$message should be set!') unless $message;

    $logger->error("$orderId> $message");

    my $xmlMsg = FusionInventory::Agent::XML::Query::SimpleMessage->new(
        {
            config => $config,
            logger => $logger,
            target => $target,
            msg    => {
                QUERY => 'DOWNLOAD',
                ID    => $orderId,
                ERR   => $errorCode,
            },
        }
    );

    if ( !$myData->{errorStack} ) {
        $myData->{errorStack} = [];
    }

    push @{ $myData->{errorStack} }, $xmlMsg;
    $order->{ERR}         = $errorCode;
    $order->{ANWSER_DATE} = time;

    return $self->pushErrorStack();
}

sub pushErrorStack {
    my ($self) = @_;

    my $logger  = $self->{logger};
    my $network = $self->{network};
    my $myData = $self->{myData};

    if ( !$myData->{errorStack} ) {
        $myData->{errorStack} = [];
    }

    if ( @{ $myData->{errorStack} } ) {
        my $message = $myData->{errorStack}->[0];
        if ( $network->send( { message => $message } ) ) {
            shift( @{ $myData->{errorStack} } );
        }
        else {
            $logger->error("Failed to contact server!");
            return;
        }
    }

    return 1;
}

sub readProlog {
    my $self = shift;

    my $prologresp = $self->{prologresp};
    my $config     = $self->{config};
    my $network = $self->{network};
    my $target     = $self->{target};
    my $logger     = $self->{logger};
    my $myData    = $self->{myData};

    if ( !$myData ) {
        $myData->{config}     = {};
        $myData->{byId}       = {};
        $myData->{byPriority} = [
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

    my $downloadBaseDir = $target->{vardir} . '/download';

    # The orders are send during the PROLOG. Since the prolog is
    # one of the arg of the check() function. We can process it.
    if (!$prologresp) {
        $logger->debug("No prolog found.");
        return;
    }
    my $conf = $prologresp->getOptionsInfoByName("DOWNLOAD");

    if ( !@$conf ) {
        $logger->debug("no DOWNLOAD options returned during PROLOG");
        return;
    }

    if ( !$target->{vardir} ) {
        $logger->error("vardir is not initialized!");
        return;
    }

    # The XML is ill formated and we have to run a loop to retriev
    # the different keys
    foreach my $paramHash (@$conf) {
        if ( $paramHash->{TYPE} eq 'CONF' ) {

            # Save the config sent during the PROLOG
            $myData->{config} = $conf->[0];
        }
        elsif ( $paramHash->{TYPE} eq 'PACK' ) {
            my $orderId = $paramHash->{ID};
            if ( $myData->{byId}{$orderId}{ERR} ) {

                if ($paramHash->{FORCEREPLAY}) {

                    $logger->debug("Replay $orderId");
                    $myData->{byId}{$orderId} = {};

                } else {

# ERR is set at the end of the process (SUCCESS or ERROR)
                    $self->setErrorCode('ERR_ALREADY_SETUP');
                    $self->reportError( $orderId,
                            "$orderId has already been processed" );
                    next;

                }
            }

            $self->setErrorCode('ERR_DOWNLOAD_INFO');

            my $protocl="https";

            my $infoURI =
              $protocl.'://' . $paramHash->{INFO_LOC} . '/' . $orderId . '/info';
            my $content = $network->get({
                    source => $infoURI,
                    timeout => 30
                });
            if ( !$content ) {
                $self->reportError( $orderId,
                    "Failed to read info file `$infoURI', is SSL ".
                    "certificat valide?" );
                next;
            }

            my $infoHash = XML::Simple::XMLin($content);
            if ( !$infoHash ) {
                $self->reportError( $orderId,
                    "Failed to parse info file `$infoURI'" );
                next;
            }
            $infoHash->{RECEIVED_DATE} = time;

            if (  !$orderId
                || $orderId !~ /^\d+$/x
                || !$infoHash->{ACT}
                || $infoHash->{PRI} !~ /^\d+$/x )
            {
                $self->reportError( $orderId,
                    "Incorrect content in info file `$infoURI'" );
                next;
            }

            $myData->{byId}{$orderId} = $infoHash;
            foreach ( keys %$paramHash ) {
                $myData->{byId}{$orderId}{$_} = $paramHash->{$_};
            }

            $myData->{byPriority}->[ $infoHash->{PRI} ]->{$orderId} =
              $myData->{byId}{$orderId};

            $logger->debug(
                "New download added in the queue. Info is `$infoURI'");
        }
    }

    # Just in case the server was down when when we tried to send the last
    # messages.
    $self->pushErrorStack();

    return 1;
}

sub _joinFindMirrorThread {
    my ($self) = @_;

    my $lastValdidIp;
    my $url;

    my $logger = $self->{logger};

    foreach ( @{$self->{findMirrorThreads}} ) {
          my @ret = $self->_processFindMirrorResult($_->join());
          ($lastValdidIp, $url) = @ret if @ret;
    }
    $self->{findMirrorThreads} = [];

    if ($lastValdidIp) {
        return ($lastValdidIp, $url);
    } else {
        return ();
    }
}

sub _processFindMirrorResult {
    my ($self, $ip, $rc, $speed, $url) = @_;

    my $logger = $self->{logger};

    if ($ip =~ /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/x) {
        if ($rc==200 || $rc==404) {
            $self->{hosts}{$1}{$2}{$3}{$4}{isUp}=1;
            $self->{hosts}{$1}{$2}{$3}{$4}{speed}=$speed;
        } else {
            $self->{hosts}{$1}{$2}{$3}{$4}{isUp}=0;
            $self->{hosts}{$1}{$2}{$3}{$4}{speed}=undef;
            $self->{hosts}{$1}{$2}{$3}{$4}{lastCheck}=time;
        }
        if ($rc==200) {
            return  ($ip, $url);
        }
    } else {
        print "parse error `$ip'\n";
    }

    return ();

}

sub findMirror {
    my ( $self, $orderId, $fragId ) = @_;

    my $config = $self->{config};
    my $logger = $self->{logger};
    my $network = $self->{network};

    my @addresses;

    if ($config->{rpcIp}) {
        push @addresses, $config->{rpcIp};
    } elsif ( $^O =~ /^linux/x ) {
        foreach (`ifconfig`) {
            if
            (/inet\saddr:(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}).*Mask:255.255.255.0$/x) {
                push @addresses, $1;
            }

        }
    }
    elsif ( $^O =~ /^MSWin/x ) {
        foreach (`route print -4`) {
            next unless
            /^\s+\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}+\s+255\.255\.255\.0/x;
            if (/(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}+)\s+\d+$/x) {
                push @addresses, $1;
            }
        }
    }

    foreach my $ip (@addresses) {
        next if $ip =~ /^127/x; # Ignore 127.x.x.x addresses
        if (/^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/x) {

            foreach (1..255) {
                next if $4==$_; # Ignore myself :) 
                next if exists ($self->{hosts}{$1}{$2}{$3}{$_});
                $self->{hosts}{$1}{$2}{$3}{$_}{lastCheck}=0;
                $self->{hosts}{$1}{$2}{$3}{$_}{isUp}=undef;
                $self->{hosts}{$1}{$2}{$3}{$_}{speed}=undef;
            }
        } else {
            $logger->fault("Invalid IP `$ip'");
        }
    }

    my $url;
    my $lastValdidIp;

    if (!$self->{firstScanWarning}) {
        $logger->debug("Looking for peers with the file in my network. ".
            "This may be long the first time.");
        $self->{firstScanWarning} = 1;
    }
    $logger->debug("Looking for $orderId-$fragId");
    NETSCAN: foreach my $a (keys %{$self->{hosts}}) {
        foreach my $b (keys %{$self->{hosts}{$a}}) {
            foreach my $c (keys %{$self->{hosts}{$a}{$b}}) {
                foreach my $d (keys %{$self->{hosts}{$a}{$b}{$c}}) {
                    # If the host had been detected as down during the last
                    # 10 minutes, I ignore it
                    if ($self->{hosts}{$a}{$b}{$c}{$d}{lastCheck}>(time -
                            600)) {
                        if (!$self->{hosts}{$a}{$b}{$c}{$d}{isUp}) {
                            next;
                        }
                    }


                    my $func = sub {

                        my $ip = "$a.$b.$c.$d";
                        my $speed=0;
                        my $url =
                        "http://$ip:62354/deploy/$orderId/$orderId-$fragId";

                        my $rand     = int rand(0xffffffff);
                        my $tempFile = $self->{tmpBaseDir}."/tmp." . $rand;

                        my $rc;
                        my $begin;
                        my $end;
                        eval {
                            local $SIG{ALRM} = sub { die "alarm\n" };
                            alarm 1;
                            $begin = Time::HiRes::time();

                            $rc = $network->getStore({
                                    source => $url,
                                    target => $tempFile,
                                    timeout => 1
                                }) or croak;

                            alarm 0;
                        };
                        $end = Time::HiRes::time();

                        my $size = (stat($tempFile))[7];
                        if ($size) {
                            $speed = int($size / ($end - $begin) / 1024);
                        }
                        unlink $tempFile;
                        return ($ip, $rc, $speed, $url);
                    };


                    # https://rt.cpan.org/Public/Bug/Display.html?id=41007
                    # http://www.perlmonks.org/index.pl?node_id=407374
                    if ( $^O =~ /^MSWin/x ) {

                        if ( @{$self->{findMirrorThreads}} > 1 ) {
                            ($lastValdidIp, $url) = $self->_joinFindMirrorThread();
                            last NETSCAN if $lastValdidIp;
                        }


                        my $thr = threads->create(
                            { 'context'    => 'list' },
                            $func
                        );
                        if ($thr) {
                            push @{$self->{findMirrorThreads}}, $thr;
                        }
                    } else {
                        ($lastValdidIp, $url) = $self->_processFindMirrorResult(&$func());
                        last NETSCAN if $lastValdidIp;
                    }
                }
            }
        }
    }
    my @ret = $self->_joinFindMirrorThread();
    ($lastValdidIp, $url) = @ret if @ret;

    if ($url) {
        $logger->debug("Mirror found on host $lastValdidIp");
    } else {
        $logger->debug("No mirror found");
    }
    return $url;
}

1;

