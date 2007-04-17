###############################################################################
## OCSINVENTORY-NG 
## Copyleft Pascal DANEK 2005
## Web : http://ocsinventory.sourceforge.net
##
## This code is open source and may be copied and modified as long as the source
## code is always made freely available.
## Please refer to the General Public Licence http://www.gnu.org/ or Licence.txt
################################################################################
package Ocsinventory::Agent::Option::Ipdiscover;

use strict;

require Exporter;

our @ISA = qw /Exporter/;

our @EXPORT = qw/
	ipdiscover_prolog_reader
	ipdiscover_inventory_handler
/;

use XML::Simple;
use Ocsinventory::Agent::Common qw /_get_path/;

sub ipdiscover_prolog_reader{
	my $current_context = shift;
	my $prolog = shift;
	$prolog = XML::Simple::XMLin( $prolog, ForceArray => ['OPTION'] );
	my $debug = $current_context->{'OCS_AGENT_DEBUG_LEVEL'};
	
	# Options management (ipdiscover only is implemented at this time)
	for my $option ( @{$prolog->{OPTION}} ){
		if( $option->{NAME} =~/ipdiscover/i){
				$current_context->{'OCS_OPTION_IPDISC_LAT'} = $option->{'PARAM'}->{'IPDISC_LAT'};
				$current_context->{'OCS_OPTION_IPDISCOVER'} = $option->{'PARAM'}->{'content'};
				print "IPDISCOVER: Getting latency from server ($current_context->{'OCS_OPTION_IPDISC_LAT'})\n" if $debug;
		}
	}

# Trying to find the request latency (order: 1-CMDL, 2-Config file, 3-Server
	if( $current_context->{'OCS_AGENT_CONFIG'}->{'IPDISC_LAT'} ){
		$current_context->{'OCS_OPTION_IPDISC_LAT'} = $current_context->{'OCS_AGENT_CONFIG'}->{'IPDISC_LAT'};
		print "IPDISCOVER: Using latency in config file($current_context->{'OCS_OPTION_IPDISC_LAT'})\n" if $debug;
	}
		
	for( @{ $current_context->{'OCS_AGENT_CMDL'} } ){
		if(/-ipdisc_lat=(\d+)/ ){# In ms
			$current_context->{'OCS_OPTION_IPDISC_LAT'} = $1;
			print "IPDISCOVER: Using latency from command line($current_context->{'OCS_OPTION_IPDISC_LAT'})\n" if $debug;
		}
	}
}

sub ipdiscover_inventory_handler{
	my $current_context = shift;
	my $request = shift;
	my $debug = $current_context->{'OCS_AGENT_DEBUG_LEVEL'};
	
	my $ipdiscover_path = &_get_path("ipdiscover");
	
	if( $current_context->{'OCS_OPTION_IPDISCOVER'} ){
		my ( $iface, $ipdiscover );
		
		my $ipdisc_lat = $current_context->{'OCS_OPTION_IPDISC_LAT'};
		
		if( $debug ){
			print "IPDISCOVER: scan ordered by server...\n";
			print "IPDISCOVER: Finding iface...";
		}
		
		#We get the iface name for the related subnet
		for(@{$request->{'CONTENT'}->{'NETWORKS'}}){
			if($_->{'IPSUBNET'}[0] eq $current_context->{'OCS_OPTION_IPDISCOVER'}){
				$iface = $_->{'DESCRIPTION'}[0];
				last;
			}
		}
		return if(!$iface or !$ipdiscover_path);
		
		#and we launch the ipdiscover
		print "$iface ...OK\nIPDISCOVER: Request latency : $ipdisc_lat\n" if $debug;
		print "IPDISCOVER: Latency set to 0. Will use the built in default\n" if( $debug and !$ipdisc_lat);
		
		$ipdiscover = `$ipdiscover_path`;
		
		if( $ipdiscover =~ /binary ver. (\d+)/ ){
			if( $1>3 ){
				$ipdiscover = `$ipdiscover_path $iface $ipdisc_lat`;
			}else{
				print "You should upgrade your ipdiscover binary (current version: $1)" if $debug;
				$ipdiscover = `$ipdiscover_path $iface`;
			}
		}
		else{
			return 1;
		}

		if($ipdiscover){
			$request->{'CONTENT'}->{'IPDISCOVER'} = XML::Simple::XMLin( $ipdiscover, ForceArray => 'H');
		}

	}
	else{
		print "IPDISCOVER: Invalid network($current_context->{'OCS_OPTION_IPDISCOVER'}). Abort..." if $debug;
	}
}
1;
