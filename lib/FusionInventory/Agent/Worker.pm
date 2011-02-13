package FusionInventory::Agent::Worker;

use strict;
use warnings;
use base qw/FusionInventory::Agent/;

use FusionInventory::Agent::Config;
use FusionInventory::Agent::Logger;
use FusionInventory::Agent::Storage;
use FusionInventory::Agent::Target::Local;
use FusionInventory::Agent::Target::Stdout;
use FusionInventory::Agent::Target::Server;

sub run {
    my ($self, %params) = @_;

    die 'No target' unless $params{target};
    die 'No task' unless $params{task};

    my $config = $self->{config};
    my $logger = $self->{logger};

    # target selection
    my $target_config = $config->getBlock($params{target});
    foreach my $key (keys %{$params{target_params}}) {
        $target_config->{$key} = $params{target_params}->{$key};
    }

    my $target_type = $target_config->{type}
        or die "No type for target $params{target}, aborting";

    my $target;
    SWITCH: {
        if ($target_type eq 'stdout') {
            $target = FusionInventory::Agent::Target::Stdout->new(
                id         => $params{target},
                logger     => $logger,
                basevardir => $self->{vardir},
                period     => $target_config->{delaytime},
                format     => $target_config->{format}
            );
            last SWITCH;
        }

        if ($target_type eq 'local') {
            $target = FusionInventory::Agent::Target::Local->new(
                id         => $params{target},
                logger     => $logger,
                basevardir => $self->{vardir},
                period     => $target_config->{delaytime},
                path       => $target_config->{path},
                format     => $target_config->{format}
            );
            last SWITCH;
        }

        if ($target_type eq 'server') {
            $target = FusionInventory::Agent::Target::Server->new(
                id         => $params{target},
                logger     => $logger,
                basevardir => $self->{vardir},
                period     => $target_config->{delaytime},
                url        => $target_config->{url},
                format     => $target_config->{format},
                tag        => $target_config->{tag},
                user       => $target_config->{user},
                password   => $target_config->{password},
                proxy      => $target_config->{proxy},
                cacertdir  => $target_config->{'ca-cert-dir'},
                cacertfile => $target_config->{'ca-cert-file'},
                sslcheck   => $target_config->{'ssl-check'},
            );
            last SWITCH;
        }

        die "Invalid type $target_type for target $params{target}, aborting";
    }

    # task selection
    my $task_config = $config->getBlock($params{task});
    foreach my $key (keys %{$params{task_params}}) {
        $task_config->{$key} = $params{task_params}->{$key};
    }

    my $task_type = $task_config->{type}
        or die "No type for task $params{task}, aborting";

    my $class = 'FusionInventory::Agent::Task::' . ucfirst($task_type);

    if (!$class->require()) {
        $logger->fatal("Class $class is not installed.");
    }
    if (!$class->isa('FusionInventory::Agent::Task')) {
        $logger->fatal("Class $class is not a FusionInventory task.");
    }

    $logger->info("Running task $params{task} for target $params{target}");

    my $task = $class->new(%$task_config);

    # run task
    $task->run(
        target   => $target,
        logger   => $logger,
        confdir  => $self->{confdir},
        datadir  => $self->{datadir},
        deviceid => $self->{deviceid},
        token    => $self->{token},
    );

}

1;

__END__

=head1 NAME

FusionInventory::Worker - Fusion Inventory worker

=head1 DESCRIPTION

A worker object run a single task against a single target.

=head1 METHODS

=head2 new(%params)

The constructor.

=head2 run(%params)

Run the worker.
