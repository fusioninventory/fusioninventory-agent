package FusionInventory::Agent::Recipient;

use strict;
use warnings;

use UNIVERSAL::require;

sub create {
    my ($class, %params) = @_;

    my $target = $params{target};
    my $output_class =
        !defined $target         ? 'FusionInventory::Agent::Recipient::Stdout'    :
        $target =~ m{^https?://} ? 'FusionInventory::Agent::Recipient::Server'    :
        -d $target               ? 'FusionInventory::Agent::Recipient::Filesystem':
                                   undef                                       ;

    die "invalid target $target" unless $output_class;
    $output_class->require();

    return $output_class->new(%params);
}

1;
