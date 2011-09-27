package FusionInventory::Agent::HTTP::Server;

use strict;
use warnings;
use threads;

use English qw(-no_match_vars);
use HTTP::Daemon;
use Net::IP;
use Text::Template;
use File::Basename;

use FusionInventory::Agent::Logger;

my $log_prefix = "[http server] ";

sub new {
    my ($class, %params) = @_;

    my $self = {
        logger          => $params{logger} ||
                           FusionInventory::Agent::Logger->new(),
        agent           => $params{agent},
        scheduler       => $params{scheduler},
        htmldir         => $params{htmldir},
        ip              => $params{ip},
        port            => $params{port} || 62354,
        trust           => $params{trust}

    };
    bless $self, $class;

    $self->{listener} = threads->create('_listen', $self);

    return $self;
}

sub _handle {
    my ($self, $client, $request, $clientIp) = @_;
    
    my $logger = $self->{logger};
    my $scheduler = $self->{scheduler};
    my $htmldir = $self->{htmldir};

    if (!$request) {
        $client->close();
        return;
    }

    my $path = $request->uri()->path();
    $logger->debug($log_prefix . "request $path from client $clientIp");

    # non-GET requests
    my $method = $request->method();
    if ($method ne 'GET') {
        $logger->debug($log_prefix . "error, invalid request type: $method");
        $client->send_error(400);
        $client->close;
        undef($client);
        return;
    }

    # GET requests
    SWITCH: {
        # root request
        if ($path eq '/') {

            my $template = Text::Template->new(
                TYPE => 'FILE', SOURCE => "$self->{htmldir}/index.tpl"
            );
            if (!$template) {
                $logger->error($log_prefix . "Template access failed: $Text::Template::ERROR");
                ;

                my $response = HTTP::Response->new(
                    500,
                    'KO',
                    HTTP::Headers->new('Content-Type' => 'text/html'),
                    "No template"
                );

                $client->send_response($response);
                return;
            }

            my $hash = {
                version => $FusionInventory::Agent::VERSION,
                trust   => $self->_is_trusted($clientIp),
                status  => $self->{agent}->getStatus(),
                targets => [
                    map { $_->getStatus() } $self->{scheduler}->getTargets()
                ]
            };

            my $response = HTTP::Response->new(
                200,
                'OK',
                HTTP::Headers->new('Content-Type' => 'text/html'),
                $template->fill_in(HASH => $hash)
            );

            $client->send_response($response);

            last SWITCH;
        } 

        # deploy request
        if ($path =~ m{^/deploy/getFile/./../([\w\d/-]+)$}) {
            my $sha512 = $1;

            return unless $sha512 =~ /^..(.{6})/;
            my $name = $1;
            my $path;

            File::Find->require();
            Digest::SHA->require();

            foreach my $target ($self->{scheduler}->getTargets()) {
                my $shareDir = $target->{storage}->getDirectory()."/deploy/fileparts/shared";
                next unless -d $shareDir;

                my $wanted = sub {
                    return unless -f $_;
                    return unless basename($_) eq $name;

                    my $sha = Digest::SHA->new('512');
                    $sha->addfile($File::Find::name, 'b');
                    return unless $sha->hexdigest eq $sha512;

                    $path = $File::Find::name;
                };
                File::Find::find({ wanted => $wanted, no_chdir => 1 }, $shareDir);
                last if $path;
            }
            if ($path) {
                $logger->debug($log_prefix . "file $sha512 found");
                $client->send_file_response($path);
                $logger->debug($log_prefix . "file $path sent");
            } else {
                $client->send_error(404);
            }
            last SWITCH;
        }

        # now request
        if ($path =~ m{^/now(?:/(\S+))?$}) {
            my $token = $1;

            my ($code, $message, $trace);
            if (
                $self->_is_trusted($clientIp) ||
                $self->_is_authenticated($token)
            ) {
                foreach my $target ($scheduler->getTargets()) {
                    $target->setNextRunDate(1);
                }
                $self->{agent}->resetToken();
                $code    = 200;
                $message = "OK";
                $trace   = "valid request, forcing execution right now";
            } else {
                $code    = 403;
                $message = "Access denied";
                $trace   = "invalid request (bad token or bad address)";
            }

            my $template = Text::Template->new(
                TYPE => 'FILE', SOURCE => "$self->{htmldir}/now.tpl"
            );

            my $hash = {
                message => $message
            };

            my $response = HTTP::Response->new(
                $code,
                'OK',
                HTTP::Headers->new('Content-Type' => 'text/html'),
                $template->fill_in(HASH => $hash)
            );

            $client->send_response($response);
            $logger->debug($log_prefix . $trace);

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

        $logger->debug("error, unknown path: $path");
        $client->send_error(400);
    }

    $client->close();
}

sub _is_trusted {
    my ($self, $address) = @_;

    return 0 unless $self->{trust};

    my $source  = Net::IP->new($address);
    my $trusted = Net::IP->new($self->{trust});
    my $result = $source->overlaps($trusted);

    return 
        $result == $IP_A_IN_B_OVERLAP || # included in trusted range
        $result == $IP_IDENTICAL;        # equals trusted address
}

sub _is_authenticated {
    my ($self, $token) = @_;

    return 0 unless $token;

    return $token eq $self->{agent}->getToken();
}

sub _listen {
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
        $logger->error($log_prefix . "failed to start the HTTPD service");
        return;
    } 

    my $url = $self->{ip} ?
        "http://$self->{ip}:$self->{port}" :
        "http://localhost:$self->{port}" ;

    $logger->info($log_prefix . "HTTPD service started at $url");

    # allow the thread to be stopped 
    threads->set_thread_exit_only(1);
    $SIG{'KILL'} = sub {};

    while (1) {
        my ($client, $socket) = $daemon->accept();
        next unless $socket;
        my (undef, $iaddr) = sockaddr_in($socket);
        my $clientIp = inet_ntoa($iaddr);
        my $request = $client->get_request();
        $self->_handle($client, $request, $clientIp);
    }
}

sub DESTROY {
    my ($self) = @_;

    return unless $self->{listener};

    if ($self->{listener}->is_joinable()) {
        $self->{listener}->join();
    } else {
        $self->{listener}->kill('KILL')->detach();
    }
}

1;
__END__

=head1 NAME

FusionInventory::Agent::HTTP:Server - An embedded HTTP server

=head1 DESCRIPTION

This is the server used by the agent to listen on the network for messages sent
by OCS or GLPI servers.

It is an HTTP server listening on port 62354 (by default). The following
requests are accepted:

=over

=item /status

=item /deploy

=item /now

=back

Authentication is based on a token created by the agent, and sent to the
server at initial connection. Connection from addresses matching the trust
parameter are trusted without token.

=head1 METHODS

=head2 new(%params)

The constructor. The following parameters are allowed, as keys of the %params
hash:

=over

=item I<logger>

the logger object to use

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

=item I<trust>

an IP adress or an IP adress range from which to trust incoming requests
without authentication token (default: none)

=back
