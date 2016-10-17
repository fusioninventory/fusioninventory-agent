package FusionInventory::Agent::Task::Inventory::Linux::AntiVirus::Armadito;

use strict;
use warnings;

sub isEnabled {
    my (%params) = @_;
    return 0 if $params{no_category}->{antivirus};
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $logger;
    $logger = $params{logger};

    my $inventory = $params{inventory};

    my $antivirus = {
    #    COMPANY  => $object->{companyName},
    #    NAME     => $object->{displayName},
    #    GUID     => $object->{instanceGuid},
    #    VERSION  => $object->{versionNumber},
    #    ENABLED  => $object->{onAccessScanningEnabled},
    #    UPTODATE => $object->{productUptoDate}
    };

    $inventory->addEntry(
        section => 'ANTIVIRUS',
        entry   => $antivirus
    );
}
1;
