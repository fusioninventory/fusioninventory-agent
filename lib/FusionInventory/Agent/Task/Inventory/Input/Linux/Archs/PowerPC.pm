package FusionInventory::Agent::Task::Inventory::Input::Linux::Archs::PowerPC;

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

sub isEnabled {
    return
        $Config{archname} =~ /^(ppc|powerpc)/;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    foreach my $cpu (_getCPUsFromProc(
        logger => $logger, file => '/proc/cpuinfo'
    )) {
        $inventory->addEntry(
            section => 'CPUS',
            entry   => $cpu
        );
    }

    my $bios;

    $bios->{SSN} = getFirstLine(file => '/proc/device-tree/serial-number');
    $bios->{SSN} =~ s/[^\,^\.^\w^\ ]//g; # I remove some unprintable char

    $bios->{SMODEL} = getFirstLine(file => '/proc/device-tree/model');
    $bios->{SMODEL} =~ s/[^\,^\.^\w^\ ]//g;

    my $colorCode = getFirstLine(file => '/proc/device-tree/color-code');
    my ($color) = unpack "h7" , $colorCode;
    $bios->{SMODEL} .= " color: $color" if $color;

    $bios->{BVERSION} =
        getFirstLine(file => '/proc/device-tree/openprom/model');
    $bios->{BVERSION} =~ s/[^\,^\.^\w^\ ]//g;

    my $copyright = getFirstLine(file => '/proc/device-tree/copyright');
    if ($copyright && $copyright =~ /Apple/) {
        # What about the Apple clone?
        $bios->{BMANUFACTURER} = "Apple Computer, Inc.";
        $bios->{SMANUFACTURER} = "Apple Computer, Inc."
    }

    $inventory->setBios($bios);
}

sub _getCPUsFromProc {
    my @cpus;
    foreach my $cpu (getCPUsFromProc(@_)) {

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
