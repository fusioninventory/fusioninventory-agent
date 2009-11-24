package Ocsinventory::Agent::RPC;

use HTTP::Daemon;

use threads;

sub new {

    my $self = {};

    bless $self;

    $self->{thr} = threads->create('server', $self);


    return $self;
}

sub server {
    my ($self) = @_;

    my $daemon = $self->{daemon} = HTTP::Daemon->new || die;
    print "Please contact me at: <URL:", $daemon->url, ">\n";
    while (my $c = $daemon->accept) {
        while (my $r = $c->get_request) {
            if ($r->method eq 'GET' and $r->uri->path eq "/xyzzy") {
                # remember, this is *not* recommended practice :-)
                $c->send_file_response("/etc/passwd");
            }
            else {
                $c->send_error(RC_FORBIDDEN)
            }
        }
        $c->close;
        undef($c);
    }
}



1;
