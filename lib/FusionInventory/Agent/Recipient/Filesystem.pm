package FusionInventory::Agent::Recipient::Filesystem;

use strict;
use warnings;

sub new {
    my ($class, %params) = @_;

    die "missing target parameter" unless $params{target};
    die "non-existing path $params{target}"
        unless -e $params{target};
    die "invalid path $params{target}, expecting a directory"
        unless -d $params{target};

    return bless {
        path     => $params{target},
        deviceid => $params{deviceid},
        task     => $params{task},
        verbose  => $params{verbose},
        count    => 0
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
