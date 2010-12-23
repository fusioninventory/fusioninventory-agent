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
    return can_run('mpt-status');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $devices = getDevicesFromUdev(logger => $logger);

    foreach my $hd (@$devices) {
        foreach (`mpt-status -n -i $hd->{SCSI_UNID}`) {
            next unless /phys_id:(\d+).*product_id:\s*(\S*)\s+revision:(\S+).*size\(GB\):(\d+)/;
            my $id = $1;

            my $storage = {
                NAME => $hd->{NAME},
                DESCRIPTION => 'SATA',
                TYPE        => 'disk',
                MODEL       => $2,
                FIRMWARE    => $3,
                SIZE        => $4 * 1024
            };

            $storage->{SERIALNUMBER} = getSerialnumberFromSmartctl(
                device => "/dev/sg$id"
            );
            $storage->{MANUFACTURER} = getCanonicalManufacturer(
                $storage->{MODEL}
            );

            $inventory->addStorage($storage);
        }
    }

}

1;
