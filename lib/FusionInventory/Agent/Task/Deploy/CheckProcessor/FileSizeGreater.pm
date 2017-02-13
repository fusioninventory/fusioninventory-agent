package FusionInventory::Agent::Task::Deploy::CheckProcessor::FileSizeGreater;

use strict;
use warnings;

use base "FusionInventory::Agent::Task::Deploy::CheckProcessor";

sub prepare {
}

sub success {
    my ($self) = @_;

    $self->on_failure("missing file");
    return 0 unless -f $self->{path};

    $self->on_failure("no value provided to check file size again");
    my $lower = $self->{value};
    return 0 unless (defined($lower));

    $self->on_failure("file stat failure");
    my @fstat = stat($self->{path});
    return 0 unless (@fstat);

    $self->on_failure("file size not found");
    my $size = $fstat[7];
    return 0 unless (defined($size));

    $self->on_failure("file size not greater: $size <= $lower");
    $self->on_success("file size is greater: $size > $lower");
    return ( $size > $lower );
}

1;
