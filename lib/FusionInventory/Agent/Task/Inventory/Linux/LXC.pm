package FusionInventory::Agent::Task::Inventory::Linux::LXC;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isEnabled {
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $hardware  = _getLibvirtLXC_UUID(logger => $logger);

    $inventory->setHardware($hardware) if $hardware;
}

sub _getLibvirtLXC_UUID {

    my @environ = split( '\0', getAllLines( file => "/proc/1/environ" ) );

    my $hardware;
    foreach my $var (@environ) {
      if ( $var =~ /^LIBVIRT_LXC_UUID/) {
        my ( $name, $value ) = split( '=', $var );
        $hardware = { UUID => $value };
      }
    }

    return $hardware;
}

1;
