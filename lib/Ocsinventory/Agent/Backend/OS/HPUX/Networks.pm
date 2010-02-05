package Ocsinventory::Agent::Backend::OS::HPUX::Networks;

sub check  { can_load("Net::IP qw(:PROC)"); }

sub run {
   my $params = shift;
   my $inventory = $params->{inventory};

   my $name;
   my $lanid;

   my $ipmask;
   my $ipgateway;
   my $status;
   my $macaddr;
   my $speed;
   my $type;
   my $ipsubnet;
   my $description;
   my $ipaddress;

   my $binip;
   my $binmask;
   my $binsubnet;

   for ( `lanscan -iap`) {
     # Reinit variable
     $name="";
     $lanid="";
     $ipmask="";
     $ipgateway="";
     $status="";
     $macaddr="";
     $speed="";
     $type="";
     $ipsubnet="";
     $description="";
     $ipaddress="";

     if ( /^(\S+)\s(\S+)\s(\S+)\s+(\S+)/) {
       $name=$2;
       $macaddr=$1;
       $lanid=$4;

       #print "name $name macaddr $macaddr lanid $lanid\n";
       for ( `lanadmin -g $lanid` ) {
	 if (/Type.+=\s(.+)/) { $type = $1; };
	 if (/Description\s+=\s(.+)/) { $description = $1; };
	 if (/Speed.+=\s(\d+)/) {
            $speed = $1;

            unless ( $speed <= 1000000 ) { # in old version speed was given in Mbps
                                           # we want speed in Mbps
                                                $speed = $1/1000000;
					      }
				      };
	 if (/Operation Status.+=\s(.+)/) { $status = $1; };

       }; # for lanadmin
       #print "name $name macaddr $macaddr lanid $lanid speed $speed status $status \n";
       for ( `ifconfig $name 2> /dev/null` ) {
	 if ( /inet\s(\S+)\snetmask\s(\S+)\s/ ) {
            $ipaddress=$1;
	    $ipmask=$2;
	    if ($ipmask =~ /(..)(..)(..)(..)/) {
               $ipmask=sprintf ("%i.%i.%i.%i",hex($1),hex($2),hex($3),hex($4));
	    }

	 };   
       }; # For ifconfig
       $binip = ip_iptobin ($ipaddress ,4);
       $binmask = ip_iptobin ($ipmask ,4);
       $binsubnet = $binip & $binmask;
       $ipsubnet = ip_bintoip($binsubnet,4);

      $inventory->addNetworks({

          DESCRIPTION => $description,
          IPADDRESS => $ipaddress,
          IPGATEWAY => $ipgateway,
          IPMASK => $ipmask,
          IPSUBNET => $ipsubnet,
          MACADDR => $macaddr,
          STATUS => $status,
          SPEED => $speed,
          TYPE => $type,
			     });

     }; # If
   }; # For lanscan
 }

1;
