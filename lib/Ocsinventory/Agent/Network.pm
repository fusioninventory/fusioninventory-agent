package Ocsinventory::Agent::Network;
# TODO:
#  - set the correct deviceID and olddeviceID
use strict;
use warnings;

use LWP::UserAgent;

use Ocsinventory::Compress;

sub new {
  my (undef, $params) = @_;

  my $self = {};
  
  $self->{accountconfig} = $params->{accountconfig}; 
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
  }


  $self->{compress} = new Ocsinventory::Compress ({logger => $logger});
  # Connect to server
  $self->{ua} = LWP::UserAgent->new(keep_alive => 1);
  if ($self->{config}->{proxy}) {
    $self->{ua}->proxy(['http', 'https'], $self->{config}->{proxy});
  }  else {
    $self->{ua}->env_proxy;
  }
  my $version = 'OCS-NG_unified_unix_agent_v';
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
  
  my $compress = $self->{compress};
  my $message = $args->{message};
  my ($msgtype) = ref($message) =~ /::(\w+)$/; # Inventory or Prolog

  my $req = HTTP::Request->new(POST => $self->{URI});

  $req->header('Pragma' => 'no-cache', 'Content-type',
    'application/x-compress');

  # Check server name against provided SSL certificate
  if ( $self->{URI} =~ /^https:\/\/([^\/]+).*$/ ) {
    my $cn = $1;
    $cn =~ s/([\-\.])/\\$1/g;
    $req->header('If-SSL-Cert-Subject' => '/CN='.$cn);
    $logger->debug ("Validating Cert CN=".$cn);
  }

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
  my $tmp = "Ocsinventory::Agent::XML::Response::".$msgtype;
  eval "require $tmp";
  if ($@) {
      $logger->error ("Can't load response module $tmp: $@");
  }
  $tmp->import();
  my $response = $tmp->new ({

     accountconfig => $target->{accountconfig},
     accountinfo => $target->{accountinfo},
     content => $content,
     logger => $logger,
     origmsg => $message,
     target => $target,
     config => $self->{config}

      });

  return $response;
}

1;
