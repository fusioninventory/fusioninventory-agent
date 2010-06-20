package FusionInventory::Agent::Task::Inventory::OS::Win32::CPU;

use strict;
use warnings;

use FusionInventory::Agent::Task::Inventory::OS::Win32;

use Win32::TieRegistry ( Delimiter=>"/", ArrayValues=>0 );

# the CPU description in WMI is false, we use the registry instead
# Hardware\Description\System\CentralProcessor\1
# thank you Nicolas Richard 
sub getCPUInfoFromRegistry {
    my ($cpuId) = @_;
    
    my $KEY_WOW64_64KEY = 0x100; 

    my $machKey= $Registry->Open( "LMachine", {Access=>Win32::TieRegistry::KEY_READ()|$KEY_WOW64_64KEY,Delimiter=>"/"} );

    my $data =
        $machKey->{"Hardware/Description/System/CentralProcessor/".$cpuId};

    my $info;

    foreach my $tmpkey (%$data) {
        next unless $tmpkey =~ /^\/(.*)/;
        my $key = $1;

        $info->{$key} = $data->{$tmpkey};
    }

    return $info;
}



sub isInventoryEnabled {
    return 1;
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $serial;
    my $speed;

    my $vmsystem;

    my @dmidecodeCpu;
    if (can_run("dmidecode")) {
        my $in;
	my $currentSpeed;
        foreach (`dmidecode`) {
            if ($in && /^Handle/)  {
                # Mouahaha SONY...
                $speed = $currentSpeed if $currentSpeed > $speed;

                push @dmidecodeCpu, {serial => $serial, speed => $speed};
                $in = 0;

		$speed = $serial = $currentSpeed;
            }

            if (/^Handle.*type 4,/) {
                $in = 1 
            } elsif ($in) {
                $speed = $1 if /Max Speed:\s+(\d+)\s+MHz/i;
                $speed = $1*1000 if /Max Speed:\s+(\w+)\s+GHz/i;

                $speed = $1 if /Current Speed:\s+(\d+)\s+MHz/i;
                $speed = $1*1000 if /Current Speed:\s+(\w+)\s+GHz/i;
		
                $serial = $1 if /ID:\s+(.*)/i;
            }
        }
    }



    my $cpuId = 0;
    foreach my $Properties
        (getWmiProperties('Win32_Processor',
qw/NumberOfCores ProcessorId MaxClockSpeed/)) {

        my $info = getCPUInfoFromRegistry($cpuId);

#        my $cache = $Properties->{L2CacheSize}+$Properties->{L3CacheSize};
        my $core = $Properties->{NumberOfCores};
        my $description = $info->{Identifier};
        my $name = $info->{ProcessorNameString};
        my $manufacturer = $info->{VendorIdentifier};
        my $serial = $dmidecodeCpu[$cpuId]->{serial} || $Properties->{ProcessorId};
        my $speed = $dmidecodeCpu[$cpuId]->{speed} || $Properties->{MaxClockSpeed};

        $manufacturer =~ s/Genuine//;
        $manufacturer =~ s/(TMx86|TransmetaCPU)/Transmeta/;
        $manufacturer =~ s/CyrixInstead/Cyrix/;
        $manufacturer=~ s/CentaurHauls/VIA/;
        $serial =~ s/\s//g;

        $name =~ s/^\s+//;
        $name =~ s/\s+$//;

        $vmsystem = "QEMU"if $name =~ /QEMU/i;

        $inventory->addCPU({
#                CACHE => $cache,
                CORE => $core,
                DESCRIPTION => $description,
                NAME => $name,
                MANUFACTURER => $manufacturer,
                SERIAL => $serial,
                SPEED => $speed

                });

        $cpuId++;
    }

    if ($vmsystem) {
        $inventory->setHardware ({
                VMSYSTEM => $vmsystem 
                });
    }




}
1;
