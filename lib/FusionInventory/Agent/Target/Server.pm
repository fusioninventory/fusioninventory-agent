package FusionInventory::Agent::Target::Server;

use strict;
use warnings;
use base 'FusionInventory::Agent::Target';

use English qw(-no_match_vars);

sub new {
    my ($class, $params) = @_;

    my $self = $class->SUPER::new($params);

    my $subdir = $params->{path};
    $subdir =~ s/\//_/g;
    $subdir =~ s/:/../g if $OSNAME eq 'MSWin32';

    $self->_init({
        vardir => $self->{config}->{basevardir} . '/' . $subdir
    });
   
    return $self;
}

1;
