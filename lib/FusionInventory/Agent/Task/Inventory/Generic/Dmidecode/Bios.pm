package FusionInventory::Agent::Task::Inventory::Generic::Dmidecode::Bios;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Generic;

sub isEnabled {
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my ($bios, $hardware) = _getBiosHardware(logger => $logger);

    $inventory->setBios($bios) if $bios;
    $inventory->setHardware($hardware) if $hardware;
}

sub _getBiosHardware {
    my $infos = getDmidecodeInfos(@_);

    my $bios_info    = $infos->{0}->[0];
    my $system_info  = $infos->{1}->[0];
    my $base_info    = $infos->{2}->[0];
    my $chassis_info = $infos->{3}->[0];

    my $bios = {
        BMANUFACTURER => $bios_info->{'Vendor'},
        BDATE         => $bios_info->{'Release Date'},
        BVERSION      => $bios_info->{'Version'},
        ASSETTAG      => $chassis_info->{'Asset Tag'}
    };

    $bios->{SMODEL} =
        $system_info->{'Product'}      ||
        $system_info->{'Product Name'};
    $bios->{MMODEL} = $base_info->{'Product Name'};
    $bios->{SKUNUMBER} = $system_info->{'SKU Number'};

    $bios->{SMANUFACTURER} =
        $system_info->{'Manufacturer'} ||
        $system_info->{'Vendor'};
    $bios->{MMANUFACTURER} = $base_info->{'Manufacturer'};

    $bios->{SSN} = $system_info->{'Serial Number'};
    $bios->{MSN} = $base_info->{'Serial Number'};

    if ($bios->{MMODEL} && $bios->{MMODEL} eq "VirtualBox" &&
        $bios->{SSN} eq "0" &&
        $bios->{MSN} eq "0") {
        $bios->{SSN} = $system_info->{'UUID'}
    }
    my $hardware = {
        UUID => $system_info->{'UUID'},
        CHASSIS_TYPE  => $chassis_info->{'Type'}
    };

    return $bios, $hardware;
}

1;
