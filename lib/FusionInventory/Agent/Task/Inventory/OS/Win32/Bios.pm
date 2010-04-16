package FusionInventory::Agent::Task::Inventory::OS::Win32::Bios;

use strict;
use Win32::OLE qw(in CP_UTF8);
use Win32::OLE::Const;

Win32::OLE-> Option(CP=>CP_UTF8);

use Win32::OLE::Enum;


sub isInventoryEnabled {1}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};



    my $WMIServices = Win32::OLE->GetObject(
            "winmgmts:{impersonationLevel=impersonate,(security)}!//./" );

    if (!$WMIServices) {
        print Win32::OLE->LastError();
    }

    my $smodel;
    my $smanufacturer;
    my $ssn;
    my $bdate;
    my $bversion;
    my $bmanufacturer;
    my $mmanufacturer;
    my $msn;
    my $model;
    my $assettag;


    foreach my $Properties ( Win32::OLE::in( $WMIServices->InstancesOf(
                    'Win32_BaseBoard' ) ) )
    {

        $ssn = $Properties->{SerialNumber};
        $smodel = $Properties->{Product};
        $smanufacturer = $Properties->{Manufacturer};

    }


    foreach my $Properties ( Win32::OLE::in( $WMIServices->InstancesOf(
                    'Win32_Bios' ) ) )
    {

        $ssn = $Properties->{SerialNumber} unless $ssn;
        $bmanufacturer = $Properties->{Manufacturer} unless $bmanufacturer;
        $bversion = $Properties->{SMBIOSBIOSVersion} unless $bversion;
        $bversion = $Properties->{BIOSVersion} unless $bversion;
        $bversion = $Properties->{Version} unless $bversion;
        $bdate = "$3/$2/$1" if $bdate && $Properties->{ReleaseData} =~ 
/^(\d{4})(\d{2})(\d{2})/;
    }




    foreach my $Properties ( Win32::OLE::in( $WMIServices->InstancesOf(
                    'Win32_SystemEnclosure' ) ) )
    {

        $ssn = $Properties->{SerialNumber} unless $ssn;
        $assettag = $Properties->{SMBIOSAssetTag} unless $assettag;

    }

    foreach my $Properties ( Win32::OLE::in( $WMIServices->InstancesOf(
                    'Win32_ComputerSystem' ) ) )
    {

        $smanufacturer = $Properties->{Manufacturer} unless $smanufacturer;
        $model = $Properties->{Model} unless $model;

    }



        $inventory->setBios({
                SMODEL => $smodel,
                SMANUFACTURER =>  $smanufacturer,
                SSN => $ssn,
                BDATE => $bdate,
                BVERSION => $bversion,
                BMANUFACTURER => $bmanufacturer,
                MMANUFACTURER => $mmanufacturer,
                MSN => $msn,
                MMODEL => $model,
                ASSETTAG => $assettag

                });



}
1;
