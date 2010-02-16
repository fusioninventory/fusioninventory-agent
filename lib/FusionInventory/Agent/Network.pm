package FusionInventory::Agent::Network;
# TODO:
#  - set the correct deviceID and olddeviceID
use strict;
use warnings;

use LWP::UserAgent;
use LWP::Simple qw ($ua getstore is_success);

use FusionInventory::Compress;

sub new {
  my (undef, $params) = @_;

  my $self = {};
  
  $self->{accountinfo} = $params->{accountinfo}; 

  my $config = $self->{config} = $params->{config};
  my $logger = $self->{logger} = $params->{logger};
  my $target = $self->{target} = $params->{target};
  
  $logger->fault('$target not initialised') unless $target;
  $logger->fault('$config not initialised') unless $config;

  my $uaserver;
  if ($target->{path} =~ /^http(|s):\/\//) {
      $uaserver = $self->{URI} = $target->{path};
      $uaserver =~ s/^http(|s):\/\///;
      $uaserver =~ s/\/.*//;
      if ($uaserver !~ /:\d+$/) {
          $uaserver .= ':443' if $self->{config}->{server} =~ /^https:/;
          $uaserver .= ':80' if $self->{config}->{server} =~ /^http:/;
      }
  } else {
    $logger->fault("Failed to parse URI: ".$target->{path});
  }


  $self->{compress} = new FusionInventory::Compress ({logger => $logger});
  # Connect to server
  $self->{ua} = LWP::UserAgent->new(keep_alive => 1);
  if ($self->{config}->{proxy}) {
    $self->{ua}->proxy(['http', 'https'], $self->{config}->{proxy});
  }  else {
    $self->{ua}->env_proxy;
  }
  my $version = 'FusionInventory-Agent_v';
  $version .= exists ($self->{config}->{VERSION})?$self->{config}->{VERSION}:'';
  $self->{ua}->agent($version);
    $self->{config}->{user}.",".
    $self->{config}->{password}."";
  $self->{ua}->credentials(
    $uaserver, # server:port, port is needed 
    $self->{config}->{realm},
    $self->{config}->{user},
    $self->{config}->{password}
  );

  bless $self;
}


sub send {
  my ($self, $args) = @_;

  my $logger = $self->{logger};
  my $target = $self->{target};
  my $config = $self->{config};
  
  my $compress = $self->{compress};
  my $message = $args->{message};
  my ($msgtype) = ref($message) =~ /::(\w+)$/; # Inventory or Prolog

  my $req = HTTP::Request->new(POST => $self->{URI});

  $req->header('Pragma' => 'no-cache', 'Content-type',
    'application/x-compress');

  $self->loadNetSSLGlueLWP() if $self->{URI} =~ /^https/i;

  $logger->debug ("sending XML");

  # Print the XMLs in the debug output
  #$logger->debug ("sending: ".$message->getContent());

  my $compressed = $compress->compress( $message->getContent() );

  if (!$compressed) {
    $logger->error ('failed to compress data');
    return;
  }

  $req->content($compressed);

  my $res = $self->{ua}->request($req);

  # Checking if connected
  if(!$res->is_success) {
    $logger->error ('Cannot establish communication with `'.
        $self->{URI}.': '.
        $res->status_line.'`');
    return;
  }

  # stop or send in the http's body

  my $content = '';

  if ($res->content) {
    $content = $compress->uncompress($res->content);
    if (!$content) {
        $logger->error ("Deflating problem");
        return;
    }
  }

  # AutoLoad the proper response object
  my $msgType = ref($message); # The package name of the message object
  my $tmp = "FusionInventory::Agent::XML::Response::".$msgtype;
  eval "require $tmp";
  if ($@) {
      $logger->error ("Can't load response module $tmp: $@");
  }
  $tmp->import();
  my $response = $tmp->new ({

     accountinfo => $target->{accountinfo},
     content => $content,
     logger => $logger,
     origmsg => $message,
     target => $target,
     config => $self->{config}

      });

  return $response;
}

# LWP doesn't support SSL cert check and
# Net::SSLGlue::LWP is a workaround to fix that
sub loadNetSSLGlueLWP {
  my ($self, $args) = @_;

  my $logger = $self->{logger};
  my $config = $self->{config};


  if ($config->{noSslCheck}) {
      $logger->info( "--no-ssl-check parameter "
          . "found. Don't check server identity!!!" );
      return;
  }

  my $parameter;
  if ($config->{caCertFile}) {
    if (!-f $config->{caCertFile} || !-l $config->{caCertFile}) {
        $logger->fault("--ca-cert-file doesn't existe ".
            "`".$config->{caCertFile}."'");
    }

    $parameter = " SSL_ca_file=".$config->{caCertFile};
  } elsif ($config->{caCertDir}) {
    if (!-d $config->{caCertDir}) {
        $logger->fault("--ca-cert-dir doesn't existe ".
            "`".$config->{caCertDir}."'");
    }

    $parameter = " SSL_ca_path=".$config->{caCertDir};
  }

  eval 'use Net::SSLGlue::LWP SSL_ca_path => \'/etc/ssl/certs\';';
  if ($@) {
      $logger->fault(
          "Failed to load Net::SSLGlue::LWP, to ".
         "validate the server SSL cert. If you want ".
         "to ignore this message and want to ignore SSL ".
         "verification, you can use the ".
         "--no-ssl-check parameter."
      );
  }

} 

sub getStore {
  my ($self, $args) = @_;

  my $source = $args->{source};
  my $target = $args->{target};
  my $timeout = $args->{timeout};

  $ua->timeout($timeout) if $timeout;

  $self->loadNetSSLGlueLWP() if $source =~ /^https/i;

  my $rc = LWP::Simple::getstore( $source, $target );

}

sub get {
  my ($self, $args) = @_;

  my $source = $args->{source};
  my $timeout = $args->{timeout};
            
  $ua->timeout($timeout) if $timeout;

  $self->loadNetSSLGlueLWP() if $source =~ /^https/i;

  return LWP::Simple::get($source);

}

sub isSuccess {
  my ($self, $args) = @_;

  my $code = $args->{code};

  return is_success($code);

}

1;
