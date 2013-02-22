package FusionInventory::Agent::Task::Inventory::Win32::OS;

use strict;
use warnings;
use integer;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Hostname;
use FusionInventory::Agent::Tools::Win32;

sub isEnabled {
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    foreach my $object (getWMIObjects(
            class      => 'Win32_OperatingSystem',
            properties => [ qw/
                OSLanguage Caption Version SerialNumber Organization
                RegisteredUser CSDVersion TotalSwapSpaceSize
                OSArchitecture LastBootUpTime
            / ]
        )) {

        my $key = parseProductKey(getRegistryValue(path => 'HKEY_LOCAL_MACHINE/Software/Microsoft/Windows NT/CurrentVersion/DigitalProductId'));
        if (!$key) { # 582
           $key = parseProductKey(getRegistryValue(path => 'HKEY_LOCAL_MACHINE/Software/Microsoft/Windows NT/CurrentVersion/DigitalProductId4'));
        }
        my $description = encodeFromRegistry(getRegistryValue(
            path   => 'HKEY_LOCAL_MACHINE/SYSTEM/CurrentControlSet/Services/lanmanserver/Parameters/srvcomment',
            logger => $logger
        ));
        my $installDate = getFormatedLocalTime(hex2dec(
            encodeFromRegistry(getRegistryValue(
                path   => 'HKEY_LOCAL_MACHINE/SOFTWARE/Microsoft/Windows NT/CurrentVersion/InstallDate',
                logger => $logger
            ))
        ));

        $object->{TotalSwapSpaceSize} = int($object->{TotalSwapSpaceSize} / (1024 * 1024))
            if $object->{TotalSwapSpaceSize};

        $inventory->setHardware({
            WINLANG       => $object->{OSLanguage},
            OSNAME        => $object->{Caption},
            OSVERSION     => $object->{Version},
            WINPRODKEY    => $key,
            WINPRODID     => $object->{SerialNumber},
            WINCOMPANY    => $object->{Organization},
            WINOWNER      => $object->{RegistredUser},
            OSCOMMENTS    => $object->{CSDVersion},
            SWAP          => $object->{TotalSwapSpaceSize},
            DESCRIPTION   => $description,
        });

        my $osArchitecture =  $object->{OSArchitecture} || '32-bit';
        $osArchitecture =~ s/ /-/; # "64 bit" => "64-bit"

        my $boottime;
        if ($object->{LastBootUpTime} =~
                /^(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})/) {
            $boottime = getFormatedDate($1, $2, $3, $4, $5, 6);
        }

        $inventory->setOperatingSystem({
            NAME           => "Windows",
            INSTALL_DATE   => $installDate,
    #        VERSION       => $OSVersion,
            KERNEL_VERSION => $object->{Version},
            FULL_NAME      => $object->{Caption},
            SERVICE_PACK   => $object->{CSDVersion},
            ARCH           => $osArchitecture,
            BOOT_TIME      => $boottime,
        });
    }

    # In the rare case WMI DB is broken,
    # We first initialize the name by kernel32
    # call
    my $name = FusionInventory::Agent::Tools::Hostname::getHostname();
    $name = $ENV{COMPUTERNAME} unless $name;
    my $domain;

    if ($name  =~ s/^([^\.]+)\.(.*)/$1/) {
        $domain = $2;
    }

    $inventory->setHardware({
        NAME       => $name,
        WORKGROUP  => $domain
    });

    foreach my $object (getWMIObjects(
        class      => 'Win32_ComputerSystem',
        properties => [ qw/
            Name Domain Workgroup UserName PrimaryOwnerName TotalPhysicalMemory
        / ]
    )) {

        $object->{TotalPhysicalMemory} = int($object->{TotalPhysicalMemory} / (1024 * 1024))
            if $object->{TotalPhysicalMemory};

        $inventory->setHardware({
            MEMORY     => $object->{TotalPhysicalMemory},
            WORKGROUP  => $object->{Domain} || $object->{Workgroup},
            WINOWNER   => $object->{PrimaryOwnerName}
        });

        if (!$name) {
            $inventory->setHardware({
                NAME       => $object->{Name},
            });
        }


    }

    foreach my $object (getWMIObjects(
        class      => 'Win32_ComputerSystemProduct',
        properties => [ qw/UUID/ ]
    )) {

        my $uuid = $object->{UUID};
        $uuid = '' if $uuid =~ /^[0-]+$/;
        $inventory->setHardware({
            UUID => $uuid,
        });

    }


}

1;
