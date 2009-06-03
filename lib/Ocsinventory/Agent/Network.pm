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
  $self->{compatibilityLayer} = $params->{compatibilityLayer}; 
  my $logger = $self->{logger} = $params->{logger};
use Data::Dumper;
  $self->{config} = $params->{config};
  my $uaserver;
  if ($self->{config}->{server} =~ /^http(|s):\/\//) {
      $self->{URI} = $self->{config}->{server};
      $uaserver = $self->{config}->{server};
      $uaserver =~ s/^http(|s):\/\///;
      $uaserver =~ s/\/.*//;
      if ($uaserver !~ /:\d+$/) {
          $uaserver .= ':443' if $self->{config}->{server} =~ /^https:/;
          $uaserver .= ':80' if $self->{config}->{server} =~ /^http:/;
      }
  } else {
      $self->{URI} = "http://".$self->{config}->{server}.$self->{config}->{remotedir};
      $uaserver = $self->{config}->{server};
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
  my $compatibilityLayer = $self->{compatibilityLayer};
  my $compress = $self->{compress};
  my $message = $args->{message};
  my ($msgtype) = ref($message) =~ /::(\w+)$/; # Inventory or Prolog

  my $req = HTTP::Request->new(POST => $self->{URI});

  $req->header('Pragma' => 'no-cache', 'Content-type',
    'application/x-compress');

  $logger->debug ("sending XML");

  #############
  ### Compatibility with linux_agent modules
  if ($msgtype eq "Inventory") {
    $compatibilityLayer->hook({name => 'inventory_handler'}, $message->{h});
  } elsif ($msgtype eq "Prolog") {
    $compatibilityLayer->hook({name => 'prolog_writers'}, $message->{h});
  }
  #############

  $logger->debug ("sending: ".$message->getContent());

  my $compressed = $compress->compress( $message->getContent() );

  if (!$compressed) {
    $logger->error ('failed to compress data');
    return;
  }

  $req->content($compressed);

  my $res = $self->{ua}->request($req);

  # Checking if connected
  if(!$res->is_success) {
    $logger->error ('Cannot establish communication : '.$res->status_line);
    return;
  }

  # stop or send in the http's body

  my $content = $compress->uncompress($res->content);

  if (!$content) {
    $logger->error ("Deflating problem");
    return;
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

     accountconfig => $self->{accountconfig},
     accountinfo => $self->{accountinfo},
     content => $content,
     logger => $logger,
     origmsg => $message,
     config => $self->{config}

      });


  ### Compatibility with linux_agent modules
  if ($msgtype eq "Prolog") {
    $compatibilityLayer->hook({name => 'prolog_reader'}, $response->getRawXML());
  }
  #############

  return $response;
}

1;
