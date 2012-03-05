package FusionInventory::Agent::Task::Inventory::Input::AIX::Bios;

use strict;
use warnings;

use List::Util qw(first);

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::AIX;

sub isEnabled {
    return 1;
}

# NOTE:
# Q: SSN can also use `uname -n`? What is the best?
# A: uname -n since it doesn't need root priv

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $bios = {
        BMANUFACTURER => 'IBM',
        SMANUFACTURER => 'IBM',
    };

    my @infos = getLsvpdInfos(logger => $logger);

    my $system = first { $_->{DS} eq 'System Firmware' } @infos;
    $bios->{BVERSION} = $system->{RM} if $system;

    my $platform = first { $_->{DS} eq 'Platform Firmware' } @infos;
    $bios->{BVERSION} .= "(Firmware : $platform->{RM})" if $platform;

    my $vpd = first { $_->{DS} eq 'System VPD' } @infos;
    if ($vpd) {
        $bios->{SMODEL} = $vpd->{TM};
        $bios->{SSN} = $vpd->{SE};
    }

    $inventory->setBios($bios);
}

1;
