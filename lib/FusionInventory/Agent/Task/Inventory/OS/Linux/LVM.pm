package FusionInventory::Agent::Task::Inventory::OS::Linux::LVM;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;


sub isEnabled {
    can_run("lvs");
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{inventory};

    foreach my $volume (_getLogicalVolumes(
        command => 'lvs -a --noheading --nosuffix --units M -o lv_name,vg_name,lv_attr,lv_size,lv_uuid,seg_count',
        logger  => $logger
    )) {
        $inventory->addEntry(section => 'LVS', entry => $volume);
    }

    foreach my $volume (_getPhysicalVolumes(
        command => 'pvs --noheading --nosuffix --units M -o +pv_uuid',
        logger  => $logger
    )) {
        $inventory->addEntry(section => 'PVS', entry => $volume);
    }

    foreach my $volume (_getVolumeGroups(
        command => 'vgs --noheading --nosuffix --units M -o +vg_uuid,vg_extent_size',
        logger  => $logger
    )) {
        $inventory->addEntry(section => 'VGS', entry => $volume);
    }
}

sub _getLogicalVolumes {
    my $handle = getFileHandle(@_);
    return unless $handle;

    my @volumes;
    while (my $line = <$handle>) {
        my @line = split(/\s+/, $line);

        push @volumes, {
            LVNAME => $line[1],
            VGNAME => $line[2],
            ATTR   => $line[3],
            SIZE   => int($line[4]||0),
            UUID   => $line[5],

        };
    }
    close $handle;

    return @volumes;
}

sub _parsePvs {
    my $handle = getFileHandle(@_);
    return unless $handle;

    my @volumes;
    while (my $line = <$handle>) {
        my @line = split(/\s+/, $line);

        push @volumes, {
            DEVICE => $line[1],
            PVNAME => $line[2],
            FORMAT => $line[3],
            ATTR   => $line[4],
            SIZE   => int($line[5]||0),
            FREE   => int($line[6]||0),
            UUID   => $line[7],
        }
    }
    close $handle;

    return @volumes;
}

sub _parseVgs {
    my $handle = getFileHandle(@_);
    return unless $handle;

    my @volumes;
    while (my $line = <$handle>) {
        my @line = split(/\s+/, $line);

        push @volumes, {
            VGNAME   => $line[1],
            PV_COUNT => $line[2],
            LV_COUNT => $line[3],
            ATTR     => $line[5],
            SIZE     => $line[6],
            FREE     => $line[7],
            UUID     => $line[8]
        }
    }
    close $handle;

    return @volumes;
}

1;
