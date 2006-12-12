package Ocsinventory::Agent::Network;
# TODO:
#  - set the correct deviceID and olddeviceID
use strict;
use warnings;

use LWP::UserAgent;
use XML::Simple;
#use Compress::Zlib;
use Data::Dumper; # XXX DEBUG

use Ocsinventory::Compress;

sub new {
  my (undef, $params) = @_;

  my $self = {};

  $self->{params} = $params->{params};
  my $logger = $self->{logger} = $params->{logger};
  $self->{URI} = "http://".$self->{params}->{server}."/ocsinventory"; 

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

  $logger->log ({level => 'debug', message => 'sending XML'});

  print Dumper($args);
  my $message = $compress->compress( $args->{message}->content() );
  if (!$message) {
    $logger->log({level => 'fault', message => 'failed to compress data with ZLib'});
  }

  $req->content($message);

  my $res = $self->{ua}->request($req);

  # Checking if connected
  if(!$res->is_success) {
    $logger->log ({
	level => 'fault',
	message => 'Cannot establish communication : '.$res->status_line
      });
  }

  # stop or send in the http's body
  my $content = $compress->uncompress($res->content);
  if (!$content) {
    $logger->log ({
	level => 'fault',
	message => "Deflating problem",
      });
  }

  my $xml = XML::Simple::XMLin( $content, ForceArray => ['OPTION'] );

  return if($xml->{RESPONSE} =~ /^$/);
  $xml->{RESPONSE};
}

1;
