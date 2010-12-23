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

    foreach my $device (@$devices) {
        next unless $device->{MANUFACTURER};
        next unless $device->{MANUFACTURER} eq 'Adaptec';

        foreach my $storage (_getStoragesFromProc(device => $device, logger => $logger)) {
            $inventory->addStorage($storage);
        }
    }
}

sub _getStoragesFromProc {
    my %params = (
        file => '/proc/scsi/scsi',
        @_
    );

    return unless $params{device};

    my $handle = getFilehandle(file => $params{file}, logger => $params{logger});
    next unless $handle;

    my @storages;

    my $count = -1;
    while (<$handle>) {
        next unless /^Host:\sscsi$params{device}->{SCSI_COID}/;
        $count++;
        next unless /Model:\s(\S+).*Rev:\s(\S+)/;
        my $storage = {
            NAME        => $params{device}->{NAME},
            DESCRIPTION => 'SATA',
            TYPE        => 'disk',
            MODEL       => $1,
            FIRMWARE    => $2
        };
        next if $storage->{MODEL} =~ 'raid';

        $storage->{MANUFACTURER} = getCanonicalManufacturer(
            $storage->{MODEL}
        );
        $storage->{SERIALNUMBER} = getSerialnumber(device => "/dev/sg$count");

        push @storages, $storage;
    }
    close $handle;

    return @storages;
}

1;
