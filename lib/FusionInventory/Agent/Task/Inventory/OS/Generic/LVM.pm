package FusionInventory::Agent::Task::Inventory::OS::Generic::LVM;

# LVM for HP-UX and Linux
use strict;

use warnings;

use English qw(-no_match_vars);


sub isInventoryEnabled {
    can_run("lvdisplay");
}

sub _parseLvs {
    my ($file, $mode) = @_;

    my $handle;
    if (!open $handle, $mode, $file) {
        warn "Can't open $file: $ERRNO";
        return;
    }

    my $entries = [];
    foreach (<$handle>) {
        my @line = split(/\s+/, $_);

        push @$entries, {
            LVNAME => $line[1],
            VGNAME => $line[2],
            ATTR => $line[3],
            SIZE => int($line[4]||0),
            UUID => $line[5],

        };

    }

    return $entries;
}

sub _parsePvs {
    my ($file, $mode) = @_;

    my $handle;
    if (!open $handle, $mode, $file) {
        warn "Can't open $file: $ERRNO";
        return;
    }

    my $entries = [];
    foreach (<$handle>) {
        my @line = split(/\s+/, $_);

        push @$entries, {
            DEVICE => $line[1],
            PVNAME => $line[2],
            FORMAT => $line[3],
            ATTR => $line[4],
            SIZE => int($line[5]||0),
            FREE => int($line[6]||0),
            UUID => $line[7],
        }

    }

    return $entries;
}

sub _parseVgs {
    my ($file, $mode) = @_;

    my $handle;
    if (!open $handle, $mode, $file) {
        warn "Can't open $file: $ERRNO";
        return;
    }

    my $entries = [];
    foreach (<$handle>) {
        my @line = split(/\s+/, $_);

        push @$entries, {
            VGNAME => $line[1],
            PV_COUNT => $line[2],
            LV_COUNT => $line[3],
            ATTR => $line[5],
            SIZE => $line[6],
            FREE => $line[7],
            UUID => $line[8]
        }

    }

    return $entries;
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $lvs = _parseLvs('lvs -a --noheading --nosuffix --units M -o lv_name,vg_name,lv_attr,lv_size,lv_uuid,seg_count 2>/dev/null', '-|');
    $inventory->addLogicalVolume($_) foreach (@$lvs);
    my $pvs = _parsePvs('pvs --noheading --nosuffix --units M -o +pv_uuid 2>/dev/null', '-|');
    $inventory->addPhysicalVolume($_) foreach (@$pvs);
    my $vgs = _parseVgs('vgs --noheading --nosuffix --units M -o +vg_uuid,vg_extent_size 2>/dev/null', '-|');
    $inventory->addVolumeGroup($_) foreach (@$vgs);

}

1;
