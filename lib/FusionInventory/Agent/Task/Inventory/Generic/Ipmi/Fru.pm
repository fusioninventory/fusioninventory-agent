#
# FusionInventory agent - IPMI FRU report
#
# Copyright (c) 2016 Aleksey Bayguzov <abayguzov@pushwoosh.com>
#
# The Intelligent Platform Management Interface (IPMI) specification
# defines a set of common interfaces to a computer system which system
# administrators can use to monitor system health and manage the
# system. The IPMI consists of a main controller called the Baseboard
# Management Controller (BMC) and other satellite controllers.
#
# The BMC can be fetched through client like OpenIPMI drivers or
# through the network. Though, the BMC hold a proper MAC address.
#
# This module reports Field-replaceable unit.
# This is reported as a FRUS section in inventory.
#
# FRUS             => [ qw/NAME MANUFACTURER MANUFDATE MODEL SERIALNUMBER PARTNUMBER / ],
#

package FusionInventory::Agent::Task::Inventory::Generic::Ipmi::Fru;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

#use FusionInventory::Agent::Tools::Network;

sub isEnabled {
    return unless canRun('ipmitool');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $handle = getFileHandle( command => "ipmitool fru list", );
    return unless $handle;

    my ( %frulist, $frus );
    my $n = -1;
    while ( my $line = <$handle> ) {
        chomp $line;
        next unless $line =~ /^([^:]+)\s*:\s*(.*\S)/;
        my $key = $1;
        my $val = $2;
        $n++ if $key =~ /FRU Device Description/;
        $key =~ s/^\s+//;    # Delete leading spaces
        $key =~ s/\s+$//;    # Delete tailing spaces
        $frulist{$n}->{$key} = $val;

        #print "$key : $val\n";
    }
    close $handle;

    foreach my $i ( keys %frulist ) {
        if (!exists $frulist{$i}->{'Board Product'} ) {
          if (exists $frulist{$i}->{'Product Name'} ) {
              $frulist{$i}->{'Board Product'} = $frulist{$i}->{'Product Name'};
          }
          else {
              $frulist{$i}->{'Board Product'} = $frulist{$i}->{'Board Part Number'};
          }
        }

        if (!exists $frulist{$i}->{'Board Mfg'} ) {
            $frulist{$i}->{'Board Mfg'} = $frulist{$i}->{'Product Manufacturer'};
        }

        if (!exists $frulist{$i}->{'Board Serial'} ) {
            $frulist{$i}->{'Board Serial'} = $frulist{$i}->{'Product Serial'};
        }

        if (!exists $frulist{$i}->{'Board Part Number'} ) {
            $frulist{$i}->{'Board Part Number'} = $frulist{$i}->{'Product Part Number'};
        }


    }

    #delete empty FRUs
    foreach my $i ( keys %frulist ) {
        delete $frulist{$i} unless defined $frulist{$i}->{'Board Product'};
    }

    while ( my ( $fru_id, $fru ) = each %frulist ) {
        $frus = {
            DESCRIPTION  => 'FRU',
            NAME         => $fru->{'FRU Device Description'},
            MODEL        => $fru->{'Board Product'},
            SERIALNUMBER => $fru->{'Board Serial'},
            PARTNUMBER   => $fru->{'Board Part Number'},
            MANUFACTURER => $fru->{'Board Mfg'},
            MANUFDATE    => $fru->{'Board Mfg Date'}
        };

        $inventory->addEntry(
            section => 'FRUS',
            entry   => $frus,
        );
    }

}

1;

