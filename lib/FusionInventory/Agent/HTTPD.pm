package FusionInventory::Agent::HTTPD;

use strict;
use warnings;
use threads;

use English qw(-no_match_vars);
use HTTP::Daemon;

sub new {
    my ($class, $params) = @_;

    my $self = {
        logger          => $params->{logger},
        agent           => $params->{agent},
        targets         => $params->{targets},
        htmldir         => $params->{htmldir},
        ip              => $params->{ip},
        port            => $params->{port} || 62354,
        trust_localhost => $params->{'trust_localhost'}

    };
    bless $self, $class;

    $self->{logger}->debug($self->{htmldir} ?
        "[HTTPD] static files are in $self->{htmldir}" :
        "[HTTPD] no static files directory"
    );

    $SIG{PIPE} = 'IGNORE';
    threads->create('_listen', $self);

    return $self;
}

sub _handle {
    my ($self, $client, $request, $clientIp) = @_;
    
    my $logger = $self->{logger};
    my $targets = $self->{targets};
    my $htmldir = $self->{htmldir};

    if (!$request) {
        $client->close();
        return;
    }

    my $path = $request->uri()->path();
    $logger->debug("[HTTPD] request $path from client $clientIp");

    # non-GET requests
    my $method = $request->method();
    if ($method ne 'GET') {
        $logger->debug("[HTTPD] error, invalid request type: $method");
        $client->send_error(400);
        $client->close;
        undef($client);
        return;
    }

    # GET requests
    SWITCH: {
        # root request
        if ($path eq '/') {

            my $indexFile = $htmldir . "/index.tpl";
            my $handle;
            if (!open $handle, '<', $indexFile) {
                $logger->error("[HTTPD] Can't open share $indexFile: $ERRNO");
                $client->send_error(404);
                return;
            }
            undef $/;
            my $output = <$handle>;
            close $handle;

            my $nextContact = "";
            foreach my $target (@{$targets->{targets}}) {
                my $path = $target->{'path'};
                $path =~ s/(http|https)(:\/\/)(.*@)(.*)/$1$2$4/;
                my $timeString = $target->getNextRunDate() > 1 ?
                    localtime($target->getNextRunDate()) : "now" ;
                my $type = ref $target;
                $nextContact .= "<li>$type, $path: $timeString</li>\n";
            }

            my $status = $self->{agent}->getStatus();

            $output =~ s/%%STATUS%%/$status/;
            $output =~ s/%%NEXT_CONTACT%%/$nextContact/;
            $output =~ s/%%AGENT_VERSION%%/$FusionInventory::Agent::VERSION/;
            if ($clientIp !~ /^127\./ || !$self->{'trust_localhost'}) {
                $output =~
                s/%%IF_ALLOW_LOCALHOST%%.*%%ENDIF_ALLOW_LOCALHOST%%//;
            }
            $output =~ s/%%(END|)IF_.*?%%//g;

            my $response = HTTP::Response->new(
                200,
                'OK',
                HTTP::Headers->new('Content-Type' => 'text/html'),
                $output
            );
            $client->send_response($response);

            last SWITCH;
        } 

        # deploy request
        if ($path =~ m{^/deploy/([\w\d/-]+)$}) {
            my $file = $1;
            foreach my $target (@{$targets->{targets}}) {
                my $directory =
                    $target->getStorage()->getDirectory() . "/deploy";
                if (-f "$directory/$file") {
                    $logger->debug("[HTTPD] $path sent");
                    $client->send_file_response("$directory/$file");
                } else {
                    $logger->debug("[HTTPD] $path not found");
                }
            }
            $client->send_error(404);
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
                            "[HTTPD] untrusted address, invalid token " .
                            "$sentToken != $token"
                        );
                        $result = "untrusted address, invalid token";
                    }
               } else {
                    $logger->debug(
                        "[HTTPD] untrusted address, no token received"
                    );
                    $result = "untrusted address, no token received";
                }
            }

            my ($code, $message);
            if ($result eq "ok") {
                $targets->resetNextRunDate();
                $code    = 200;
                $message = "Done."
            } else {
                $code    = 403;
                $message = "Access denied: $result.";
            }

            my $response = HTTP::Response->new(
                $code,
                'OK',
                HTTP::Headers->new('Content-Type' => 'text/html'),
                "<html><head><title>FusionInventory-Agent</title></head><body>$message<br/><a href='/'>Back</a></body><html>"
            );
            $client->send_response($response);

            last SWITCH;
        }

        # status request
        if ($path eq '/status') {
            my $status = $self->{agent}->getStatus();
            my $response = HTTP::Response->new(
                200,
                'OK',
                HTTP::Headers->new('Content-Type' => 'text/plain'),
               "status: ".$status
            );
            $client->send_response($response);
            last SWITCH;
        }

        # static content request
        if ($path =~ m{^/(logo.png|site.css|favicon.ico)$}) {
            my $file = $1;
            $client->send_file_response("$htmldir/$file");
            last SWITCH;
        }

        $logger->debug("[HTTPD] error, unknown path: $path");
        $client->send_error(400);
    }

    $client->close();
}

sub _listen {
    my ($self) = @_;

    my $targets = $self->{targets};
    my $logger = $self->{logger};

    my $daemon = HTTP::Daemon->new(
        LocalAddr => $self->{ip},
        LocalPort => $self->{port},
        Reuse     => 1,
        Timeout   => 5
    );
  
    if (!$daemon) {
        $logger->error("[HTTPD] failed to start the HTTPD service");
        return;
    } 

    my $url = $self->{ip} ?
        "http://$self->{ip}:$self->{port}" :
        "http://localhost:$self->{port}" ;

    $logger->info(
        "[HTTPD] service started at: $url"
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

FusionInventory::Agent::HTTPD - An embedded HTTP server

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
token if parameter trust_localhost is true.

=head1 METHODS

=head2 new($params)

The constructor. The following parameters are allowed, as keys of the $params
hashref:

=over

=item I<logger>

the logger object to use

=item I<targets>

the targets list object to use

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
