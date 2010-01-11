package Ocsinventory::Agent::Target;

use Ocsinventory::Agent::AccountConfig;
use File::Path;
use Sys::Hostname;

use strict;
use warnings;

sub new {
    my (undef, $params) = @_;

    my $self = {};

    my $lock : shared;
    $self->{'lock'} = \$lock;
    lock($self->{'lock'});

    my $nextRunDate : shared;
    $self->{'nextRunDate'} = \$nextRunDate;

    $self->{'config'} = $params->{'config'};
    $self->{'logger'} = $params->{'logger'};
    $self->{'type'} = $params->{'type'};
    $self->{'path'} = $params->{'path'};

    my $config = $self->{'config'};
    my $logger = $self->{'logger'};
    my $target = $self->{'target'};


    bless $self;
   
    $self->{debugPrintTimer} = 0;
    
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




    $self->{storage} = new Ocsinventory::Agent::Storage({
            target => $self
        });


    if ($self->{'type'} eq 'server') {

        $self->{accountinfo} = new Ocsinventory::Agent::AccountInfo({

                logger => $logger,
                config => $config,
                target => $self,

            });
    
        my $accountinfo = $self->{accountinfo};

        if ($config->{tag}) {
            if ($accountinfo->get("TAG")) {
                $logger->debug("A TAG seems to already exist in the server for this ".
                    "machine. The -t paramter may be ignored by the server unless it ".
                    "has OCS_OPT_ACCEPT_TAG_UPDATE_FROM_CLIENT=1.");
            }
            $accountinfo->set("TAG",$config->{tag});
        }

        my $storage = $self->{storage};
        $self->{myData} = $storage->restore();

        ${$self->{'nextRunDate'}} = $self->{myData}{'nextRunDate'};
    }


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

    lock($self->{'lock'});
# The agent can contact different servers. Each server accountconfig is
# stored in a specific file:
    if (
        ((!-d $config->{basevardir} && !mkpath ($config->{basevardir})) ||
            !$self->isDirectoryWritable($config->{basevardir}))

        &&
        $^O !~ /^MSWin/) {

        if (! -d $ENV{HOME}."/.ocsinventory/var") {
            $logger->info("Failed to create basevardir: ".$config->{basevardir}." directory: $!. ".
                "I'm going to use the home directory instead (~/.ocsinventory/var).");
        }

        $config->{basevardir} = $ENV{HOME}."/.ocsinventory/var";
        if (!-d $config->{basevardir} && !mkpath ($config->{basevardir})) {
            $logger->error("Failed to create basedir: ".$config->{basedir}." directory: $!".
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

    if (!-d $self->{vardir} && !mkpath ($self->{vardir})) {
        $logger->error("Failed to create vardir: ".$self->{vardir}." directory: $!");
    }

    if (!$self->isDirectoryWritable($self->{vardir})) {
        $logger->error("Can't write in ".$self->{vardir});
        exit(1);
    }

    if (-d $self->{vardir}) {
        $self->{accountconfig} = $self->{vardir}."/ocsinv.conf";
        $self->{accountinfofile} = $self->{vardir}."/ocsinv.adm";
        $self->{last_statefile} = $self->{vardir}."/last_state";
    }


}


sub setNextRunDate {

    my ($self, $args) = @_;

    my $accountconfig = $self->{accountconfig};
    my $config = $self->{config};
    my $logger = $self->{logger};
    my $storage = $self->{storage};

    my $serverdelay = $accountconfig->get('PROLOG_FREQ');

    lock($self->{'lock'});

    my $time;
    if( $self->{prologFreqChanged} ){
        $logger->debug("Compute next_time file with random value");
        $time  = time + int rand(($serverdelay?$serverdelay*3600:$config->{delaytime}));
    }
    else{
        $time = time + ($serverdelay?$serverdelay*3600:$config->{delaytime});
    }

    $self->{'myData'}{'nextRunDate'} = $time;
    
    ${$self->{'nextRunDate'}} = $self->{myData}{'nextRunDate'};

    $logger->debug (
        "[".$self->{'path'}."]".
        " Next server contact'd just been planned for ".
        localtime($self->{'myData'}{'nextRunDate'})
    );


    $storage->save($self->{'myData'});

}

sub getNextRunDate {
    my ($self) = @_;

    my $accountconfig = $self->{accountconfig};
    my $config = $self->{config};
    my $logger = $self->{logger};

    lock($self->{'lock'});

    # Only for server mode
    return 1 if $self->{'type'} ne 'server';


    if (${$self->{'nextRunDate'}}) {
      
        if ($self->{debugPrintTimer} < time) {
            $logger->debug (
                "[".$self->{'path'}."]".
                " Next server contact planned for ".
                localtime($self->{'myData'}{'nextRunDate'})
            );
            $self->{debugPrintTimer} = time + 600;
        }; 

        return ${$self->{'nextRunDate'}};
    }

    $self->setNextRunDate();

    if (!${$self->{'nextRunDate'}}) {
        $logger->fault('nextRunDate not set!');
    }

    return $self->{'myData'}{'nextRunDate'} ;

}

sub resetNextRunDate {
    my ($self) = @_;

    my $logger = $self->{logger};
    my $storage = $self->{storage};

    lock($self->{'lock'});
    $logger->debug("Force run now");
    
    $self->{'myData'}{'nextRunDate'} = 1;
    $storage->save($self->{'myData'});
    
    ${$self->{'nextRunDate'}} = $self->{myData}{'nextRunDate'};
}

1;
