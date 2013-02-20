package FusionInventory::Agent::Task::Inventory::Input::Linux::Storages::SCSI;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Linux;

my %disktypes = (
    0 => "Disk",
    5 => "CD-ROM"
);


sub isEnabled {
    return -r '/sys/class/scsi_device';
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $count = -1;

    opendir(D, "/sys/class/scsi_generic") || die "Can't opedir /sys/class/scsi_generic: $!\n";
    my @targets = readdir(D);
    closedir(D);

    # get data
    foreach my $target (@targets) {
        next if $target eq '.' || $target eq '..';

        my $dev = "/sys/class/scsi_generic/$target/device";
        my $type = getSysVal("$dev/type");
        # work only on Direct-Access and CD-ROM
        next if $type != 0 && $type != 5;

        my $manufacturer = getSysVal("$dev/vendor");
        # Omit ATA disks
        next if $manufacturer =~ /ATA/;

        my $model = getSysVal("$dev/model");
        my $firmware = getSysVal("$dev/rev");

        my $size;
        if (-e "$dev/block") {
            opendir(D, "$dev/block") || die "Can't opedir $dev/block: $!\n";
            my $blockdev;
            while ($blockdev = readdir(D)) {
                last if $blockdev ne '.' && $blockdev ne '..';
            }
            closedir(D);
            $size = getSysVal("$dev/block/$blockdev/size")/2048;
        }

        my $info = getInfoFromSmartctl(device => "/dev/$target");

	$inventory->addEntry(
            section => 'STORAGES',
            entry => {
                NAME         => "$manufacturer $model",
                MANUFACTURER => $manufacturer,
                MODEL        => $model,
                DESCRIPTION  => 'Storage',
                TYPE         => $disktypes{$type},
                DISKSIZE     => $size,
                SERIALNUMBER => $info->{SERIALNUMBER},
                FIRMWARE     => $firmware,
                INTERFACE    => $info->{DESCRIPTION}
            }
        );
    }
}

sub getSysVal {
    my $file = shift;
    my $val = undef;
    if (-e $file) {
        open(F, $file);
        $val = <F>;
        chomp($val);
        close(F);
    }
    return $val;
}

1;
