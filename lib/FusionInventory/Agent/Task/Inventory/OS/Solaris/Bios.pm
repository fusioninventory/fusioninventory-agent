package FusionInventory::Agent::Task::Inventory::OS::Solaris::Bios;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Solaris;

sub isEnabled {
    return
        can_run('showrev') ||
        can_run('/usr/sbin/smbios');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    my ($SystemSerial, $SystemModel, $SystemManufacturer, $BiosManufacturer,
        $BiosVersion, $BiosDate, $uuid);

    my $zone = getZone();
    if ($zone) {

        my $arch;
        if (can_run('showrev')) {
            my $infos = _parseShowrew();
            $SystemModel        = $infos->{'Application architecture'};
            $SystemManufacturer = $infos->{'Hardware provider'};
            $arch               = $infos->{'Application architecture'};
        } else {
            $arch =
                getFirstLine(command => 'arch') eq 'i86pc' ? 'i386' : 'unknown';
        }

        if ($arch eq "i386") {
            # use smbios for i386 arch
            my $handle = getFileHandle(
                command => "/usr/sbin/smbios"
            );
            while (my $line = <$handle>) {
                if ($line =~ /^\s*Manufacturer:\s*(.+)$/) {
                    $SystemManufacturer = $1
                }
                if ($line =~ /^\s*Serial Number:\s*(.+)$/) {
                    $SystemSerial = $1;
                }
                if ($line =~ /^\s*Product:\s*(.+)$/) {
                    $SystemModel = $1;
                }
                if ($line =~ /^\s*Vendor:\s*(.+)$/) {
                    $BiosManufacturer = $1;
                }
                if ($line =~ /^\s*Version String:\s*(.+)$/) {
                    $BiosVersion = $1;
                }
                if ($line =~ /^\s*Release Date:\s*(.+)$/) {
                    $BiosDate = $1;
                }
                if ($line =~ /^\s*UUID:\s*(.+)$/) {
                    $uuid = $1;
                }
            }
            close $handle;
        } elsif ($arch =~ /sparc/i) {
            # use prtconf for Sparc arch

            my $handle = getFileHandle(
                command => "/usr/sbin/prtconf -pv"
            );

            my ($name, $OBPstring);
            while (my $line = <$handle>) {
                # prtconf is an awful thing to parse
                if ($line =~ /^\s*banner-name:\s*'(.+)'$/) {
                    $SystemModel = $1;
                }
                unless ($name) {
                    if ($line =~ /^\s*name:\s*'(.+)'$/) {
                        $name = $1;
                    }
                }
                unless ($OBPstring) {
                    if ($line =~ /^\s*version:\s*'(.+)'$/) {
                        $OBPstring = $1;
                        # looks like : "OBP 4.16.4 2004/12/18 05:18"
                        #    with further informations sometime
                        if ($OBPstring =~ m@OBP\s+([\d|\.]+)\s+(\d+)/(\d+)/(\d+)@ ) {
                            $BiosVersion = "OBP $1";
                            $BiosDate = "$2/$3/$4";
                        } else {
                            $BiosVersion = $OBPstring;
                        }
                    }
                }
            }
            close $handle;

            $SystemModel .= " ($name)" if( $name );

            if( -x "/opt/SUNWsneep/bin/sneep" ) {
                $SystemSerial = getFirstLine(
                    command => '/opt/SUNWsneep/bin/sneep'
                );
            } else {
                foreach(`/bin/find /opt -name sneep`) {
                    next unless /^(\S+)/;
                    $SystemSerial = getFirstLine(command => $1);
                }
            }
        }
    } else {
        my $infos = _parseShowrew();
        $SystemManufacturer = $infos->{'Hardware provider'};

        $SystemModel = "Solaris Containers";
        $SystemSerial = "Solaris Containers";

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

sub _parseShowRew {
    my $handle = getFileHandle(
        command => "showrev",
    );
    return unless $handle;

    my $infos;
    while (my $line = <$handle>) {
        next unless $line =~ /^ ([^:]+) : \s+ (\S+)/x;
        $infos->{$1} = $2;
    }
    close $handle;

    return $infos;
}

1;
