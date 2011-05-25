package FusionInventory::Agent::Task::Inventory::OS::AIX::Hardware;

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

    my ($serial, $model, $version, $date);

    my @infos = getLsvpdInfos(logger => $logger);

    my $system = first { $_->{DS} eq 'System Firmware' } @infos;
    $version = $system->{RM} if $system;

    my $platform = first { $_->{DS} eq 'Platform Firmware' } @infos;
    $version .= "(Firmware : $platform->{RM})" if $platform;

    my $vpd = first { $_->{DS} eq 'System VPD' } @infos;
    if ($vpd) {
        $model = $vpd->{TM};
        $serial = $vpd->{SE};
    }

    # Writing data
    $inventory->setBios({
        SMANUFACTURER => 'IBM',
        SMODEL        => $model,
        SSN           => $serial,
        BMANUFACTURER => 'IBM',
        BVERSION      => $version,
        BDATE         => $date,
    });
}

1;
