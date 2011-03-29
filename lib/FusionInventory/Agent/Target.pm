package FusionInventory::Agent::Target;

use strict;
use warnings;

use Config;
use English qw(-no_match_vars);

use FusionInventory::Agent::Logger;
use FusionInventory::Agent::Storage;

BEGIN {
    # threads and threads::shared must be loaded before
    # $lock is initialized
    if ($Config{usethreads}) {
        eval {
            require threads;
            require threads::shared;
        };
        if ($EVAL_ERROR) {
            print "[error]Failed to use threads!\n"; 
        }
    }
}

# resetNextRunDate() can also be called from another thread (RPC)
my $lock : shared;

sub new {
    my ($class, $params) = @_;

    die 'no basevardir parameter' unless $params->{basevardir};

    my $self = {
        logger    => $params->{logger} ||
                     FusionInventory::Agent::Logger->new(),
        deviceid  => $params->{deviceid},
        delaytime => $params->{delaytime} || 3600,
    };
    bless $self, $class;

    return $self;
}

sub _init {
    my ($self, $params) = @_;

    my $logger = $self->{logger};

    my $nextRunDate : shared;
    $self->{nextRunDate} = \$nextRunDate;

    # target identity
    $self->{id} = $params->{id};

    # target storage
    $self->{storage} = FusionInventory::Agent::Storage->new({
        logger    => $self->{logger},
        directory => $params->{vardir}
    });

    my $storage = $self->{storage};
    $self->{myData} = $storage->restore();

    if ($self->{myData}{nextRunDate}) {
        $logger->debug (
            "[target $self->{id}] Next server contact planned for ".
            localtime($self->{myData}{nextRunDate})
        );
        ${$self->{nextRunDate}} = $self->{myData}{nextRunDate};
    }

    $self->{currentDeviceid} = $self->{myData}{currentDeviceid};

    $self->{last_statefile} = $params->{vardir} . "/last_state";
}

sub getStorage {
    my ($self) = @_;

    return $self->{storage};
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
        "[target $self->{id}] Next server contact has just been planned for ".
        localtime($self->{myData}{nextRunDate})
    );

    $storage->save({ data => $self->{myData} });
}

sub getNextRunDate {
    my ($self) = @_;

    my $logger = $self->{logger};

    lock($lock);

    if (${$self->{nextRunDate}}) {
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

    $self->{currentDeviceid} = $deviceid;

}

1;

1;

__END__

=head1 NAME

FusionInventory::Agent::Target - Abstract target

=head1 DESCRIPTION

This is an abstract class for execution targets.

=head1 METHODS

=head2 new($params)

The constructor. The following parameters are allowed, as keys of the $params
hashref:

=over

=item I<logger>

the logger object to use

=item I<delaytime>

the initial delay before contacting the target, in seconds 
(default: 3600)

=item I<deviceid>

the agent identifier

=item I<basevardir>

the base directory of the storage area (mandatory)

=back

=head2 getNextRunDate()

Get nextRunDate attribute.

=head2 setNextRunDate($nextRunDate)

Set nextRunDate attribute.

=head2 getStorage()

Return the storage object for this target.

=head2 getDescription()

Return a string description of the target.
