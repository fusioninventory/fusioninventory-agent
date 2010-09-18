package t::Utils;

use strict;
use Exporter ();
use IO::Socket::INET;
use vars qw( @ISA @EXPORT @EXPORT_OK );

@ISA       = qw( Exporter );
@EXPORT    = qw( &server_start &server_next &fork_proxy &web_ok &bare_request );
@EXPORT_OK = @EXPORT;

use HTTP::Daemon;
use LWP::UserAgent;

# start a simple server
sub server_start {

    # create a HTTP::Daemon (on an available port)
    my $daemon = HTTP::Daemon->new(
        LocalAddr => 'localhost',
        LocalPort => 8080,
        ReuseAddr => 1,
      )
      or die "Unable to start web server";
    return $daemon;
}

# This must NOT be called in an OO fashion but this way:
# server_next( $server, $coderef, ... );
#
# The optional coderef takes a HTTP::Request as its first argument
# and returns a HTTP::Response. The rest of server_next() arguments
# are passed to &$anwser;

sub server_next {
    my $daemon = shift;
    my $answer = shift;

    # get connection data
    my $conn = $daemon->accept;
    my $req  = $conn->get_request;

    # compute some answer
    my $rep;
    if ( ref $answer eq 'CODE' ) {
        $rep = $answer->( $req, @_ );
    }
    else {
        $rep = HTTP::Response->new(
            200, 'OK',
            HTTP::Headers->new( 'Content-Type' => 'text/plain' ),
            sprintf( "You asked for <a href='%s'>%s</a>", ( $req->uri ) x 2 )
        );
    }

    use Data::Dumper;
    print "foo\n";
    print Dumper($conn);
    $conn->send_error(404);
    print "baz\n";
    print Dumper($conn);
    $conn->send_response($rep);
    print "bar\n";
    $conn->close;
}

# run a stand-alone proxy
# the proxy accepts an optional coderef to run after serving all requests
sub fork_proxy {
    my $proxy = shift;
    my $sub   = shift;

    my $pid = fork;
    die "Unable to fork proxy" if not defined $pid;

    if ( $pid == 0 ) {
        $0 .= " (proxy)";

        # this is the http proxy
        $proxy->start;
        $sub->() if ( defined $sub and ref $sub eq 'CODE' );
        exit 0;
    }

    # back to the parent
    return $pid;
}

# check that the web connection is working
sub web_ok {
    my $ua = LWP::UserAgent->new( env_proxy => 1, timeout => 30 );
    my $res =
      $ua->request(
        HTTP::Request->new( GET => shift||'http://www.google.com/intl/en/' ) );
    return $res->is_success;
}

# send a simple request without LWP::UA
# bare_request($url, $headers, $proxy)
sub bare_request {
    my ($url, $headers, $proxy) = @_;

    # connect directly to the proxy
    $proxy->url() =~ /:(\d+)/;
    my $sock = IO::Socket::INET->new(
        PeerAddr => 'localhost',
        PeerPort => $1,
        Proto    => 'tcp'
      ) or do { warn "Can't connect to the proxy"; return ""; };
    
    # send the request
    print $sock "GET $url HTTP/1.0\015\012",
                $headers->as_string( "\015\012" ), "\015\012";
    my $content = join "", <$sock>;

    # close the connection to the proxy
    close $sock or warn "close: $!";
    return $content;
}

package HTTP::Proxy;

# return the requested internal filter stack
# _filter_stack( body|header, request|response, HTTP::Message )
sub _filter_stack {
    my ( $self, $part, $mesg ) = splice( @_, 0, 3 );
    die "No <$part><$mesg> filter stack"
      unless $part =~ /^(?:header|body)$/
      and $mesg =~ /^(?:request|response)$/;

    for (@_) {
        die "$_ is not a HTTP::Request or HTTP::Response"
          unless ( ref $_ ) =~ /^HTTP::(Request|Response)$/;
        $self->{ lc $1 } = $_;
    }
    $self->{response}->request( $self->{request} );
    return $self->{$part}{$mesg};
}

