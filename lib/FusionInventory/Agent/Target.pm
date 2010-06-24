package FusionInventory::Agent::Target;

use strict;
use warnings;

use English qw(-no_match_vars);
use File::Path;
use Config;

BEGIN {
    # threads and threads::shared must be load before
    # $lock is initialized
    if ($Config{usethreads}) {
        eval {
            require threads;
            require threads::shared;
        };
        if ($EVAL_ERROR) {
            print "[error]Failed to use threads!\n"; 
        }
    }
}

# resetNextRunDate() can also be call from another thread (RPC)
my $lock : shared;

sub new {
    my ($class, $params) = @_;

    my $self = {};

    lock($lock);

    my $nextRunDate : shared;
    $self->{nextRunDate} = \$nextRunDate;

    $self->{config} = $params->{config};
    $self->{logger} = $params->{logger};
    $self->{type} = $params->{type};
    $self->{path} = $params->{path} || '';
    $self->{deviceid} = $params->{deviceid};


    my $config = $self->{config};
    my $logger = $self->{logger};
    my $target = $self->{target};
    my $type   = $self->{type};


    $self->{format} = ($type eq 'local' && $config->{html})?'HTML':'XML';

    bless $self, $class;
   
    $self->{debugPrintTimer} = 0;
    
    $self->init();

    if ($params->{type} !~ /^(server|local|stdout)$/ ) {
        $logger->fault('bad type'); 
    }

    if (!-d $self->{vardir}) {
        $logger->fault("Bad vardir setting!");
    }

    $self->{storage} = FusionInventory::Agent::Storage->new({
        target => $self
    });

    if ($self->{type} eq 'server') {

        $self->{accountinfo} = FusionInventory::Agent::AccountInfo->new({
            logger => $logger,
            config => $config,
            target => $self,
        });
    
        my $accountinfo = $self->{accountinfo};

        if ($config->{tag}) {
            if ($accountinfo->get("TAG")) {
                $logger->debug(
                    "A TAG seems to already exist in the server for this ".
                    "machine. The -t paramter may be ignored by the server " .
                    "unless it has OCS_OPT_ACCEPT_TAG_UPDATE_FROM_CLIENT=1."
                );
            }
            $accountinfo->set("TAG", $config->{tag});
        }

        my $storage = $self->{storage};
        $self->{myData} = $storage->restore();

        if ($self->{myData}{nextRunDate}) {
            $logger->debug (
                "[$self->{path}] Next server contact planned for ".
                localtime($self->{myData}{nextRunDate})
            );
            ${$self->{nextRunDate}} = $self->{myData}{nextRunDate};
        }
    }
    $self->{currentDeviceid} = $self->{myData}{currentDeviceid};

    return $self;
}

sub isDirectoryWritable {
    my ($self, $dir) = @_;

    return -w $dir;
}

# TODO refactoring needed here.
sub init {
    my ($self) = @_;

    my $config = $self->{config};
    my $logger = $self->{logger};

    lock($lock);
# The agent can contact different servers. Each server has it's own
# directory to store data
    if (
        ((!-d $config->{basevardir} && !mkpath ($config->{basevardir})) ||
            !$self->isDirectoryWritable($config->{basevardir}))
        && $OSNAME ne 'MSWin32'
    ) {

        if (! -d $ENV{HOME}."/.ocsinventory/var") {
            $logger->info(
                "Failed to create basevardir: $config->{basevardir} " .
                "directory: $ERRNO. I'm going to use the home directory " .
                "instead (~/.ocsinventory/var)."
            );
        }

        $config->{basevardir} = $ENV{HOME}."/.ocsinventory/var";
        if (!-d $config->{basevardir} && !mkpath ($config->{basevardir})) {
            $logger->error(
                "Failed to create basedir: $config->{basedir} directory: " .
                "$ERRNO. The HOSTID will not be written on the harddrive. " .
                "You may have duplicated entry of this computer in your OCS " .
                "database"
            );
        }
        $logger->debug("var files are stored in ".$config->{basevardir});
    }

    if ($self->{type} eq 'server') {
        my $dir = $self->{path};
        $dir =~ s/\//_/g;
        # On Windows, we can't have ':' in directory path
        $dir =~ s/:/../g if $OSNAME eq 'MSWin32';
        $self->{vardir} = $config->{basevardir} . "/" . $dir;
    } else {
        $self->{vardir} = $config->{basevardir} . "/__LOCAL__";
    }
    $logger->debug("vardir: $self->{vardir}");

    if (!-d $self->{vardir} && !mkpath ($self->{vardir})) {
        $logger->error(
            "Failed to create vardir: $self->{vardir} directory: $ERRNO"
        );
    }

    if (!$self->isDirectoryWritable($self->{vardir})) {
        $logger->fault("Can't write in $self->{vardir}");
    }

    $self->{accountinfofile} = $self->{vardir} . "/ocsinv.adm";
    $self->{last_statefile} = $self->{vardir} . "/last_state";
}

sub setNextRunDate {

    my ($self, $args) = @_;

    my $config = $self->{config};
    my $logger = $self->{logger};
    my $storage = $self->{storage};

    lock($lock);

    my $serverdelay = $self->{myData}{prologFreq};

    lock($lock);

    my $time;
    if( $self->{prologFreqChanged} ){
        $logger->debug("Compute next_time file with random value");
        $time = time + int rand(
            $serverdelay ? $serverdelay * 3600 : $config->{delaytime}
        );
    } else {
        $time = time + int rand(
            $serverdelay ? $serverdelay * 3600 : $config->{delaytime}
        );
    }
    $self->{myData}{nextRunDate} = $time;
    
    ${$self->{nextRunDate}} = $self->{myData}{nextRunDate};

    $logger->debug (
        "[$self->{path}] Next server contact'd just been planned for ".
        localtime($self->{myData}{nextRunDate})
    );

    $storage->save({ data => $self->{myData} });
}

sub getNextRunDate {
    my ($self) = @_;

    my $config = $self->{config};
    my $logger = $self->{logger};

    lock($lock);

    if (${$self->{nextRunDate}}) {
      
        if ($self->{debugPrintTimer} < time) {
            $self->{debugPrintTimer} = time + 600;
        }; 

        return ${$self->{nextRunDate}};
    }

    $self->setNextRunDate();

    if (!${$self->{nextRunDate}}) {
        $logger->fault('nextRunDate not set!');
    }

    return $self->{myData}{nextRunDate} ;

}

sub resetNextRunDate {
    my ($self) = @_;

    my $logger = $self->{logger};
    my $storage = $self->{storage};

    lock($lock);
    $logger->debug("Force run now");
    
    $self->{myData}{nextRunDate} = 1;
    $storage->save({ data => $self->{myData} });
    
    ${$self->{nextRunDate}} = $self->{myData}{nextRunDate};
}

sub setPrologFreq {

    my ($self, $prologFreq) = @_;

    my $config = $self->{config};
    my $logger = $self->{logger};
    my $storage = $self->{storage};

    return unless $prologFreq;

    if ($self->{myData}{prologFreq} && ($self->{myData}{prologFreq}
            eq $prologFreq)) {
        return;
    }
    if (defined($self->{myData}{prologFreq})) {
        $logger->info(
            "PROLOG_FREQ has changed since last process ". 
            "(old=$self->{myData}{prologFreq},new=$prologFreq)"
        );
    } else {
        $logger->info("PROLOG_FREQ has been set: $prologFreq");
    }

    $self->{myData}{prologFreq} = $prologFreq;
    $storage->save({ data => $self->{myData} });

}

sub setCurrentDeviceID {

    my ($self, $deviceid) = @_;

    my $config = $self->{config};
    my $logger = $self->{logger};
    my $storage = $self->{storage};

    return unless $deviceid;

    if ($self->{myData}{currentDeviceid} &&
        ($self->{myData}{currentDeviceid} eq $deviceid)) {
        return;
    }

    if (!$self->{myData}{currentDeviceid}) {
        $logger->debug("DEVICEID initialized at $deviceid");
    } else {
        $logger->info(
            "DEVICEID has changed since last process ". 
            "(old=$self->{myData}{currentDeviceid},new=$deviceid"
        );
    }

    $self->{myData}{currentDeviceid} = $deviceid;
    $storage->save({ data => $self->{myData} });

    $self->{currentDeviceid} = $deviceid;

}

1;
