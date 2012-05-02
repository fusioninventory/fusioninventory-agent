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

    foreach my $device (@devices) {
        foreach my $disk (_getDiskFromMptStatus(
            name    => $device->{NAME},
            logger  => $logger,
            command => "mpt-status -n -i $device->{SCSI_UNID}"
        )) {
            $disk->{SERIALNUMBER} = getSerialnumber(
                device => "/dev/sg$disk->{id}"
            );
            delete $disk->{id};
            $inventory->addEntry(section => 'STORAGES', entry => $disk);
        }
    }

}

sub _getDiskFromMptStatus {
    my (%params) = @_;

    my $handle = getFileHandle(%params);
    next unless $handle;

    my @disks;
    while (my $line = <$handle>) {
        next unless $line =~ /phys_id:(\d+).*product_id:\s*(\S*)\s+revision:(\S+).*size\(GB\):(\d+)/;

        my $disk = {
            NAME         => $params{name},
            DESCRIPTION  => 'SATA',
            TYPE         => 'disk',
            id           => $1,
            MODEL        => $2,
            MANUFACTURER => getCanonicalManufacturer($2),
            FIRMWARE     => $3,
            SIZE         => $4 * 1024
        };

        push @disks, $disk;
    }
    close $handle;

    return @disks;
}

1;
