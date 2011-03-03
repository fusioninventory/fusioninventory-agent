package FusionInventory::Agent::Task::Deploy::Job;

use Data::Dumper;
use English qw(-no_match_vars);

use strict;
use warnings;

sub new {
    my (undef, $params) = @_;

    my $self = $params->{data};
    $self->{associatedFiles} = $params->{associatedFiles};

    bless $self;
}


sub checkWinkey {
    my ($self) = @_;

    return 1 unless $self->{requires}{winkey};

    return unless $OSNAME eq 'MSWin32'
}

sub checkFreespace {
    my ($self) = @_;

    return 1;
}

sub getNextToProcess {
    my ($self) = @_;

    return unless $self->{actions};

    shift @{$self->{actions}};
}

1;
