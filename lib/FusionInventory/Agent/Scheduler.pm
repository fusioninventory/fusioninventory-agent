package FusionInventory::Agent::Scheduler;

use strict;
use warnings;

use FusionInventory::Agent::Target::Local;
use FusionInventory::Agent::Target::Stdout;
use FusionInventory::Agent::Target::Server;

sub new {
    my ($class, $params) = @_;

    my $self = {
        config   => $params->{config},
        logger   => $params->{logger},
        deviceid => $params->{deviceid},
        targets  => []
    };

    bless $self, $class;

    $self->init();

    return $self;
}

sub init {
    my ($self) = @_;

    my $config = $self->{config};
    my $logger = $self->{logger};
    my $deviceid = $self->{deviceid};

    if ($config->{'stdout'}) {
        push
            @{$self->{targets}},
            FusionInventory::Agent::Target::Stdout->new({
                logger     => $logger,
                deviceid   => $deviceid,
                delaytime  => $config->{delaytime},
                basevardir => $config->{basevardir},
            });
    }

    if ($config->{'local'}) {
        push
            @{$self->{targets}},
            FusionInventory::Agent::Target::Local->new({
                logger     => $logger,
                deviceid   => $deviceid,
                delaytime  => $config->{delaytime},
                basevardir => $config->{basevardir},
                path       => $config->{local},
            });
    }

    foreach my $val (split(/,/, $config->{'server'})) {
        my $url;
        if ($val !~ /^https?:\/\//) {
            $logger->debug(
                "the --server passed doesn't have a protocole, assume http " .
                "as default"
            );
            $url = "http://$val/ocsinventory";
        } else {
            $url = $val;
        }
        push
            @{$self->{targets}},
            FusionInventory::Agent::Target::Server->new({
                logger     => $logger,
                deviceid   => $deviceid,
                delaytime  => $config->{delaytime},
                basevardir => $config->{basevardir},
                path       => $url,
            });
    }

}

sub getNext {
    my ($self) = @_;

    my $config = $self->{'config'};
    my $logger = $self->{'logger'};

    return unless @{$self->{targets}};

    if ($config->{'daemon'} || $config->{'service'}) {
        # block until a target is eligible to run, then return it
        while (1) {
            foreach my $target (@{$self->{targets}}) {
                if (time > $target->getNextRunDate()) {
                    return $target;
                }
            }
            sleep(10);
        }
    } else {
        my $target = shift @{$self->{targets}};

        # return next target if eligible, nothing otherwise
        if ($config->{'lazy'}) {
            if (time > $target->getNextRunDate()) {
                $logger->debug("Processing $target->{path}");
                return $target;
            } else {
                $logger->info(
                    "Nothing to do for $target->{path}. Next server contact " .
                    "planned for " . localtime($target->getNextRunDate())
                );
                return;
            }
        }

        # return next target after waiting for a random delay
        if ($config->{'wait'}) {
            my $wait = int rand($config->{'wait'});
            $logger->info(
                "Going to sleep for $wait second(s) because of the wait " .
                "parameter"
            );
            sleep($wait);
            return $target;
        }

        # return next target immediatly
        return $target;
    }

    # should never get reached
    return;
}

sub numberOfTargets {
    my ($self) = @_;

    return @{$self->{targets}}
}

sub resetNextRunDate {
    my ($self) = @_;

    foreach my $target (@{$self->{targets}}) {
        $target->resetNextRunDate();
    }
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Scheduler - A target scheduler

=head1 DESCRIPTION

This is the object used by the agent to schedule various targets.

=head1 METHODS

=head2 new($params)

The constructor. The following named parameters are allowed:

=over

=item config (mandatory)

=item logger (mandatory)

=item deviceid (mandatory)
