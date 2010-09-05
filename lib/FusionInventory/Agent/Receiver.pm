package FusionInventory::Agent::Receiver;

use strict;
use warnings;
use threads;
use threads::shared;

use English qw(-no_match_vars);
use HTTP::Daemon;

use FusionInventory::Agent::Storage;

my $lock :shared;
my $status :shared = "unknown";

sub new {
    my ($class, $params) = @_;

    my $self = {
        config    => $params->{config},
        logger    => $params->{logger},
        scheduler => $params->{scheduler}
    };

    my $config = $self->{config};
    my $logger = $self->{logger};

    if ($config->{'share-dir'}) {
        $self->{htmlDir} = $config->{'share-dir'}.'/html';
    } elsif ($config->{'devlib'}) {
        $self->{htmlDir} = "./share/html";
    }
    if ($self->{htmlDir}) {
        $logger->debug("[Receiver] Static files are in ".$self->{htmlDir});
    } else {
        $logger->debug("[Receiver] No static files directory");
    }


    my $storage = $self->{storage} = FusionInventory::Agent::Storage->new({
        target => {
            vardir => $config->{basevardir},
        }
    });

    bless $self, $class;

    return $self if $config->{'no-socket'};

    $SIG{PIPE} = 'IGNORE';
    if (
        $config->{daemon}           ||
        $config->{'daemon-no-fork'} ||
        $config->{winService}
    ) {
        $self->{thr} = threads->create('server', $self);
    }


    return $self;
}

sub handler {
    my ($self, $c, $r, $clientIp) = @_;
    
    my $logger = $self->{logger};
    my $scheduler = $self->{scheduler};
    my $config = $self->{config};
    my $htmlDir = $self->{htmlDir};

    if (!$r) {
        $c->close;
        undef($c);
        return;
    }

    my $path = $r->uri()->path();
    $logger->debug("[Receiver] request $path from client $clientIp");

    # non-GET requests
    my $method = $r->method();
    if ($method ne 'GET') {
        $logger->debug("[Receiver] invalid request type: $method");
        $c->send_error(500);
        $c->close;
        undef($c);
        return;
    }

    # GET requests
    SWITCH: {
        # root request
        if ($path eq '/') {
            if ($clientIp !~ /^127\./) {
                $c->send_error(404);
                return;
            }

            my $nextContact = "";
            foreach my $target (@{$scheduler->{targets}}) {
                my $path = $target->{path};
                $path =~ s/(http|https)(:\/\/)(.*@)(.*)/$1$2$4/;
                my $timeString = $target->getNextRunDate() > 1 ?
                    localtime($target->getNextRunDate()) :
                    "now";
                $nextContact .=
                    "<li>$target->{type}, $path: $timeString</li>\n";
            }

            my $indexFile = $htmlDir."/index.tpl";
            my $handle;
            if (!open $handle, '<', $indexFile) {
                $logger->error("Can't open share $indexFile: $ERRNO");
                $c->send_error(404);
                return;
            }
            undef $/;
            my $output = <$handle>;
            close $handle;

            $output =~ s/%%STATUS%%/$status/;
            $output =~ s/%%NEXT_CONTACT%%/$nextContact/;
            $output =~ s/%%AGENT_VERSION%%/$FusionInventory::Agent::VERSION/;
            if (!$config->{'rpc-trust-localhost'}) {
                $output =~
                s/%%IF_ALLOW_LOCALHOST%%.*%%ENDIF_ALLOW_LOCALHOST%%//;
            }
            $output =~ s/%%(END|)IF_.*?%%//g;
            my $r = HTTP::Response->new(
                200,
                'OK',
                HTTP::Headers->new('Content-Type' => 'text/html'),
                $output
            );
            $c->send_response($r);
            last SWITCH;
        }

        # deploy request
        if ($path =~ m{^/deploy/([\w\d/-]+)$}) {
            my $file = $1;
            foreach my $target (@{$scheduler->{targets}}) {
                if (-f $target->{vardir}."/deploy/".$file) {
                    $logger->debug("Send /deploy/".$file);
                    $c->send_file_response($target->{vardir}."/deploy/".$file);
                } else {
                    $logger->debug("Not found /deploy/".$file);
                }
            }
            $c->send_error(404);
            last SWITCH;
        }

        # now request
        if ($path =~ m{^/now(?:/(\S+))?$}) {
            my $sentToken = $1;
            my $currentToken = $self->getToken();
            my ($code, $msg);
            if (
                ($config->{'rpc-trust-localhost'} && $clientIp =~ /^127\./)
                    or
                ($sentToken eq $currentToken)
            ) {
                $self->getToken('forceNewToken');
                $scheduler->resetNextRunDate();
                $code = 200;
                $msg = "Done."
            } else {
                $logger->debug("[Receiver] bad token $sentToken != ".$currentToken);
                $code = 403;
                $msg = "Access denied. rpc-trust-localhost is off or the token is invalide."
            }
            my $r = HTTP::Response->new(
                $code,
                'OK',
                HTTP::Headers->new('Content-Type' => 'text/html'),
                "<html><head><title>FusionInventory-Agent</title></head><body>$msg <br /><a href='/'>Back</a></body><html>"
            );
            $c->send_response($r);

            last SWITCH;
        }

        # status request
        if ($path eq '/status') {
            #$c->send_status_line(200, $status)
            my $r = HTTP::Response->new(
                200,
                'OK',
                HTTP::Headers->new('Content-Type' => 'text/plain'),
               "status: ".$status
            );
            $c->send_response($r);
            last SWITCH;
        }

        # static content request
        if ($path =~ m{^/(logo.png|site.css|favicon.ico)$}) {
            $c->send_file_response($htmlDir."/$1");
            last SWITCH;
        }
    }

    $c->close;
    undef($c);
}

sub server {
    my ($self) = @_;

    my $config = $self->{config};
    my $scheduler = $self->{scheduler};
    my $logger = $self->{logger};

    my $daemon;
   
    if ($config->{'rpc-ip'}) {
        $daemon = $self->{daemon} = HTTP::Daemon->new(
            LocalAddr => $config->{'rpc-ip'},
            LocalPort => 62354,
            Reuse     => 1,
            Timeout   => 5
        );
    } else {
        $daemon = $self->{daemon} = HTTP::Daemon->new(
            LocalPort => 62354,
            Reuse     => 1,
            Timeout   => 5
        );
    }
  
    if (!$daemon) {
        $logger->error("[Receiver] Failed to start the service");
        return;
    } 
    $logger->info("[Receiver] Service started at: ". $daemon->url);

    # threads::joinable is available since perl 5.10 only
    my $joinableAvalaible = defined &threads::joinable;

    while (1) {

        if ($joinableAvalaible) {
            no strict 'subs'; ## no critic
            # threads::joinable symbol is not defined in perl 5.8
            my @threads = threads->list(threads::joinable);
            $_->join() foreach @threads;
        }

        # Limit the max number of running thread
        # On Windows, it's about 15MB per thread! We need to keep the
        # number of threads low.
        if (!$joinableAvalaible || threads->list() > 3) {
            foreach my $thread (threads->list()) {
                next if $thread->tid == 1; # This is me!
                $thread->join;
            };
        }
        my ($c, $socket) = $daemon->accept;
        next unless $socket;
        my(undef,$iaddr) = sockaddr_in($socket);
        my $clientIp = inet_ntoa($iaddr);
# HTTP::Daemon::get_request is not thread
# safe and must be called from the master thread
        my $r = $c->get_request;
        threads->create(\&handler, $self, $c, $r, $clientIp);
    }
}

sub getToken {
    my ($self, $forceNewToken) = @_; 

 
    my $storage = $self->{storage};
    my $logger = $self->{logger};

    lock($lock);

    my $myData = $storage->restore();
    if ($forceNewToken || !$myData->{token}) {

        my @chars = ('A'..'Z');
        $myData->{token} =
            map { $chars[rand @chars] }
            1..8;

        $storage->save({ data => $myData });
    }
    
    $logger->debug("token is: ".$myData->{token});

    return $myData->{token};

}

sub setCurrentStatus {
    my ($self, $newStatus) = @_;

    $status = $newStatus;

}

1;
__END__

=head1 NAME

FusionInventory::Agent::Receiver - An HTTP message receiver

=head1 DESCRIPTION

This is the object used by the agent to listen on the network for messages sent
by OCS or GLPI servers.

It is an HTTP server listening on port 62354. The following requests are
accepted:

=over

=item /status

=item /deploy

=item /now

=back

Authentication is based on a token created by the agent, and sent to the
server at initial connection. Connection from local host is allowed without
token if configuration option rpc-trust-localhost is true.

=head1 METHODS

=head2 new

The constructor. The following arguments are allowed:

=over

=item config (mandatory)

=item logger (mandatory)

=item scheduler (mandatory)
