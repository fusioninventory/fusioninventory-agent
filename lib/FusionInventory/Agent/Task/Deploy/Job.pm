package FusionInventory::Agent::Task::Deploy::Job;

use strict;
use warnings;

use English qw(-no_match_vars);

sub new {
    my ($class, %params) = @_;

    my $self = {
        uuid            => $params{data}->{uuid},
        requires        => $params{data}->{requires},
        checks          => $params{data}->{checks},
        actions         => $params{data}->{actions},
        associatedFiles => $params{associatedFiles}
    };

    bless $self, $class;

    return $self;
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
