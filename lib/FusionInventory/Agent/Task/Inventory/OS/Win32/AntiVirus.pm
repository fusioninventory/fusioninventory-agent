package FusionInventory::Agent::Task::Inventory::OS::Win32::AntiVirus;

use strict;
use warnings;

use FusionInventory::Agent::Tools::Win32;

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

# Doesn't works on Win2003 Server

# On Win7, we need to use SecurityCenter2
    foreach my $instance (qw/SecurityCenter SecurityCenter2/) {
        my $moniker = "winmgmts:{impersonationLevel=impersonate,(security)}!//./root/$instance";

        foreach my $object (getWMIObjects(
                moniker    => $moniker,
                class      => "AntiVirusProduct",
                properties => [ qw/
                    companyName displayName instanceGuid onAccessScanningEnabled
                    productUptoDate versionNumber
               / ]
        ))) {

            my $enable   = $object->{onAccessScanningEnabled};
            my $uptodate = $object->{productUptoDate};

            if ($object->{productState}) {
                # http://blogs.msdn.com/b/alejacma/archive/2008/05/12/how-to-get-antivirus-information-with-wmi-vbscript.aspx?PageIndex=2#comments
                my $bin = sprintf( "%b\n", $object->{productState});
                if ($bin =~ /(\d)00000(\d)000000(\d)00000$/) {
                    $uptodate = $1 || $2;
                    $enable = $3?0:1;
                }
            }
            $inventory->addAntiVirus({
                COMPANY  => $object->{companyName},
                NAME     => $object->{displayName},
                GUID     => $object->{instanceGuid},
                ENABLED  => $enable,
                UPTODATE => $uptodate,
                VERSION  => $object->{versionNumber}
            });
        }
    }

}
1;

