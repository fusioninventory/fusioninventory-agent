package Ocsinventory::Agent::Target;

use Ocsinventory::Agent::AccountConfig;
use File::Path;
use Sys::Hostname;

use strict;
use warnings;

sub new {
    my (undef, $params) = @_;

    my $self = {};

    $self->{'config'} = $params->{'config'};
    $self->{'logger'} = $params->{'logger'};
    $self->{'type'} = $params->{'type'};
    $self->{'path'} = $params->{'path'};

    my $logger = $self->{'logger'};
    my $config = $self->{'config'};


    bless $self;

    $self->init();

    if ($params->{'type'} !~ /^(server|local|stdout)$/ ) {
        $logger->fault('bad type'); 
    }

    if (!-d $self->{'vardir'}) {
        $logger->fault("Bad vardir setting!");
    }


    $self->{accountconfig} = new Ocsinventory::Agent::AccountConfig({

            logger => $logger,
            config => $config,

        });

    my $accountconfig = $self->{accountconfig};

    my $hostname = hostname; # Sys::Hostname
    if ((!$config->{deviceid}) || $config->{deviceid} !~ /\Q$hostname\E-(?:\d{4})(?:-\d{2}){5}/) {
        my ($YEAR, $MONTH , $DAY, $HOUR, $MIN, $SEC) = (localtime
            (time))[5,4,3,2,1,0];
        $config->{old_deviceid} = $config->{deviceid};
        $config->{deviceid} =sprintf "%s-%02d-%02d-%02d-%02d-%02d-%02d",
        $hostname, ($YEAR+1900), ($MONTH+1), $DAY, $HOUR, $MIN, $SEC;
        $accountconfig->set('DEVICEID',$config->{deviceid});
        $accountconfig->write();
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



# TODO refactoring needed here.
sub init {
    my ($self) = @_;

    my $config = $self->{'config'};
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


sub getNextRunDate {
    my ($self) = @_;

    my $accountconfig = $self->{accountconfig};
    my $config = $self->{config};
    my $logger = $self->{logger};

    return $self->{'nextRunDate'} if $self->{'nextRunDate'};

    # No nextRunDate, Need to compute nextRunDate

    my $prologFreq = $accountconfig->get('PROLOG_FREQ');
    if ($prologFreq) {
        my $serverdelay = $prologFreq*3600;
        $self->{'nextRunDate'} = time + int rand($serverdelay);
    } else {
        $self->{'nextRunDate'} = time + int rand($config->{delaytime});
    }
    $logger->info("nextRunDate: ".$self->{'nextRunDate'});

    return $self->{'nextRunDate'};


}



1;
