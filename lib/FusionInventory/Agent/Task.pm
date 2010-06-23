package FusionInventory::Agent::Task;

use strict;
use warnings;

use English qw(-no_match_vars);
use UNIVERSAL::require;

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


    my $cmd;
    $cmd .= "\"$EXECUTABLE_NAME\""; # The Perl binary path
    $cmd .= "  -Ilib" if $config->{devlib};
    $cmd .= " -MFusionInventory::Agent::Task::".$module;
    $cmd .= " -e \"FusionInventory::Agent::Task::".$module."::main();\" --";
    $cmd .= " \"".$target->{vardir}."\"";

    $logger->debug("cmd is: '$cmd'");
    system($cmd);

    $logger->debug("[task] end of ".$module);

}


1;
