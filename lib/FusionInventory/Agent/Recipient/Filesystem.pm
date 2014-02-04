package FusionInventory::Agent::Recipient::Filesystem;

use strict;
use warnings;

use JSON;

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

    return unless $params{message};
    return if $params{control} and !$self->{verbose};

    my $file = sprintf("%s/%s", $self->{path}, $params{filename});

    open(my $handle, '>', $file);
    if (ref $params{message} eq 'HASH') {
        print $handle to_json($params{message}, { ascii => 1, pretty => 1 } );
    } else {
        print $handle $params{message}->getContent();
    }
    close($handle);
}

1;
