package FusionInventory::Agent::HTTPD;

use strict;
use warnings;
use threads;
use threads::shared;

use English qw(-no_match_vars);
use HTTP::Daemon;

my $lock :shared;
my $status :shared = "unknown";

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
        "[WWW] static files are in $self->{htmldir}" :
        "[WWW] no static files directory"
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
                my $directory = $target->{vardir} ."/deploy";
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

        $logger->debug("[WWW] error, unknown path: $path");
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
        $logger->error("Failed to start the HTTPD server");
        return;
    } 

    my $url = $self->{ip} ?
        "http://$self->{ip}:$self->{port}" :
        "http://localhost:$self->{port}" ;

    $logger->info(
        "HTTPD service started at: $url"
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

FusionInventory::Agent::HTTPD - the RPC interface 

=head1 DESCRIPTION

FusionInventory Agent can listen on the network through an embedded HTTP
server. This server can only be used to wakeup the agent or download
OcsDeploy cached files. The server uses port 62354.

Every time the agent contact the server, it send a token, this token will
be needed to identify the server who want to awake an agent.

Once an agent is awake, it will contact the server as usual to know
the jobs it need to do.

=head1 SYNOPSIS

In this example, we want to wakeup machine "aMachine":

  use LWP::Simple;

  my $machine = "aMachine";
  my $token = "aaaaaaaaaaaaaa";
  if (!get("http://$machine:62354/now/$token")) {
    print "Failed to wakeup $machine\n";
    return;
  }
  sleep(10);
  print "Current status\n";
  print get("http://$machine:62354/status");
