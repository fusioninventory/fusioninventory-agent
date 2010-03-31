package FusionInventory::Agent::Task;

use strict;
use warnings;

use English;

sub new {
    my (undef, $params) = @_;

    my $self = {};

    $self->{config} = $params->{config};
    $self->{logger} = $params->{logger};
    $self->{target} = $params->{target};

    $self->{module} = $params->{module};
    $self->{name} = $params->{name};

    my $config = $self->{config};
    my $logger = $self->{logger};
    my $module = $self->{module};
    my $name = $self->{name};

    return if $config->{$name};

    bless $self;
    if (!$self->isModInstalled()) {
        $logger->info("Module FusionInventory::Agent::Task::$module is not installed.");
        return;
    }


    return $self;
}

sub isModInstalled {
    my ($self) = @_;

    my $module = $self->{module};

    foreach my $inc (@INC) {
        return 1 if -f $inc.'/FusionInventory/Agent/Task/'.$module.'.pm'; 
    }

    return 0;
}

sub run {
    my ($self) = @_;

    my $config = $self->{config};
    my $logger = $self->{logger};
    my $target = $self->{target};
    
    my $module = $self->{module};
    my $name = $self->{name};

    my $cmd;
    $cmd .= $EXECUTABLE_NAME; # The Perl binary path
    $cmd .= "  -Ilib" if $config->{devlib};
    $cmd .= " -MFusionInventory::Agent::Task::".$module;
    $cmd .= " -e 'FusionInventory::Agent::Task::".$module."::main();' --";
    $cmd .= " ".$target->{vardir};

    $logger->debug("cmd is: '$cmd'");
    system($cmd);

    $logger->debug("[task] end of ".$module);

}


1;
