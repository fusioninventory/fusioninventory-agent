package Test::Server;

use warnings;
use strict;
use base qw(HTTP::Server::Simple::CGI HTTP::Server::Simple::Authen);

use Test::Auth;

my $dispatch_table = {};

=head1 OVERLOADED METHODS

=cut

our $pid;

sub new {
    die 'An instance of TestServer has already been started.' if $pid;

    my $class = shift;
    my %params = (
        port => 8080,
        @_
    );

    my $self = $class->SUPER::new($params{port});

    $self->{user}     = $params{user};
    $self->{password} = $params{password};

    return $self;
}

sub run {
    my $self = shift;

    $pid = $self->SUPER::run(@_);

    $SIG{__DIE__} = \&stop;

    return $pid;
}

sub authen_handler {
    my ($self) = @_;
    return Test::Auth->new(
        user     => $self->{user},
        password => $self->{password}
    );
}

sub handle_request {
    my $self = shift;
    my $cgi  = shift;

    my $path = $cgi->path_info();
    my $handler = $dispatch_table->{$path};

    if ($handler) {
        if (ref($handler) eq "CODE") {
            $handler->($self, $cgi);
        } else {
            print "HTTP/1.0 200 OK\r\n";
            print "\r\n";
            print $handler;
        }
    } else {
        print "HTTP/1.0 404 Not found\r\n";
        print
        $cgi->header,
        $cgi->start_html('Not found'),
        $cgi->h1('Not found'),
        $cgi->end_html;
    }
}

# overriden to add status to return code in the headers
sub authenticate {
    my $self = shift;
    my $user = $self->do_authenticate();
    unless (defined $user) {
        my $realm = $self->authen_realm();
        print "HTTP/1.0 401 Authentication required\r\n";
        print qq(WWW-Authenticate: Basic realm="$realm"\r\n\r\n);
        print "Authentication required.";
        return;
    }
    return $user;
}

sub print_banner {
}

=head1 METHODS UNIQUE TO TestServer

=cut

sub set_dispatch {
    my $self = shift;
    $dispatch_table = shift;

    return;
}

sub background {
    my $self = shift;

    $pid = $self->SUPER::background()
        or Carp::confess( q{Can't start the test server} );

    sleep 1; # background() may come back prematurely, so give it a second to fire up

    return $pid;
}


sub hostname {
    my $self = shift;

    return '127.0.0.1';
}

sub root {
    my $self = shift;
    my $port = $self->port;
    my $hostname = $self->hostname;

    return "http://$hostname:$port";
}

sub stop {
    if ( $pid ) {
        kill( 9, $pid ) unless $^S;
        undef $pid;
    }

    return;
}

1;
