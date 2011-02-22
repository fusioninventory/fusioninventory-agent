package FusionInventory::Agent::Task::Deploy;
our $VERSION = '0.0.1';

use strict;
use warnings;

use Carp;
use XML::Simple;
use File::Copy;
use File::Glob ':glob';
use File::Path;
use File::stat;
use Digest::MD5 qw(md5);

use File::Copy::Recursive qw(dirmove);
use Time::HiRes;

use Cwd qw(getcwd realpath);

use FusionInventory::Logger;
use FusionInventory::Agent::Storage;
use FusionInventory::Agent::XML::Query::SimpleMessage;
use FusionInventory::Agent::XML::Response::Prolog;
use FusionInventory::Agent::Network;

use HTTP::Request::Common qw(GET);

sub main {
    my ( undef ) = @_;

    my $self = {};
    bless $self;

    my $storage = FusionInventory::Agent::Storage->new({
            target => {
                vardir => $ARGV[0],
            }
        });

    my $data = $storage->restore({
            module => "FusionInventory::Agent"
        });
    my $myData = $self->{myData} = $storage->restore();

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

    my $vardir = realpath($self->{'target'}->{'vardir'});

    $self->{downloadBaseDir} =  $vardir. '/deploy';
    $self->{runBaseDir}      = $vardir . '/run';
    $self->{tmpBaseDir}      = $vardir . '/tmp';

    foreach (qw/downloadBaseDir runBaseDir tmpBaseDir/) {
        if ( !-d $self->{$_} && !mkpath( $self->{$_} ) ) {
            $logger->error("Failed to create $self->{$_}");
        }
    }

    # Just in case some errors had not been sent
    # previously
    $self->pushErrorStack();

    $self->readProlog();

    # Try to imitate as much as I can the Windows agent
    #    foreach (0..$myData->{config}->{PERIOD_LENGTH}) {
    foreach my $priority ( 0 .. 10 ) {
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


    $storage->save({ data => $myData });

    exit(0);
}

sub diskIsFull {
    my ( $self, $params ) = @_;

    my $logger = $self->{logger};

    my $spaceFree;
    if ($^O =~ /^MSWin/) {

        if (!eval ('
                use Win32::OLE qw(in CP_UTF8);
                use Win32::OLE::Const;

                Win32::OLE->Option(CP => CP_UTF8);

                1')) {
            $logger->error("Failed to load Win32::OLE: $@");
        }


        my $letter;
        if ($self->{downloadBaseDir} !~ /^(\w):./) {
            $logger->error("Path parse error: ".$self->{downloadBaseDir});
            return;
        }
        $letter = $1.':';


        my $WMIServices = Win32::OLE->GetObject(
            "winmgmts:{impersonationLevel=impersonate,(security)}!//./" );

        if (!$WMIServices) {
            $logger->error(Win32::OLE->LastError());
            return;
        }

        foreach my $properties ( Win32::OLE::in(
                $WMIServices->InstancesOf('Win32_LogicalDisk'))) {

            next unless lc($properties->{Caption}) eq lc($letter);
            my $t = $properties->{FreeSpace};
            if ($t && $t =~ /(\d+)\d{6}$/) {
                $spaceFree = $1;
            }
        }
    } elsif ($^O =~ /^solaris/i) {
        my $dfFh;
        if (open($dfFh, '-|', "df", '-b', $self->{downloadBaseDir})) {
            foreach(<$dfFh>) {
                if (/^\S+\s+(\d+)/) {
                    $spaceFree = int($1/1024);
                }
            }
            close $dfFh
        } else {
            $logger->error("Failed to exec df");
        }
    } else {
        my $dfFh;
        if (open($dfFh, '-|', "df", '-Pk', $self->{downloadBaseDir})) {
            foreach(<$dfFh>) {
                if (/^\S+\s+\S+\s+(\d+)/) {
                    $spaceFree = $1 / 1024;
                }
            }
            close $dfFh
        } else {
            $logger->error("Failed to exec df");
        }
    }

    if(!$spaceFree) {
	$logger->debug('$spaceFree is undef!');
	$spaceFree=0;
    }

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
              . "http://Forge.FusionInventory.org with this message and the "
              . "archive." );
        return;
    }

    eval "use Archive::Extract;";
    if ($@) {
        $logger->debug("Archive::Extract not found: $@, will use tar directly.");
	if ($type->{$magicNumber} eq 'tgz') {
            system("cd \"$runDir\" && gunzip -q < \"$downloadDir/final\" | tar xvf -")
        } else {
            $logger->error("Archive type: `".$type->{$magicNumber}.
                            " not supported. Please install ".
                            " Archive::Extractsubmit a patch.");
        }
    } else {
        $logger->debug("Archive::Extract found");
        $Archive::Extract::DEBUG = $config->{debug} ? 1 : 0;
        my $archiveExtract = Archive::Extract->new(

            archive => "$downloadDir/final",
            type    => $type->{$magicNumber}

        );

        if ( !$archiveExtract->extract( to => "$runDir" ) ) {
            $self->reportError( $orderId,
                "Failed to extract archive $downloadDir/final" );
            return;
        }
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
        foreach ( bsd_glob("$runDir/*") ) {
            if (   ( -d $_ && !dirmove( $_, $order->{PATH} ) )
                || ( -f $_ && !move( $_, $order->{PATH} ) ) )
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
    $self->setErrorCode('SUCCESS_OK');
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

    my $downloadBaseDir = $self->{downloadBaseDir};
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

    my $baseUrl;
    if ($order->{PACK_LOC} !~ /^http(|s)\:\/\//) {
        $baseUrl = ( $order->{PROTO} =~ /^HTTP$/ix ) ? "http://" : "";
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

    my $lastScan = 0;
    my $mirrorIp;
    while ( grep ( /1/, @downloadToDo ) ) {

        my $fragId = int( rand(@downloadToDo) ) + 1;    # pick a random frag
        next unless $downloadToDo[ $fragId - 1 ] == 1;  # Already done?

        my $frag = $orderId . '-' . $fragId;

        my $remoteFile;
        my $localFile = $downloadDir . '/' . $frag;

        my $rc;
        # Reuse the last mirror found
        if ($mirrorIp) {
            $remoteFile = "http://$mirrorIp:".
            ($config->{'rpc-port'} || 62354).
            "/deploy/$orderId/$orderId-$fragId";
            $rc = $network->getStore({
                source => $remoteFile,
                target => $localFile . '.part'
            });
        }

        # Or get a mirror and use it
        if ((!$rc || !$network->isSuccess({ code => $rc })) && $lastScan < time - 180) {
            $mirrorIp = findMirror({
            port => $config->{'rpc-port'} || 62354,
            orderId => $orderId,
            fragId => $fragId,
            logger => $logger,
            }) unless $mirrorIp;
            if ($mirrorIp) {
                $remoteFile = "http://$mirrorIp:".
                ($config->{'rpc-port'} || 62354).
                "/deploy/$orderId/$orderId-$fragId";
                $rc = $network->getStore({
                        source => $remoteFile,
                        target => $localFile . '.part'
                    });
            }
            $lastScan = time;
        }

        # Or use the upstream server
        if (!$rc || !$network->isSuccess({ code => $rc })) {
            $remoteFile = $baseUrl . '/' . $frag;
            $rc = $network->getStore({
                source => $remoteFile,
                target => $localFile . '.part'
            });
            sleep($fragLatency);
        }
        if ($rc && $network->isSuccess({code => $rc}) && move( $localFile . '.part', $localFile ) ) {

            # TODO to a md5sum/sha256 check here
            $order->{ERROR_COUNT} = 0;
            $logger->debug( $remoteFile . ' -> ' . $localFile . ': success' );
            $downloadToDo[ $fragId - 1 ] = 0;

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

    foreach my $fragId ( 1 .. $order->{FRAGS} ) {
        my $frag = $orderId . '-' . $fragId;

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

#Set the ErrCode to report for the following code block in case of error.
sub setErrorCode {
    my ( $self, $errorCode ) = @_;

    my $logger = $self->{logger};

    $logger->fault('No $errorCode!') unless $errorCode;

    $self->{errorCode} = $errorCode;

    return 1;
}

# Report error to the server and to the user throught the logger
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

    # The orders are send during the PROLOG. Since the prolog is
    # one of the arg of the check() function. We can process it.
    if (!$prologresp) {
        $logger->debug("No prolog found.");
        return;
    }
    my $conf = $prologresp->getOptionsInfoByName("DOWNLOAD");

    if ( !$conf || !@$conf ) {
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

            my $infoURI;

            if ($paramHash->{INFO_LOC} =~ /^http(|s)\:\/\//) {
                $infoURI = $paramHash->{INFO_LOC} . '/' . $orderId . '/info';
            } else {
                $infoURI = $protocl.'://' . $paramHash->{INFO_LOC} . '/' . $orderId . '/info';
            }
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

sub findMirror {
    my ( $self, $orderId, $fragId ) = @_;
 
    my $config = $self->{config};
    my $logger = $self->{logger};

    return if $config->{'no-p2p'};
    
    if (!eval "use FusionInventory::Agent::Task::OcsDeploy::P2P; 1;") {
        $logger->debug("Fails to use P2P: ".$@);
        return;
    }

    return FusionInventory::Agent::Task::OcsDeploy::P2P::findMirrorWithPOE(@_);
}


1;


__END__

=head1 NAME

FusionInventory::Agent::Task::OcsDeploy - OCS Inventory Software deployment support for FusionInvnetory Agent

=head1 DESCRIPTION

With this module, F<FusionInventory> can accept software deployment
request from an OCS Inventory server.

OCS Inventory uses SSL certificat to authentificat the server. You may have
to point F<--ca-cert-file> or F<--ca-cert-dir> to your public certificat.

If the P2P option is turned on, the agent will looks for peer in its network. The network size will be limited at 255 machines.

=cut
