package Ocsinventory::Agent::RPC;

use HTTP::Daemon;
use Ocsinventory::Agent::Storage;

use threads;

use strict;
use warnings;

sub new {
    my (undef, $params) = @_;

    my $self = {};

    $self->{config} = $params->{config};
    $self->{logger} = $params->{logger};
    $self->{targets} = $params->{targets};

    my $config = $self->{config};

    use Data::Dumper;

    my $storage = $self->{storage} = new Ocsinventory::Agent::Storage({
            target => {
                vardir => $config->{basevardir},
            }
        });


    bless $self;

    if ($config->{deamon} || $config->{daemonNoFork}) {
        $self->{thr} = threads->create('server', $self);
    }


    return $self;
}

sub handler {
    my ($self, $c) = @_;
    
    my $logger = $self->{logger};
    my $targets = $self->{targets};

    my $r = $c->get_request;
    if ($r->method eq 'GET' and $r->uri->path =~ /^\/deploy\/([a-zA-Z\/-]+)$/) {
        my $file = $1;
        foreach my $target (@{$targets->{targets}}) {
            if (-f $target->{vardir}."/deploy/".$file) {
                $c->send_file_response($target->{vardir}."/deploy/".$file);
            }
        }
        $logger->debug("[RPC]Err, 404");
        $c->send_error(404)
    } elsif ($r->method eq 'GET' and $r->uri->path =~ /^\/now\/(\S+)$/) {
        my $token = $1;
        $logger->debug("[RPC]'now' catched");
        if ($token ne $self->getToken()) {
            $c->send_status_line(403)
        } else {
            $targets->resetNextRunDate();
            $c->send_status_line(200)
        }
    } else {
        $logger->debug("[RPC]Err, 500");
        $c->send_error(500)
    }
    $c->close;
    undef($c);
}

sub server {
    my ($self) = @_;

    my $targets = $self->{targets};
    my $logger = $self->{logger};

    my $daemon = $self->{daemon} = HTTP::Daemon->new(
        LocalPort => 62354,
        Reuse => 1);
  
   if (!$daemon) {
        $logger->error("Failed to start the RPC server");
        return;
   } 
    $logger->info("RPC service started at: ". $daemon->url);
    while (my $c = $daemon->accept) {
        threads->create(\&handler, $self, $c)->detach();
    }
}

sub getToken {
    my ($self, $reset) = @_; 

    my $lock :shared;
 
    my $storage = $self->{storage};
    my $logger = $self->{logger};

    lock($lock);

    if ($self->{token}) {

    }
    my $myData = $storage->restore(__PACKAGE__);
    if (!$myData->{token}) {

        my $tmp = '';
        $tmp .= pack("W",65+rand(24)) foreach (0..100);
        $myData->{token} = $tmp;

        $storage->save($myData);
    }
    $self->{token} = $myData->{token};
    
    $logger->debug("token is :".$self->{token});

    return $self->{token};

}

1;
