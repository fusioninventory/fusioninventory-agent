package FusionInventory::Agent::Task::Inventory::OS::Win32::OS;

use strict;
use warnings;

use Encode qw(encode);
use English qw(-no_match_vars);
use Win32::OLE::Variant;
use Win32::TieRegistry (
    Delimiter   => '/',
    ArrayValues => 0,
    qw/KEY_READ/
);

use FusionInventory::Agent::Tools::Win32;

#http://www.perlmonks.org/?node_id=497616
# Thanks William Gannon && Charles Clarkson

# TODO: FusionInventory::Agent::Tools::Win32::getValueFromRegistry()
sub _getValueFromRegistry {
    my ($logger, $path) = @_;

    my $key;
    if (is64bit()) {
        my $machKey = $Registry->Open('LMachine', { Access=> KEY_READ()|KEY_WOW64_64KEY() } )
	    or $logger->error("Can't open HKEY_LOCAL_MACHINE: $EXTENDED_OS_ERROR");
	$key = $machKey->{$path};
    } else {
	my $machKey = $Registry->Open('LMachine', { Access=> KEY_READ() } )
            or $logger->error("Can't open HKEY_LOCAL_MACHINE: $EXTENDED_OS_ERROR");
        $key = $machKey->{$path};
    }

    return $key
}

sub getXPkey {
    my ($logger) = @_;

    my $key = _getValueFromRegistry($logger, 'Software/Microsoft/Windows NT/CurrentVersion/DigitalProductId');
    return unless $key;

    my @encoded = ( unpack 'C*', $key )[ reverse 52 .. 66 ];

    # Get indices
    my @indices;
    foreach ( 0 .. 24 ) {
        my $index = 0;

        # Shift off remainder
        ( $index, $_ ) = quotient( $index, $_ ) foreach @encoded;

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

sub quotient {
    use integer;
    my( $index, $encoded ) = @_;

    # Same as $index * 256 + $product_key ???
    my $dividend = $index * 256 ^ $encoded;

    # return modulus and integer quotient
    return(
        $dividend % 24,
        $dividend / 24,
    );
}



sub isInventoryEnabled {
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    foreach my $object (getWmiObjects(
        class      => 'Win32_OperatingSystem',
        properties => [ qw/
            OSLanguage Caption Version SerialNumber Organization RegisteredUser
            CSDVersion TotalSwapSpaceSize
        / ]
    )) {

        my $key = getXPkey($logger); 
        my $description = encodeFromRegistry(_getValueFromRegistry(
                    $logger,
                    'SYSTEM/CurrentControlSet/Services/lanmanserver/Parameters/srvcomment'
                    ));

        $inventory->setHardware({
            WINLANG => $object->{OSLanguage},
            OSNAME => $object->{Caption},
            OSVERSION =>  $object->{Version},
            WINPRODKEY => $key,
            WINPRODID => $object->{SerialNumber},
            WINCOMPANY => $object->{Organization},
            WINOWNER => $object->{RegistredUser},
            OSCOMMENTS => $object->{CSDVersion},
            SWAP => int(($object->{TotalSwapSpaceSize}||0)/(1024*1024)),
            DESCRIPTION => $description,
        });
    }

    foreach my $object (getWmiObjects(
        class      => 'Win32_ComputerSystem',
        properties => [ qw/Name Domain Workgroup UserName PrimaryOwnerName TotalPhysicalMemory/ ]
    )) {

        my $workgroup = $object->{Domain} || $object->{Workgroup};
        my $userdomain;
#        my $userid;
#        my @tmp = split(/\\/, $object->{UserName});
#        $userdomain = $tmp[0];
#        $userid = $tmp[1];
        my $winowner = $object->{PrimaryOwnerName};

        #$inventory->addUser({ LOGIN => encode('UTF-8', $object->{UserName}) });
        $inventory->setHardware(
            MEMORY     => int(($object->{TotalPhysicalMemory}||0)/(1024*1024)),
            USERDOMAIN => $userdomain,
            WORKGROUP  => $workgroup,
            WINOWNER   => $winowner,
            NAME       => $object->{Name},
        );
    }

    foreach my $object (getWmiObjects(
        class      => 'Win32_ComputerSystemProduct',
        properties => [ qw/UUID/ ]
    )) {

        my $uuid = $object->{UUID};
        $uuid = '' if $uuid =~ /^[0-]+$/;
        #$inventory->addUser({ LOGIN => encode('UTF-8', $object->{UserName}) });
        $inventory->setHardware(
            UUID => $uuid,
        );

    }
}

1;
