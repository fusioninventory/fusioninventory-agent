package FusionInventory::Agent::Task::Inventory::OS::AIX::Hardware;

use strict;
use warnings;

use List::Util qw(first);

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::AIX;

sub isInventoryEnabled {
    return 1;
}

# NOTE:
# Q: SSN can also use `uname -n`? What is the best?
# A: uname -n since it doesn't need root priv

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    # Using "type 0" section
    my ($SystemSerial, $SystemModel, $BiosVersion, $BiosDate, $flag);

    # lsvpd
    my @devices = getDevicesFromLsvpd(logger => $logger);

    my $system = first { $_->{DS} eq 'System Firmware' } @devices;
    $BiosVersion = $system->{RM} if $system;

    my $platform = first { $_->{DS} eq 'Platform Firmware' } @devices;
    $BiosVersion .= "(Firmware : $platform->{RM})" if $platform;

    my $vpd = first { $_->{DS} eq 'System VPD' } @devices;
    if ($vpd) {
        $SystemModel = $vpd->{TM};
        $SystemSerial = $vpd->{SE};
    }

    # fetch the serial number like prtconf do
    if (! $SystemSerial) {
        $flag = 0;
        foreach (getAllLines(command => 'lscfg -vpl sysplanar0')) {
            if (/\s+System\ VPD/) {
                $flag = 1;
                next;
            }
            next unless $flag;
            if ($flag && /\.+(\S*?)$/) {
                $SystemSerial = $1;
                last;
            }
        }
    }


    # Writing data
    $inventory->setBios({
        SMANUFACTURER => 'IBM',
        SMODEL        => $SystemModel,
        SSN           => $SystemSerial,
        BMANUFACTURER => 'IBM',
        BVERSION      => $BiosVersion,
        BDATE         => $BiosDate,
    });
}

1;
