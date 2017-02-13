package FusionInventory::Agent::Task::Deploy::CheckProcessor::FileSizeLower;

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
    my $greater = $self->{value};
    return 0 unless (defined($greater));

    $self->on_failure("file stat failure");
    my @fstat = stat($self->{path});
    return 0 unless (@fstat);

    $self->on_failure("file size not found");
    my $size = $fstat[7];
    return 0 unless (defined($size));

    $self->on_failure("file size not lower: $size >= $greater");
    $self->on_success("file size is lower: $size < $greater");
    return ( $size < $greater );
}

1;
