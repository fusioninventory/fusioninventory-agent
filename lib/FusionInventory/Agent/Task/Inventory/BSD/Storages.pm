package FusionInventory::Agent::Task::Inventory::BSD::Storages;

use strict;
use warnings;

use XML::TreePP;

use FusionInventory::Agent::Tools;

sub isEnabled {
    my (%params) = @_;
    return 0 if $params{no_category}->{storage};
    return canRun('sysctl');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $storages = _retrieveStoragesFromSysCtl(
        logger => $logger
    );
    for my $storage (@$storages) {
        $inventory->addEntry(
            section => 'STORAGES',
            entry   => $storage
        );
    }
}

sub _retrieveStoragesFromSysCtl {
    my (%params) = @_;

    my @storages = _getDevicesFromSysCtl(
        %params,
        file => $params{sysctlFile} ? $params{sysctlFile} : ''
    );
    _extractDataFromDmesg(
        file => $params{dmesgFile} ? $params{dmesgFile} : '',
        storages => \@storages
    );

    return @storages;
}

sub _getDevicesFromSysCtl {
    my (%params) = @_;

    my $command = 'sysctl kern.geom.confxml';
    my $lines = getAllLines(
        command => $command,
        %params
    );
    $lines =~ s/^kern.geom.confxml://;
    my $tpp = XML::TreePP->new();
    my $tree = $tpp->parse($lines);

    my @devices = ();
    for my $class (@{$tree->{mesh}->{class}}) {
        my $name = $class->{name} || $class->{'#name'} || '';
        next unless ($name && $name eq 'DISK');
        for my $geom (@{$class->{geom}}) {
            my $device = {};
            $device->{NAME} = $geom->{name} if $geom->{name};
            $device->{DESCRIPTION} = $geom->{provider}->{config}->{descr}
                if ($geom->{provider}
                    && $geom->{provider}->{config}
                    && $geom->{provider}->{config}->{descr});
            $device->{DISKSIZE} = $geom->{provider}->{mediasize}
                if ($geom->{provider}
                    && defined $geom->{provider}->{mediasize});
            $device->{TYPE} = _retrieveDeviceTypeFromName($device->{NAME});
            push @devices, $device;
        }
    }

    return @devices;
}

sub _retrieveDeviceTypeFromName {
    my $name = shift;
    my $type = not (defined $name) ? 'unknown' :
            $name =~ /^da/ ? 'disk' :
            $name =~ /^ada/ ? 'disk' :
            $name =~ /^cd/ ? 'cdrom' :
                'unknown';
    return $type;
}

sub _extractDataFromDmesg {
    my (%params) = @_;

    my $storages = $params{storages};

    my $dmesgLines = getAllLines(
        command => 'dmesg',
        %params
    );
    for my $storage (@$storages) {
        next unless $storage->{NAME};
        $storage->{MODEL} = getFirstMatch(
            string => $dmesgLines,
            pattern => qr/^\Q$storage->{NAME}\E.*<(.*)>/
        ) || '';
        my $desc = getFirstMatch(
            string => $dmesgLines,
            pattern => qr/^\Q$storage->{NAME}\E: (.*<.*>.*)$/
        );
        $storage->{DESCRIPTION} = $desc if $desc;
        $storage->{SERIALNUMBER} = getFirstMatch(
            string => $dmesgLines,
            pattern => qr/^\Q$storage->{NAME}\E: Serial Number (.*)$/
        ) || '';

        if ($storage->{MODEL}) {
            if ($storage->{MODEL} =~ s/^(SGI|SONY|WDC|ASUS|LG|TEAC|SAMSUNG|PHILIPS|PIONEER|MAXTOR|PLEXTOR|SEAGATE|IBM|SUN|SGI|DEC|FUJITSU|TOSHIBA|YAMAHA|HITACHI|VERITAS)\s*//i) {
                $storage->{MANUFACTURER} = $1;
            }

            # clean up the model
            $storage->{MODEL} =~ s/^(\s|,)*//;
            $storage->{MODEL} =~ s/(\s|,)*$//;
        }
    }
}

sub _getDevicesFromFstab {
    my (%params) = (
        file => '/etc/fstab',
        @_
    );

    my $handle = getFileHandle(%params);
    return unless $handle;

    my (@devices, %seen);
    while (my $line = <$handle>) {
        next unless $line =~ m{^/dev/(\S+)};
        next if $seen{$1}++;
        push @devices, { DESCRIPTION => $1 };
    }
    close $handle;

    return @devices;
}

1;
