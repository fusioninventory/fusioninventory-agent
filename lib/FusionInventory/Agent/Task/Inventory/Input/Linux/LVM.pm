package FusionInventory::Agent::Task::Inventory::Input::Linux::LVM;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;

sub isEnabled {
    canRun('lvs');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{inventory};

    foreach my $volume (_getLogicalVolumes(
        command => 'lvs -a --noheading --nosuffix --units M -o lv_name,vg_name,lv_attr,lv_size,lv_uuid,seg_count',
        logger  => $logger
    )) {
        $inventory->addEntry(section => 'LOGICAL_VOLUMES', entry => $volume);
    }

    foreach my $volume (_getPhysicalVolumes(
        command => 'pvs --noheading --nosuffix --units M -o +pv_uuid,pv_pe_count,pv_size',
        logger  => $logger
    )) {
        $inventory->addEntry(section => 'PHYSICAL_VOLUMES', entry => $volume);
    }

    foreach my $group (_getVolumeGroups(
        command => 'vgs --noheading --nosuffix --units M -o +vg_uuid,vg_extent_size,pv_uuid',
        logger  => $logger
    )) {
        $inventory->addEntry(section => 'VOLUME_GROUPS', entry => $group);
    }
}

sub _getLogicalVolumes {
    my $handle = getFileHandle(@_);
    return unless $handle;

    my @volumes;
    while (my $line = <$handle>) {
        my @infos = split(/\s+/, $line);

        push @volumes, {
            LV_NAME   => $infos[1],
            VG_UUID   => $infos[2],
            ATTR      => $infos[3],
            SIZE      => int($infos[4]||0),
            LV_UUID   => $infos[5],
            SEG_COUNT => $infos[6],
        }

    }
    close $handle;

    return @volumes;
}

sub _getPhysicalVolumes {
    my $handle = getFileHandle(@_);
    return unless $handle;

    my @volumes;
    while (my $line = <$handle>) {
        my @infos = split(/\s+/, $line);

        push @volumes, {
            DEVICE      => $infos[1],
            PV_NAME     => $infos[2],
            FORMAT      => $infos[3],
            ATTR        => $infos[4],
            SIZE        => int($infos[5]||0),
            FREE        => int($infos[6]||0),
            PV_UUID     => $infos[7],
            PV_PE_COUNT => $infos[8],
            PE_SIZE     =>  int($infos[5] / $infos[8])
        };
    }
    close $handle;

    return @volumes;
}

sub _getVolumeGroups {
    my $handle = getFileHandle(@_);
    return unless $handle;

    my @groups;
    while (my $line = <$handle>) {
        my @infos = split(/\s+/, $line);

        push @groups, {
            VG_NAME        => $infos[1],
            PV_COUNT       => $infos[2],
            LV_COUNT       => $infos[3],
            ATTR           => $infos[5],
            SIZE           => int($infos[6]||0),
            FREE           => int($infos[7]||0),
            VG_UUID        => $infos[8],
            VG_EXTENT_SIZE => $infos[9],
        };
    }
    close $handle;

    return @groups;
}

1;
