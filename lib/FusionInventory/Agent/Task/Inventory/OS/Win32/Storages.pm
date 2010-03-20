package FusionInventory::Agent::Task::Inventory::OS::Win32::Storages;

use strict;
use Win32::OLE qw(in CP_UTF8);
use Win32::OLE::Const;

Win32::OLE-> Option(CP=>CP_UTF8);

use Win32::OLE::Enum;

use Encode qw(encode);

sub isInventoryEnabled {1}

sub getManufacturer {
    my $model = shift;
    if($model =~ /(maxtor|western|sony|compaq|hewlett packard|ibm|seagate|toshiba|fujitsu|lg|samsung|nec|transcend|matshita|pioneer)/i) {
        return ucfirst(lc($1));
    }
    elsif ($model =~ /^HP/) {
        return "Hewlett Packard";
    }
    elsif ($model =~ /^WDC/) {
        return "Western Digital";
    }
    elsif ($model =~ /^ST/) {
        return "Seagate";
    }
    elsif ($model =~ /^HD/ or $model =~ /^IC/ or $model =~ /^HU/) {
        return "Hitachi";
    }
}

sub doInventory {

    my $params = shift;
    my $logger = $params->{logger};
    my $inventory = $params->{inventory};

    my $WMIServices = Win32::OLE->GetObject(
            "winmgmts:{impersonationLevel=impersonate,(security)}!//./" );

    if (!$WMIServices) {
        print Win32::OLE->LastError();
    }


    my @storages;
    foreach my $Properties ( Win32::OLE::in( $WMIServices->InstancesOf(
                    'Win32_DiskDrive' ) ) )
    {

        push @storages, {
            MANUFACTURER => encode('UTF-8', $Properties->{Manufacturer}),
            MODEL => encode('UTF-8', $Properties->{Model}),
            DESCRIPTION => encode('UTF-8', $Properties->{Description}),
            NAME => encode('UTF-8', $Properties->{Name}),
            TYPE => encode('UTF-8', $Properties->{MediaType}),
            DISKSIZE => $Properties->{Size}/(1024*1024)
        };

    }
    foreach (@storages) {
        $inventory->addStorages($_);
    }

}
1;
