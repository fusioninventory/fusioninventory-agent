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

    my ($tw_cli, $hd);

    my ($card, $card_model, $unit, $unit_id, $port, $serialnumber, $serial, $model, $capacity, $firmware, $description, $media, $device, $manufacturer, $sn);

    my $devices = getDevicesFromUdev(logger => $logger);

    # First, getting the cards : c0, c1... etc.
    foreach (`tw_cli info`) {
        if (/^(c\d)+\s+([\w|-]+)/) {
            $card = $1;
            $card_model = $2;
            $logger->debug("Card : $card - Model : $card_model");

        }
        if ($card) {

            # Second, getting the units : u0, u1... etc.
            foreach (`tw_cli info $card`) {

                if (/^(u)(\d+).*/) {
                    $unit = $1 . $2;
                    $unit_id = $2;
                }
                if ($unit) {

                    # Try do get unit's serial in order to compare it to what
                    # was found in udev db.
                    # Works only on newer cards.
                    # Allow us to associate a node to a drive : sda ->
                    # WD-WMANS1648590
                    $sn = `tw_cli info $card $unit serial 2> /dev/null`;
                    $sn =~ s/^.*serial number\s=\s(\w*)\s*/$1/;

                    # Third, getting the ports : p0, p1... etc.
                    foreach(`tw_cli info $card $unit`) {
                        $port =  $1 if /^.*(p\d+).*/;
                        if ($port) {

                            # Finally, getting drives' values.
                            foreach (`tw_cli info $card $port model serial capacity firmware`) {

                                $model = $1 if /^.*Model\s=\s(.*)/;
                                $serialnumber = $1 if /^.*Serial\s=\s(.*)/;
                                $capacity = 1024*$1 if /^.*Capacity\s=\s(\S+)\sGB.*/;
                                $firmware = $1 if /^.*Firmware Version\s=\s(.*)/;
                            }
                            foreach my $hd (@$devices) {

                                # How does this work with multiple older cards
                                # where serial for units is not implemented ?
                                # Need to be tested on a system with multiple
                                # 3ware cards.
                                if (($hd->{SERIALNUMBER} eq 'AMCC_' . $sn) or ($hd->{MODEL} eq 'Logical_Disk_' . $unit_id)) {
                                    $device = $hd->{NAME};
                                }
                            }

                            # Getting description from card model, very basic
                            # and unreliable
                            # Assuming only IDE drives can be plugged in
                            # 5xxx/6xxx cards and
                            # SATA drives only to 7xxx/8xxx/9xxxx cards
                            $description = undef;
                            foreach ($card_model) {
                                $description = "IDE" if /^[5-6].*/;
                                $description = "SATA" if /^[7-9].*/;
                            }
                            $media = 'disk';
                            $manufacturer = getCanonicalManufacturer($model);
                            $port = undef;
                            $logger->debug("3ware: $device, $manufacturer, $model, $description, $media, $capacity, $serialnumber, $firmware");
                            $inventory->addStorage({
                                    NAME => $device,
                                    MANUFACTURER => $manufacturer,
                                    MODEL => $model,
                                    DESCRIPTION => $description,
                                    TYPE => $media,
                                    DISKSIZE => $capacity,
                                    SERIALNUMBER => $serialnumber,
                                    FIRMWARE => $firmware,
                                });
                        }
                        $port = undef;
                    }
                    $unit = undef;
                }
            }
            $card = undef;
            $card_model = undef;
        }
    }
}

1;
