### UNMERGED YET! ###
package FusionInventory::Agent::Task::Inventory::OS::Win32::OS;

use strict;
use warnings;
use integer;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools::Win32;

sub isInventoryEnabled {
    return 1;
}

sub doInventory {
    my ($params) = @_;

    my $inventory = $params->{inventory};
    my $logger = $params->{logger};

    foreach my $object (getWmiObjects(
            class      => 'Win32_OperatingSystem',
            properties => [ qw/
                OSLanguage Caption Version SerialNumber Organization \
                RegisteredUser CSDVersion TotalSwapSpaceSize
            / ]
        )) {

        my $key = _getXPkey();
        my $description = encodeFromRegistry(getValueFromRegistry(
            'SYSTEM/CurrentControlSet/Services/lanmanserver/Parameters/srvcomment'
        ));

        $object->{TotalSwapSpaceSize} = int($object->{TotalSwapSpaceSize} / (1024 * 1024))
            if $object->{TotalSwapSpaceSize};

        $inventory->setHardware({
            WINLANG     => $object->{OSLanguage},
            OSNAME      => $object->{Caption},
            OSVERSION   => $object->{Version},
            WINPRODKEY  => $key,
            WINPRODID   => $object->{SerialNumber},
            WINCOMPANY  => $object->{Organization},
            WINOWNER    => $object->{RegistredUser},
            OSCOMMENTS  => $object->{CSDVersion},
            SWAP        => $object->{TotalSwapSpaceSize},
            DESCRIPTION => $description,
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
            WINOWNER   => $object->{PrimaryOwnerName},
            NAME       => $object->{Name},
        });
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
    my $key = getRawRegistryKey(
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
