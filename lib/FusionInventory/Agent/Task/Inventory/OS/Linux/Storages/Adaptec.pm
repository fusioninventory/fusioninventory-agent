package FusionInventory::Agent::Task::Inventory::OS::Linux::Storages::Adaptec;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Task::Inventory::OS::Linux::Storages;

# Tested on 2.6.* kernels
#
# Cards tested :
#
# Adaptec AAC-RAID

my @devices = FusionInventory::Agent::Task::Inventory::OS::Linux::Storages::getFromUdev();

sub isInventoryEnabled {

    if (can_run ('smartctl') ) { 
        foreach my $hd (@devices) {
            next unless $hd->{MANUFACTURER};

            if ($hd->{MANUFACTURER} eq 'Adaptec') {
                return 1;
            }
        }
    }
    return 0;

}

sub doInventory {

    my $params = shift;
    my $inventory = $params->{inventory};
    my $logger = $params->{logger};

    if (-r '/proc/scsi/scsi') {
        foreach my $hd (@devices) {
            my $handle;
            if (!open $handle, '<', '/proc/scsi/scsi') {
                warn "Can't open /proc/scsi/scsi: $ERRNO";
                next;
            }

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

            my ($host, $model, $firmware, $manufacturer, $size, $serialnumber);
            my $count = -1;
            while (<$handle>) {
                ($host, $count) = (1, $count+1) if /^Host:\sscsi$hd->{SCSI_COID}.*/;
                if ($host) {
                    if ((/.*Model:\s(\S+).*Rev:\s(\S+).*/) and ($1 !~ 'raid.*')) {
                        $model = $1;
                        $firmware = $2;
                        $manufacturer = FusionInventory::Agent::Task::Inventory::OS::Linux::Storages::getManufacturer($model);
                        foreach (`smartctl -i /dev/sg$count`) {
                            $serialnumber = $1 if /^Serial Number:\s+(\S*).*/;
                        }
                        $logger->debug("Adaptec: $hd->{NAME}, $manufacturer, $model, SATA, disk, $hd->{DISKSIZE}, $serialnumber, $firmware");
                        $host = undef;

                        $inventory->addStorages({
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
            close $handle;
        }
    }

}

1;
