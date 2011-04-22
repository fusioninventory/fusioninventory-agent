package FusionInventory::Agent::Task::Inventory::OS::HPUX::Bios;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::HPUX;

###
# Version 1.1
# Correction of Bug n 522774
#
# thanks to Marty Riedling for this correction
#
###

sub isInventoryEnabled {
    return can_run('model');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $BiosVersion;
    my $BiosDate;
    my $SystemModel;
    my $SystemSerial;
    my $SystemUUID;

    $SystemModel = getFirstLine(command => 'model');

    if (can_run('/usr/contrib/bin/machinfo')) {
        my $info = getInfoFromMachinfo(logger => $logger);
        $BiosVersion  = $info->{'Firmware info'}->{'firmware revision'};
        $SystemSerial = $info->{'Platform info'}->{'machine serial number'};
        $SystemUUID   = uc($info->{'Platform info'}->{'machine id number'});
    } else {
        foreach ( `echo 'sc product cpu;il' | /usr/sbin/cstm` ) {
            next unless /PDC Firmware/;
            if ( /Revision:\s+(\S+)/ ) { $BiosVersion = "PDC $1" }
        }
        foreach ( `echo 'sc product system;il' | /usr/sbin/cstm` ) {
            next unless /System Serial Number/;
            if ( /:\s+(\w+)/ ) { $SystemSerial = $1 }
        }
    }

    $inventory->setBios(
        BVERSION      => $BiosVersion,
        BDATE         => $BiosDate,
        BMANUFACTURER => "HP",
        SMANUFACTURER => "HP",
        SMODEL        => $SystemModel,
        SSN           => $SystemSerial,
    );
    $inventory->setHardware(
        UUID => $SystemUUID
    );
}

1;
