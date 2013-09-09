package FusionInventory::Agent::Broker;

use strict;
use warnings;

use UNIVERSAL::require;

sub create {
    my ($class, %params) = @_;

    my $target = $params{target};
    my $output_class =
        !defined $target         ? 'FusionInventory::Agent::Broker::Stdout'    :
        $target =~ m{^https?://} ? 'FusionInventory::Agent::Broker::Server'    :
        -d $target               ? 'FusionInventory::Agent::Broker::Filesystem':
                                   undef                                       ;

    die "invalid target $target" unless $output_class;
    $output_class->require();

    return $output_class->new(%params);
}

1;
