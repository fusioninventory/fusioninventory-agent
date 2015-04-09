package FusionInventory::Agent::Task::Inventory::MacOS::Bios;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::MacOS;

sub isEnabled {
    return canRun('/usr/sbin/system_profiler');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $infos = getSystemProfilerInfos(type => 'SPHardwareDataType', logger => $logger);
    my $info = $infos->{'Hardware'}->{'Hardware Overview'};

    my ($device) = getIODevices(
        class => 'IOPlatformExpertDevice',
        logger => $logger
    );

    # set the bios informaiton from the apple system profiler
    $inventory->setBios({
        SMANUFACTURER => $device->{'manufacturer'} || 'Apple Inc', # duh
        SMODEL        => $info->{'Model Identifier'} ||
                         $info->{'Machine Model'},
        # New method to get the SSN, because of MacOS 10.5.7 update
        # system_profiler gives 'Serial Number (system): XXXXX' where 10.5.6
        # and lower give 'Serial Number: XXXXX'
        SSN           => $info->{'Serial Number'}          ||
                         $info->{'Serial Number (system)'} ||
                         $device->{'serial-number'},
        BVERSION      => $info->{'Boot ROM Version'},
    });

    $inventory->setHardware({
        UUID => $info->{'Hardware UUID'} || $device->{'IOPlatformUUID'}
    });
}

1;
