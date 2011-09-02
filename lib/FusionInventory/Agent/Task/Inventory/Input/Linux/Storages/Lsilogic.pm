package FusionInventory::Agent::Task::Inventory::Input::Linux::Storages::Lsilogic;

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

sub isEnabled {
    return canRun('mpt-status');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my @devices = getDevicesFromUdev(logger => $logger);

    foreach my $hd (@devices) {
        my $handle = getFileHandle(
            logger => $logger,
            command => "mpt-status -n -i $hd->{SCSI_UNID}"
        );
        next unless $handle;
        while (my $line = <$handle>) {
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

            $storage->{SERIALNUMBER} = getSerialnumber(
                device => "/dev/sg$id"
            );
            $storage->{MANUFACTURER} = getCanonicalManufacturer(
                $storage->{MODEL}
            );

            $inventory->addEntry(section => 'STORAGES', entry => $storage);
        }
        close $handle;
    }

}

1;
