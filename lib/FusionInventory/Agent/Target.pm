package FusionInventory::Agent::Target;

use strict;
use warnings;

use English qw(-no_match_vars);
use File::Path qw(make_path);

use FusionInventory::Agent::Storage;

sub new {
    my ($class, $params) = @_;

    my $self = {
        delaytime       => $params->{delaytime},
        logger          => $params->{logger},
        path            => $params->{path} || '',
        deviceid        => $params->{deviceid},
        nextRunDate     => undef,
        debugPrintTimer => 0
    };
    bless $self, $class;

    my $logger = $self->{logger};

    # The agent can contact different servers. Each server has it's own
    # directory to store data
    $self->{vardir} = $params->{basevardir} . '/' . $params->{dir};

    if (!-d $self->{vardir}) {
        make_path($self->{vardir}, {error => \my $err});
        if (@$err) {
            $logger->error("Failed to create $self->{vardir}");
        }
    }

    if (! -w $self->{vardir}) {
        die "Can't write in $self->{vardir}";
    }

    $logger->debug("storage directory: $self->{vardir}");

    $self->{storage} = FusionInventory::Agent::Storage->new({
        target => $self
    });
    $self->_load();

    return $self;
}

sub setNextRunDate {

    my ($self, $args) = @_;

    my $logger = $self->{logger};
    my $storage = $self->{storage};

    my $serverdelay = $self->{myData}{prologFreq};

    my $max;
    if ($serverdelay) {
        $max = $serverdelay * 3600;
    } else {
        $max = $self->{delaytime};
        # If the PROLOG_FREQ has never been initialized, we force it at 1h
        $self->setPrologFreq(1);
    }
    $max = 1 unless $max;

    my $time = time + ($max/2) + int rand($max/2);

    $self->{myData}{nextRunDate} = $time;
    
    $self->{nextRunDate} = $self->{myData}{nextRunDate};

    $logger->debug (
        "[$self->{path}] Next server contact'd just been planned for ".
        localtime($self->{myData}{nextRunDate})
    );

    $storage->save({ data => $self->{myData} });
}

sub getNextRunDate {
    my ($self) = @_;

    if ($self->{debugPrintTimer} < time) {
        $self->{debugPrintTimer} = time + 600;
    }; 

    return $self->{nextRunDate};
}

sub resetNextRunDate {
    my ($self) = @_;

    my $logger = $self->{logger};

    $logger->debug("Force run now");
    
    $self->{nextRunDate} = 1;
    $self->_save();
}

sub _load {
    my ($self) = @_;

    my $data = $self->{storage}->restore();
    $self->{nextRunDate} = $data->{nextRunDate};

    if ($self->{nextRunDate}) {
        $self->{logger}->debug (
            "[$self->{path}] Next server contact planned for ".
            localtime($data->{nextRunDate})
        );
    }

    return $data;
}

sub _save {
    my ($self, $data) = @_;

    $data->{nextRunDate} = $self->{nextRunDate};
    $self->{storage}->save({ data => $data });
}

1;
