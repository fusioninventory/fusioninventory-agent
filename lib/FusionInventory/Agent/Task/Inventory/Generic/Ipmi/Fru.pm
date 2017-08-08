#
# OcsInventory agent - IPMI lan channel report
#
# Copyright (c) 2008 Jean Parpaillon <jean.parpaillon@kerlabs.com>
#
# The Intelligent Platform Management Interface (IPMI) specification
# defines a set of common interfaces to a computer system which system
# administrators can use to monitor system health and manage the
# system. The IPMI consists of a main controller called the Baseboard
# Management Controller (BMC) and other satellite controllers.
#
package FusionInventory::Agent::Task::Inventory::Generic::Ipmi::Fru;

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

    my $fru = getIpmiFru(logger => $logger);
    my $psu;

    foreach my $descr (keys %$fru) {
        next unless $descr =~ /^PS(\d+)/;

        $psu = {
            PARTNUM     => $fru->{$descr}->{data}->{'Board Part Number'},
            SERIAL      => $fru->{$descr}->{data}->{'Board Serial'},
            DESCRIPTION => $fru->{$descr}->{data}->{'Board Product'},
            VENDOR      => $fru->{$descr}->{data}->{'Board Mfg'},
        }

        $inventory->addEntry(
            section => 'PSU',
            entry   => $psu
        );

        undef $psu;
    }
}

1;
