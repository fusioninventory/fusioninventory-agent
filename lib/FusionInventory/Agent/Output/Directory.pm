package FusionInventory::Agent::Output::Directory;

use strict;
use warnings;

sub new {
    my ($class, %params) = @_;

    die "invalid path" unless -d $params{path};

    return bless {
        path    => $params{path},
        task    => $params{task},
        verbose => $params{verbose},
        count   => 0
    }, $class;
}

sub send {
    my ($self, %params) = @_;

    # don't display control message by default
    return unless $self->{verbose}
        or $params{message}->{h}->{CONTENT}->{DEVICE};

    my $file = sprintf(
        "%s/%s.%d.xml", $self->{path}, $self->{task}, $self->{count}
    );

    open(my $handle, '>', $file);
    print $handle $params{message}->getContent();
    close($handle);

    $self->{count}++;
}

1;
