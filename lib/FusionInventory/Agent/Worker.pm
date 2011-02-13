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

    my $logger = $self->{logger};

    my $job;
    if ($params{job}) {
        $job = $self->getJobFromConfiguration($params{job});
    } elsif ($params{task} && $params{target}) {
        $job = $self->getAnonymousJob($params{task}, $params{target});
    } else {
        $logger->error("Unable to create a job, aborting");
    }

    my $task    = $self->getTaskFromConfiguration($job->{task});
    my $target  = $self->getTargetFromConfiguration($job->{target});
    my $storage = $job->getStorage();

    $logger->info(
        sprintf(
            "Running task '%s' for target '%s' as job '%s'",
            $task->{id}, $target->{id}, $job->{id}
        )
    );

    # run task
    $task->run(
        target   => $target,
        logger   => $logger,
        storage  => $storage,
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
