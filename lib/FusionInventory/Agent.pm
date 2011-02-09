package FusionInventory::Agent;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Job;

our $VERSION = '3.0';
our $VERSION_STRING =
    "FusionInventory unified agent for UNIX, Linux and MacOSX ($VERSION)";
our $AGENT_STRING =
    "FusionInventory-Agent_v$VERSION";

sub new {
    my ($class, %params) = @_;

    my $self = {
        confdir => $params{confdir},
        datadir => $params{datadir},
        vardir  => $params{vardir},
    };
    bless $self, $class;

    my $config = FusionInventory::Agent::Config->new(
        directory => $params{confdir},
        file      => $params{conffile},
    );
    $self->{config} = $config;

    my $logger = FusionInventory::Agent::Logger->new(
        %{$config->getBlock('logger')},
        backends => [ $config->getValues('logger.backends') ],
        debug    => $params{debug}
    );
    $self->{logger} = $logger;

    if ($REAL_USER_ID != 0) {
        $logger->info("You should run this program as super-user.");
    }

    $logger->debug("Configuration directory: $self->{confdir}");
    $logger->debug("Data directory: $self->{datadir}");
    $logger->debug("Storage directory: $self->{vardir}");

    # restore state
    my $storage = FusionInventory::Agent::Storage->new(
        logger    => $logger,
        directory => $self->{vardir}
    );
    my $dirty;
    my $data = $storage->restore();

    if ($data->{deviceid}) {
        $self->{deviceid} = $data->{deviceid};
    } else {
        $self->{deviceid} = getDeviceId();
        $dirty = 1;
    }

    if ($data->{token}) {
        $self->{token} = $data->{token};
    } else {
        $self->{token} = getRandomToken();
        $dirty = 1;
    }

    if ($dirty) {
        $storage->save(
            data => {
                deviceid => $self->{deviceid},
                token    => $self->{token}
            }
        );
    }

    $logger->debug("FusionInventory Agent initialised");

    return $self;
}

sub getDeviceId {
    my $hostname = getHostname();
    my ($year, $month , $day, $hour, $min, $sec) =
        (localtime(time()))[5,4,3,2,1,0];
    return sprintf "%s-%02d-%02d-%02d-%02d-%02d-%02d",
        $hostname, ($year + 1900), ($month + 1), $day, $hour, $min, $sec;
}

sub getRandomToken {
    my @chars = ('A'..'Z');
    return join('', map { $chars[rand @chars] } 1..8);
}

sub createJob {
    my ($self, $job_name) = @_;

    my $config = $self->{config};
    my $logger = $self->{logger};

    my $job_config = $config->getBlock($job_name);
    if (!keys %$job_config) {
        $logger->error("No configuration for job $job_name, skipping");
        return;
    }

    my $target_name = $job_config->{target};
    if (!$target_name) {
        $logger->error("No target for job $job_name, skipping");
        return;
    }

    my $target_config = $config->getBlock($target_name);
    if (!keys %$target_config) {
        $logger->error("No configuration for target $target_name, skipping");
        return;
    }

    my $target_type = $target_config->{type};
    if (!$target_type) {
        $logger->error("No type for target $target_name, skipping");
        return;
    }

    my $target_class =
        $target_type eq 'stdout' ? 'FusionInventory::Agent::Target::Stdout':
        $target_type eq 'local'  ? 'FusionInventory::Agent::Target::Local' :
        $target_type eq 'server' ? 'FusionInventory::Agent::Target::Server':
                                   undef                                   ;
    if (!$target_class) {
        $logger->error("Invalid type $target_type, skipping");
        return;
    }

    my $task_name = $job_config->{task};
    if (!$task_name) {
        $logger->error("No task for job $job_name, skipping");
        return;
    }

    my $task_config = $config->getBlock($task_name);
    if (!keys %$task_config) {
        $logger->error("No configuration for task $task_name, skipping");
        return;
    }

    my $task_type = $task_config->{type};
    if (!$task_type) {
        $logger->error("No type for task $task_name, skipping");
        return;
    }

    my $task_class = 'FusionInventory::Agent::Task::' . ucfirst($task_type);

    if (!$task_class->require()) {
        $logger->error("Unavailable class $task_class, skipping");
        return;
    }

    if (!$task_class->isa('FusionInventory::Agent::Task')) {
        $logger->error("Invalid class $task_class, skipping");
        return;
    }

    return FusionInventory::Agent::Job->new(
        id         => $job_name,
        task       => $job_config->{task},
        target     => $job_config->{target},
        period     => $job_config->{period},
        logger     => $self->{logger},
        basevardir => $self->{vardir},
    );
}

1;
__END__

=head1 NAME

FusionInventory::Agent - Fusion Inventory agent

=head1 DESCRIPTION

This is the agent object.
