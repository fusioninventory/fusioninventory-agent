###############################################################################
## OCSINVENTORY-NG 
## Copyleft Pascal DANEK 2005
## Web : http://ocsinventory.sourceforge.net
##
## This code is open source and may be copied and modified as long as the source
## code is always made freely available.
## Please refer to the General Public Licence http://www.gnu.org/ or Licence.txt
################################################################################
package Ocsinventory::Agent::Option::Update;

require Exporter;

use strict;

our @ISA = qw /Exporter/;

our @EXPORT = qw/
	update_start_handler
/;

use LWP::UserAgent;
use XML::Simple;
use Ocsinventory::Agent::Common qw /_get_path _debug _uncompress/;

my $ipdiscover_path = &_get_path("ipdiscover");
my $dmidecode_path = &_get_path("dmidecode");

my $current_context;
my $URI;
my $exe_path;
my $install_path;
my $debug;
my $DeviceID;
my $ServerName;
my $ua;

# Update or not
sub update_start_handler{

	my (@resp, $ASversion, $Aversion, $Dversion, $Iversion, $ISversion, $DSversion, @conf, $old, $message, $xml, $content, $ipflag, $dmiflag, $update, $AuthUpdate);
	
	$current_context = shift;
	
	$URI 		= $current_context->{'OCS_AGENT_SERVER_URI'};
	$exe_path	= $current_context->{'OCS_AGENT_EXE_PATH'};
	$install_path 	= $current_context->{'OCS_AGENT_INSTALL_PATH'};
	$debug 		= $current_context->{'OCS_AGENT_DEBUG_LEVEL'};
	$ServerName	= $current_context->{'OCS_AGENT_SERVER_NAME'};
	$DeviceID	= $current_context->{'OCS_AGENT_DEVICEID'};
	$Aversion	= $current_context->{'OCS_AGENT_VERSION'};
	
	
	# Configuration reading
	my $xmlconf = XML::Simple::XMLin($install_path."/ocsinv.conf", SuppressEmpty => undef);
	
	for(`$dmidecode_path|head -n1`, `$ipdiscover_path|head -n1`){
		if(/dmidecode\s+(\d+\.\d+)/i){
			$Dversion = $1;
		}elsif(/ipdiscover.+ver\. (\d+(?:\.\d+)?)/i){
			$Iversion = $1;
		}
	}
	
	$AuthUpdate = $xmlconf->{'UPDATE'};
		
	return unless($AuthUpdate and $Dversion and $Iversion and $Aversion);
	
	# Connect to server
	$ua = LWP::UserAgent->new(keep_alive => 1);
	$ua->agent('OCS-NG_linux_client_v'.$Aversion);
	
	my %request;
	
	# Sending our current version
	# Generation of xml message
	$request{'QUERY'}      = [ 'UPDATE' ];
	$request{'PLATFORM'}   = [ 'LINUX' ];
	$request{'AGENT'}      = [ $Aversion ];
	$request{'DMI'}        = [ $Dversion ];
	$request{'IPDISCOVER'} = [ $Iversion ];

	$message = XMLout( \%request, RootName => 'REQUEST', XMLDecl => '<?xml version="1.0" encoding="ISO-8859-1"?>',
	                  SuppressEmpty => undef );
	&_debug($message, 'SENDING') if $debug and $debug>1;

	# sending
	my $req = HTTP::Request->new(POST => $URI);
	$req->header('Pragma' => 'no-cache', 'Content-type' => 'application/x-compress', 'Connection' => 'Keep-alive');
	$message = Compress::Zlib::compress( $message )  or die localtime()." => Inflating problem (update)\n";
	$req->content($message);
	my $res = $ua->request($req);

	unless($res->is_success) {
		die localtime()." => Update failed : ".$res->status_line, "\n";
	}
	
	$content = _uncompress($res->content)  or die localtime()." => Inflating problem (update)\n";
	&_debug($content, 'RECEIVING') if $debug and $debug>1;
	$xml=XML::Simple::XMLin( $content , SuppressEmpty => undef);

	# The server tell us what files to ask
	if($xml->{RESPONSE} eq 'UPDATE'){
		$update=1;
	}elsif($xml->{RESPONSE} eq 'NO_UPDATE'){
		$update=0;
	}else{
		print localtime()." => Update response not readable : ".$content."\n";
		return;
	}
	# Update or not
	if($update){
		# Wich versions ?
		if(($xml->{AGENT})){$ASversion=$xml->{AGENT}}
		if(($xml->{DMI})){$DSversion=$xml->{DMI}}
		if(($xml->{IPDISCOVER})){$ISversion=$xml->{IPDISCOVER}}

		# OCS AGENT
		if(($ASversion)){
			die("Relaunch ocs agent. Quitting.\n\n") unless &_update_file($exe_path."/ocsinventory-client.pl", $ASversion);
		}

		# DMI AGENT
		if(($DSversion)){
			if($dmidecode_path){
				$dmiflag = 1 unless &_update_file($dmidecode_path, $DSversion);
			}
		}
			
		# IPDISCOVER AGENT
		if($ISversion){
			if($ipdiscover_path){
				$ipflag = 1 unless &_update_file($ipdiscover_path, $ISversion);
			}
		}
		
		# Writing new versions to .conf
		if($ipflag or $dmiflag){
		  #writing ocsinv.conf
		  my %xmlconf;
		  #
		  $xmlconf{'DEVICEID'}   = [ $DeviceID ];
		  $xmlconf{'OCSFSERVER'} = [ $ServerName ];
		  $xmlconf{'DMIVERSION'} = $dmiflag?[ $DSversion ]:[ $Dversion ];
		  $xmlconf{'IPDISCOVER_VERSION'} = $ipflag?[ $ISversion ]:[ $Iversion ];
		  $xmlconf{'UPDATE'}     = [ "1" ] if $AuthUpdate;
		  #
		  my $xml = XML::Simple::XMLout( \%xmlconf, RootName => 'CONF' );
		  #
		  open CONF, ">$install_path/ocsinv.conf";
		  print CONF $xml;
		  close CONF;
		}
	}else{
		print localtime()." => No update\n";
	}
	0;
}

sub _update_file{
	my $path = shift;
	my $name; 
	my $version = shift;
	my $content;
	my $fail;
	my $agent;
	
	#If it's a binary, we retrieve the filename
	if($path=~/ocsinventory-client.pl$/){
		$agent = 1;
		$name = 'agent';
	}else{
		($name) = $path=~/\/([^\/]+)$/;
	}
	
		
	print localtime()." => updating $name... to the version $version\n";
	
	# We ask file to server
	# We construct url on the fly to take some benefits about proxies
	
	&_debug("Asking for an updated file\nGET $URI/update/linux/$name/$version/", "SENDING") if $debug>1;
	
	my $res;
	my $req = HTTP::Request->new(GET => "$URI/update/linux/$name/$version/");
	unless($res = $ua->request($req)){
		warn localtime()." => Cannot get $name\n = $!";
		return(1);
	}
	
	unless($res->is_success){
		warn localtime()." => Update problem with $name\n";
		return(1);
	}else{
		unless($content = _uncompress($res->content)){
			warn localtime()." => Inflating problem (update)\n";
			return(1);
		}
		rename($path, $path.'.old');
		open FILE, ">".$path;
		# Writing the new data
		print FILE $content;
		close FILE;
		print localtime()." => $name updated\n";
		return(0);
	}
}
1;
