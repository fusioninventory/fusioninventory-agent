package FusionInventory::Agent::Target::Local;

use strict;
use warnings;
use base 'FusionInventory::Agent::Target';

my $count = 0;

sub new {
    my ($class, $params) = @_;

    my $self = $class->SUPER::new($params);

    $self->_init({
        id     => 'local' . $count++,
        vardir => $params->{basevardir} . '/__LOCAL__',
    });

    return $self;
}

1;

__END__

=head1 NAME

FusionInventory::Agent::Target::Local - Local target

=head1 DESCRIPTION

This is a target for storing execution result in a local folder.
