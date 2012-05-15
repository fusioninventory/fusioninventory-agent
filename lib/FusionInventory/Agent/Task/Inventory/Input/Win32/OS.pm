package FusionInventory::Agent::Task::Inventory::Input::Win32::OS;

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

    foreach my $object (getWmiObjects(
            class      => 'Win32_OperatingSystem',
            properties => [ qw/
                OSLanguage Caption Version SerialNumber Organization \
                RegisteredUser CSDVersion TotalSwapSpaceSize
            / ]
        )) {

        my $key = _getXPkey(path => 'HKEY_LOCAL_MACHINE/Software/Microsoft/Windows NT/CurrentVersion/DigitalProductId');
        if (!$key) { # 582
           $key = _getXPkey(path => 'HKEY_LOCAL_MACHINE/Software/Microsoft/Windows NT/CurrentVersion/DigitalProductId4');
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

        $inventory->setOperatingSystem({
            NAME           => "Windows",
            INSTALL_DATE   => $installDate,
    #        VERSION       => $OSVersion,
            KERNEL_VERSION => $object->{Version},
            FULL_NAME      => $object->{Caption},
            SERVICE_PACK   => $object->{CSDVersion}
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

    foreach my $object (getWmiObjects(
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

    foreach my $object (getWmiObjects(
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

#http://www.perlmonks.org/?node_id=497616
# Thanks William Gannon && Charles Clarkson
sub _getXPkey {
    my $key = getRegistryValue(@_);
    return unless $key;

    my @encoded = ( unpack 'C*', $key )[ reverse 52 .. 66 ];

    # Get indices
    my @indices;
    foreach ( 0 .. 24 ) {
        my $index = 0;

        # Shift off remainder
        ( $index, $_ ) = _quotient( $index, $_ ) foreach @encoded;

        # Store index.
        unshift @indices, $index;
    }

    # translate base 24 "digits" to characters
    my $cd_key =
        join '',
        qw( B C D F G H J K M P Q R T V W X Y 2 3 4 6 7 8 9 )[ @indices ];

    # Add seperators
    $cd_key =
        join '-',
        $cd_key =~ /(.{5})/g;

    return if $cd_key =~ /^[B-]*$/;
    return $cd_key;
}

sub _quotient {
    my($index, $encoded) = @_;

    # Same as $index * 256 + $product_key ???
    my $dividend = $index * 256 ^ $encoded; ## no critic (ProhibitBitwise)

    # return modulus and integer quotient
    return(
        $dividend % 24,
        $dividend / 24,
    );
}


1;
