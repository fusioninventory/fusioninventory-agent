package FusionInventory::Agent::Target;

use strict;
use warnings;
use threads;
use threads::shared;

use Carp;
use English qw(-no_match_vars);
use File::Path qw(make_path);

# resetNextRunDate() can also be call from another thread (RPC)
my $lock :shared;

sub new {
    my ($class, $params) = @_;

    if ($params->{type} !~ /^(server|local|stdout)$/ ) {
        croak 'bad type';
    }

    my $self = {
        config          => $params->{config},
        logger          => $params->{logger},
        type            => $params->{type},
        path            => $params->{path} || '',
        deviceid        => $params->{deviceid},
        debugPrintTimer => 0
    };
    bless $self, $class;

    lock($lock);

    my $nextRunDate :shared;
    $self->{nextRunDate} = \$nextRunDate;

    $self->{config} = $params->{config};
    $self->{logger} = $params->{logger};
    $self->{type} = $params->{type};
    $self->{path} = $params->{path} || '';
    $self->{deviceid} = $params->{deviceid};


    my $config = $self->{config};
    my $logger = $self->{logger};
    my $type   = $self->{type};


    $self->{format} = ($type eq 'local' && $config->{html})?'HTML':'XML';

    $self->init();

    $self->{storage} = FusionInventory::Agent::Storage->new({
        target => $self
    });

    my $storage = $self->{storage};
    if ($self->{type} eq 'server') {
        $self->{accountinfo} = FusionInventory::Agent::AccountInfo->new({
            logger => $logger,
            config => $config,
            storage => $storage,
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

    return $self;
}

sub init {
    my ($self) = @_;

    my $config = $self->{config};
    my $logger = $self->{logger};

    lock($lock);

    # The agent can contact different servers. Each server has it's own
    # directory to store data

    my $dir;
    if ($self->{type} eq 'server') {
        $dir = $self->{path};
        $dir =~ s/\//_/g;
        # On Windows, we can't have ':' in directory path
        $dir =~ s/:/../g if $OSNAME eq 'MSWin32';
    } else {
        $dir = '__LOCAL__';

    }
    $self->{vardir} = $config->{basevardir} . '/' . $dir;

    if (!-d $self->{vardir}) {
        make_path($self->{vardir}, {error => \my $err});
        if (@$err) {
            $logger->error("Failed to create $self->{vardir}");
        }
    }

    if (! -w $self->{vardir}) {
        croak "Can't write in $self->{vardir}";
    }

    $logger->debug("storage directory: $self->{vardir}");

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

    my $max = $serverdelay ? $serverdelay * 3600 : $config->{delaytime};
    $max = 1 unless $max;

    my $time = time + ($max/2) + int rand($max/2);

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
        croak 'nextRunDate not set!';
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
}

1;
