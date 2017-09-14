package FusionInventory::Agent::SNMP::MibSupport::Digi;

use strict;
use warnings;

use base 'FusionInventory::Agent::SNMP::MibSupport';

# Constants extracted from Digi Sarian-Monitor.mib
use constant    sarianMonitor   => ".1.3.6.1.4.1.16378.10000" ;
use constant    sarianGPRS      => sarianMonitor . ".2" ;
use constant    sarianSystem    => sarianMonitor . ".3" ;

sub mibSupport {
    return [
        {
            name    => "sarianMonitor",
            oid     => sarianMonitor
        }
    ];
}

sub run {
    my (%params) = @_;

    my $device = $params{device};
    my $snmp   = $params{snmp} || $device->{snmp};

    my $sarianSystem = $snmp->walk(sarianSystem);

    # Handle modem Digi private OIDs if found
    if ($sarianSystem) {
        my $modem = {
            NAME            => "Digi modem",
            DESCRIPTION     => $sarianSystem->{'14.0'},
            MODEL           => $sarianSystem->{'19.0'},
            MANUFACTURER    => "Digi",
        };

        $device->addModem($modem);

        # Add modem firmware
        my $modemFirmware = {
            NAME            => "Digi modem",
            DESCRIPTION     => "Digi $sarianSystem->{'19.0'} modem",
            TYPE            => "modem",
            VERSION         => $sarianSystem->{'20.0'},
            MANUFACTURER    => "Digi"
        };

        $device->addFirmware($modemFirmware);
    }
}

1;

__END__

=head1 NAME

Inventory module for Digi modems and associated sim cards & firmwares

=head1 DESCRIPTION

The module adds SIMCARDS, MODEMS & FIRMWARES support for Digi devices
