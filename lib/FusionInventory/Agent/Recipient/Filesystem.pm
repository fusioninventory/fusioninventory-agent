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
        verbose  => $params{verbose},
    }, $class;
}

sub send {
    my ($self, %params) = @_;

    return if $params{control} and !$self->{verbose};

    my $file = sprintf('%s/%s.xml', $self->{path}, $params{hint});

    open(my $handle, '>', $file);
    print $handle $params{message}->getContent();
    close($handle);

}

1;
