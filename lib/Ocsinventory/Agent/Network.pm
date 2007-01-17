package Ocsinventory::Agent::Network;
# TODO:
#  - set the correct deviceID and olddeviceID
use strict;
use warnings;

use LWP::UserAgent;
use Data::Dumper; # XXX

use Ocsinventory::Compress;

sub new {
  my (undef, $params) = @_;

  my $self = {};

  $self->{params} = $params->{params};
  my $logger = $self->{logger} = $params->{logger};
  $self->{URI} = "http://".$self->{params}->{server}."/ocsinventory";
  $self->{respHandlers} = $params->{respHandlers}; 


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
  my $compress = $self->{compress};

  my $req = HTTP::Request->new(POST => $self->{URI});

  $req->header('Pragma' => 'no-cache', 'Content-type',
    'application/x-compress');

  $logger->debug ("sending XML");

  my $message = $compress->compress( $args->{message}->content() );
  if (!$message) {
    $logger->fault ('failed to compress data with Compress::ZLib');
  }

  $req->content($message);

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

  my $ret = XML::Simple::XMLin( $content, ForceArray => ['OPTION'] );

  print "=BEGIN=SERVER RET======\n";
  print Dumper($ret);
  print "=END=SERVER RET========\n";
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

  return $ret->{RESPONSE};
}

1;
