package FusionInventory::Agent::Recipient::Inventory::Filesystem;

use strict;
use warnings;
use base 'FusionInventory::Agent::Recipient::Filesystem';

sub new {
    my ($class, %params) = @_;

    die "missing target parameter" unless $params{target};
    die "non-existing path $params{target}"
        unless -e $params{target};

    return bless {
        path     => $params{target},
        deviceid => $params{deviceid},
        task     => $params{task},
        verbose  => $params{verbose},
        datadir  => $params{datadir},
        count    => 0
    }, $class;
}

sub send {
    my ($self, %params) = @_;

    my $file;
    if (-d $self->{path}) {
        $file = sprintf(
            "%s/%s.%s",
            $self->{path},
            $self->{deviceid},
            'ocs'
        );
    } else {
        $file = $self->{path};
    }

    my $handle;
    if (Win32::Unicode::File->require()) {
        $handle = Win32::Unicode::File->new('w', $file);
    } else {
        open($handle, '>', $file);
    }

    print $handle $params{message}->getContent();

    close($handle);
}

1;
