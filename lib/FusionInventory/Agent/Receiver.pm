package FusionInventory::Agent::Receiver;

use strict;
use warnings;
use threads;
use threads::shared;

use English qw(-no_match_vars);
use HTTP::Daemon;

use FusionInventory::Logger;

sub new {
    my ($class, $params) = @_;

    my $self = {
        logger          => $params->{logger} || FusionInventory::Logger->new(),
        scheduler       => $params->{scheduler},
        agent           => $params->{agent},
        htmldir         => $params->{htmldir},
        ip              => $params->{ip},
        port            => $params->{port},
        trust_localhost => $params->{trust_localhost},
    };
    bless $self, $class;

    my $logger = $self->{logger};
    $logger->debug($self->{htmldir} ?
        "[WWW] static files are in $self->{htmldir}" :
        "[WWW] no static files directory"
    );

    $SIG{PIPE} = 'IGNORE';
    threads->create('_server', $self);

    return $self;
}

sub _handle {
    my ($self, $c, $r, $clientIp) = @_;
    
    my $logger = $self->{logger};
    my $scheduler = $self->{scheduler};
    my $htmldir = $self->{htmldir};

    if (!$r) {
        $c->close;
        undef($c);
        return;
    }

    my $path = $r->uri()->path();
    $logger->debug("[WWW] request $path from client $clientIp");

    # non-GET requests
    my $method = $r->method();
    if ($method ne 'GET') {
        $logger->debug("[WWW] error, invalid request type: $method");
        $c->send_error(400);
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

            my $indexFile = $htmldir."/index.tpl";
            my $handle;
            if (!open $handle, '<', $indexFile) {
                $logger->error("[WWW] can't open share $indexFile: $ERRNO");
                $c->send_error(404);
                return;
            }
            undef $/;
            my $output = <$handle>;
            close $handle;

            my $nextContact = "";
            foreach my $target (@{$scheduler->{targets}}) {
                my ($type, $path);
                if ($target->isa('FusionInventory::Agent::Target::Server')) {
                    $type = 'server';
                    $path = $target->getUrl();
                    $path =~ s/(http|https)(:\/\/)(.*@)(.*)/$1$2$4/;
                }
                if ($target->isa('FusionInventory::Agent::Target::Local')) {
                    $type = 'local';
                    $path = $target->getPath();
                }
                if ($target->isa('FusionInventory::Agent::Target::Stdout')) {
                    $type = 'stdout';
                    $path = 'stdout';
                }
                my $timeString = $target->getNextRunDate() > 1 ?
                    localtime($target->getNextRunDate()) : "now";
                $nextContact .=
                    "<li>$type, $path: $timeString</li>\n";
            }
            my $status = $self->{agent}->getStatus();

            $output =~ s/%%STATUS%%/$status/;
            $output =~ s/%%NEXT_CONTACT%%/$nextContact/;
            $output =~ s/%%AGENT_VERSION%%/$FusionInventory::Agent::VERSION/;
            if (!$self->{trust_localhost}) {
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
            foreach my $target (@{$scheduler->getTargets()}) {
                my $directory = $target->getStorage()->getDirectory();
                my $file = $directory . $path;
                if (-f $file) {
                    $logger->debug("[WWW] send $path");
                    $c->send_file_response($file);
                } else {
                    $logger->debug("[WWW] not found $path");
                }
            }
            $c->send_error(404);
            last SWITCH;
        }

        # now request
        if ($path =~ m{^/now(?:/(\S+))?$}) {
            my $sentToken = $1;

            my $result;
            if ($clientIp =~ /^127\./ && $self->{trust_localhost}) {
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
                            "[WWW] untrusted address, invalid token $sentToken != $token"
                        );
                        $result = "untrusted address, invalid token";
                    }
                } else {
                    $logger->debug(
                        "[WWW] untrusted address, no token received"
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
            $c->send_file_response($htmldir."/$1");
            last SWITCH;
        }

        $logger->debug("[WWW] error, unknown path: $path");
        $c->send_error(400);
    }

    $c->close;
    undef($c);
}

sub _server {
    my ($self) = @_;

    my $scheduler = $self->{scheduler};
    my $logger = $self->{logger};

    my $daemon = HTTP::Daemon->new(
        LocalAddr => $self->{ip},
        LocalPort => $self->{port},
        Reuse     => 1,
        Timeout   => 5
    );

    if (!$daemon) {
        $logger->error("[WWW] failed to start the service");
        return;
    } 
    my $url = $self->{ip} ?
        "http://$self->{ip}:$self->{port}" :
        "http://localhost:$self->{port}" ;

    $logger->info(
        "[WWW] Service started at: $url"
    );

    while (1) {
        my ($client, $socket) = $daemon->accept();
        next unless $socket;
        my (undef, $iaddr) = sockaddr_in($socket);
        my $clientIp = inet_ntoa($iaddr);
        my $request = $client->get_request();
        $self->_handle($client, $request, $clientIp);
    }
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Receiver - An HTTP message receiver

=head1 DESCRIPTION

This is the object used by the agent to listen on the network for messages sent
by OCS or GLPI servers.

It is an HTTP server listening on port 62354 (by default). The following
requests are accepted:

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

The constructor. The following parameters are allowed, as keys of the $params
hashref:

=over

=item I<logger>

the logger object to use (default: a new stderr logger)

=item I<scheduler>

the scheduler object to use

=item I<agent>

the agent object

=item I<htmldir>

the directory where HTML templates and static files are stored

=item I<ip>

the network adress to listen to (default: all)

=item I<port>

the network port to listen to

=item I<trust_localhost>

a flag allowing to trust local request without authentication tokens (default:
false)

=back
