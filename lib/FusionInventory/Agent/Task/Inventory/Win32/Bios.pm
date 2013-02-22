package FusionInventory::Agent::Task::Inventory::Win32::Bios;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools::Win32;

# Only run this module if dmidecode has not been found
our $runMeIfTheseChecksFailed =
    ["FusionInventory::Agent::Task::Inventory::Generic::Dmidecode::Bios"];

sub isEnabled {
    return 1;
}

sub _dateFromIntString {
    my ($string) = @_;

    if ($string && $string =~ /^(\d{4})(\d{2})(\d{2})/) {
        return "$2/$3/$1";
    }

    return $string;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $bios = {
        BDATE => _dateFromIntString(getRegistryValue(
            path   => "HKEY_LOCAL_MACHINE/Hardware/Description/System/BIOS/BIOSReleaseDate",
            logger => $logger
        ))
    };

    foreach my $object (getWMIObjects(
        class      => 'Win32_Bios',
        properties => [ qw/
            SerialNumber Version Manufacturer SMBIOSBIOSVersion BIOSVersion ReleaseDate
        / ]
    )) {
        $bios->{BIOSSERIAL}    = $object->{SerialNumber};
        $bios->{SSN}           = $object->{SerialNumber};
        $bios->{BMANUFACTURER} = $object->{Manufacturer};
        $bios->{BVERSION}      = $object->{SMBIOSBIOSVersion} ||
                                 $object->{BIOSVersion}       ||
                                 $object->{Version};
        $bios->{BDATE}         = _dateFromIntString($object->{ReleaseDate});
    }

    foreach my $object (getWMIObjects(
        class      => 'Win32_ComputerSystem',
        properties => [ qw/
            Manufacturer Model
        / ]
    )) {
        $bios->{SMANUFACTURER} = $object->{Manufacturer};
        $bios->{SMODEL}        = $object->{Model};
    }

    foreach my $object (getWMIObjects(
            class      => 'Win32_SystemEnclosure',
            properties => [ qw/
                SerialNumber SMBIOSAssetTag
            / ]
    )) {
        $bios->{ENCLOSURESERIAL} = $object->{SerialNumber} ;
        $bios->{SSN}             = $object->{SerialNumber} unless $bios->{SSN};
        $bios->{ASSETTAG}        = $object->{SMBIOSAssetTag};
    }

    foreach my $object (getWMIObjects(
            class => 'Win32_BaseBoard',
            properties => [ qw/
                SerialNumber Product Manufacturer
            / ]
    )) {
        $bios->{MSN}             = $object->{SerialNumber};
        $bios->{MMODEL}          = $object->{Product};
        $bios->{SSN}             = $object->{SerialNumber}
            unless $bios->{SSN};
        $bios->{SMANUFACTURER}   = $object->{Manufacturer}
            unless $bios->{SMANUFACTURER};

    }

    foreach (keys %$bios) {
        $bios->{$_} =~ s/\s+$// if $bios->{$_};
    }

    $inventory->setBios($bios);

    SWITCH: {
        if (
            ($bios->{VERSION} && $bios->{VERSION} eq 'VirtualBox') ||
            ($bios->{MMODEL}  && $bios->{MMODEL} eq 'VirtualBox')
           ) {
            $inventory->setHardware ({
                VMSYSTEM => 'VirtualBox'
            });
            last SWITCH;
        }

        if (
            ($bios->{BIOSSERIAL} && $bios->{BIOSSERIAL} =~ /VMware/i) ||
            ($bios->{SMODEL}     && $bios->{SMODEL} eq 'VirtualBox')
           ) {
            $inventory->setHardware ({
                VMSYSTEM => 'VMware'
            });
            last SWITCH;
        }

        if (
            ($bios->{SMANUFACTURER} && $bios->{SMANUFACTURER} eq 'Xen') ||
            ($bios->{BMANUFACTURER} && $bios->{BMANUFACTURER} eq 'Xen')
           ) {
            $inventory->setHardware ({
                VMSYSTEM => 'Xen'
            });
            last SWITCH;
        }
    }

}

1;
