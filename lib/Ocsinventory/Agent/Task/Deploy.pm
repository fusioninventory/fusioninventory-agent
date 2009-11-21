package Ocsinventory::Agent::Task::Deploy;
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
use Time::HiRes;

use Cwd;

use Ocsinventory::Logger;
use Ocsinventory::Agent::Storage;
use Ocsinventory::Agent::XML::SimpleMessage;
use Ocsinventory::Agent::XML::Response::Prolog;
use Ocsinventory::Agent::Network;

sub main {
    my ( undef ) = @_;

    my $self = {};
    bless $self;

    my $storage = new Ocsinventory::Agent::Storage({
            config => {
                vardir => $ARGV[0],
            }
        });

    my $data = $storage->restore("Ocsinventory::Agent");
    my $myData = $self->{myData} = $storage->restore(__PACKAGE__);

    my $config = $self->{config} = $data->{config};
    my $logger = $self->{logger} = new Ocsinventory::Logger ({
            config => $self->{config}
        });
    $self->{prologresp} = $data->{prologresp};



    if (!$config->{'server'}) {
        $logger->debug("No server. Exiting...");
        exit(0);
    }

    my $network = $self->{network} = new Ocsinventory::Agent::Network ({

            logger => $logger,
            config => $config,

        });


    if ( !exists( $self->{config}->{vardir} ) ) {
        $logger->fault('No vardir in $config');
    }

    $self->{downloadBaseDir} = $self->{config}->{vardir} . '/download';
    $self->{runBaseDir}      = $self->{config}->{vardir} . '/run';
    $self->{tmpBaseDir}      = $self->{config}->{vardir} . '/tmp';


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
            $self->clean(
                {
                    orderId      => $orderId
                }
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

    $storage->save($myData);

    exit(0);
}


sub clean {
    my ( $self, $params ) = @_;

    my $config  = $self->{config};
    my $logger  = $self->{logger};
    my $myData = $self->{myData};

    my $orderId = $params->{orderId};
    my $purge = $params->{purge} || 0;

    $logger->fault("orderId missing") unless $orderId;

    my @dirToCleanUp;
    push (@dirToCleanUp, $self->{runBaseDir} . '/' . $orderId);
    push (@dirToCleanUp, $self->{tmpBaseDir});
    if ($purge) {
        push (@dirToCleanUp, $self->{downloadBaseDir} . '/' . $orderId);
    }

    $logger->fault("no orderId") unless $orderId;

    foreach (@dirToCleanUp) {
        next unless -d;
#        $logger->debug("Clean the $_ directory");
        if ( !rmtree($_) ) {
            $self->reportError( $orderId, "Failed to clean $_" );
        }
    }

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
    if ( !open FILE, "<$downloadDir/final" ) {
        $self->reportError( $orderId, "Failed to open $downloadDir/final: $!" );
        return;
    }
    binmode(FILE);

    my $tmp;
    read( FILE, $tmp, 16 );
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

    1;
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

            # TODO clean up
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
    elsif ( $order->{ACT} =~ /^(LAUNCH|EXECUTE)$/ ) {

        my $cmd = $order->{'NAME'};
        if ( !-f "$runDir/$cmd" ) {
            $self->reportError( $orderId, "$runDir/$cmd not found" );
            return;
        }

        if ( $order->{ACT} eq 'LAUNCH' ) {
            if ( $^O !~ /^MSWin/ ) {
                $cmd .= './' unless $cmd =~ /^\//;
                if ( chmod( 0755, "$runDir/$cmd" ) ) {
                    $self->reportError( $orderId, "Cannot chmod: $!" );
                    return;
                }
            }
        }

        $logger->debug("Launching $cmd...");

        if ( !chdir("$runDir/") ) {
            $self->reportError( $orderId, "Failed to chdir to '$runDir'" );
            return;
        }
        system($cmd );
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
        elsif ( $order->{RET_VAL} != ( $? >> 8 ) ) {
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

    1;
}

sub downloadAndConstruct {
    my ( $self, $params ) = @_;

    my $config  = $self->{config};
    my $logger  = $self->{logger};
    my $myData = $self->{myData};

    my $orderId = $params->{orderId};
    my $order   = $myData->{byId}->{$orderId};

    my $downloadBaseDir = $config->{vardir} . '/download';
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

    my $baseUrl = ( $order->{PROTO} =~ /^HTTP$/i ) ? "http://" : "";
    $baseUrl .= $order->{PACK_LOC};
    $baseUrl .= '/' if $order->{PACK_LOC} !~ /\/$/;
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
        print ".";

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

        my $rc = LWP::Simple::getstore( $remoteFile, $localFile . '.part' );
        if ( is_success($rc) && move( $localFile . '.part', $localFile ) ) {

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
    if ( !open( FINALFILE, ">$downloadDir/final" ) ) {
        $logger->error("Failed to open $downloadDir/final");
        return;
    }
    binmode(FINALFILE);    # ...

    foreach my $fragID ( 1 .. $order->{FRAGS} ) {
        my $frag = $orderId . '-' . $fragID;

        my $localFile = $downloadDir . '/' . $frag;
        if ( !open( FRAG, "<$localFile" ) ) {
            $logger->error("Failed to open $localFile");

            close FINALFILE;
            return;
        }
        binmode(FRAG);

        foreach (<FRAG>) {
            if ( !print FINALFILE) {
                close FINALFILE;
                $self->reportError( $orderId,
                    "Failed to write in $localFile: $!" );
                return;
            }
        }
        close FRAG;
    }

    close FINALFILE;

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
    if ( open( FINALFILE, "<$downloadDir/final" ) ) {
        binmode(FINALFILE);    # ...
        $md5->add($_) while (<FINALFILE>);
        close FINALFILE;
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

    1;
}

=item setErrorCode

Set the ErrCode to report for the following code block in case of error.

=cut

sub setErrorCode {
    my ( $self, $errorCode ) = @_;

    my $logger = $self->{logger};

    $logger->fault('No $errorCode!') unless $errorCode;

    $self->{errorCode} = $errorCode;

}

=item reportError

Report error to the server and to the user throught the logger

=cut

sub reportError {
    my ( $self, $orderId, $message ) = @_;

    my $config  = $self->{config};
    my $logger  = $self->{logger};
    my $myData = $self->{myData};

    my $errorCode = $self->{errorCode};
    my $order     = $myData->{byId}->{$orderId};

    $logger->fault('$errorCode is not set!')  unless $errorCode;
    $logger->fault('$message should be set!') unless $message;

    $logger->error("$orderId> $message");

    my $xmlMsg = new Ocsinventory::Agent::XML::SimpleMessage(
        {
            config => $config,
            logger => $logger,
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

    $self->pushErrorStack();
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

    1;
}

sub readProlog {
    my $self = shift;

    my $prologresp = $self->{prologresp};
    my $config     = $self->{config};
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

    my $downloadBaseDir = $config->{vardir} . '/download';

    # The orders are send during the PROLOG. Since the prolog is
    # one of the arg of the check() function. We can process it.
    $logger->fault("No prolog object") unless $prologresp;
    my $conf = $prologresp->getOptionsInfoByName("DOWNLOAD");

    if ( !@$conf ) {
        $logger->debug("no DOWNLOAD options returned during PROLOG");
        return;
    }

    if ( !$config->{vardir} ) {
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
            # LWP doesn't support SSL cert check and
            # Net::SSLGlue::LWP is a workaround to fix that
            if ( !$config->{unsecureSoftwareDeployment} ) {
                eval 'use Net::SSLGlue::LWP SSL_ca_path => TODO';
                if ($@) {
                    $self->reportError( $orderId,
                            "Failed to load "
                          . "Net::SSLGlue::LWP, to validate the server "
                          . "SSL cert." );
                    next;
                }
            }
            else {
                $logger->info( "--unsecure-software-deployment parameter "
                      . "found. Don't check server identity!!!" );
                $protocl="http";
            }

            my $infoURI =
              $protocl.'://' . $paramHash->{INFO_LOC} . '/' . $orderId . '/info';
            $ua->timeout(30);
            my $content = LWP::Simple::get($infoURI);
            if ( !$content ) {
                $self->reportError( $orderId,
                    "Failed to read info file `$infoURI'" );
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
                || $orderId !~ /^\d+$/
                || !$infoHash->{ACT}
                || $infoHash->{PRI} !~ /^\d+$/ )
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

    1;
}

sub _joinFindMirrorThread {
    my ($self) = @_;

    my $lastValdidIp;

    foreach ( @{$self->{findMirrorThreads}} ) {
        my ($ip, $rc, $speed) = $_->join();
        if ($ip =~ /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/) {
            if ($rc==200 || $rc==404) {
                $self->{hosts}{$1}{$2}{$3}{$4}{isUp}=1;
                $self->{hosts}{$1}{$2}{$3}{$4}{speed}=$speed;
            } else {
                $self->{hosts}{$1}{$2}{$3}{$4}{isUp}=0;
                $self->{hosts}{$1}{$2}{$3}{$4}{speed}=undef;
            }
            $self->{hosts}{$1}{$2}{$3}{$4}{lastCheck}=time;
            if ($rc==200) {
                $lastValdidIp = $ip;
            }
        } else {
            print "parse error `$ip'\n";
        }
    }
    $self->{findMirrorThreads} = [];

    return $lastValdidIp;
}

sub findMirror {
    my ( $self, $orderId, $fragId ) = @_;

    my $config = $self->{config};
    my $logger = $self->{logger};

    my @addresses;
    if ( $^O =~ /^linux/ ) {
        foreach (`ifconfig`) {
            if
            (/inet\saddr:(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}).*Mask:255.255.255.0$/) {
                push @addresses, $1;
            }

        }
    }
    elsif ( $^O =~ /^MSWin/ ) {
        foreach (`route print -4`) {
            next unless
            /^\s+\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}+\s+255\.255\.255\.0/;
            next unless /(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}+)\s+\d+$/;
            push @addresses, $1;
        }
    }

    foreach (@addresses) {
        next if /^127/; # Ignore 127.x.x.x addresses
        next unless /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/;

        foreach (1..255) {
            next if $4==$_; # Ignore myself :) 
            next if exists ($self->{hosts}{$1}{$2}{$3}{$_});
            $self->{hosts}{$1}{$2}{$3}{$_}{lastCheck}=0;
            $self->{hosts}{$1}{$2}{$3}{$_}{isUp}=undef;
            $self->{hosts}{$1}{$2}{$3}{$_}{speed}=undef;
        }
    }

    my $lastValdidIp;


    my @threads;
    NETSCAN: foreach my $a (keys %{$self->{hosts}}) {
        foreach my $b (keys %{$self->{hosts}{$a}}) {
            foreach my $c (keys %{$self->{hosts}{$a}{$b}}) {
                foreach my $d (keys %{$self->{hosts}{$a}{$b}{$c}}) {
                    if ( @{$self->{findMirrorThreads}} > 15 ) {
                        my $tmp = $self->_joinFindMirrorThread();
                        if ($tmp) {
                            $lastValdidIp = $tmp;
                            last NETSCAN;
                        }
                    }

                    # If the host had been detected as down during the last
                    # 10 minutes, I ignore it
                    if ($self->{hosts}{$a}{$b}{$c}{$d}{lastCheck}>(time -
                            600)) {
                        if (!$self->{hosts}{$a}{$b}{$c}{$d}{isUp}) {
                            next;
                        }
                    }

                    my $ip = "$a.$b.$c.$d";

                    my $thr = threads->create(
                        { 'context'    => 'list' },
                        sub {

                            my $speed=0;
                            my $url =
                            "http://$ip:62354/Ocsinventory::Agent::Task::Inventory::Deploy/files/$orderId/$orderId-$fragId";

                            my $rand     = int rand(0xffffffff);
                            my $tempFile = $self->{tmpBaseDir}."/tmp." . $rand;

                            my $rc;
                            my $begin;
                            my $end;
                            $ua->timeout(2);
                            eval {
                                local $SIG{ALRM} = sub { die "alarm\n" };
                                alarm 3;
                                $begin = Time::HiRes::time();

                                $rc = LWP::Simple::getstore( $url, $tempFile
                                ) or die;

                                alarm 0;
                            };
                            $end = Time::HiRes::time();

                            my $size = (stat($tempFile))[7];
                            if ($size) {
                                $speed = int($size / ($end - $begin) / 1024);
                            }
                            unlink $tempFile;
                            return ($ip, $rc, $speed);
                        }
                    );

                    if ($thr) {
                        push @{$self->{findMirrorThreads}}, $thr;
                    }

                }
            }
        }
    }
    my $tmp = $self->_joinFindMirrorThread();
    $lastValdidIp = $tmp if $tmp;
    if ($lastValdidIp) {
        return
        "http://$lastValdidIp:62354/".
        "Ocsinventory::Agent::Task::Inventory::Deploy".
        "/files/$orderId/$orderId-$fragId";
    } else {
        return;
    }
}

1;

