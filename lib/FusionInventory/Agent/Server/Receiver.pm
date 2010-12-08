package FusionInventory::Agent::Server::Receiver;

use strict;
use warnings;

use English qw(-no_match_vars);
use POE;
use POE::Component::Server::HTTP;
use HTTP::Status;
use File::stat;
use Text::Template;

use FusionInventory::Agent::Logger;

sub new {
    my ($class, %params) = @_;

    $params{port} = 62354 unless defined $params{port};

    my $self = {
        logger          => $params{logger} || FusionInventory::Agent::Logger->new(),
        state           => $params{state},
        htmldir         => $params{htmldir},
        trust_localhost => $params{trust_localhost},
    };

    bless $self, $class;

    POE::Component::Server::HTTP->new(
        Port    => $params{port},
        Address => $params{ip},
        ContentHandler => {
            '/'       => sub { $self->main(@_) },
            '/deploy' => sub { $self->deploy(@_) },
            '/now'    => sub { $self->now(@_) },
            '/files'  => sub { $self->files(@_) },
        },
        StreamHandler => sub { $self->stream(@_) },
        Headers => { Server => 'FusionInventory Agent' },
    );

    $self->{logger}->info(
        "Web interface started at http://" .
        ($params{ip} || "127.0.0.1")      .
        ":$params{port}"
    );

    return $self;
}

sub main {
    my ($self, $request, $response) = @_;

    my $logger = $self->{logger};

    my $remote_ip = $request->connection->remote_ip;
   

    if ($remote_ip ne '127.0.0.1') {
        $response->content("Forbidden");
        $response->code(403);
        return;
    }

    my $template = Text::Template->new(
        TYPE => 'FILE', SOURCE => "$self->{htmldir}/index.tpl"
    );

    my $hash = {
        version => $FusionInventory::Agent::VERSION,
        trust   => $self->{trust_localhost},
        targets => [
            map { $_->getDescription() } $self->{state}->getTargets()
        ]
    };

    $response->code(RC_OK);
    $response->content(
        $template->fill_in(HASH => $hash)
    );

    return RC_OK;
}

sub deploy {
    my ($self, $request, $response) = @_;

    my $logger = $self->{logger};
    
    my $path = $request->uri->path;

    if ($path =~ m{^/deploy/([\w\d/-]+)$}) {
        my $file = $1;
        foreach my $target ($self->{state}->getTargets()) {
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
            POE::Kernel->post( Scheduler => 'runAllNow' );
            print "ok\n";
        } else {
            # authenticated request
            if ($sentToken) {
                my $token = $self->{state}->resetToken();
                if ($sentToken eq $token) {
                    $result = "ok";
                    $self->{state}->resetToken();
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
            #$scheduler->scheduleTargets(0);
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

=head2 new(%params)

The constructor. The following parameters are allowed, as keys of the %params
hash:

=over

=item I<logger>

the logger object to use (default: a new stderr logger)

=item I<state>

the server state object

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
