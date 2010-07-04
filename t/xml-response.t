#!/usr/bin/perl
package Logger;
sub new {
    my $self = {};
    bless $self;
}
sub debug {}
1;
use strict;
use warnings;
use Test::More;
use FindBin;
use FusionInventory::Agent::XML::Response;
my $test = { 
'OPTION' => [
                      {
                        'NAME' => 'REGISTRY',
                        'PARAM' => [
                                   {
                                     'NAME' => 'blablabla',
                                     'content' => '*',
                                     'REGTREE' => '0',
                                     'REGKEY' => 'SOFTWARE/Mozilla'
                                   }
                                 ]
                      },
                      {
                        'NAME' => 'DOWNLOAD',
                        'PARAM' => [
                                   {
                                     'FRAG_LATENCY' => '10',
                                     'TIMEOUT' => '30',
                                     'PERIOD_LATENCY' => '1',
                                     'ON' => '1',
                                     'TYPE' => 'CONF',
                                     'PERIOD_LENGTH' => '10',
                                     'CYCLE_LATENCY' => '6'
                                   }
                                 ]
                      }
                    ],
          'RESPONSE' => 'SEND',
          'PROLOG_FREQ' => '1'

};


plan tests => 1;
my $logger = Logger->new ();
my $response = FusionInventory::Agent::XML::Response->new({
    content => '<REPLY>                                                                                                                                                                                                            
  <OPTION>                                                                                                                                                                                                         
    <NAME>REGISTRY</NAME>                                                                                                                                                                                          
    <PARAM NAME="blablabla" REGKEY="SOFTWARE/Mozilla" REGTREE="0">*</PARAM>                                                                                                                                        
  </OPTION>                                                                                                                                                                                                        
  <OPTION>                                                                                                                                                                                                         
    <NAME>DOWNLOAD</NAME>                                                                                                                                                                                          
    <PARAM FRAG_LATENCY="10" PERIOD_LATENCY="1" TIMEOUT="30" ON="1" TYPE="CONF" CYCLE_LATENCY="6" PERIOD_LENGTH="10" />                                                                                            
  </OPTION>                                                                                                                                                                                                        
  <RESPONSE>SEND</RESPONSE>                                                                                                                                                                                        
  <PROLOG_FREQ>1</PROLOG_FREQ>                                                                                                                                                                           
</REPLY>'
,
    logger => $logger
    });

my $href = $response->getParsedContent();
is_deeply($href, $test, "prolog");
