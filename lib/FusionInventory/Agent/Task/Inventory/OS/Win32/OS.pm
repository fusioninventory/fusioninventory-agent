package FusionInventory::Agent::Task::Inventory::OS::Win32::OS;

use strict;
use warnings;
use integer;

use English qw(-no_match_vars);
use Win32::OLE::Variant;
use Win32::TieRegistry (
    Delimiter   => '/',
    ArrayValues => 0,
    qw/KEY_READ/
);

use FusionInventory::Agent::Tools::Win32;

sub isInventoryEnabled {
    return 1;
}

sub doInventory {
    my ($params) = @_;

    my $inventory = $params->{inventory};
    my $logger = $params->{logger};

    foreach my $Properties (getWmiProperties('Win32_OperatingSystem', qw/
        OSLanguage Caption Version SerialNumber Organization RegisteredUser
        CSDVersion TotalSwapSpaceSize
        /)) {

        my $key = _getXPkey();
        my $description = encodeFromRegistry(_getValueFromRegistry(
            'SYSTEM/CurrentControlSet/Services/lanmanserver/Parameters/srvcomment'
        ));

        $inventory->setHardware({
            WINLANG     => $Properties->{OSLanguage},
            OSNAME      => $Properties->{Caption},
            OSVERSION   => $Properties->{Version},
            WINPRODKEY  => $key,
            WINPRODID   => $Properties->{SerialNumber},
            WINCOMPANY  => $Properties->{Organization},
            WINOWNER    => $Properties->{RegistredUser},
            OSCOMMENTS  => $Properties->{CSDVersion},
            SWAP        => int(($Properties->{TotalSwapSpaceSize}||0)/(1024*1024)),
            DESCRIPTION => $description,
        });
    }

    foreach my $Properties (getWmiProperties('Win32_ComputerSystem', qw/
        Name Domain Workgroup UserName PrimaryOwnerName TotalPhysicalMemory
    /)) {

        my $workgroup = $Properties->{Domain} || $Properties->{Workgroup};
        my $winowner = $Properties->{PrimaryOwnerName};

        $inventory->setHardware({
            MEMORY     => int(($Properties->{TotalPhysicalMemory}||0)/(1024*1024)),
            WORKGROUP  => $workgroup,
            WINOWNER   => $winowner,
            NAME       => $Properties->{Name},
        });
    }

    foreach my $Properties (getWmiProperties('Win32_ComputerSystemProduct', qw/
        UUID
    /)) {

        my $uuid = $Properties->{UUID};
        $uuid = '' if $uuid =~ /^[0-]+$/;
        $inventory->setHardware({
            UUID => $uuid,
        });

    }
}

#http://www.perlmonks.org/?node_id=497616
# Thanks William Gannon && Charles Clarkson


sub _getValueFromRegistry {
    my ($path) = @_;

    my $machKey = $Registry->Open('LMachine', { Access=> KEY_READ })
        or die "Can't open HKEY_LOCAL_MACHINE: $EXTENDED_OS_ERROR";
    my $key = $machKey->{$path};

    if (!$key) { # 64bit OS?
        $machKey = $Registry->Open('LMachine', { Access=> KEY_READ|KEY_WOW64_64KEY() })
            or die "Can't open HKEY_LOCAL_MACHINE: $EXTENDED_OS_ERROR";
        $key = $machKey->{$path};
    }

    return $key
}

sub _getXPkey {
    my $key = _getValueFromRegistry(
        'Software/Microsoft/Windows NT/CurrentVersion/DigitalProductId'
    );
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

    return $cd_key;
}

sub _quotient {
    my($index, $encoded) = @_;

    # Same as $index * 256 + $product_key ???
    my $dividend = $index * 256 ^ $encoded;

    # return modulus and integer quotient
    return(
        $dividend % 24,
        $dividend / 24,
    );
}


1;
