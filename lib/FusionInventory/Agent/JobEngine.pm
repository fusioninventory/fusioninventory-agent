package FusionInventory::Agent::JobEngine;

use IPC::Open3;
use IO::Select;
use POSIX ":sys_wait_h";

use English;

sub new {
    my (undef, $params) = @_;

    my $self = {};

    $self->{logger} = $params->{logger};

    bless $self;
}

sub start {
    my $self = shift;
    my $name = shift;
    my @cmd = @_;

    $self->{name} = $name;

    $self->{pid} = open3(
        $self->{stdin},
        $self->{stdout},
        $self->{stderr},
        @cmd
    );

    if (!$self->{pid}) {
        print "Failed to start cmd\n";
    }
}


sub isModInstalled {
    my ($self) = @_;

    my $module = $self->{module};

    foreach my $inc (@INC) {
        return 1 if -f $inc.'/FusionInventory/Agent/Task/'.$module.'.pm';
    }

    return 0;
}


sub startTask {
    my ($self, $module) = @_;

    my $logger = $self->{logger};

    if (!$self->isModInstalled($module)) {
        $logger->debug("$module is not avalaible");
    }

    my @cmd;
    push @cmd, "\"$EXECUTABLE_NAME\"";
    push @cmd, "-Ilib" if $config->{devlib};
    push @cmd, "-MFusionInventory::Agent::Task::".$module;
    push @cmd, "-e";
    push @cmd, "FusionInventory::Agent::Task::".$module."::main();";
    push @cmd, "--";
    push @cmd, $target->{vardir};

    $self->start("Module $module", @cmd);

}

sub isDead {
    my ($self) = @_;

    return if waitpid( $self->{pid}, WNOHANG) == 0;

    my $child_exit_status = $? >> 8;
    print "End of task ".$self->{name}. " With return code ".$child_exit_status."\n";

    return 1;
}

sub getError {
    my ($self) = @_;

    my $h = $self->{stdout};
    my $s = IO::Select->new();
    $s->add($h);

    my $buffer;

    my $tmp;
    while ($s->can_read(.5) && ($tmp = <$h>)) {
        last unless defined($tmp);
        $buffer .= $tmp;
    }
    return unless defined($buffer);

    while ($buffer =~ s/(\w+):(.*?)\n//) {
        print "Error($1): $2\n";

    }
    print "remaining error messages:\n $buffer\n";
}

1;
