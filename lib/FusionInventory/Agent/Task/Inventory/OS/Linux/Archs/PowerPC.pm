package FusionInventory::Agent::Task::Inventory::OS::Linux::Archs::PowerPC;

use strict;
use warnings;

use Config;


use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Linux;

#processor       : 0
#cpu             : POWER4+ (gq)
#clock           : 1452.000000MHz
#revision        : 2.1
#
#processor       : 1
#cpu             : POWER4+ (gq)
#clock           : 1452.000000MHz
#revision        : 2.1
#
#timebase        : 181495202
#machine         : CHRP IBM,7029-6C3
#
#

sub isInventoryEnabled {
    return
        $Config{archname} =~ /^(ppc|powerpc)/;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    foreach my $cpu (_getCPUsFromProc($logger, '/proc/cpuinfo')) {
        $inventory->addEntry(
            section => 'CPUS',
            entry   => $cpu
        );
    }

    my $SystemSerial = getFirstLine(file => '/proc/device-tree/serial-number');
    $SystemSerial =~ s/[^\,^\.^\w^\ ]//g; # I remove some unprintable char

    my $SystemModel = getFirstLine(file => '/proc/device-tree/model');
    $SystemModel =~ s/[^\,^\.^\w^\ ]//g;

    my $colorCode = getFirstLine(file => '/proc/device-tree/color-code');
    my ($color) = unpack "h7" , $colorCode;
    $SystemModel .= " color: $color" if $color;

    my $BiosVersion = getFirstLine(file => '/proc/device-tree/openprom/model');
    $BiosVersion =~ s/[^\,^\.^\w^\ ]//g;

    my ($BiosManufacturer, $SystemManufacturer);
    my $copyright = getFirstLine(file => '/proc/device-tree/copyright');
    if ($copyright && $copyright =~ /Apple/) {
        # What about the Apple clone?
        $BiosManufacturer = "Apple Computer, Inc.";
        $SystemManufacturer = "Apple Computer, Inc." 
    }

    $inventory->setBios({
        SMANUFACTURER => $SystemManufacturer,
        SMODEL        => $SystemModel,
        SSN           => $SystemSerial,
        BMANUFACTURER => $BiosManufacturer,
        BVERSION      => $BiosVersion,
    });

}

sub _getCPUsFromProc {
    my ($logger, $file) = @_;

    my @cpus;
    foreach my $cpu (getCPUsFromProc(logger => $logger, file => $file)) {

        my $speed;
        if (
            $cpu->{clock} &&
            $cpu->{clock} =~ /(\d+)/
        ) {
            $speed = $1;
        }

        my $manufacturer;
        if ($cpu->{machine} &&
            $cpu->{machine} =~ /IBM/
        ) {
            $manufacturer = 'IBM';
        }

        push @cpus, {
            NAME         => $cpu->{cpu},
            MANUFACTURER => $manufacturer,
            SPEED        => $speed
        };
    }

    return @cpus;
}

1;
