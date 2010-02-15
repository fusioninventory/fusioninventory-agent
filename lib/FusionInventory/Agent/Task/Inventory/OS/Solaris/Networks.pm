package FusionInventory::Agent::Task::Inventory::OS::Solaris::Networks;


#ce5: flags=1000843<UP,BROADCAST,RUNNING,MULTICAST,IPv4> mtu 1500 index 3
#        inet 55.37.101.171 netmask fffffc00 broadcast 55.37.103.255
#        ether 0:3:ba:24:9b:bf

#aggr40001:2: flags=201000843<UP,BROADCAST,RUNNING,MULTICAST,IPv4,CoS> mtu 1500 index 3
#        inet 55.37.101.172 netmask ffffff00 broadcast 223.0.146.255


use strict;

sub isInventoryEnabled {
  can_run("ifconfig") && can_run("netstat") && can_load ("Net::IP qw(:PROC)")
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $description;
    my $ipaddress;
    my $ipgateway;
    my $ipmask;
    my $ipsubnet;
    my $macaddr;
    my $status;
    my $type;  
    my $zone;
    my $OSLevel;
    my $i = 0;

    $OSLevel=`uname -r`;


    if ( $OSLevel =~ /5.8/ ){
        $zone = "global";
    }else{
        foreach (`zoneadm list -p`){
            $zone=$1 if /^0:([a-z]+):.*$/;
        } 
    }

    foreach (`netstat -rn`){
        $ipgateway=$1 if /^default\s+(\S+)/i;
    }
    #print "Nom :".$zone."*************************\n";
    if ($zone){  
        foreach (`ifconfig -a`){			
            $description = $1 if /^(\S+):/; # Interface name			
            $ipaddress = $1 if /inet\s+(\S+)/i;
            $ipmask = $1 if /\S*netmask\s+(\S+)/i; 
            $type = $1 if /groupname\s+(\S+)/i;	
            #$type = $1 if /zone\s+(\S+)/i;
            #Debug 				
            if (/ether\s+(\S+)/i) {
                # See
                # https://sourceforge.net/tracker/?func=detail&atid=487492&aid=1819948&group_id=58373
                $macaddr = sprintf "%02x:%02x:%02x:%02x:%02x:%02x" ,
                map hex, split /\:/, $1;
            }
            $status = 1 if /<UP,/;      
            #print "DES:".$description."-".$macaddr."\n";
            if(($description && $macaddr)){  
                #HEX TO DEC TO BIN TO IP   	
                $ipmask = hex($ipmask);
                $ipmask = sprintf("%d", $ipmask);
                $ipmask = unpack("B*", pack("N", $ipmask));
                $ipmask = ip_bintoip($ipmask,4);     

                my $binip = &ip_iptobin ($ipaddress ,4);
                my $binmask = &ip_iptobin ($ipmask ,4);
                my $binsubnet = $binip & $binmask;
                $ipsubnet = ip_bintoip($binsubnet,4); 
                $inventory->addNetwork({
                        DESCRIPTION => $description,
                        IPADDRESS => $ipaddress,	  
                        IPGATEWAY => $ipgateway,
                        IPMASK => $ipmask,
                        IPSUBNET => $ipsubnet,
                        MACADDR => $macaddr,
                        STATUS => $status?"Up":"Down",
                        TYPE => $type,
                    });

                $ipaddress = $description = $macaddr = $status =  $type = $ipmask = undef;
            }
        }		  
        $ipaddress = $description = $macaddr = $status =  $type = $ipmask = undef;

        foreach (`ifconfig -a`){				
            $description = $1.":".$2 if /^(\S+):(\S+):/; # Interface name zone or virtual					
            if ($description){					
                $ipaddress = $1 if /inet\s+(\S+)/i;
                $ipmask = $1 if /\S*netmask\s+(\S+)/i; 					
                $status = 1 if /<UP,/;
                $type = $1 if /zone\s+(\S+)/i;					
            }
            #Debug 	
            if(($description &&  $ipmask) ){   
                #if(($description && $macaddr)){  
                #HEX TO DEC TO BIN TO IP   	
                $ipmask = hex($ipmask);
                $ipmask = sprintf("%d", $ipmask);
                $ipmask = unpack("B*", pack("N", $ipmask));
                $ipmask = ip_bintoip($ipmask,4);     
                my $binip = &ip_iptobin ($ipaddress ,4);
                my $binmask = &ip_iptobin ($ipmask ,4);
                my $binsubnet = $binip & $binmask;
                $ipsubnet = ip_bintoip($binsubnet,4);     
                #print "INFO2 : ".$description."_". $ipaddress."_".$ipmask."_".$macaddr."\n";	
                $inventory->addNetwork({
                        DESCRIPTION => $description,
                        IPADDRESS => $ipaddress,	  
                        IPGATEWAY => $ipgateway,
                        IPMASK => $ipmask,
                        IPSUBNET => $ipsubnet,
                        MACADDR => $macaddr,
                        STATUS => $status?"Up":"Down",
                        TYPE => $type,
                    });

                $ipaddress = $description = $macaddr = $status =  $type = $ipmask = undef;
            }
        }	

        $ipaddress = $description = $macaddr = $status =  $type = $ipmask = undef;

        if ( $OSLevel =~ /5.10/ ){ 
            foreach (`dladm show-aggr`){	
                next if /device/; 
                next if /key/;
                $description = $1 if /(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/; # aggrega 	
                $macaddr = $2 if /(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/;			
                #if ($macaddr) {
                #	  $macaddr = sprintf "%02x:%02x:%02x:%02x:%02x:%02x" ,
                #	  map hex, split /\:/, $1;
                #}			
                #$status = $6 if /(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/;			
                $status = 1 if /up/;

                $inventory->addNetwork({
                        DESCRIPTION => $description,
                        IPADDRESS => $ipaddress,	  
                        IPGATEWAY => $ipgateway,
                        IPMASK => $ipmask,
                        IPSUBNET => $ipsubnet,
                        MACADDR => $macaddr,
                        STATUS => $status?"Up":"Down",
                        TYPE => $type,
                    });	  
            }

            $ipgateway = $ipsubnet = $ipaddress = $description = $macaddr = $status =  $type = $ipmask = undef;

            my $inc = 1 ;
            foreach (`/usr/sbin/fcinfo hba-port`){			    
                $description = "HBA_Port_WWN_".$inc if /HBA Port WWN:\s+(\S+)/;
                $description = $description." ".$1 if /OS Device Name:\s+(\S+)/;
                $macaddr = $1 if /HBA Port WWN:\s+(\S+)/;				
                $type = $1 if /Manufacturer:\s+(.*)$/;
                $type = $type." ".$1 if /Model:\s+(.*)$/;				
                $type = $type." ".$1 if /Firmware Version:\s+(.*)$/;
                $status = 1 if /online/;

                if(($description &&  $status) ){ 
                    print "WWN :".$description."-".$status."-".$type."\n";
                    $inventory->addNetwork({
                            DESCRIPTION => $description,
                            IPADDRESS => $ipaddress,	  
                            IPGATEWAY => $ipgateway,
                            IPMASK => $ipmask,
                            IPSUBNET => $ipsubnet,
                            MACADDR => $macaddr,
                            STATUS => $status?"Up":"Down",
                            TYPE => $type,
                        });	
                    $inc ++ ;

                    $ipgateway = $ipsubnet = $ipaddress = $description = $macaddr = $status =  $type = $ipmask = undef;
                }
            }
        }

    }else {
        foreach (`ifconfig -a`){
            $description = $1.":".$2 if /^(\S+):(\S+):/; # Interface name zone    
            $ipaddress = $1 if /inet\s+(\S+)/i;
            $ipmask = $1 if /\S*netmask\s+(\S+)/i;
            $type = $1 if /zone\s+(\S+)/i;	
            #Debug 	
            if (/ether\s+(\S+)/i) {
                # See
                # https://sourceforge.net/tracker/?func=detail&atid=487492&aid=1819948&group_id=58373
                $macaddr = sprintf "%02x:%02x:%02x:%02x:%02x:%02x" ,
                map hex, split /\:/, $1;
            }
            $status = 1 if /<UP,/;
            if(($description &&  $ipaddress) ){   
                #if(($description && $macaddr)){  zo 
                #HEX TO DEC TO BIN TO IP   	
                $ipmask = hex($ipmask);
                $ipmask = sprintf("%d", $ipmask);
                $ipmask = unpack("B*", pack("N", $ipmask));
                $ipmask = ip_bintoip($ipmask,4);     
                #print $ipmask."\n";

                my $binip = &ip_iptobin ($ipaddress ,4);
                my $binmask = &ip_iptobin ($ipmask ,4);
                my $binsubnet = $binip & $binmask;
                $ipsubnet = ip_bintoip($binsubnet,4);     

                $inventory->addNetwork({
                        DESCRIPTION => $description,
                        IPADDRESS => $ipaddress,	  
                        IPGATEWAY => $ipgateway,
                        IPMASK => $ipmask,
                        IPSUBNET => $ipsubnet,
                        MACADDR => $macaddr,
                        STATUS => $status?"Up":"Down",
                        TYPE => $type,
                    });

                $ipaddress = $description = $macaddr = $status =  $type = undef;
            }
        }	

    }
}

1;
