package FusionInventory::Agent::Task::Inventory::OS::Win32::AntiVirus;

use strict;
use warnings;

use FusionInventory::Agent::Tools::Win32;

sub isInventoryEnabled {
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    # Doesn't works on Win2003 Server
    # On Win7, we need to use SecurityCenter2
    foreach my $instance (qw/SecurityCenter SecurityCenter2/) {
        my $moniker = "winmgmts:{impersonationLevel=impersonate,(security)}!//./root/$instance";

        foreach my $object (getWmiObjects(
                moniker    => $moniker,
                class      => "AntiVirusProduct",
                properties => [ qw/
                    companyName displayName instanceGuid onAccessScanningEnabled
                    productUptoDate versionNumber productState
               / ]
        )) {
            next unless $object;
            my $enable = $object->{onAccessScanningEnabled};
            my $uptodate = $object->{productUptoDate};

            if ($object->{productState}) {
                my $bin = sprintf( "%b\n", $object->{productState});
# http://blogs.msdn.com/b/alejacma/archive/2008/05/12/how-to-get-antivirus-information-with-wmi-vbscript.aspx?PageIndex=2#comments
                if ($bin =~ /(\d)\d{5}(\d)\d{6}(\d)\d{5}$/) {
                    $uptodate = $1 || $2;
                    $enable = $3?0:1;
                }

            }

            $inventory->addEntry(
                section => 'ANTIVIRUS',
                entry   => {
                    COMPANY  => $object->{companyName},
                    NAME     => $object->{displayName},
                    GUID     => $object->{instanceGuid},
                    ENABLED  => $enable,
                    UPTODATE => $uptodate,
                    VERSION  => $object->{versionNumber}
                },
                noDuplicated => 1
            );
        }
    }
}

1;

