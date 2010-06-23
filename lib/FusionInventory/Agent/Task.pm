package FusionInventory::Agent::Task;

use strict;
use warnings;

use English qw(-no_match_vars);
use UNIVERSAL::require;

# reap child processes automatically
$SIG{CHLD} = 'IGNORE';

sub new {
    my ($class, $params) = @_;

    my $module = $params->{module};
    my $config = $params->{config};
    my $logger = $params->{logger};
    my $target = $params->{target};

    return if $config->{'no-'.lc($module)};

    my $full_module = "FusionInventory::Agent::Task::$module";
    if (!$full_module->require()) {
        $logger->info("Module $full_module is not installed.");
        return;
    }

    my $self = {
        config => $config,
        logger => $logger,
        target => $target,
        module => $module
    };

    bless $self, $class;

    return $self;
}

sub run {
    my ($self) = @_;

    my $logger = $self->{logger};
    my $module = $self->{module};

    if (my $pid = fork()) {
        # parent
    } else {
       die "fork failed: $ERRNO" unless defined $pid;
       # child
        $logger->debug("[task] executing $module in process $PID");

        my $package = "FusionInventory::Agent::Task::$module";
        my $task = $package->new({
            config => $self->{config},
            logger => $self->{logger},
            target => $self->{target},
        });
        $task->main();

        $logger->debug("[task] end of $module");
        exit 0;
    }

}

1;
