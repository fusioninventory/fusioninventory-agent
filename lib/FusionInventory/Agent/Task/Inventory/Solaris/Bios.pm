package FusionInventory::Agent::Task::Inventory::Solaris::Bios;

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

    my ($bios, $hardware);

    if (getZone() eq 'global') {
        my $arch;
        if (canRun('showrev')) {
            my $infos = _parseShowRev(logger => $logger);
            $bios->{SMODEL}        = $infos->{'Application architecture'};
            $bios->{SMANUFACTURER} = $infos->{'Hardware provider'};
            $arch               = $infos->{'Application architecture'};
        } else {
            $arch =
                getFirstLine(command => 'arch') eq 'i86pc' ? 'i386' : 'unknown';
        }

        if ($arch eq "i386") {
            my $infos = _parseSmbios(logger => $logger);

            my $biosInfos = $infos->{SMB_TYPE_BIOS};
            $bios->{BMANUFACTURER} = $biosInfos->{'Vendor'};
            $bios->{BVERSION}      = $biosInfos->{'Version String'};
            $bios->{BDATE}         = $biosInfos->{'Release Date'};

            my $systemInfos = $infos->{SMB_TYPE_SYSTEM};
            $bios->{SMANUFACTURER} = $systemInfos->{'Manufacturer'};
            $bios->{SMODEL}        = $systemInfos->{'Product'};
            $bios->{SKUNUMBER}     = $systemInfos->{'SKU Number'};
            $hardware->{UUID}      = $systemInfos->{'UUID'};

            my $motherboardInfos = $infos->{SMB_TYPE_BASEBOARD};
            $bios->{MMODEL}        = $motherboardInfos->{'Product'};
            $bios->{MSN}           = $motherboardInfos->{'Serial Number'};
            $bios->{MMANUFACTURER} = $motherboardInfos->{'Manufacturer'};
        } elsif ($arch =~ /sparc/i) {
            my $infos = _parsePrtconf(logger => $logger);
            $bios->{SMODEL} = $infos->{'banner-name'};
            $bios->{SMODEL} .= " ($infos->{name})" if $infos->{name};

            # looks like : "OBP 4.16.4 2004/12/18 05:18"
            #    with further informations sometime
            if ($infos->{version} =~ m{OBP\s+([\d|\.]+)\s+(\d+)/(\d+)/(\d+)}) {
                $bios->{BVERSION} = "OBP $1";
                $bios->{BDATE}    = "$2/$3/$4";
            } else {
                $bios->{BVERSION} = $infos->{version};
            }

            my $command = -x '/opt/SUNWsneep/bin/sneep' ?
                '/opt/SUNWsneep/bin/sneep' : 'sneep';

            $bios->{SSN} = getFirstLine(
                command => $command,
                logger  => $logger
            );
        }
    } else {
        my $infos = _parseShowRev(logger => $logger);
        $bios->{SMANUFACTURER} = $infos->{'Hardware provider'};
        $bios->{SMODEL}        = "Solaris Containers";
    }

    $inventory->setBios($bios);
    $inventory->setHardware($hardware);
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
    my (%params) = (
        command => '/usr/sbin/smbios',
        @_
    );

    my $handle = getFileHandle(%params);
    return unless $handle;

    my ($infos, $current);
    while (my $line = <$handle>) {
        if ($line =~ /^ \d+ \s+ \d+ \s+ (\S+)/x) {
            $current = $1;
            next;
        }

        if ($line =~ /^ \s* ([^:]+) : \s* (.+) $/x) {
            $infos->{$current}->{$1} = $2;
            next;
        }
    }
    close $handle;

    return $infos;
}

sub _parsePrtconf {
    my (%params) = (
        command => '/usr/sbin/prtconf -pv',
        @_
    );

    my $handle = getFileHandle(%params);
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
