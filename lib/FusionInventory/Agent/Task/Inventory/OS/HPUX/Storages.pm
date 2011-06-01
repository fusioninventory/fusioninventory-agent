package FusionInventory::Agent::Task::Inventory::OS::HPUX::Storages;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isEnabled  {
    return
        can_run('ioscan')    &&
        can_run('cut')       &&
        can_run('pvdisplay') &&
        can_run('diskinfo');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    foreach my $device (
        _parseIoscan(command => 'ioscan -kFnC disk', logger => $logger)
    ) {
        # skip alternate links
        next if
            any { /$device->{NAME}\.+lternate/ }
            `pvdisplay $device->{NAME} 2> /dev/null`;

        foreach ( `diskinfo -v $device->{NAME} 2>/dev/null`) {
            if ( /^\s+size:\s+(\S+)/ ) {
                $device->{DISKSIZE} = int( $1/1024 );
            }
            if ( /^\s+rev level:\s+(\S+)/ ) {
                $device->{FIRMWARE} = $1;
            }
        }

        $device->{TYPE} = 'disk';
        $inventory->addEntry(section => 'STORAGES', entry => $device);
    }

    foreach my $device (
        _parseIoscan(command => 'ioscan -kFnC tape', logger => $logger)
    ) {
        $device->{TYPE} = 'tape';
        $inventory->addEntry(section => 'STORAGES', entry => $device);
    }

}

sub _parseIoscan {
    my $handle = getFileHandle(@_);
    return unless $handle;

    my @devices;
    my ($description, $model, $manufacturer);
    while (my $line = <$handle>) {
        if ($line =~ /^\s+(\S+)/ ) {
            my $device = $1;

            push @devices, {
                MANUFACTURER => $manufacturer,
                MODEL        => $model,
                NAME         => $device,
                DESCRIPTION  => $description,
            };
        } else {
            my @infos = split(/:/, $line);
            $description = $infos[0];
            ($manufacturer, $model) = $infos[17] =~ /^(\S+) \s+ (\S.*\S)$/x;
        }
    }
    close $handle;

    return @devices;
}

1;
