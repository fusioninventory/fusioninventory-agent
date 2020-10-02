package FusionInventory::Agent::Task::Inventory::Generic::Ipmi::Fru::Controllers;

use strict;
use warnings;

use parent 'FusionInventory::Agent::Task::Inventory::Module';

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::IpmiFru qw(getIpmiFru parseFru);

my $CONTROLLERS = qr/^(?:
    BP             |
    PERC           |
    NDC            |
    Ethernet Adptr |
    SAS Ctlr
)\d*\s+/x;

sub isEnabled {
    my (%params) = @_;
    return 0 if $params{no_category}->{controller};
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $fru = getIpmiFru(%params)
        or return;

    my @fru_keys = grep { $_ =~ $CONTROLLERS } keys %$fru
        or return;

    my @fields = keys %{$inventory->getFields()->{CONTROLLERS}};
    for my $descr (@fru_keys) {
        my $ctrl = parseFru($fru->{$descr}, \@fields);
        next unless keys %$ctrl;

        # remove revision suffix from the p/n
        if ($ctrl->{MANUFACTURER} =~ /dell/i && $ctrl->{MODEL} =~ /^([0-9A-Z]{6})([A-B]\d{2})$/) {
            ($ctrl->{MODEL}, $ctrl->{REV}) = ($1, $2);
        }

        $inventory->addEntry(
            section => 'CONTROLLERS',
            entry   => $ctrl
        );
    }
}

1;
