package FusionInventory::Agent::Task::Inventory::OS::HPUX::Bios;

use strict;
use warnings;

###
# Version 1.1
# Correction of Bug n 522774
#
# thanks to Marty Riedling for this correction
#
###

sub isInventoryEnabled {
    return can_run ("model");
}

sub doInventory { 
    my $params = shift;
    my $inventory = $params->{inventory};

    my $BiosVersion;
    my $BiosDate;
    my $SystemModel;
    my $SystemSerial;
    my $SystemUUID;


    $SystemModel=`model`;
    if ( can_run ("/usr/contrib/bin/machinfo") ) {
        foreach ( `/usr/contrib/bin/machinfo` ) {
            if ( /Firmware\s+revision\s*[:=]\s+(\S+)/ ) {
                $BiosVersion = $1;
            } elsif ( /achine\s+serial\s+number\s*[:=]\s+(\S+)/ ) {
                $SystemSerial = $1;
            } elsif (/achine\s+id\s+number\s+=\s+(\S+)/) {
                $SystemUUID = uc $1;
            } elsif (/achine\s+ID\s+number:\s+(\S+)/) {
                $SystemUUID = uc $1;
            }
        }
    } else { #Could not run machinfo
        for ( `echo 'sc product cpu;il' | /usr/sbin/cstm | grep "PDC Firmware"` ) {
            if ( /Revision:\s+(\S+)/ ) { $BiosVersion = "PDC $1" }
        }
        for ( `echo 'sc product system;il' | /usr/sbin/cstm | grep "System Serial Number"` ) {
            if ( /:\s+(\w+)/ ) { $SystemSerial = $1 }
        }
    }

    $inventory->setBios ({
        BVERSION => $BiosVersion,
        BDATE => $BiosDate,
        BMANUFACTURER => "HP",
        SMANUFACTURER => "HP",
        SMODEL => $SystemModel,
        SSN => $SystemSerial,
    });
    $inventory->setHardware({
        UUID => $SystemUUID
    });
}

1;
