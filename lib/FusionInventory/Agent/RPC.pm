package FusionInventory::Agent::RPC;

use strict;
use warnings;

use HTTP::Daemon;
use FusionInventory::Agent::Storage;
use English qw(-no_match_vars);

use Config;

BEGIN {
    # threads and threads::shared must be load before
    # $lock is initialized
    if ($Config{usethreads}) {
        eval {
            require threads;
            require threads::shared;
        };
        if ($EVAL_ERROR) {
            print "[error]Failed to use threads!\n"; 
        }
    }
}

my $lock :shared;
my $status :shared = "unknown";

sub new {
    my ($class, $params) = @_;

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


    if ($config->{'share-dir'}) {
        $self->{htmlDir} = $config->{'share-dir'}.'/html';
    } elsif ($config->{'devlib'}) {
        $self->{htmlDir} = "./share/html";
    }
    if ($self->{htmlDir}) {
        $logger->debug("[RPC] static files are in ".$self->{htmlDir});
    } else {
        $logger->debug("[RPC] No static files directory");
    }


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
    my $targets = $self->{targets};
    my $config = $self->{config};
    my $htmlDir = $self->{htmlDir};

    if (!$r) {
        $c->close;
        undef($c);
        return;
    }


    $logger->debug("[RPC] $clientIp request ".$r->uri->path);
    if ($r->method eq 'GET' and $r->uri->path =~ /^\/$/) {
        my $nextContact = "";
        foreach my $target (@{$targets->{targets}}) {
            my $path = $target->{'path'};
            $path =~ s/(http|https)(:\/\/)(.*@)(.*)/$1$2$4/;
            my $timeString;
            if ($target->getNextRunDate() > 1) {
                $timeString = localtime($target->getNextRunDate());
            } else {
                $timeString = "now";
            }
            $nextContact .= "<li>".$target->{'type'}.', '.$path.": ".$timeString."</li>\n";
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
        $output =~ s/%%AGENT_VERSION%%/$config->{VERSION}/;
        if ($clientIp !~ /^127\./ || !$config->{'rpc-trust-localhost'}) {
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
    } elsif ($r->method eq 'GET' and $r->uri->path =~ /^\/now(\/|)(\S*)$/) {
        my $sentToken = $2;
        my $currentToken = $self->getToken();
        my $code;
        my $msg;
        $logger->debug("[RPC] 'now' catched");
        if (
            ($config->{'rpc-trust-localhost'} && $clientIp =~ /^127\./)
                or
            ($sentToken eq $currentToken)
        ) {
            $self->getToken('forceNewToken');
            $targets->resetNextRunDate();
            $code = 200;
            $msg = "Done."

        } else {

            $logger->debug("[RPC] bad token $sentToken != ".$currentToken);
            $code = 403;
            $msg = "Access denied. You are not using the 127.0.0.1 IP address to access the server or rpc-trust-localhost is off or the token is invalid."

        }

        my $r = HTTP::Response->new(
            $code,
            'OK',
            HTTP::Headers->new('Content-Type' => 'text/html'),
            "<html><head><title>FusionInventory-Agent</title></head><body>$msg <br /><a href='/'>Back</a></body><html>"
        );
        $c->send_response($r);

    } elsif ($r->method eq 'GET' and $r->uri->path =~ /^\/status$/) {
        #$c->send_status_line(200, $status)
        my $r = HTTP::Response->new(
            200,
            'OK',
            HTTP::Headers->new('Content-Type' => 'text/plain'),
           "status: ".$status
        );
        $c->send_response($r);

    } elsif ($r->method eq 'GET' and $r->uri->path =~
        /^\/(logo.png|site.css|favicon.ico)$/) {
        $c->send_file_response($htmlDir."/$1");
    } else {
        $logger->debug("[RPC] Err, 500");
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
   
    if ($config->{'rpc-ip'}) {
        $daemon = $self->{daemon} = HTTP::Daemon->new(
            LocalAddr => $config->{'rpc-ip'},
            LocalPort => $config->{'rpc-port'} || 62354,
            Reuse     => 1,
            Timeout   => 5
        );
    } else {
        $daemon = $self->{daemon} = HTTP::Daemon->new(
            LocalPort => $config->{'rpc-port'} || 62354,
            Reuse     => 1,
            Timeout   => 5
        );
    }
  
    if (!$daemon) {
        $logger->error("Failed to start the RPC server");
        return;
    } 
    $logger->info("RPC service started at: http://".
        ( $config->{'rpc-ip'} || "127.0.0.1" ).
        ":".
        $config->{'rpc-port'} || 62354);

# Since perl 5.10, threads::joinable is avalaible
    my $joinableAvalaible = eval 'defined(threads::joinable) && 1';

    while (1) {

        if ($joinableAvalaible) {
            no strict;
            # no strict to avoid with Perl 5.8
            # "threads::joinable" not allowed while "strict subs"
            my @threads = threads->list(threads::joinable);
            $_->join() foreach @threads;
        }

        # Limit the max number of running thread
        # On Windows, it's about 15MB per thread! We need to keep the
        # number of threads low.
        if (!$joinableAvalaible || threads->list() > 3) {
            foreach my $thread (threads->list()) {
                next if $thread->tid == 1; # This is me!
                $thread->join;
            };
        }
        my ($c, $socket) = $daemon->accept;
        next unless $socket;
        my(undef,$iaddr) = sockaddr_in($socket);
        my $clientIp = inet_ntoa($iaddr);
# HTTP::Daemon::get_request is not thread
# safe and must be called from the master thread
        my $r = $c->get_request;
        threads->create(\&handler, $self, $c, $r, $clientIp);
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
        $tmp .= pack("C",65+rand(24)) foreach (0..7);
        $myData->{token} = $tmp;

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
server. This server can only be used to wakeup the agent or download
OcsDeploy cached files. The server uses port 62354.

Every time the agent contact the server, it send a token, this token will
be needed to identify the server who want to awake an agent.

Once an agent is awake, it will contact the server as usual to know
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


=cut

