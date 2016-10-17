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
         COMPANY  => "Teclib",
         NAME     => "Armadito",
    #    GUID     => $object->{instanceGuid},
         VERSION  => "0.11",
    #    ENABLED  => $object->{onAccessScanningEnabled},
         UPTODATE => "0"
    };

    $inventory->addEntry(
        section => 'ANTIVIRUS',
        entry   => $antivirus
    );
}
1;
