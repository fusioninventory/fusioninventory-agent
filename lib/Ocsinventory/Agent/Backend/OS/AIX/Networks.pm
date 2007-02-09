package Ocsinventory::Agent::Backend::OS::AIX::Networks;

use Net::IP qw(:PROC);;
use strict;

sub check {
    `which lsvpd 2>&1`;	
	return if($? >> 8)!=0;
	`which lscfg 2>&1`;	
	return if($? >> 8)!=0;
	`which lsdev 2>&1`;	
	return if($? >> 8)!=0;
	`which lsattr 2>&1`;	
	return if($? >> 8)!=0;
	`which ifconfig 2>&1`;	
	return if($? >> 8)!=0;
	`which netstat 2>&1`;	
	($? >> 8)?0:1
}


sub run {
  my $params = shift;
  my $inventory = $params->{inventory};
	
  #Same way that dmidecode but with ifconfig
  my (@network, @dhcp, $gateway, $n, @interfaces, @lscfg, $chaine, @values, @lsattr, @ifcfg, $macaddr);

  my $description;
  my $ipaddress;
  my $ipgateway;
  my $ipmask;
  my $ipdhcp;
  my $ipsubnet;
  my $macaddr;
  my $status;
  my $type;

  # Inventaire des interfaces physiques
  my $i=0;  
  #lsvpd
  my @lsvpd = `lsvpd`;
  # Remove * (star) at the beginning of lines
  s/^\*// for (@lsvpd);
  
  for (@lsvpd){
    if (/^AX (ent\d+)/){
      (defined($n))?($n++):($n=0);
      $network[$n]{InterfaceName} = $1;
      $_=$lsvpd[$i-1];
      /^DS (.+)/;
      $network[$n]{type} = $1;
      $network[$n]{status} = 'Available';
      @lscfg=`lscfg -v -l $network[$n]{InterfaceName}`;
      for (@lscfg){
        if((/^\s*network address[.]*(\S+)/i) ) {
   		  $macaddr=$1;
   		  $macaddr=~ s/(.{2})(.{2})(.{2})(.{2})(.{2})(.{2})/$1:$2:$3:$4:$5:$6/;
   		  $network[$n]{HardwareAddress} = $macaddr;
   		}
      }
    }
  $i++;
  }
  # Inventaire des interfaces de type Etherchannel
  my @lsdev=`lsdev -Cc adapter -s pseudo -t ibm_ech`;
  my $etch;
  for (@lsdev){
    (defined($n))?($n++):($n=0);
    /^(ent\d*)\s*(\w*)\s*.*/;
    $network[$n]{InterfaceName} = $1;
    @lsattr=`export LANG=C;lsattr -EOl $1 -a 'adapter_names mode netaddr'`;
    for (@lsattr){
      if ( ! /^#/ ){
        /(.+):(.+):(.*)/;
        $etch="EtherChannel with : ".$1." (mode :".$2.", ping :".$3.")";
      }
    }
    $network[$n]{type}=$etch;
    $network[$n]{status} = 'Available';
    $network[$n]{HardwareAddress}= '00:00:00:00:00:00';
  }
  # AIX option -a obligatoire. On met à jour les interfaces actives, on utilise la tableaux @interfaces
  $n=undef;
  @ifcfg= split / /,`ifconfig -l`;
  for(@ifcfg){
    # AIX les interfaces sont des enX
    if(/^(en\S+)/i){
	  (defined($n))?($n++):($n=0); 
	  $interfaces[$n]{InterfaceName}=$1;
	  @lsattr=`lsattr -E -l $1`;
	  for (@lsattr){
        if(/^netaddr \s*([\d*\.?]*).*/i){ $interfaces[$n]{ip} = $1;}
        if(/^netmask\s*([\d*\.?]*).*/i){ $interfaces[$n]{netmask} = $1 ;}
        if(/^state\s*(\w*).*/i){ $interfaces[$n]{status} =  $1 }
      } 
    }
    if(/lo/){last;}
  }
  #Join to the other informations networks et interfaces
  for $n (0..$#network){
    for(0..$#interfaces){
      $chaine = $network[$n]{InterfaceName};
      # on a enregistré des entx et ifconfig donne des enx
      $chaine =~ s/t//g;
      
      #print $chaine." ".$interfaces[$_]{InterfaceName}."\n";
      if ($chaine eq $interfaces[$_]{InterfaceName}){
      	#print "IP =".$interfaces[$_]{ip}."and n=".$n."\n";
		$network[$n]{ip}=$interfaces[$_]{ip};
		$network[$n]{netmask}=$interfaces[$_]{netmask};
		$network[$n]{status}=$interfaces[$_]{status};
		
  	  }
    }
  }	

  #Looking for the gateway
  # AIX la cde route n'existe pas, on utilise netstat -rn
  for(`netstat -rn`){
    if(/^default\s+(\S+)/i){$gateway=$1;}
  }

  for(0..$#network){ 
	$description = $network[$_]{InterfaceName};
	$type = $network[$_]{type};
	$macaddr = $network[$_]{HardwareAddress};
	$status = $network[$_]{status};
	$ipaddress = $network[$_]{ip};
	$ipmask = $network[$_]{netmask};
	$ipdhcp = $network[$_]{dhcp};
	
    # Retrieving ip of the subnet for each interface
    if($ipmask and $ipaddress){
      # To retrieve the subnet for this iface
      my $binip = &ip_iptobin ($ipaddress ,4);
      my $binmask = &ip_iptobin ($ipmask ,4);
      my $subnet = $binip & $binmask;
      #$request{'CONTENT'}{'NETWORKS'}[$_]{'IPSUBNET'} = [ ip_bintoip($subnet,4) ] or warn(Error());
      #push @values, $request{'CONTENT'}{'NETWORKS'}[$n]{'IPSUBNET'}[0];
      $ipsubnet = ip_bintoip($subnet,4);
    }
    #print $description." ".$ipaddress."\n";
    $inventory->addNetworks({
	  DESCRIPTION => $description,
      IPADDRESS => $ipaddress,
      IPDHCP => $ipdhcp,
      IPGATEWAY => $ipgateway,
      IPMASK => $ipmask,
      IPSUBNET => $ipsubnet,
      MACADDR => $macaddr,
      STATUS => $status?"Up":"Down",
      TYPE => $type,
	});		
  }
}

1;
