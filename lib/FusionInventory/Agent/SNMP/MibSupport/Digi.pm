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

my @gprsNetworkTechnology = qw(- unknown gprs edge umts hsdpa hsupa hspa lte);

sub getFirmware {
    my (%params) = @_;

    my $device = $params{device};
    my $snmp   = $params{snmp} || $device->{snmp};

    return $snmp->get('.1.3.6.1.4.1.16378.10000.3.16.0');
}

sub getSerial {
    my (%params) = @_;

    my $device = $params{device};
    my $snmp   = $params{snmp} || $device->{snmp};

    return $snmp->get('.1.3.6.1.4.1.16378.10000.3.15.0');
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

        # Handle SIM card looking for GRPS status
        my $sarianGPRS = $snmp->walk(sarianGPRS);
        if ($sarianGPRS) {
            my $simcard = {
                IMSI    => $sarianGPRS->{'21.0'}, # gprsIMSI
                ICCID   => $sarianGPRS->{'20.0'}, # gprsICCID
                #STATE   => $sarianGPRS->{'26.0'}, # gprsSIMStatus
            };

            $device->addSimcard($simcard);

            # use IMEI as modem serial
            $modem->{SERIAL} = $sarianGPRS->{'19.0'}; # gprsIMEI

            # set modem type
            my $techno = $sarianGPRS->{'7.0'}; # gprsNetworkTechnology
            if ($techno && $techno <= @gprsNetworkTechnology) {
                $modem->{TYPE} = $gprsNetworkTechnology[$techno];
            }
        }

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
