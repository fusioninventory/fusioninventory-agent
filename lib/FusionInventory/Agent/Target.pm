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
    my ($class, %params) = @_;

    die 'no basevardir parameter' unless $params{basevardir};

    my $self = {
        logger   => $params{logger} ||
                     FusionInventory::Agent::Logger->new(),
        maxDelay => $params{maxDelay} || 3600,
    };
    bless $self, $class;

    return $self;
}

sub _init {
    my ($self, %params) = @_;

    my $logger = $self->{logger};

    my $nextRunDate : shared;
    $self->{nextRunDate} = \$nextRunDate;

    # target identity
    $self->{id} = $params{id};

    # target storage
    $self->{storage} = FusionInventory::Agent::Storage->new(
        logger    => $self->{logger},
        directory => $params{vardir}
    );

    my $storage = $self->{storage};
    my $data = $storage->restore();

    if ($data->{nextRunDate}) {
        ${$self->{nextRunDate}} = $data->{nextRunDate};
    } else {
        $self->setNextRunDate();
    }

    $logger->debug (
        "[target $self->{id}] Next server contact planned for ".
        localtime(${$self->{nextRunDate}})
    );

    $self->{last_statefile} = $params{vardir} . "/last_state";
}

sub getStorage {
    my ($self) = @_;

    return $self->{storage};
}

sub setNextRunDate {
    my ($self, $nextRunDate) = @_;

    my $logger = $self->{logger};

    lock($lock);
    
    if (! defined $nextRunDate) {
        $nextRunDate = 
            time                           +
            $self->{maxDelay} / 2          +
            int rand($self->{maxDelay} / 2);
    }

    ${$self->{nextRunDate}} = $nextRunDate;

    $logger->debug (
        "[target $self->{id}] Next server contact has just been planned for ".
        localtime(${$self->{nextRunDate}})
    );

    $self->_saveState();
}

sub getNextRunDate {
    my ($self) = @_;

    return ${$self->{nextRunDate}};
}

sub resetNextRunDate {
    my ($self) = @_;

    my $logger = $self->{logger};
    my $storage = $self->{storage};

    lock($lock);
    $logger->debug("Agent is now running");
    
    ${$self->{nextRunDate}} = 1;

    $self->_saveState();
}

sub setMaxDelay {
    my ($self, $maxDelay) = @_;

    $self->{maxDelay} = $maxDelay;

    $self->_saveState();
}

sub _saveState {
    my ($self) = @_;

    $self->{storage}->save(data => {
        maxDelay    => $self->{maxDelay},
        nextRunDate => $self->{nextRunDate},
    });
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Target - Abstract target

=head1 DESCRIPTION

This is an abstract class for execution targets.

=head1 METHODS

=head2 new(%params)

The constructor. The following parameters are allowed, as keys of the %params
hash:

=over

=item I<logger>

the logger object to use

=item I<maxDelay>

the maximum delay before contacting the target, in seconds 
(default: 3600)

=item I<basevardir>

the base directory of the storage area (mandatory)

=back

=head2 getNextRunDate()

Get nextRunDate attribute.

=head2 setNextRunDate($nextRunDate)

Set nextRunDate attribute.

=head2 resetNextRunDate()

Set nextRunDate attribute to 1.

=head2 setMaxDelay($maxDelay)

Set maxDelay attribute.

=head2 getStorage()

Return the storage object for this target.

=head2 getDescription()

Return a string description of the target.
