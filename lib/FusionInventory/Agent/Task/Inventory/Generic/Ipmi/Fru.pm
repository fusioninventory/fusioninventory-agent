package FusionInventory::Agent::Task::Inventory::Generic::Ipmi::Fru;

use strict;
use warnings;

use parent 'FusionInventory::Agent::Task::Inventory::Module';

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::PowerSupplies;

# Run after virtualization to decide if found component is virtual
our $runAfterIfEnabled = [ qw(
    FusionInventory::Agent::Task::Inventory::Generic::Dmidecode::Psu
)];

sub isEnabled {
    my (%params) = @_;
    return 0 if $params{no_category}->{psu};
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $fru = getIpmiFru(%params)
        or return;

    my @fru_keys = grep { /^(PS|Pwr Supply )\d+/ } keys(%{$fru})
        or return;

    # Empty current POWERSUPPLIES section into a new psu list
    my $psulist = Inventory::PowerSupplies->new( logger => $logger );
    my $section = $inventory->getSection('POWERSUPPLIES') || [];
    while (@{$section}) {
        my $powersupply = shift @{$section};
        $psulist->add($powersupply);
    }

    # Merge powersupplies reported by ipmitool
    my @fru = ();
    foreach my $descr (sort @fru_keys) {
        push @fru, {
            NAME         => $fru->{$descr}->{'Board Product'} ||
                $fru->{$descr}->{'Product Name'},
            PARTNUM      => $fru->{$descr}->{'Board Part Number'} ||
                $fru->{$descr}->{'Product Part Number'},
            SERIALNUMBER => $fru->{$descr}->{'Board Serial'} ||
                $fru->{$descr}->{'Product Serial'},
            POWER_MAX    => $fru->{$descr}->{'Max Power Capacity'},
            MANUFACTURER => $fru->{$descr}->{'Board Mfg'} ||
                $fru->{$descr}->{'Product Manufacturer'},
        };
    }
    $psulist->merge(@fru);

    # Add back merged powersupplies into inventory
    foreach my $psu ($psulist->list()) {
        $inventory->addEntry(
            section => 'POWERSUPPLIES',
            entry   => $psu
        );
    }
}

1;
