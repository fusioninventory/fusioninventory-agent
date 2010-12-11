package FusionInventory::Agent::Task::Inventory::OS::Linux::Storages::Lsilogic;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Linux;

# Tested on 2.6.* kernels
#
# Cards tested :
#
# LSI Logic / Symbios Logic SAS1064E PCI-Express Fusion-MPT SAS
#
# mpt-status version : 1.2.0

sub isInventoryEnabled {
    return can_run('smartctl');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $serialnumber;

    my $devices = getDevicesFromUdev(logger => $logger);

    foreach my $hd (@$devices) {
        foreach (`mpt-status -n -i $hd->{SCSI_UNID}`) {

# Example output :
            #
# ioc:0 vol_id:0 type:IM raidlevel:RAID-1 num_disks:2 size(GB):148 state: OPTIMAL flags: ENABLED
# ioc:0 phys_id:1 scsi_id:2 vendor:ATA      product_id:ST3160815AS      revision:D    size(GB):149 state: ONLINE flags: NONE sync_state: 100 ASC/ASCQ:0xff/0xff SMART ASC/ASCQ:0xff/0xff
#ioc:0 phys_id:0 scsi_id:1 vendor:ATA      product_id:ST3160815AS      revision:D    size(GB):149 state: ONLINE flags: NONE sync_state: 100 ASC/ASCQ:0xff/0xff SMART ASC/ASCQ:0xff/0xff
#scsi_id:1 100%
#scsi_id:0 100%

            if (/.*phys_id:(\d+).*product_id:\s*(\S*)\s+revision:(\S+).*size\(GB\):(\d+).*/) {
                $serialnumber = undef;
                foreach (`smartctl -i /dev/sg$1`) {
                    $serialnumber = $1 if /^Serial Number:\s+(\S*)/;
                }
                my $model = $2;
                my $size = 1024*$4; # GB => MB
                my $firmware = $3;
                my $manufacturer = getCanonicalManufacturer($model);
                $logger->debug("Lsilogic: $hd->{NAME}, $manufacturer, $model, SATA, disk, $size, $serialnumber, $firmware");

                $inventory->addStorage({
                    NAME => $hd->{NAME},
                    MANUFACTURER => $manufacturer,
                    MODEL => $model,
                    DESCRIPTION => 'SATA',
                    TYPE => 'disk',
                    DISKSIZE => $size,
                    SERIALNUMBER => $serialnumber,
                    FIRMWARE => $firmware,
                });
            }
        }
    }

}

1;
