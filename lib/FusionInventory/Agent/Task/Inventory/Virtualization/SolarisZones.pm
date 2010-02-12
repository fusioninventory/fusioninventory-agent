package FusionInventory::Agent::Task::Inventory::Virtualization::SolarisZones;

use strict;

sub isInventoryEnabled { 
  return unless can_run('zoneadm'); 
  return unless check_solaris_valid_release();
}
sub check_solaris_valid_release{
  #check if Solaris 10 release is higher than 08/07
  my @rlines;
  my $release_file;
  my $release;
  my $year;
  
  $release_file = "/etc/release";
  if (!open(SOLVERSION, $release_file)) {
    return;
  }
  @rlines = <SOLVERSION>;
  @rlines = grep(/Solaris/,@rlines);
  $release = @rlines[0];
  $release =~ m/(\d)\/(\d+)/;
  $release = $1;
  $year = $2;
  $release =~ s/^0*//g;
  $year =~ s/^0*//g;
  if ($year <= 7 and $release < 8 ){
  return 0;
  }
  1 
}

sub doInventory {
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
  my $logger = $params->{logger};

  @zones = `/usr/sbin/zoneadm list -p`;
  @zones = grep (!/global/,@zones);

  foreach $zone (@zones) {	
        ($zoneid,$zonename,$zonestatus,$pathroot,$uuid)=split(/:/,$zone);
	# 
	# Memory considerations depends on rcapd or project definitions
	# Little hack, I go directly in /etc/zones reading mcap physcap for each zone.
        $zonefile = "/etc/zones/$zonename.xml";
        if (!open(ZONE, $zonefile)) {
            $logger->debug("Failed to open $zonefile");
            next;
        }
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
