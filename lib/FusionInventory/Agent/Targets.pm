package FusionInventory::Agent::Targets;

use strict;
use warnings;

use FusionInventory::Agent::Target::Server;
use FusionInventory::Agent::Target::Local;
use FusionInventory::Agent::Target::Stdout;

sub new {
    my ($class, $params) = @_;

    my $self = {};

    my $config = $self->{config} = $params->{config};
    my $logger = $self->{logger} = $params->{logger};
    $self->{deviceid} = $params->{deviceid};

    $self->{targets} = [];
    $self->{targets} = [];

    bless $self, $class;

    $self->init();

    return $self;
}

sub addTarget {
    my ($self, $params) = @_;

    my $logger = $self->{'logger'};

    $logger->fault("No target?!") unless $params->{'target'};

    push @{$self->{targets}}, $params->{'target'};

}

sub init {
    my ($self) = @_;

    my $config = $self->{config};
    my $logger = $self->{logger};
    my $deviceid = $self->{deviceid};


    if ($config->{'stdout'}) {
        my $target = FusionInventory::Agent::Target::Stdout->new({
            logger     => $logger,
            deviceid   => $deviceid,
            delaytime  => $config->{delaytime},
            basevardir => $config->{basevardir},
        });
        $self->addTarget({
            target => $target
        });
    }

    if ($config->{'local'}) {
        my $target = FusionInventory::Agent::Target::Local->new({
            logger     => $logger,
            deviceid   => $deviceid,
            delaytime  => $config->{delaytime},
            basevardir => $config->{basevardir},
            path       => $config->{local},
            html       => $config->{html},
        });
        $self->addTarget({
            target => $target
        });
    }

    foreach my $val (split(/,/, $config->{'server'})) {
        my $url;
        $val =~ s/^\s+//;
        $val =~ s/\s+$//;
        if ($val !~ /^http(|s):\/\//) {
            $logger->debug("the --server passed doesn't ".
                "have a protocole, ".
                "assume http as default");
            $url = "http://".$val.'/ocsinventory';
        } else {
            $url = $val;
        }
        my $target = FusionInventory::Agent::Target::Server->new({
            logger     => $logger,
            deviceid   => $deviceid,
            delaytime  => $config->{delaytime},
            basevardir => $config->{basevardir},
            url        => $url,
            tag        => $config->{tag},
        });
        $self->addTarget({
            target => $target
        });
    }

}

sub getNext {
    my ($self) = @_;

    my $config = $self->{'config'};
    my $logger = $self->{'logger'};

    return unless @{$self->{targets}};

    if ($config->{daemon} || $config->{service}) {
        while (1) {
            foreach my $target (@{$self->{targets}}) {
                if (time > $target->getNextRunDate()) {
                    return $target;
                }
            }
            sleep(10);
        }
    } elsif ($config->{'lazy'} && @{$self->{targets}}) {
        my $target = shift @{$self->{targets}};
        if (time > $target->getNextRunDate()) {
            $logger->debug("Processing ".$target->{'path'});
            return $target;
        } else {
            $logger->info("Nothing to do for ".$target->{'path'}.
		". Next server contact planned for ".
                localtime($target->getNextRunDate())
		);
        }
    } elsif ($config->{'wait'}) {
        my $wait = int rand($config->{'wait'});
        $logger->info("Going to sleep for $wait second(s) because of the".
            " wait parameter");
        sleep($wait);
        return shift @{$self->{targets}}
    } else {
        return shift @{$self->{targets}}
    }

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
