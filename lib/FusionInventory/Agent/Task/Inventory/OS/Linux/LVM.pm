package FusionInventory::Agent::Task::Inventory::OS::Linux::LVM;

use FusionInventory::Agent::Tools;
# LVM for HP-UX and Linux
use strict;

use warnings;

use English qw(-no_match_vars);


sub isInventoryEnabled {
    can_run("lvdisplay");
}

sub _parseLvs {
    my $handle = getFileHandle(@_);

    my $entries = [];
    foreach (<$handle>) {
        my @line = split(/\s+/, $_);

        push @$entries, {
            LV_NAME => $line[1],
            VG_UUID => $line[2],
            ATTR => $line[3],
            SIZE => int($line[4]||0),
            LV_UUID => $line[5],
            SEG_COUNT => $line[6],
        };

    }

    return $entries;
}

sub _parsePvs {
    my $handle = getFileHandle(@_);

    my $entries = [];
    foreach (<$handle>) {
        my @line = split(/\s+/, $_);
        push @$entries, {
            DEVICE => $line[1],
            PV_NAME => $line[2],
            FORMAT => $line[3],
            ATTR => $line[4],
            SIZE => int($line[5]||0),
            FREE => int($line[6]||0),
            PV_UUID => $line[7],
            PV_PE_COUNT => $line[8],
            PE_SIZE => int($line[5] / $line[8])
        }

    }

    return $entries;
}

sub _parseVgs {
    my $handle = getFileHandle(@_);

    my $entries = [];
    foreach (<$handle>) {
        my @line = split(/\s+/, $_);

        push @$entries, {
            VG_NAME => $line[1],
            PV_COUNT => $line[2],
            LV_COUNT => $line[3],
            ATTR => $line[5],
            SIZE => int($line[6]||0),
            FREE => int($line[7]||0),
            VG_UUID => $line[8],
            VG_EXTENT_SIZE => $line[9],
        }

    }

    return $entries;
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};
    my $pvs = _parsePvs('command' => 'pvs --noheading --nosuffix --units M -o +pv_uuid,pv_pe_count,pv_size 2>/dev/null');
    $inventory->addPhysicalVolume($_) foreach (@$pvs);
    my $lvs = _parseLvs('command' => 'lvs -a --noheading --nosuffix --units M -o lv_name,vg_uuid,lv_attr,lv_size,lv_uuid,seg_count 2>/dev/null');
    $inventory->addLogicalVolume($_) foreach (@$lvs);
    my $vgs = _parseVgs('command' => 'vgs --noheading --nosuffix --units M -o +vg_uuid,vg_extent_size,pv_uuid 2>/dev/null');
    $inventory->addVolumeGroup($_) foreach (@$vgs);

}

1;
