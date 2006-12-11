package Ocsinventory::Agent::Network;
# TODO:
#  - set the correct deviceID and olddeviceID
use strict;
use warnings;

use LWP::UserAgent;
use Compress::Zlib;
use XML::Simple;
use Data::Dumper; # XXX DEBUG

sub new {
  my (undef, $params) = @_;

  my $self = {};

  print Dumper($params);
  $self->{params} = $params->{params};
  $self->{URI} = "http://".$self->{params}->{server}."/ocsinventory"; 

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
  my ($self, $params) = @_;

  print Dumper($params);
  warn unless $params->{message}->content();

  my $req = HTTP::Request->new(POST => $self->{URI});

  $req->header('Pragma' => 'no-cache', 'Content-type',
    'application/x-compress');

#  _debug($message, 'SENDING') if $debug and $debug>1; TODO

  my $message = Compress::Zlib::compress( $params->{message}->content() )  or die localtime()." =>
  failed to compress data with ZLib (prolog)\n";

  $req->content($message);

  my $res = $self->{ua}->request($req);

  # Checking if connected
  unless($res->is_success) {
    die localtime()." => Cannot establish communication : ".$res->status_line, "\n";
  }

  # stop or send in the http's body
  my $content = Compress::ZLib::uncompress($res->content)  or die localtime()." => Deflating problem (prolog)\n";

#  &_debug($content, 'RECEIVING') if $$debug and $debug>1;

  # Call modules prolog readers sub
#        _call_prolog_readers($content); TODO
  my $xml = XML::Simple::XMLin( $content, ForceArray => ['OPTION'] );

  # If -force tag
#  return(1) if $force; TODO What's force param goal?

  return if($xml->{RESPONSE} =~ /^$/);
  $xml->{RESPONSE};
}

1;
