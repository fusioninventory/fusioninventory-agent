package FusionInventory::Agent::Task::Inventory::OS::Win32::OS;

use strict;
use warnings;

use FusionInventory::Agent::Task::Inventory::OS::Win32;

use Win32::TieRegistry;

use Win32::OLE::Variant;

use Encode qw(encode);

use constant wbemFlagReturnImmediately => 0x10;
use constant wbemFlagForwardOnly => 0x20;

#http://www.perlmonks.org/?node_id=497616
# Thanks William Gannon && Charles Clarkson


sub getXPkey {
    my $key     = shift;
    my @encoded = ( unpack 'C*', $Registry->{$key} )[ reverse 52 .. 66 ];

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
    my $params = shift;
    my $inventory = $params->{inventory};

        foreach my $Properties
            (getWmiProperties('Win32_OperatingSystem',
qw/OSLanguage Caption Version SerialNumber Organization RegisteredUser CSDVersion/)) {

                my $key = &getXPkey(qq!HKEY_LOCAL_MACHINE\\Software\\Microsoft\\Windows NT\\CurrentVersion\\\\DigitalProductId!); 

        $inventory->setHardware({

                WINLANG => $Properties->{OSLanguage},
                OSNAME => $Properties->{Caption},
                OSVERSION =>  $Properties->{Version},
                WINPRODKEY => $key,
                WINPRODID => $Properties->{SerialNumber},
                WINCOMPANY => $Properties->{Organization},
                WINOWNER => $Properties->{RegistredUser},
                OSCOMMENTS => $Properties->{CSDVersion},

                });

    }


        foreach my $Properties
            (getWmiProperties('Win32_ComputerSystem',
qw/Workgroup UserName PrimaryOwnerName/)) {


        my $workgroup = $Properties->{Workgroup};
        my $userdomain;
#        my $userid;
#        my @tmp = split(/\\/, $Properties->{UserName});
#        $userdomain = $tmp[0];
#        $userid = $tmp[1];
        my $winowner = $Properties->{PrimaryOwnerName};

        #$inventory->addUser({ LOGIN => encode('UTF-8', $Properties->{UserName}) });
        $inventory->setHardware({

                USERDOMAIN => $userdomain,
                WORKGROUP => $workgroup,
                WINOWNER => $winowner,

                });

    }

        foreach my $Properties
            (getWmiProperties('Win32_ComputerSystemProduct',
qw/UUID/)) {


        my $uuid = $Properties->{UUID};
        $uuid = '' if $uuid =~ /^[0-]+$/;
        #$inventory->addUser({ LOGIN => encode('UTF-8', $Properties->{UserName}) });
        $inventory->setHardware({

                UUID => $uuid,

                });

    }


}
1;
