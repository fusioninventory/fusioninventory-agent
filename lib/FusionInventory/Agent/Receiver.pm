package FusionInventory::Agent::Receiver;

use strict;
use warnings;
#use threads;
#use threads::shared;

use Sys::Hostname;
use English qw(-no_match_vars);
use POE;
use POE::Component::Server::HTTP;
use HTTP::Status;
use File::stat;

use FusionInventory::Logger;

sub new {
    my ($class, $params) = @_;

    my $self = {
        logger          => $params->{logger} || FusionInventory::Logger->new(),
        scheduler       => $params->{scheduler},
        agent           => $params->{agent},
        ip              => $params->{ip} || '127.0.0.1',
        port            => $params->{port},
        htmldir         => $params->{htmldir},
        trust_localhost => $params->{trust_localhost},
    };

    my $logger = $self->{logger};

    $logger->debug($self->{htmldir} ?
        "[WWW] static files are in $self->{htmldir}" :
        "[WWW] no static files directory"
    );


    if ($self->{htmldir}) {
        $logger->debug("[WWW] Static files are in ".$self->{htmldir});
    } else {
        $logger->debug("[WWW] No static files directory");
    }

    bless $self, $class;

    $SIG{PIPE} = 'IGNORE';

    $self->{httpd} = POE::Component::Server::HTTP->new(
        Port => $self->{rpc_port} || 62354,
        ContentHandler => {
            '/' => sub { $self->main(@_) },
            '/deploy/' => sub { $self->deploy(@_) },
            '/now' => sub { $self->now(@_) },
            '/files/' => sub { $self->files(@_) },
        },
        StreamHandler  => sub { $self->stream(@_) },
        Headers => { Server => 'FusionInventory Agent' },
    );
    if ($self->{httpd}) { # XXX TODO
        $logger->error("[WWW] failed to start the service");
        return;
    } 

    $logger->info("RPC service started at: http://".
        ( $self->{'ip'} || "127.0.0.1" ).
        ":".
        ($self->{'www-port'} || 62354));

    return $self;
}



sub main {
    my ($self, $request, $response) = @_;

    my $logger = $self->{logger};
    my $scheduler = $self->{scheduler};

    my $remote_ip = $request->connection->remote_ip;
   

    if ($remote_ip ne '127.0.0.1') {
        $response->content("Forbidden");
        $response->code(403);
        return;
    }


    $response->code(RC_OK);


    my $indexFile = $self->{htmldir}."/index.tpl";
    my $handle;
    if (!open $handle, '<', $indexFile) {
        $logger->error("Can't open share $indexFile: $ERRNO");
        $response->code(500);
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
    if (!$self->{trust_localhost}) {
        $output =~
        s/%%IF_ALLOW_LOCALHOST%%.*%%ENDIF_ALLOW_LOCALHOST%%//;
    }
    $output =~ s/%%(END|)IF_.*?%%//g;
    $response->content($output);

    return RC_OK;
}

sub deploy {
    my ($self, $request, $response) = @_;

    my $logger = $self->{logger};
    my $scheduler = $self->{scheduler};
    
    my $path = $request->uri->path;

    if ($path =~ m{^/deploy/([\w\d/-]+)$}) {
        my $file = $1;
        foreach my $target (@{$scheduler->{targets}}) {
            if (-f $target->{vardir}."/deploy/".$file) {
                $logger->debug("Send /deploy/".$file);
# XXX TODO
                $self->sendFile($response, $target->{vardir}."/deploy/".$file);
                return;
            } else {
                $logger->debug("Not found /deploy/".$file);
                $response->code(404);
            }
        }
    }
}

sub now {
    my ($self, $request, $response) = @_;

    my $logger = $self->{logger};
    my $scheduler = $self->{scheduler};
    
    my $path = $request->uri->path;
    my $remote_ip = $request->connection->remote_ip;

    # now request
    if ($path =~ m{^/now(/|)(\S+)?$}) {
        my $sentToken = $2;
        my $result;

        print $remote_ip."\n";
        if ($remote_ip eq '127.0.0.1' && $self->{trust_localhost}) {
            # trusted request
            $result = "ok";
        print "ok\n";
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
            $response->code(200);
            $message = "Done."
        } else {
            $response->code(403);
            $message = "Access denied: $result.";
        }

        my $output = "<html><head><title>FusionInventory-Agent</title></head><body>$message<br /><a href='/'>Back</a></body><html>";
        $response->content($output);

#        # static content request
#        if ($path =~ m{^/(logo.png|site.css|favicon.ico)$}) {
#            $c->send_file_response($htmldir."/$1");
#            last SWITCH;
#        }
#
#        $logger->debug("[WWW] error, unknown path: $path");
#        $c->send_error(400);
#>>>>>>> master
    }
}

sub files {
    my ($self, $request, $response) = @_;

    my $config = $self->{config};
    my $logger = $self->{logger};

    my $path = $request->uri->path;

    if ($path =~ /^\/files(.*)/) {
        $self->sendFile($response, $self->{htmldir}.$1);
        return;

    }
}

sub sendFile {
    my ($self, $response, $file) = @_;

    my $logger = $self->{logger};

    my $st = stat($file);
    my $fh;
    if (!open $fh, "<$file") {
        $logger->error("Failed to open $file");
        return;
    }
    binmode($fh);
    $self->{todo}{$response->{connection}{my_id}} = $fh;


    $response->streaming(1);
    $response->code(RC_OK);         # you must set up your response header
    $response->content_type('application/binary');
    $response->content_length($st->size);

}

sub stream {
    my($self, $resquest, $response)=@_;

    my $fh = $self->{todo}{$response->{connection}{my_id}};

    my $buffer;
    my $dataRemain = read ($fh, $buffer, 1024); 
    $response->send($buffer);
   
    if (!$dataRemain) {
        close($fh);
        $response->streaming(0);
        $response->close;
        $resquest->header(Connection => 'close');
        delete($self->{todo}{$response->{connection}{my_id}});
    }
}


#sub _handle {
#    my ($self, $c, $r, $clientIp) = @_;
#    
#    my $logger = $self->{logger};
#    my $scheduler = $self->{scheduler};
#    my $htmldir = $self->{htmldir};
#
#    if (!$r) {
#        $c->close;
#        undef($c);
#        return;
#    }
#
#    my $path = $r->uri()->path();
#    $logger->debug("[WWW] request $path from client $clientIp");
#
#    # non-GET requests
#    my $method = $r->method();
#    if ($method ne 'GET') {
#        $logger->debug("[WWW] invalid request type: $method");
#        $c->send_error(500);
#        $c->close;
#        undef($c);
#        return;
#    }
#
#    # GET requests
#    SWITCH: {
#
#        # status request
#        if ($path eq '/status') {
#            my $status = $self->{agent}->getStatus();
#            my $r = HTTP::Response->new(
#                200,
#                'OK',
#                HTTP::Headers->new('Content-Type' => 'text/plain'),
#               "status: $status"
#            );
#            $c->send_response($r);
#            last SWITCH;
#        }
#
#        # static content request
#        if ($path =~ m{^/(logo.png|site.css|favicon.ico)$}) {
#            $c->send_file_response($htmldir."/$1");
#            last SWITCH;
#        }
#    }

#    $c->close;
#    undef($c);
#}

#sub _server {
#    my ($self) = @_;
#
#    my $scheduler = $self->{scheduler};
#    my $logger = $self->{logger};
#
#    my $daemon = HTTP::Daemon->new(
#        LocalAddr => $self->{'ip'},
#        LocalPort => $self->{'www-port'},
#        Reuse     => 1,
#        Timeout   => 5
#    );
#
#    if (!$daemon) {
#        $logger->error("[WWW] Failed to start the service");
#        return;
#    } 
#    $logger->info(
#        "[WWW] Service started at: http://$self->{'ip'}:$self->{'www-port'}"
#    );
#
#    while (1) {
#        my ($client, $socket) = $daemon->accept();
#        next unless $socket;
#        my (undef, $iaddr) = sockaddr_in($socket);
#        my $clientIp = inet_ntoa($iaddr);
#        my $request = $client->get_request();
#        $self->_handle($client, $request, $clientIp);
#    }
#}
#
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
token if configuration option www-trust-localhost is true.

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
