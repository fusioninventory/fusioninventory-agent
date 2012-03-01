package FusionInventory::Agent::Task::Inventory::Input::Solaris::Bios;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Solaris;

sub isEnabled {
    return
        canRun('showrev') ||
        canRun('/usr/sbin/smbios');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my ($SystemSerial, $SystemModel, $SystemManufacturer, $BiosManufacturer,
        $BiosVersion, $BiosDate, $uuid);

    my $zone = getZone();
    if ($zone) {

        my $arch;
        if (canRun('showrev')) {
            my $infos = _parseShowRev(logger => $logger);
            $SystemModel        = $infos->{'Application architecture'};
            $SystemManufacturer = $infos->{'Hardware provider'};
            $arch               = $infos->{'Application architecture'};
        } else {
            $arch =
                getFirstLine(command => 'arch') eq 'i86pc' ? 'i386' : 'unknown';
        }

        if ($arch eq "i386") {
            my $infos = _parseSmbios($logger);
            $SystemManufacturer = $infos->{'Manufacturer'};
            $SystemSerial       = $infos->{'Serial Number'};
            $SystemModel        = $infos->{'Product'};
            $BiosManufacturer   = $infos->{'Vendor'};
            $BiosVersion        = $infos->{'Version String'};
            $BiosDate           = $infos->{'Release Date'};
            $uuid               = $infos->{'UUID'};
        } elsif ($arch =~ /sparc/i) {
            my $infos = _parsePrtconf($logger);
            $SystemModel = $infos->{'banner-name'};
            $SystemModel .= " ($infos->{name})" if $infos->{name};

            # looks like : "OBP 4.16.4 2004/12/18 05:18"
            #    with further informations sometime
            if ($infos->{version} =~ m{OBP\s+([\d|\.]+)\s+(\d+)/(\d+)/(\d+)}) {
                $BiosVersion = "OBP $1";
                $BiosDate    = "$2/$3/$4";
            } else {
                $BiosVersion = $infos->{version};
            }

            my $command = -x '/opt/SUNWsneep/bin/sneep' ?
                '/opt/SUNWsneep/bin/sneep' : 'sneep';

            $SystemSerial = getFirstLine(
                command => $command,
                logger  => $logger
            );
        }
    } else {
        my $infos = _parseShowRev($logger);
        $SystemManufacturer = $infos->{'Hardware provider'};
        $SystemModel        = "Solaris Containers";
    }

    $inventory->setBios({
        BVERSION      => $BiosVersion,
        BDATE         => $BiosDate,
        BMANUFACTURER => $BiosManufacturer,
        SMANUFACTURER => $SystemManufacturer,
        SMODEL        => $SystemModel,
        SSN           => $SystemSerial
    });

    $inventory->setHardware({
        UUID => $uuid
    });
}

sub _parseShowRev {
    my (%params) = (
        command => 'showrev',
        @_
    );

    my $handle = getFileHandle(%params);
    return unless $handle;

    my $infos;
    while (my $line = <$handle>) {
        next unless $line =~ /^ ([^:]+) : \s+ (\S+)/x;
        $infos->{$1} = $2;
    }
    close $handle;

    return $infos;
}

sub _parseSmbios {
    my ($logger) = @_;

    my $handle = getFileHandle(
        command => "/usr/sbin/smbios",
        logger  => $logger
    );
    return unless $handle;

    my $infos;
    while (my $line = <$handle>) {
        next unless $line =~ /^ \s* ([^:]+) : \s* (.+) $/x;
        $infos->{$1} = $2;
    }
    close $handle;

    return $infos;
}

sub _parsePrtconf {
    my ($logger) = @_;

    my $handle = getFileHandle(
        command => "/usr/sbin/prtconf -pv",
        logger  => $logger
    );
    return unless $handle;

    my $infos;
    while (my $line = <$handle>) {
        next unless $line =~ /^ \s* ([^:]+) : \s* ' (.+) '$/x;
        next if $infos->{$1};
        $infos->{$1} = $2;
    }
    close $handle;

    return $infos;
}

1;
