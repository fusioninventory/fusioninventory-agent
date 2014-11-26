package FusionInventory::Agent::Target::Directory;

use strict;
use warnings;
use base qw(FusionInventory::Agent::Target);

use JSON;

sub new {
    my ($class, %params) = @_;

    die "missing path parameter" unless $params{path};
    die "non-existing path $params{path}"
        unless -e $params{path};
    die "invalid path $params{path}, expecting a directory"
        unless -d $params{path};

    return bless {
        path => $params{path},
    }, $class;
}

sub send {
    my ($self, %params) = @_;

    return unless $params{message};
    return unless $params{filename};

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
