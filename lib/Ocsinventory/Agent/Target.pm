package Ocsinventory::Agent::Target;

use File::Path;

sub new {
    my (undef, $params) = @_;

    my $self = {};

    $self->{'config'} = $params->{'config'};
    $self->{'logger'} = $params->{'logger'};
    $self->{'type'} = $params->{'type'};
    $self->{'path'} = $params->{'path'};

    my $logger = $self->{'logger'};



    bless $self;

    $self->init();

    if ($params->{'type'} !~ /^(server|local|stdout)$/ ) {
        $logger->fault('bad type'); 
    }

    if (!-d $self->{'vardir'}) {
        $logger->fault("Bad vardir setting!");
    }

    return $self;
}

sub isDirectoryWritable {
    my ($self, $dir) = @_;

    my $tmpFile = $dir."/file.tmp";

    open TMP, ">$tmpFile" or return;
    print TMP "1" or return;
    close TMP or return;
    unlink($tmpFile) or return;

}



sub init {
    my ($self) = @_;

    my $logger = $self->{'logger'};

# The agent can contact different servers. Each server accountconfig is
# stored in a specific file:
    if (
        ((!-d $config->{basevardir} && !mkpath ($config->{basevardir})) ||
            !$self->isDirectoryWritable($config->{basevardir}))

        &&
        $^O !~ /^MSWin/) {

        if (! -d $ENV{HOME}."/.ocsinventory/var") {
            $logger->info("Failed to create ".$config->{basevardir}." directory: $!. ".
                "I'm going to use the home directory instead (~/.ocsinventory/var).");
        }

        $config->{basevardir} = $ENV{HOME}."/.ocsinventory/var";
        if (!-d $config->{basevardir} && !mkpath ($config->{basevardir})) {
            $logger->error("Failed to create ".$config->{basedir}." directory: $!".
                "The HOSTID will not be written on the harddrive. You may have duplicated ".
                "entry of this computer in your OCS database");
        }
        $logger->debug("var files are stored in ".$config->{basevardir});
    }

    if ($self->{'type'} eq 'server') {
        my $dir = $self->{path};
        $dir =~ s/\//_/g;
        # On Windows, we can't have ':' in directory path
        $dir =~ s/:/../g if $^O =~ /^MSWin/; # Conditional because there is
        # already directory like that created by 2.x < agent
        $self->{vardir} = $config->{basevardir}."/".$dir;
    } else {
        $self->{vardir} = $config->{basevardir}."/__LOCAL__";
    }
    $logger->debug("vardir: ".$self->{vardir});

    if (!-d $self->{vardir} && mkpath ($self->{vardir})) {
        $logger->error("Failed to create ".$self->{vardir}." directory: $!");
    }

    if (!$self->isDirectoryWritable($self->{vardir})) {
        $logger->error("Can't write in ".$self->{vardir});
        exit(1);
    }

    if (-d $self->{vardir}) {
        $self->{accountconfig} = $self->{vardir}."/ocsinv.conf";
        $self->{accountinfofile} = $self->{vardir}."/ocsinv.adm";
        $self->{last_statefile} = $self->{vardir}."/last_state";
        $self->{next_timefile} = $self->{vardir}."/next_timefile";
    }


}


1;
