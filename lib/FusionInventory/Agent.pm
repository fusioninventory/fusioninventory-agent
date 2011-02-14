package FusionInventory::Agent;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Job;

# We need to keep a X.X.X revision format
# https://rt.cpan.org/Public/Bug/Display.html?id=61282
our $VERSION = '3.0.0';

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

sub getTaskFromConfiguration {
    my ($self, $id) = @_;

    my $logger = $self->{logger};

    my $config = $self->{config}->getBlock($id);
    if (!$config) {
        $logger->error("No such task `$id' in configuration");
        return;
    }

    my $type = $config->{type};
    $logger->error("No type for task $id") unless $type;

    my $class = 'FusionInventory::Agent::Task::' . ucfirst($type);
    $logger->error("Non-existing type $type for task $id")
        unless $class->require();
    $logger->error("Invalid type $type for task $id")
        unless $class->isa('FusionInventory::Agent::Task');

    return $class->new(id => $id, %$config);
}

sub getTargetFromConfiguration {
    my ($self, $id) = @_;

    my $logger = $self->{logger};

    my $config = $self->{config}->getBlock($id);
    if (!$config) {
        $logger->error("No such target `$id' in configuration");
        return;
    }
    
    my $type = $config->{type};
    $logger->error("No type for target $id") unless $type;

    my $class = 'FusionInventory::Agent::Target::' . ucfirst($type);
    $logger->error("Non-existing type $type for target $id")
        unless $class->require();
    $logger->error("Invalid type $type for target $id")
        unless $class->isa('FusionInventory::Agent::Target');

    return $class->new(id => $id, %$config);
}

sub getJobFromConfiguration {
    my ($self, $id) = @_;

    my $logger = $self->{logger};

    my $config = $self->{config}->getBlock($id);
    $logger->error("No such job $id in configuration") unless $config;

    return FusionInventory::Agent::Job->new(
        id         => $id,
        task       => $config->{task},
        target     => $config->{target},
        period     => $config->{period},
        logger     => $self->{logger},
        basevardir => $self->{vardir},
    );
}

sub getAnonymousJob {
    my ($self, $task, $target) = @_;

    return FusionInventory::Agent::Job->new(
        id         => 'anonymous',
        task       => $task,
        target     => $target,
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
