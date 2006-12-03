package Ocsinventory::Agent::Network;
# TODO:
#  - set the correct deviceID and olddeviceID
use strict;

use LWP::UserAgent;
use Compress::Zlib;
use XML::Simple;
use Data::Dumper; # XXX DEBUG

sub new {
  my (undef, %params) = @_;

  my $self = {};

  $self->{params} = \%params;
  $self->{URI} = "http://".$params{server}."/ocsinventory"; 

  # Connect to server
  $self->{ua} = LWP::UserAgent->new(keep_alive => 1);
  $self->{ua}->agent('OCS-NG_unified_unix_agent_v0.0.1');
  $self->{ua}->credentials( $params{server}, $params{realm}, $params{user} => $params{pwd} );

  bless $self;
}

sub needInventory { # Prolog
  my $self = shift;
  my %params = %{$self->{params}};

  my %request;
  $request{'QUERY'} = ['PROLOG'];
  # $request{'DEVICEID'} = [$DeviceID]; TODO set the correct device ID

  my $message=XMLout( \%request, RootName => 'REQUEST', XMLDecl =>
    '<?xml version="1.0" encoding="ISO-8859-1"?>',
    NoSort => 1, SuppressEmpty => undef );

  #####
  #HTTP
  #####

  my $req = HTTP::Request->new(POST => $self->{URI});

  $req->header('Pragma' => 'no-cache', 'Content-type',
    'application/x-compress');

#  _debug($message, 'SENDING') if $debug and $debug>1; TODO

  $message = Compress::Zlib::compress( $message )  or die localtime()." =>
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

  if($xml->{RESPONSE} eq 'STOP'){
    print localtime()." => Inventory not generated, command by server...\n";
    return(0);
  }elsif($xml->{RESPONSE} eq 'SEND'){
    return(1);
#       }elsif($xml->{RESPONSE} eq 'OTHER'){
#               print localtime()." => Inventory not generated, command by server...\n";
#               return(0);
  }else{
    die("Server response unreadeable. Abort...\n");
  }

}


sub sendInventory {
  my ($self, $inventory) = @_;
  my %params = %{$self->{params}};

  # Query type is INVENTORY
  my %request;
  $request{'QUERY'} = ['INVENTORY'];

  # Writing DeviceID
  #$request{'DEVICEID'} = [ $DeviceID ]; TODO

  # Writing old deviceid if needed
  #$request{'CONTENT'}{'OLD_DEVICEID'} = [ $old_deviceid ] if $old_deviceid; TODO

  my $message = XMLout( \%request, RootName => 'REQUEST', XMLDecl => '<?xml version="1.0" encoding="ISO-8859-1"?>', NoSort => 1, SuppressEmpty => undef );

}



1;
