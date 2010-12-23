package FusionInventory::Agent::Task::Inventory::OS::Linux::Storages::Adaptec;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Linux;

# Tested on 2.6.* kernels
#
# Cards tested :
#
# Adaptec AAC-RAID

sub isInventoryEnabled {
    return -r '/proc/scsi/scsi';
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $devices = getDevicesFromUdev(logger => $logger);

    foreach my $hd (@$devices) {
        next unless $hd->{MANUFACTURER};
        next unless $hd->{MANUFACTURER} eq 'Adaptec';

        my $handle = getFilehandle(file => '/proc/scsi/scsi');
        next unless $handle;

# Example output:
        #
# Attached devices:
# Host: scsi0 Channel: 00 Id: 00 Lun: 00
#   Vendor: Adaptec  Model: raid10           Rev: V1.0
#   Type:   Direct-Access                    ANSI  SCSI revision: 02
# Host: scsi0 Channel: 01 Id: 00 Lun: 00
#   Vendor: HITACHI  Model: HUS151436VL3800  Rev: S3C0
#   Type:   Direct-Access                    ANSI  SCSI revision: 03
# Host: scsi0 Channel: 01 Id: 01 Lun: 00
#   Vendor: HITACHI  Model: HUS151436VL3800  Rev: S3C0
#   Type:   Direct-Access                    ANSI  SCSI revision: 03

        my $count = -1;
        while (<$handle>) {
            next unless /^Host:\sscsi$hd->{SCSI_COID}/;
            $count++;
            next unless /Model:\s(\S+).*Rev:\s(\S+)/;
            my $storage = {
                NAME        => $hd->{NAME},
                DESCRIPTION => 'SATA',
                TYPE        => 'disk',
                MODEL       => $1,
                FIRMWARE    => $2
            };
            next if $storage->{MODEL} =~ 'raid';

            $storage->{MANUFACTURER} = getCanonicalManufacturer(
                $storage->{MODEL}
            );
            $storage->{SERIALNUMBER} = getSerialnumberFromSmartctl(device => "/dev/sg$count");

            $inventory->addStorage($storage);
        }
        close $handle;
    }
}

1;
