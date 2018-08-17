package FusionInventory::Agent::Task::Maintenance;

use strict;
use warnings;

use parent 'FusionInventory::Agent::Task';

use English qw(-no_match_vars);
use UNIVERSAL::require;
use File::Basename;

use FusionInventory::Agent::Task::Maintenance::Version;

our $VERSION = FusionInventory::Agent::Task::Maintenance::Version::VERSION;

sub isEnabled {
    my ($self) = @_;

    if (!$self->{target}->isType('scheduler')) {
        $self->{logger}->debug("Maintenance task only compatible with Scheduler target");
        return;
    }

    my $found = 0;
    # Lookup for each target task if a Maintenance module exists
    foreach my $task ($self->{target}->otherTasks()) {
        my $taskdir = dirname(__FILE__) .'/'. ucfirst($task);
        next unless -d $taskdir;

        my $maintenance = $taskdir.'/Maintenance.pm';
        next unless -e $maintenance;

        $found ++;
        last;
    }

    return $found;
}

sub run {
    my ($self) = @_;

    my $logger = $self->{logger};
    my @taskclass = split('::', __PACKAGE__);
    pop @taskclass;

    # Lookup for each target task if a Maintenance module exists and run
    # the its doMaintenance() API
    foreach my $task ($self->{target}->otherTasks()) {
        my $taskdir = dirname(__FILE__) .'/'. ucfirst($task);
        next unless -d $taskdir;

        my $file = $taskdir.'/Maintenance.pm';
        next unless -e $file;

        my $module = join('::', @taskclass, ucfirst($task), 'Maintenance');
        $module->require();
        if ($EVAL_ERROR) {
            $logger->debug("failed to load $task maintenance module: $EVAL_ERROR");
           next;
        }

        $logger->debug2("Doing $task Maintenance");
        my $maintenance = $module->new(
            target  => $self->{target},
            config  => $self->{config},
            logger  => $logger,
        );
        $maintenance->doMaintenance();
    }
}

1;

__END__

=head1 NAME

FusionInventory::Agent::Task::Maintenance - Maintenance for FusionInventory Agent environment

=head1 DESCRIPTION

With this module, F<FusionInventory> will maintain its environment clean
and safe.

=head1 FUNCTIONS

=head2 isEnabled()

Lookup for a Maintenance module for each target enabled tasks.

Returns true if the task should be finally enabled.

=head2 run()

Run the Maintenance task by calling each doMaintenance() API from each
task Maintenance found modules.
