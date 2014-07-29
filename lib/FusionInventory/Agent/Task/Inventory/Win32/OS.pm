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

    my $operatingSystem = getWMIObjects(
        class      => 'Win32_OperatingSystem',
        properties => [ qw/
            OSLanguage Caption Version SerialNumber Organization
            RegisteredUser CSDVersion TotalSwapSpaceSize
            OSArchitecture LastBootUpTime
        / ]
    );

    my $key =
        parseProductKey(getRegistryValue(path => 'HKEY_LOCAL_MACHINE/Software/Microsoft/Windows NT/CurrentVersion/DigitalProductId')) ||
        parseProductKey(getRegistryValue(path => 'HKEY_LOCAL_MACHINE/Software/Microsoft/Windows NT/CurrentVersion/DigitalProductId4'));

    my $description = encodeFromRegistry(getRegistryValue(
        path   => 'HKEY_LOCAL_MACHINE/SYSTEM/CurrentControlSet/Services/lanmanserver/Parameters/srvcomment',
        logger => $logger
    ));

    $operatingSystem->{TotalSwapSpaceSize} = int($operatingSystem->{TotalSwapSpaceSize} / (1024 * 1024))
        if $operatingSystem->{TotalSwapSpaceSize};

    $inventory->setHardware({
        WINLANG       => $operatingSystem->{OSLanguage},
        OSNAME        => $operatingSystem->{Caption},
        OSVERSION     => $operatingSystem->{Version},
        WINPRODKEY    => $key,
        WINPRODID     => $operatingSystem->{SerialNumber},
        WINCOMPANY    => $operatingSystem->{Organization},
        WINOWNER      => $operatingSystem->{RegistredUser},
        OSCOMMENTS    => $operatingSystem->{CSDVersion},
        SWAP          => $operatingSystem->{TotalSwapSpaceSize},
        DESCRIPTION   => $description,
    });

    my $osArchitecture =  $operatingSystem->{OSArchitecture} || '32-bit';
    $osArchitecture =~ s/ /-/; # "64 bit" => "64-bit"

    my $boottime;
    if ($operatingSystem->{LastBootUpTime} =~
            /^(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})/) {
        $boottime = getFormatedDate($1, $2, $3, $4, $5, 6);
    }

    $inventory->setOperatingSystem({
        NAME           => "Windows",
        INSTALL_DATE   => _getInstallDate(),
        KERNEL_VERSION => $operatingSystem->{Version},
        FULL_NAME      => $operatingSystem->{Caption},
        SERVICE_PACK   => $operatingSystem->{CSDVersion},
        ARCH           => $osArchitecture,
        BOOT_TIME      => $boottime,
    });

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

    my $computerSystem = getWMIObjects(
        class      => 'Win32_ComputerSystem',
        properties => [ qw/
            Name Domain Workgroup UserName PrimaryOwnerName TotalPhysicalMemory
        / ]
    );

    $computerSystem->{TotalPhysicalMemory} = int($computerSystem->{TotalPhysicalMemory} / (1024 * 1024))
        if $computerSystem->{TotalPhysicalMemory};

    $inventory->setHardware({
        MEMORY     => $computerSystem->{TotalPhysicalMemory},
        WORKGROUP  => $computerSystem->{Domain} || $computerSystem->{Workgroup},
        WINOWNER   => $computerSystem->{PrimaryOwnerName}
    });

    if (!$name) {
        $inventory->setHardware({
            NAME => $computerSystem->{Name},
        });
    }

    my $computerSystemProduct = getWMIObjects(
        class      => 'Win32_ComputerSystemProduct',
        properties => [ qw/UUID/ ]
    );

    my $uuid = $computerSystemProduct->{UUID};
    $uuid = '' if $uuid =~ /^[0-]+$/;
    $inventory->setHardware({
        UUID => $uuid,
    });
}

sub _getInstallDate {
    my $installDate = getRegistryValue(
        path   => 'HKEY_LOCAL_MACHINE/SOFTWARE/Microsoft/Windows NT/CurrentVersion/InstallDate'
    );
    return unless $installDate;

    my $dec = hex2dec($installDate);
    return unless $dec;

    return getFormatedLocalTime($dec);
}



1;
