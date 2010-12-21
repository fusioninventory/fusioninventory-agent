package FusionInventory::Agent::Task::Inventory::OS::Linux::Storages::3ware;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Linux;

# Tested on 2.6.* kernels
#
# Cards tested :
#
# 8006-2LP
# 9500S-4LP
# 9550SXU-4LP
# 9550SXU-8LP
# 9650SE-2LP
# 9650SE-4LPML
# 9650SE-8LPML
#
# AMCC/3ware CLI (version 2.00.0X.XXX)

sub isInventoryEnabled {
    return can_run('tw_cli');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $devices = getDevicesFromUdev(logger => $logger);

    foreach my $card (_getCards()) {
        foreach my $unit (_getUnits($card)) {

            # Try do get unit's serial in order to compare it to what was found
            # in udev db.
            # Works only on newer cards.
            # Allow us to associate a node to a drive : sda -> WD-WMANS1648590
            my $sn =
                `tw_cli info $card->{id} $unit->{id} serial 2> /dev/null`;
            $sn =~ s/serial number\s=\s(\w*)\s*/$1/;

            foreach my $port (_getPorts($card, $unit)) {
                # Finally, getting drives' values.
                my $storage = _getStorage($card, $port);

                foreach my $device (@$devices) {
                    # How does this work with multiple older cards
                    # where serial for units is not implemented ?
                    # Need to be tested on a system with multiple
                    # 3ware cards.
                    if (
                        $device->{SERIALNUMBER} eq 'AMCC_' . $sn ||
                        $device->{MODEL} eq 'Logical_Disk_' . $unit->{index}
                    ) {
                        $storage->{NAME} = $device->{NAME};
                    }
                }

                $inventory->addStorage($storage);
            }
        }
    }
}


sub _getCards {

    my @cards;
    foreach (`tw_cli info`) {
        next unless /^(c\d+)\s+([\w-]+)/;
        push @cards, { id => $1, model => $2 };
    }

    return @cards;
}

sub _getUnits {
    my ($card) = @_;

    my @units;
    foreach (`tw_cli info $card->{id}`) {
        next unless /^(u(\d+))/;
        push @units, { id => $1, index => $2 };
    }

    return @units;
}

sub _getPorts {
    my ($card, $unit) = @_;

    my @ports;
    foreach(`tw_cli info $card->{id} $unit->{id}`) {
        next unless /(p\d+)/;
        push @ports, { id => $1 }
    }

    return @ports;
}

sub _getStorage {
    my ($card, $port) = @_;

    my $storage;
    foreach (`tw_cli info $card->{id} $port->{id} model serial capacity firmware`) {
        if (/Model\s=\s(.*)/) {
            $storage->{MODEL} = $1;
        } elsif (/Serial\s=\s(.*)/) {
            $storage->{SERIALNUMBER} = $1;
        } elsif (/Capacity\s=\s(\S+)\sGB.*/) {
            $storage->{DISKSIZE} = 1024 * $1;
        } elsif (/Firmware Version\s=\s(.*)/) {
            $storage->{FIRMWARE} = $1
        }
    }

    $storage->{MANUFACTURER} = getCanonicalManufacturer(
        $storage->{MODEL}
    );
    $storage->{TYPE} = 'disk';

    # Getting description from card model, very basic
    # and unreliable
    # Assuming only IDE drives can be plugged in
    # 5xxx/6xxx cards and
    # SATA drives only to 7xxx/8xxx/9xxxx cards
    $storage->{DESCRIPTION} = 
        $card->{model} =~ /^[56]/  ? 'IDE'  :
        $card->{model} =~ /^[789]/ ? 'SATA' :
        undef;

    return $storage;
}

1;
