package Ocsinventory::Agent::Backend::Virtualization::SolarisZones;

use strict;

sub check { can_run('zoneadm') }

sub run {
  my @zones;
  my @lines;
  my $zone;
  my $zoneid;
  my $zonename;
  my $zonestatus;
  my $zonefile;
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
        $zonefile = "/etc/zones/$zonename.xml";
        open(ZONE, $zonefile);    
        @lines = <ZONE>;
        @lines = grep(/mcap/,@lines);
        $memcap = @lines[0];
	$memcap=~ s/[^\d]+//g;
	$memory=$memcap/1024/1024;
	if (!$memcap){
	  $memory="";
	}
        	
	$vcpu = `/usr/sbin/psrinfo -p`; 
	chomp $vcpu;
        if (!$vcpu){
          $vcpu="";
        }

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
