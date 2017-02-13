package FusionInventory::Agent::Task::Deploy::CheckProcessor::FileSHA512;

use strict;
use warnings;

use Digest::SHA;

use base "FusionInventory::Agent::Task::Deploy::CheckProcessor";

sub prepare {
    my ($self) = @_;

    $self->on_success("expected sha512 file checksum");
}

sub success {
    my ($self) = @_;

    $self->on_failure("missing file");
    return 0 unless -f $self->{path};

    $self->on_failure("no value provided to check file size again");
    my $expected = $self->{value};
    return 0 unless (defined($expected));

    $self->on_failure("sha512 not supported");
    my $sha = Digest::SHA->new('512');
    return 0 unless (defined($sha));

    $self->on_failure("file sha512 not found");
    my $sha512 = "";
    eval {
        $sha->addfile($self->{path}, 'b');
        $sha512 = $sha->hexdigest;
    };
    return 0 unless (defined($sha512) && $sha512);

    $self->on_failure("wrong sha512 file checksum");
    return ( $sha512 eq $expected );
}

1;
