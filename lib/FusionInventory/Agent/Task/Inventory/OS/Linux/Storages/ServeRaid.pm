package FusionInventory::Agent::Task::Inventory::OS::Linux::Storages::ServeRaid;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

# Tested on 2.6.* kernels
#
# Cards tested :
#
# IBM ServeRAID-6M 
# IBM ServeRAID-6i

sub isInventoryEnabled {
    return can_run('ipssend');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};
    my $slot;

    foreach (`ipssend GETVERSION 2>/dev/null`) {

# Example Output :
# Found 1 IBM ServeRAID controller(s).
#----------------------------------------------------------------------
#ServeRAID Controller(s) Version Information
#----------------------------------------------------------------------
#   Controlling BIOS version       : 7.00.14
        #
#ServeRAID Controller Number 1
#   Controller type                : ServeRAID-6M
#   Controller slot information    : 2
#   Actual BIOS version            : 7.00.14
#   Firmware version               : 7.00.14
#   Device driver version          : 7.10.18

        $slot = $1 if /.*ServeRAID Controller Number\s(\d*).*/;

        next unless /.*Controller type.*:\s(.*)/;
        my $name = $1;
        my ($serial, $capacity, $scsi, $channel, $state);

        foreach (`ipssend GETCONFIG $slot PD 2>/dev/null`) {
# Example Output :
#   Channel #1:
#      Target on SCSI ID 0
#         Device is a Hard disk
#         SCSI ID                  : 0
#         PFA (Yes/No)             : No
#         State                    : Online (ONL)
#         Size (in MB)/(in sectors): 34715/71096368
#         Device ID                : IBM-ESXSCBR036C3DFQDB2Q6CDKM
#         FRU part number          : 32P0729

            $channel        = $1 if /.*Channel #(.*):/;
            $scsi           = $1 if /.*SCSI ID.*:\s(.*)/;
            $state          = $1 if /.*State.*\((.*)\)/;            
            $capacity       = $1 if /.*Size.*:\s(\d*)\/(\d*)/;
            $serial         = $1 if /.*Device ID.*:\s(.*)/;

            if (/.*FRU part number.*:\s(.*)/) {
                my $model = $1;
                my $manufacturer = getCanonicalManufacturer($serial);
                ## my $fullname = "$name $slot/$channel/$scsi $state";

                $inventory->addStorage({
                    NAME            => "$manufacturer $model",
                    MANUFACTURER    => $manufacturer,
                    MODEL           => $model,
                    DESCRIPTION     => "SCSI",
                    TYPE            => "disk",
                    DISKSIZE        => $capacity,
                    SERIALNUMBER    => $serial,
                    FIRMWARE        => ""}
                ); 

                # don't undef $channel, appear only once for several drive.
                $scsi = $state = $capacity = $serial = undef;
            }
        }
    }
}

1;

