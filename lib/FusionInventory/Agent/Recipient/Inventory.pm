package FusionInventory::Agent::Recipient::Inventory;

use strict;
use warnings;

use UNIVERSAL::require;

sub create {
    my ($class, %params) = @_;

    my $target = $params{target};
    my $output_class =
        !defined $target         ? 'FusionInventory::Agent::Recipient::Inventory::Stdout'    :
        $target =~ m{^https?://} ? 'FusionInventory::Agent::Recipient::Inventory::Server'    :
        -d $target               ? 'FusionInventory::Agent::Recipient::Inventory::Filesystem':
                                   undef                                       ;

    die "invalid target $target" unless $output_class;
    $output_class->require();

    return $output_class->new(%params);
}

1;
