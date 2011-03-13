package FusionInventory::Agent::Task::Inventory::OS::Win32::AntiVirus;

use strict;
use warnings;

use Config;

use Win32;
use Win32::OLE('in');
use Win32::OLE::Variant;

use FusionInventory::Agent::Task::Inventory::OS::Win32;

sub doInventory {
    my $params = shift;

    my $inventory = $params->{inventory};



# Doesn't works on Win2003 Server

# On Win7, we need to use SecurityCenter2
    foreach my $instance (qw/SecurityCenter SecurityCenter2/) {
        my $WMIServices = Win32::OLE->GetObject(
                "winmgmts:{impersonationLevel=impersonate,(security)}!//./root/$instance" );


        if (!$WMIServices) {
#            print STDERR Win32::OLE->LastError();
            next;
        }



        my @properties;
        foreach my $properties ( Win32::OLE::in( $WMIServices->InstancesOf(
                        "AntiVirusProduct" ) ) )
        {
            my $enable = $properties->{onAccessScanningEnabled};
            my $uptodate = $properties->{productUptoDate};

            if ($properties->{productState}) {
                my $bin = sprintf( "%b\n", $properties->{productState});
# http://blogs.msdn.com/b/alejacma/archive/2008/05/12/how-to-get-antivirus-information-with-wmi-vbscript.aspx?PageIndex=2#comments
                if ($bin =~ /(\d)00000(\d)000000(\d)00000$/) {
                    $uptodate = $1 || $2;
                    $enable = $3?0:1;
                }

            }
            $inventory->addAntiVirus({
                    COMPANY => $properties->{companyName},
                    NAME => $properties->{displayName},
                    GUID => $properties->{instanceGuid},
                    ENABLED => $enable,
                    UPTODATE => $uptodate,
                    VERSION => $properties->{versionNumber}
                    });
            return;
        }
    }

}
1;

