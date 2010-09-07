package FusionInventory::Agent::Receiver;

use strict;
use warnings;
use threads;
use threads::shared;

use English qw(-no_match_vars);
use HTTP::Daemon;

sub new {
    my ($class, $params) = @_;

    my $self = {
        logger                => $params->{logger},
        scheduler             => $params->{scheduler},
        agent                 => $params->{agent},
        'rpc-ip'              => $params->{'rpc-ip'},
        'rpc-trust-localhost' => $params->{'rpc-trust-localhost'},
    };

    my $logger = $self->{logger};

    if ($params->{'share-dir'}) {
        $self->{htmlDir} = $params->{'share-dir'}.'/html';
    } elsif ($params->{'devlib'}) {
        $self->{htmlDir} = "./share/html";
    }
    if ($self->{htmlDir}) {
        $logger->debug("[Receiver] Static files are in ".$self->{htmlDir});
    } else {
        $logger->debug("[Receiver] No static files directory");
    }

    bless $self, $class;

    $SIG{PIPE} = 'IGNORE';
    $self->{thr} = threads->create('_server', $self);

    return $self;
}

sub _handler {
    my ($self, $c, $r, $clientIp) = @_;
    
    my $logger = $self->{logger};
    my $scheduler = $self->{scheduler};
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
            my $status = $self->{agent}->getStatus();

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
            if (!$self->{'rpc-trust-localhost'}) {
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
            my $token = $self->{agent}->getToken();
            my ($code, $msg);
            if (
                ($self->{'rpc-trust-localhost'} && $clientIp =~ /^127\./)
                    or
                ($sentToken eq $token)
            ) {
                $self->{agent}->resetToken();
                $scheduler->resetNextRunDate();
                $code = 200;
                $msg = "Done."
            } else {
                $logger->debug("[Receiver] bad token $sentToken != $token");
                $code = 403;
                $msg = "Access denied: untrusted address and invalid token.";
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
            my $status = $self->{agent}->getStatus();
            my $r = HTTP::Response->new(
                200,
                'OK',
                HTTP::Headers->new('Content-Type' => 'text/plain'),
               "status: $status"
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

sub _server {
    my ($self) = @_;

    my $scheduler = $self->{scheduler};
    my $logger = $self->{logger};

    my $daemon;
   
    if ($self->{'rpc-ip'}) {
        $daemon = $self->{daemon} = HTTP::Daemon->new(
            LocalAddr => $self->{'rpc-ip'},
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
        threads->create(\&_handler, $self, $c, $r, $clientIp);
    }
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

=head2 new($params)

The constructor. The following named parameters are allowed:

=over

=item logger (mandatory)

=item scheduler (mandatory)

=item agent (mandatory)

=item devlib (mandatory)

=item share-dir (mandatory)

=item rpc-ip (mandatory)

=item rpc-trust_localhost (mandatory)

=back
