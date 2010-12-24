package FusionInventory::Agent::Task::Base;

use strict;
use warnings;

sub new {
    my ($class) = @_;

    my $self = {};
    bless $self, $class;

    my $storage = FusionInventory::Agent::Storage->new({
        target => {
            vardir => $ARGV[0],
        }
    });
    my $data = $storage->restore({
        module => "FusionInventory::Agent"
    });
    $self->{storage} = $storage;
    $self->{data} = $data;
    my $myCaller = scalar(caller(0));
    $self->{myData} = $storage->restore({ module => $myCaller  });

    $self->{config} = $data->{config};
    $self->{target} = $data->{target};
    $self->{logger} = FusionInventory::Logger->new({
        config => $self->{config}
    });
    $self->{prologresp} = $data->{prologresp};

    return $self;
}

1;
