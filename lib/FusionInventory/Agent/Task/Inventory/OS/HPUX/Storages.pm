package FusionInventory::Agent::Task::Inventory::OS::HPUX::Storages;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled  {
    return
        can_run('ioscan')    &&
        can_run('cut')       &&
        can_run('pvdisplay') &&
        can_run('diskinfo');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    my $description;
    my $path;
    my $vendor;
    my $ref;
    my $size;

    my $devdsk;
    my $devrdsk;
    my $revlvl;

    foreach ( `ioscan -kFnC disk | cut -d ':' -f 1,11,18` ) {
        if ( /(\S+)\:(\S+)\:(\S+)\s+(\S+)/ ) {
            $description = $1;
            $path = $2;
            $vendor = $3;
            $ref = $4;
        }
        my $alternate = 0 ;
        if ( /\s+(\/dev\/dsk\/\S+)\s+(\/dev\/rdsk\/\S+)/ ) {
            $devdsk  = $1;
            $devrdsk = $2;
            # We look if whe are on an alternate link
            foreach ( `pvdisplay $devdsk 2> /dev/null` ) {
                if ( /$devdsk\.+lternate/ ) {
                    $alternate = 1;
                }
            }

            # skip alternate link
            next if $alternate;

            foreach ( `diskinfo -v $devrdsk 2>/dev/null`) {
                if ( /^\s+size:\s+(\S+)/ ) {
                    $size=$1;
                    $size = int ( $size/1024 ) if $size;
                }
                if ( /^\s+rev level:\s+(\S+)/ ) {
                    $revlvl=$1;
                }
            }
            $inventory->addStorage({
                MANUFACTURER => $vendor,
                MODEL        => $ref,
                NAME         => $devdsk,
                DESCRIPTION  => $description,
                TYPE         => 'disk',
                DISKSIZE     => $size,
                FIRMWARE     => $revlvl,
            });
        }
    }

    foreach ( `ioscan -kFnC tape | cut -d ':' -f 1,11,18` ) {
        if ( /(\S+)\:(\S+)\:(\S+)\s+(\S+)/ ) {
            $description = $1;
            $path = $2;
            $vendor = $3;
            $ref = $4;
        }
        if ( /^\s+(\/dev\/rmt\/\Sm)\s+/ ) {
            $devdsk = $1;
            $inventory->addStorage({
                MANUFACTURER => $vendor,
                MODEL        => $ref,
                NAME         => $devdsk,
                DESCRIPTION  => $description,
                TYPE         => 'tape',
                DISKSIZE     => ''
            });
        }
    }
}

1;
