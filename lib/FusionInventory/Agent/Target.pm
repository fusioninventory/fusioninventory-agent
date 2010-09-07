package FusionInventory::Agent::Target;

use strict;
use warnings;
use threads;
use threads::shared;

use English qw(-no_match_vars);
use File::Path qw(make_path);

# resetNextRunDate() can also be call from another thread (RPC)
my $lock :shared;

sub new {
    my ($class, $params) = @_;

    my $self = {
        delaytime       => $params->{delaytime},
        logger          => $params->{logger},
        path            => $params->{path} || '',
        deviceid        => $params->{deviceid},
        debugPrintTimer => 0
    };
    bless $self, $class;

    my $nextRunDate :shared;
    $self->{nextRunDate} = \$nextRunDate;

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

    $self->{accountinfofile} = $self->{vardir} . "/ocsinv.adm";
    $self->{last_statefile} = $self->{vardir} . "/last_state";

    $self->{storage} = FusionInventory::Agent::Storage->new({
        target => $self
    });

    return $self;
}

sub setNextRunDate {

    my ($self, $args) = @_;

    my $logger = $self->{logger};
    my $storage = $self->{storage};

    lock($lock);

    my $serverdelay = $self->{myData}{prologFreq};

    lock($lock);

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
    
    ${$self->{nextRunDate}} = $self->{myData}{nextRunDate};

    $logger->debug (
        "[$self->{path}] Next server contact'd just been planned for ".
        localtime($self->{myData}{nextRunDate})
    );

    $storage->save({ data => $self->{myData} });
}

sub getNextRunDate {
    my ($self) = @_;

    my $logger = $self->{logger};

    lock($lock);

    if (${$self->{nextRunDate}}) {
      
        if ($self->{debugPrintTimer} < time) {
            $self->{debugPrintTimer} = time + 600;
        }; 

        return ${$self->{nextRunDate}};
    }

    $self->setNextRunDate();

    if (!${$self->{nextRunDate}}) {
        die 'nextRunDate not set!';
    }

    return $self->{myData}{nextRunDate} ;

}

sub resetNextRunDate {
    my ($self) = @_;

    my $logger = $self->{logger};
    my $storage = $self->{storage};

    lock($lock);
    $logger->debug("Force run now");
    
    $self->{myData}{nextRunDate} = 1;
    $storage->save({ data => $self->{myData} });
    
    ${$self->{nextRunDate}} = $self->{myData}{nextRunDate};
}

sub setPrologFreq {

    my ($self, $prologFreq) = @_;

    my $logger = $self->{logger};
    my $storage = $self->{storage};

    return unless $prologFreq;

    if ($self->{myData}{prologFreq} && ($self->{myData}{prologFreq}
            eq $prologFreq)) {
        return;
    }
    if (defined($self->{myData}{prologFreq})) {
        $logger->info(
            "PROLOG_FREQ has changed since last process ". 
            "(old=$self->{myData}{prologFreq},new=$prologFreq)"
        );
    } else {
        $logger->info("PROLOG_FREQ has been set: $prologFreq");
    }

    $self->{myData}{prologFreq} = $prologFreq;
    $storage->save({ data => $self->{myData} });

}

sub setCurrentDeviceID {

    my ($self, $deviceid) = @_;

    my $logger = $self->{logger};
    my $storage = $self->{storage};

    return unless $deviceid;

    if ($self->{myData}{currentDeviceid} &&
        ($self->{myData}{currentDeviceid} eq $deviceid)) {
        return;
    }

    if (!$self->{myData}{currentDeviceid}) {
        $logger->debug("DEVICEID initialized at $deviceid");
    } else {
        $logger->info(
            "DEVICEID has changed since last process ". 
            "(old=$self->{myData}{currentDeviceid},new=$deviceid"
        );
    }

    $self->{myData}{currentDeviceid} = $deviceid;
    $storage->save({ data => $self->{myData} });
}

1;
