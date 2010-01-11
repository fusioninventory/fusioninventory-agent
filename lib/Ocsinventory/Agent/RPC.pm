package Ocsinventory::Agent::RPC;

use HTTP::Daemon;

use threads;

sub new {
    my (undef, $params) = @_;

    my $self = {};

    $self->{config} = $params->{config};
    $self->{targets} = $params->{targets};

    my $config = $self->{config};


    bless $self;

    if ($config->{deamon} || $config->{daemonNoFork}) {
        $self->{thr} = threads->create('server', $self);
    }


    return $self;
}

sub handler {
    my ($self, $c) = @_;

    my $r = $c->get_request;
    if ($r->method eq 'GET' and $r->uri->path =~ /^\/deploy\/([a-zA-Z\/-]+)$/) {
        my $file = $1;
        foreach my $target (@{$targets->{targets}}) {
            print $target->{vardir}."/deploy/".$file."\n";
            if (-f $target->{vardir}."/deploy/".$file) {
                $c->send_file_response($target->{vardir}."/deploy/".$file);
            }
        }
        $c->send_error(404)
    } elsif ($r->method eq 'GET' and $r->uri->path =~ /^\/reset$/) {
        print "RESET catched\n";
    } else {
        $c->send_error(500)
    }
    $c->close;
    undef($c);
}

sub server {
    my ($self) = @_;

    my $targets = $self->{targets};
    my $daemon = $self->{daemon} = HTTP::Daemon->new(LocalPort => 62354) || die;
    print "Please contact me at: <URL:", $daemon->url, ">\n";
    while (my $c = $daemon->accept) {
        threads->create(\&handler, $self, $c)->detach();
    }
}



1;
