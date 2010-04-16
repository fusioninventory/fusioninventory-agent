package FusionInventory::Agent::Task::Inventory::OS::Win32::CPU;

use strict;
use Win32::OLE qw(in CP_UTF8);
use Win32::OLE::Const;
 
Win32::OLE-> Option(CP=>CP_UTF8);
 
use Win32::OLE::Enum;

use Encode qw(encode);

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

sub isInventoryEnabled {1}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};



    my $WMIServices = Win32::OLE->GetObject(
            "winmgmts:{impersonationLevel=impersonate,(security)}!//./" );

    if (!$WMIServices) {
        print Win32::OLE->LastError();
    }
    my $cpuId = 0;
    foreach my $Properties ( Win32::OLE::in( $WMIServices->InstancesOf( 'Win32_Processor' ) ) )
    {

        my $info = getCPUInfoFromRegistry($cpuId++);

        my $cache = $Properties->{L2CacheSize}+$Properties->{L3CacheSize};
        my $core = $Properties->{NumberOfCores};
        my $description = $info->{Identifier};
        my $name = $info->{ProcessorNameString};
        my $manufacturer = $info->{VendorIdentifier};
        my $serial = $Properties->{ProcessorId};
        my $speed = $Properties->{MaxClockSpeed};

        $manufacturer =~ s/Genuine//;
        $manufacturer =~ s/(TMx86|TransmetaCPU)/Transmeta/;
        $manufacturer =~ s/CyrixInstead/Cyrix/;
        $manufacturer=~ s/CentaurHauls/VIA/;

        $inventory->addCPU({
                CACHE => $cache,
                CORE => $core,
                DESCRIPTION => $description,
                NAME => $name,
                MANUFACTURER => $manufacturer,
                SERIAL => $serial,
                SPEED => $speed

                });
    }



}
1;
