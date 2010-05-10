package FusionInventory::Agent::RPC;

use HTTP::Daemon;
use FusionInventory::Agent::Storage;

use Config;

use strict;
use warnings;

BEGIN {
  # threads and threads::shared must be load before
  # $lock is initialized
  if ($Config{usethreads}) {
    if (!eval "use threads;1;" || !eval "use threads::shared;1;") {
      print "[error]Failed to use threads!\n"; 
    }
  }
}

my $lock :shared;

sub new {
    my (undef, $params) = @_;

    my $self = {};

    $self->{config} = $params->{config};
    $self->{logger} = $params->{logger};
    $self->{targets} = $params->{targets};
    my $config = $self->{config};
    my $logger = $self->{logger};

    if (!$Config{usethreads}) {
      $logger->debug("threads support is need for RPC"); 
      return;
    }



    my $storage = $self->{storage} = new FusionInventory::Agent::Storage({
            target => {
                vardir => $config->{basevardir},
            }
        });

    return if $config->{noSocket};

    bless $self;

    $SIG{PIPE} = 'IGNORE';
    if ($config->{daemon} || $config->{daemonNoFork}) {
        $self->{thr} = threads->create('server', $self);
    }


    return $self;
}

sub handler {
    my ($self, $c) = @_;
    
    my $logger = $self->{logger};
    my $targets = $self->{targets};

    my $r = $c->get_request;
    if (!$r) {
        $c->close;
        undef($c);
        return;
    } elsif ($r->method eq 'GET' and $r->uri->path =~ /^\/deploy\/([a-zA-Z\d\/-]+)$/) {
        my $file = $1;
        foreach my $target (@{$targets->{targets}}) {
            if (-f $target->{vardir}."/deploy/".$file) {
                $logger->debug("Send /deploy/".$file);
                $c->send_file_response($target->{vardir}."/deploy/".$file);
            } else {
                $logger->debug("Not found /deploy/".$file);
            }
        }
        $c->send_error(404)
    } elsif ($r->method eq 'GET' and $r->uri->path =~ /^\/now\/(\S+)$/) {
        my $token = $1;
        $logger->debug("[RPC]'now' catched");
        if ($token ne $self->getToken()) {
            $logger->debug("[RPC] bad token $token != ".$self->getToken());
            $c->send_status_line(403)
        } else {
            $self->getToken('forceNewToken');
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

    my $config = $self->{config};
    my $targets = $self->{targets};
    my $logger = $self->{logger};

    my $daemon;
   
    if ($config->{rpcIp}) {
        $daemon = $self->{daemon} = HTTP::Daemon->new(
            LocalAddr => $config->{rpcIp},
            LocalPort => 62354,
            Reuse => 1);
    } else {
        $daemon = $self->{daemon} = HTTP::Daemon->new(
            LocalPort => 62354,
            Reuse => 1);
    }
  
   if (!$daemon) {
        $logger->error("Failed to start the RPC server");
        return;
   } 
    $logger->info("RPC service started at: ". $daemon->url);

    my @stack;
    while (1) {
        # Limit to 10 the max number of running thread
        LIMIT: while (@stack > 10) {
            foreach (0..@stack-1) {
                my $thr = $stack[$_];
                # is_joinable is not avalaible on perl 5.8
                if (eval {$thr->is_joinable();1;}) {
                    $thr->join();
                    splice(@stack, $_, 1);
                    last LIMIT;
                }
            }
            # This is the plan B
            my $thr = shift(@stack);
            $thr->join();
        }
        my $c = $daemon->accept;
        my $thr = threads->create(\&handler, $self, $c);
        push @stack, $thr;
    }
}

sub getToken {
    my ($self, $forceNewToken) = @_; 

 
    my $storage = $self->{storage};
    my $logger = $self->{logger};

    lock($lock);

    my $myData = $storage->restore();
    if ($forceNewToken || !$myData->{token}) {

        my $tmp = '';
        $tmp .= pack("C",65+rand(24)) foreach (0..100);
        $myData->{token} = $tmp;

        $storage->save({ data => $myData });
    }
    
    $logger->debug("token is :".$myData->{token});

    return $myData->{token};

}

1;
__END__

=head1 NAME

FusionInventory::Agent::RPC - the RPC interface 

=head1 DESCRIPTION

FusionInventory Agent can listen on the network through an embedded HTTP
server. This server can only be used to wakeup the agent of download
OcsDeploy cached files. The server uses port 62354.

Every time the agent contact the server, it pushs a token, this token will
be needed to identify the server who want to awake an agent.

Once an agent is awake, its agent will contact the server as usual to know
the jobs it need to do.

=head1 SYNOPSIS

In this example, we want to wakeup machine "aMachine":

  use LWP::Simple;

  my $machine = "aMachine";
  my $token = "aaaaaaaaaaaaaa";
  if (!get("http://$machine:62354/now/$token")) {
    print "Failed to wakeup $machine\n"; 
  }


=cut

