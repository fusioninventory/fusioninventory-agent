package FusionInventory::Agent::Target::Stdout;

use strict;
use warnings;
use base 'FusionInventory::Agent::Target';

use English qw(-no_match_vars);

my $count = 0;

sub new {
    my ($class, %params) = @_;

    my $self = $class->SUPER::new(%params);

    $self->_init(
        id     => 'stdout' . $count++,
        vardir => $params{basevardir} . '/__LOCAL__',
    );

    return $self;
}

sub getDescription {
    my ($self) = @_;

    return "stdout";
}

1;

1;

__END__

=head1 NAME

FusionInventory::Agent::Target::Stdout - Stdout target
