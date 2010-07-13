package FusionInventory::Agent::RPC;

use strict;
use warnings;
use threads;
use threads::shared;

use English qw(-no_match_vars);
use HTTP::Daemon;

use FusionInventory::Agent::Storage;

my $lock :shared;
my $status :shared = "unknown";

sub new {
    my ($class, $params) = @_;

    my $self = {
        config      => $params->{config},
        logger      => $params->{logger},
        targetsList => $params->{targetsList}
    };

    my $config = $self->{config};
    my $logger = $self->{logger};

    if ($config->{'share-dir'}) {
        $self->{htmlDir} = $config->{'share-dir'}.'/html';
    } elsif ($config->{'devlib'}) {
        $self->{htmlDir} = "./share/html";
    }
    $logger->debug("[RPC] static files are in ".$self->{htmlDir});


    my $storage = $self->{storage} = FusionInventory::Agent::Storage->new({
        target => {
            vardir => $config->{basevardir},
        }
    });

    bless $self, $class;

    return $self if $config->{'no-socket'};

    $SIG{PIPE} = 'IGNORE';
    if (
        $config->{daemon}           ||
        $config->{'daemon-no-fork'} ||
        $config->{winService}
    ) {
        $self->{thr} = threads->create('server', $self);
    }


    return $self;
}

sub handler {
    my ($self, $c, $r, $clientIp) = @_;
    
    my $logger = $self->{logger};
    my $targetsList = $self->{targetsList};
    my $config = $self->{config};
    my $htmlDir = $self->{htmlDir};

    if (!$r) {
        $c->close;
        undef($c);
        return;
    }

    my $path = $r->uri()->path();
    $logger->debug("[RPC]$clientIp request $path");

    if ($r->method() ne 'GET') {
        $logger->debug("[RPC]Err, 500");
        $c->send_error(500);
        $c->close;
        undef($c);
        return;
    }

    SWITCH: {
        if ($path eq '/') {
            if ($clientIp !~ /^127\./) {
                $c->send_error(404);
                return;
            }

            my $nextContact = "";
            foreach my $target (@{$targetsList->{targets}}) {
                my $path = $target->{path};
                $path =~ s/(http|https)(:\/\/)(.*@)(.*)/$1$2$4/;
                my $timeString = $target->getNextRunDate() > 1 ?
                    localtime($target->getNextRunDate()) :
                    "now";
                $nextContact .=
                    "<li>$target->{type}, $path: $timeString</li>\n";
            }

            my $indexFile = $htmlDir."/index.tpl";
            my $handle;
            if (!open $handle, '<', $indexFile) {
                $logger->error("Can't open share $indexFile: $ERRNO");
                $c->send_error(404);
                return;
            }
            undef $/;
            my $output = <$handle>;
            close $handle;

            $output =~ s/%%STATUS%%/$status/;
            $output =~ s/%%NEXT_CONTACT%%/$nextContact/;
            $output =~ s/%%AGENT_VERSION%%/$FusionInventory::Agent::VERSION/;
            if (!$config->{'rpc-trust-localhost'}) {
                $output =~
                s/%%IF_ALLOW_LOCALHOST%%.*%%ENDIF_ALLOW_LOCALHOST%%//;
            }
            $output =~ s/%%(END|)IF_.*?%%//g;
            my $r = HTTP::Response->new(
                200,
                'OK',
                HTTP::Headers->new('Content-Type' => 'text/html'),
                $output
            );
            $c->send_response($r);
            last SWITCH;
        }

        if ($path =~ m{^/deploy/([\w\d/-]+)$}) {
            my $file = $1;
            foreach my $target (@{$targetsList->{targets}}) {
                if (-f $target->{vardir}."/deploy/".$file) {
                    $logger->debug("Send /deploy/".$file);
                    $c->send_file_response($target->{vardir}."/deploy/".$file);
                } else {
                    $logger->debug("Not found /deploy/".$file);
                }
            }
            $c->send_error(404);
            last SWITCH;
        }

        if ($path =~ m{^/now(?:/(\S+))?$}) {
            my $sentToken = $1;
            my $currentToken = $self->getToken();
            $logger->debug("[RPC]'now' catched");
            if (
                ($config->{'rpc-trust-localhost'} && $clientIp =~ /^127\./)
                    or
                ($sentToken eq $currentToken)
            ) {
                $self->getToken('forceNewToken');
                $targetsList->resetNextRunDate();
                $c->send_status_line(200)
            } else {
                $logger->debug("[RPC] bad token $sentToken != ".$currentToken);
                $c->send_status_line(403)
            }
            last SWITCH;
        }

        if ($path eq '/status') {
            #$c->send_status_line(200, $status)
            my $r = HTTP::Response->new(
                200,
                'OK',
                HTTP::Headers->new('Content-Type' => 'text/plain'),
               "status: ".$status
            );
            $c->send_response($r);
            last SWITCH;
        }

        if ($path =~ m{^/(logo.png|site.css|favicon.ico)$}) {
            $c->send_file_response($htmlDir."/$1");
            last SWITCH;
        }

        $logger->debug("[RPC]Err, 500");
        $c->send_error(500)
    }

    $c->close;
    undef($c);
}

sub server {
    my ($self) = @_;

    my $config = $self->{config};
    my $targetsList = $self->{targetsList};
    my $logger = $self->{logger};

    my $daemon;
   
    if ($config->{'rpc-ip'}) {
        $daemon = $self->{daemon} = HTTP::Daemon->new(
            LocalAddr => $config->{'rpc-ip'},
            LocalPort => 62354,
            Reuse     => 1,
            Timeout   => 5
        );
    } else {
        $daemon = $self->{daemon} = HTTP::Daemon->new(
            LocalPort => 62354,
            Reuse     => 1,
            Timeout   => 5
        );
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
        my ($c, $socket) = $daemon->accept;
        next unless $socket;
        my(undef,$iaddr) = sockaddr_in($socket);
        my $clientIp = inet_ntoa($iaddr);
# HTTP::Daemon::get_request is not thread
# safe and must be called from the master thread
        my $r = $c->get_request;
        my $thr = threads->create(\&handler, $self, $c, $r, $clientIp);
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

        my @chars = ('A'..'Z');
        $myData->{token} =
            map { $chars[rand @chars] }
            1..8;

        $storage->save({ data => $myData });
    }
    
    $logger->debug("token is: ".$myData->{token});

    return $myData->{token};

}

sub setCurrentStatus {
    my ($self, $newStatus) = @_;

    $status = $newStatus;

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
        return;
    }
    sleep(10);
    print "Current status\n";
    print get("http://$machine:62354/status");
