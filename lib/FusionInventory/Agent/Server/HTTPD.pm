package FusionInventory::Agent::Server::HTTPD;

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
        ContentHandler => { '/' => sub { $self->content(@_) } },
        Headers => { Server => 'FusionInventory Agent' },
    );

    $self->{logger}->info(
        "[httpd] Web interface started at http://" .
        ($params{ip} || "127.0.0.1")      .
        ":$params{port}"
    );

    return $self;
}

sub content {
    my ($self, $request, $response) = @_;

    my $logger    = $self->{logger};
    my $path      = $request->uri()->path();
    my $remote_ip = $request->connection()->remote_ip();

    $logger->debug("[httpd] request $path received from $remote_ip");

    # first match wins
    my @methods = (
        [ deploy  => qr{^/deploy/(\S+)$} ],
        [ files   => qr{^/files/(\S+)$}   ],
        [ now     => qr{^/now(?:/(\S+))?$} ],
        [ default => qr{^/} ]
    );

    foreach my $item (@methods) {
        my ($method, $pattern) = @$item;
        if (my @matched = ($path =~ $pattern)) {
            $self->$method($request, $response, @matched);
            return $response->code();
        }
    }

    $logger->debug("[httpd] no handler found for request");
    $response->code(500);
    return RC_OK;
}

sub default {
    my ($self, $request, $response) = @_;

    my $logger = $self->{logger};
    $logger->debug("[httpd] 'default' handler called");

    if ($request->connection()->remote_ip() ne '127.0.0.1') {
        $response->content("Access denied");
        $response->code(403);
        return;
    }

    my $template = Text::Template->new(
        TYPE => 'FILE', SOURCE => "$self->{htmldir}/index.tpl"
    );

    my $hash = {
        version => $FusionInventory::Agent::VERSION,
        trust   => $self->{trust_localhost},
        jobs   => [ $self->{state}->getJobs() ]
    };

    $response->code(RC_OK);
    $response->content(
        $template->fill_in(HASH => $hash)
    );

    return RC_OK;
}

sub files {
    my ($self, $request, $response, $file) = @_;

    my $logger = $self->{logger};
    $logger->debug("[httpd] 'file' handler called, with file $file");

    $self->sendFile(
        $response, $self->{htmldir} . '/' . $file
    );
}

sub deploy {
    my ($self, $request, $response, $file) = @_;

    my $logger = $self->{logger};
    $logger->debug("[httpd] 'deploy' handler called, with file $file");

    foreach my $target ($self->{state}->getTargets()) {
        $self->sendFile(
            $response,
            $target->getStorage()->getDirectory() . '/' . $file
        );
    }
}

sub now {
    my ($self, $request, $response, $token) = @_;

    my $logger = $self->{logger};
    $logger->debug(
        "[httpd] 'now' handler called" .
        ($token ? ", with token $token" : "")
    );

    my $result;

    if (
        $request->connection()->remote_ip() eq '127.0.0.1' &&
        $self->{trust_localhost}
    ) {
            # trusted request
            $result = "ok";
    } else {
        if ($token) {
            # authenticated request
            if ($token eq $self->{state}->getToken()) {
                $result = "ok";
                $self->{state}->resetToken();
            } else {
                $result = "untrusted address, invalid token";
            }
        } else {
            $result = "untrusted address, no token received";
        }
    }

    my ($code, $message);
    if ($result eq "ok") {
        $message = "Done";
        $code = 200;
        $self->{state}->runAllJobs();
    } else {
        $message = "Access denied";
        $code = 403;
    }

    my $content = "<html><head><title>FusionInventory-Agent</title></head><body>$message<br /><a href='/'>Back</a></body><html>";

    $response->code($code);
    $response->content($content);
}


sub sendFile {
    my ($self, $response, $file) = @_;

    if (-f $file) {
        if (!open my $fh, '<', $file) {
            $response->code(RC_FORBIDDEN);
            $response->content('Access denied');
        } else {
            local $RS;
            $response->code(RC_OK);
            $response->content(<$fh>);
            close $fh;
        }
    } else {
        $response->code(RC_NOT_FOUND);
        $response->content('not found');
    }
}

1;
__END__

=head1 NAME

FusionInventory::Agent::HTTPD - Agent web server

=head1 DESCRIPTION

This is the agent HTTP server, listening on port 62354 (by default). The
following requests are accepted:

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
