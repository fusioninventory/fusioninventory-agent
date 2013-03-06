package FusionInventory::Agent::Task::Inventory::Linux::Bios;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;

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


    my %mapping = (

        ASSETTAG       => "/sys/devices/virtual/dmi/id/chassis_asset_tag",
        BDATE          => "/sys/devices/virtual/dmi/id/bios_date",
        BMANUFACTURER  => "/sys/devices/virtual/dmi/id/bios_vendor",
        BVERSION       => "/sys/devices/virtual/dmi/id/bios_version",
        MMANUFACTURER  => "/sys/devices/virtual/dmi/id/board_vendor",
        MMODEL         => "/sys/devices/virtual/dmi/id/board_name",
        MSN            => "/sys/devices/virtual/dmi/id/board_serial",
        MMANUFACTURER  => "/sys/devices/virtual/dmi/id/sys_vendor",
        SMODEL         => "/sys/devices/virtual/dmi/id/product_name",
        SSN            => "/sys/devices/virtual/dmi/id/product_serial",

    );

    my $bios;

    foreach my $key (keys %mapping) {
        $bios->{$key} = getFirstLine(file => $mapping{$key}) || undef;
    }

    $inventory->setBios($bios);

}

1;
