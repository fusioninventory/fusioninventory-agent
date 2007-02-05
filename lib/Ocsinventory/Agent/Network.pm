package Ocsinventory::Agent::Network;
# TODO:
#  - set the correct deviceID and olddeviceID
use strict;
use warnings;

use LWP::UserAgent;
use Data::Dumper; # XXX

use UNIVERSAL qw( isa ) ;

use Ocsinventory::Compress;

sub new {
  my (undef, $params) = @_;

  my $self = {};

  $self->{compatibilityLayer} = $params->{compatibilityLayer}; 
  my $logger = $self->{logger} = $params->{logger};
  $self->{params} = $params->{params};
  $self->{respHandlers} = $params->{respHandlers}; 
  $self->{URI} = "http://".$self->{params}->{server}.$self->{params}->{remotedir};


  $self->{compress} = new Ocsinventory::Compress ({logger => $logger});
  # Connect to server
  $self->{ua} = LWP::UserAgent->new(keep_alive => 1);
  $self->{ua}->agent('OCS-NG_unified_unix_agent_v'.$self->{params}->{version});
  $self->{ua}->credentials(
    $self->{params}->{server},
    $self->{params}->{realm},
    $self->{params}->{user},
    $self->{params}->{pwd}
  );

  bless $self;
}

sub send {
  my ($self, $args) = @_;

  my $logger = $self->{logger};
  my $compatibilityLayer = $self->{compatibilityLayer};
  my $compress = $self->{compress};
  my $message = $args->{message};

  my $req = HTTP::Request->new(POST => $self->{URI});

  $req->header('Pragma' => 'no-cache', 'Content-type',
    'application/x-compress');

  $logger->debug ("sending XML");


  #############
  ### Compatibility with linux_agent modules
  if (isa $message, "Ocsinventory::Agent::XML::Inventory") {
    $compatibilityLayer->hook({name => 'inventory_handler'}, $message->{h});
  } elsif (isa $message, "Ocsinventory::Agent::XML::Prolog") {
    $compatibilityLayer->hook({name => 'prolog_writers'}, $message->{h});

  }
  #############

  my $compressed = $compress->compress( $message->content() );
  if (!$compressed) {
    $logger->fault ('failed to compress data with Compress::ZLib');
  }

  $req->content($compressed);

  my $res = $self->{ua}->request($req);

  # Checking if connected
  if(!$res->is_success) {
    $logger->fault ('Cannot establish communication : '.$res->status_line);
  }

  # stop or send in the http's body
  my $content = $compress->uncompress($res->content);
  if (!$content) {
    $logger->fault ("Deflating problem");
  }

  my $ret = XML::Simple::XMLin( $content, ForceArray => ['OPTION','PARAM'] );

  $logger->debug("=BEGIN=SERVER RET======");
  $logger->debug(Dumper($ret));
  $logger->debug("=END=SERVER RET======");

  ### Compatibility with linux_agent modules
  if (isa $message, "Ocsinventory::Agent::XML::Prolog") {
    $compatibilityLayer->hook({name => 'prolog_read'}, $ret);

  }
  #############

  # for every key returned in the return I try to execute the Handlers 
  foreach (keys %$ret) {
    next if $_ =~ /^RESPONSE$/; # response is returned directly
    if (defined $self->{respHandlers}->{$_}) {
      $self->{respHandlers}->{$_}($ret->{$_});
    } else {
    $logger->debug ('No respHandlers avalaible for '.$_.". The data ".
      "returned by server in this hash will be lost.");
    }
  }

  return $ret;
}

1;
