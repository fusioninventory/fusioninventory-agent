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
        logger              => $params->{logger},
        scheduler           => $params->{scheduler},
        agent               => $params->{agent},
        rpc_ip              => $params->{rpc_ip},
        rpc_port            => $params->{rpc_port},
        rpc_trust_localhost => $params->{rpc_trust_localhost},
    };

    my $logger = $self->{logger};

    if ($params->{share_dir}) {
        $self->{htmlDir} = $params->{share_dir}.'/html';
    } elsif ($params->{devlib}) {
        $self->{htmlDir} = "./share/html";
    }
    if ($self->{htmlDir}) {
        $logger->debug("[Receiver] Static files are in ".$self->{htmlDir});
    } else {
        $logger->debug("[Receiver] No static files directory");
    }

    bless $self, $class;

    $SIG{PIPE} = 'IGNORE';
    threads->create('_server', $self);

    return $self;
}

sub handle {
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

            my $nextContact = "";
            foreach my $target (@{$scheduler->{targets}}) {
                my $path = $target->{path};
                $path =~ s/(http|https)(:\/\/)(.*@)(.*)/$1$2$4/;
                my $timeString = $target->getNextRunDate() > 1 ?
                    localtime($target->getNextRunDate()) : "now";
                my $type = ref $target;
                $nextContact .=
                    "<li>$type, $path: $timeString</li>\n";
            }
            my $status = $self->{agent}->getStatus();

            $output =~ s/%%STATUS%%/$status/;
            $output =~ s/%%NEXT_CONTACT%%/$nextContact/;
            $output =~ s/%%AGENT_VERSION%%/$FusionInventory::Agent::VERSION/;
            if (!$self->{rpc_trust_localhost}) {
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

            my $result;
            if ($clientIp =~ /^127\./ && $self->{rpc_trust_localhost}) {
                # trusted request
                $result = "ok";
            } else {
                # authenticated request
                if ($sentToken) {
                    my $token = $self->{agent}->resetToken();
                    if ($sentToken eq $token) {
                        $result = "ok";
                        $self->{agent}->resetToken();
                    } else {
                        $logger->debug(
                            "[Receiver] untrusted address, invalid token $sentToken != $token"
                        );
                        $result = "untrusted address, invalid token";
                    }
                } else {
                    $logger->debug(
                        "[Receiver] untrusted address, no token received"
                    );
                    $result = "untrusted address, no token received";
                }
            }

            my ($code, $message);
            if ($result eq "ok") {
                $scheduler->scheduleTargets(0);
                $code    = 200;
                $message = "Done."
            } else {
                $code    = 403;
                $message = "Access denied: $result.";
            }

            my $r = HTTP::Response->new(
                $code,
                'OK',
                HTTP::Headers->new('Content-Type' => 'text/html'),
                "<html><head><title>FusionInventory-Agent</title></head><body>$message<br /><a href='/'>Back</a></body><html>"
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

    my $daemon = HTTP::Daemon->new(
        LocalAddr => $self->{rpc_ip},
        LocalPort => $self->{rpc_port} || 62354,
        Reuse     => 1,
        Timeout   => 5
    );

    if (!$daemon) {
        $logger->error("[Receiver] Failed to start the service");
        return;
    } 
    $logger->info("RPC service started at: http://".
        ( $self->{'rpc_ip'} || "127.0.0.1" ).
        ":".
        $self->{rpc_port} || 62354);

    while (1) {
        my ($client, $socket) = $daemon->accept();
        next unless $socket;
        my (undef, $iaddr) = sockaddr_in($socket);
        my $clientIp = inet_ntoa($iaddr);
        my $request = $client->get_request();
        $self->handle($client, $request, $clientIp);
    }
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Receiver - An HTTP message receiver

=head1 DESCRIPTION

This is the object used by the agent to listen on the network for messages sent
by OCS or GLPI servers.

It is an HTTP server listening on port 62354 (by default). The following requests are
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

=item share_dir (mandatory)

=item rpc_ip (default: undef)

=item rpc_trust_localhost (default: false)

=back
