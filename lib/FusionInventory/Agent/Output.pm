package FusionInventory::Agent::Output;

use strict;
use warnings;

use UNIVERSAL::require;

sub create {
    my ($class, %params) = @_;

    my $target = $params{target};
    my $output_class =
        !defined $target         ? 'FusionInventory::Agent::Output::Stdout'   :
        $target =~ m{^https?://} ? 'FusionInventory::Agent::Output::Server'   :
        -d $target               ? 'FusionInventory::Agent::Output::Directory':
                                   undef                                      ;

    die "invalid target $target" unless $output_class;
    $output_class->require();

    return $output_class->new(%params);
}

1;
