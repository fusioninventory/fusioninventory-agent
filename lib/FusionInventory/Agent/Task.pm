package FusionInventory::Agent::Task;

use strict;
use warnings;

use English qw(-no_match_vars);

sub new {
    my ($class, $params) = @_;

    my $self = {};

    $self->{config} = $params->{config};
    $self->{logger} = $params->{logger};
    $self->{target} = $params->{target};

    $self->{module} = $params->{module};


    my $config = $self->{config};
    my $logger = $self->{logger};
    my $module = $self->{module};


    return if $config->{'no-'.lc($self->{module})};


    bless $self, $class;
    if (!$self->isModInstalled()) {
        $logger->debug("Module FusionInventory::Agent::Task::$module is not installed.");
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


    my $cmd;
    $cmd .= "\"$EXECUTABLE_NAME\""; # The Perl binary path
    if ($^O eq "MSWin32") {
        $ENV{PERL5LIB}="";
        $ENV{PERLLIB}="";
        $cmd .= "  -Ilib" if $config->{devlib};
        $cmd .= " -MFusionInventory::Agent::Task::".$module;
        $cmd .= " -e \"FusionInventory::Agent::Task::".$module."::main();\" --";
    } else {
        $cmd .= " -e \"";
        $cmd .= "\@INC=qw(";
        $cmd .= $_." " foreach (@INC);
        $cmd .= "); ";
        $cmd .= "eval 'use FusionInventory::Agent::Task::$module;'; ";
        $cmd .= "FusionInventory::Agent::Task::".$module."::main();\" --";
    }
    $cmd .= " \"".$target->{vardir}."\"";

    $logger->debug("cmd is: '$cmd'");
    system($cmd);

    $logger->debug("[task] end of ".$module);

}


1;
