package Ocsinventory::Agent::Backend::Virtualization::SolarisZones;

use strict;

sub check { can_run('zoneadm') }

sub run {
  my $zone;
  my @zones;
  my $zoneid;
  my $zonename;
  my $zonestatus;
  my $pathroot;
  my $uuid;
  my $memory;
  my $memcap;
  my $vcpu;
  my $params = shift;
  my $inventory = $params->{inventory};
  @zones = `/usr/sbin/zoneadm list -p`;
  @zones = grep (!/global/,@zones);
  foreach $zone (@zones) {	
        ($zoneid,$zonename,$zonestatus,$pathroot,$uuid)=split(/:/,$zone);
	# 
	# Memory considerations depends on rcapd or project definitions
	# Little hack, I go directly in /etc/zones reading mcap physcap for each zone.
        $memcap=`grep mcap /etc/zones/$zonename.xml`;	
	$memcap=~ s/[^\d]+//g;
	$memory=$memcap/1024/1024;
	if (!$memcap){
	  $memory="";
	}
        	
	$vcpu = `/usr/sbin/psrinfo -p`; 
	chomp $vcpu;

        my $machine = {

            MEMORY => $memory,
            NAME => $zonename,
            UUID => $uuid,
            STATUS => $zonestatus,
            SUBSYSTEM => "Solaris Zones",
            VMTYPE => "Solaris Zones",
	    VMID => $zoneid,
            VCPU => $vcpu,

        };

        $inventory->addVirtualMachine($machine);

    }
}

1;
