package FusionInventory::Agent::Task::Inventory;

use strict;
use warnings;
use base 'FusionInventory::Agent::Task';

use English qw(-no_match_vars);
use File::Find;
use UNIVERSAL::require;

use FusionInventory::Agent::XML::Query::Inventory;

sub new {
    my ($class, $params) = @_;

    my $self = $class->SUPER::new($params);

    $self->{inventory} = FusionInventory::Agent::XML::Query::Inventory->new({
        target => $self->{target},
        logger => $self->{logger},
    });

    $self->{modules} = {};

     return $self;
}

sub run {
    my ($self) = @_;

    $self->_feedInventory();

    SWITCH: {
        if ($self->{target}->isa('FusionInventory::Agent::Target::Stdout')) {
            if ($self->{config}->{format} eq 'xml') {
                print $self->{inventory}->getContent();
            } else {
                print $self->{inventory}->getContentAsHTML();
            }
            last SWITCH;
        }

        if ($self->{target}->isa('FusionInventory::Agent::Target::Local')) {
            my $file =
                $self->{config}->{local} .
                "/" .
                $self->{target}->{deviceid} .
                '.ocs';

            if (open my $handle, '>', $file) {
                if ($self->{config}->{format} eq 'xml') {
                    print $handle $self->{inventory}->getContent();
                } else {
                    print $handle $self->{inventory}->getContentAsHTML();
                }
                close $handle;
                $self->{logger}->info("Inventory saved in $file");
            } else {
                warn "Can't open $file: $ERRNO"
            }
            last SWITCH;
        }

        if ($self->{target}->isa('FusionInventory::Agent::Target::Server')) {
            die "No prologresp!" unless $self->{prologresp};

            if ($self->{config}->{force}) {
                $self->{logger}->debug(
                    "Force enable, ignore prolog and run inventory."
                );
            } else {
                my $parsedContent = $self->{prologresp}->getParsedContent();
                if (
                    !$parsedContent ||
                    ! $parsedContent->{RESPONSE} ||
                    ! $parsedContent->{RESPONSE} eq 'SEND'
                ) {
                    $self->{logger}->debug(
                        "No inventory requested in the prolog, exiting"
                    );
                    return;
                }
            }

            my $accountinfo = $self->{target}->{accountinfo};

            # Put ACCOUNTINFO values in the inventory
            $accountinfo->setAccountInfo($self->{inventory});

            my $response = $self->{transmitter}->send(
                {message => $self->{inventory}}
            );

            return unless $response;
            $self->{inventory}->saveLastState();

            my $parsedContent = $response->getParsedContent();
            if (
                $parsedContent &&
                $parsedContent->{RESPONSE} &&
                $parsedContent->{RESPONSE} eq 'ACCOUNT_UPDATE'
            ) {
                $accountinfo->reSetAll($parsedContent->{ACCOUNTINFO});
            }

            last SWITCH;
        }
    }

}

sub _initModList {
    my $self = shift;

    my $logger = $self->{logger};
    my $config = $self->{config};
    my $storage = $self->{storage};

    my @modules;
    # This is a workaround for PAR::Packer. Since it resets @INC
    # I can't find the backend modules to load dynamically. So
    # I prepare a list and include it.
    FusionInventory::Agent::Task::Inventory::ModuleToLoad->require();
    if (!$EVAL_ERROR) {
        $logger->debug(
            "use FusionInventory::Agent::Task::Inventory::ModuleToLoad to " . 
            "get the modules to load. This should not append unless you use " .
            "the standalone agent built with PAR::Packer (pp)"
        );
        @modules = 
            @FusionInventory::Agent::Task::Inventory::ModuleToLoad::list;
    }

    # compute a list of directories to scan
    my @dirToScan;
    if ($config->{devlib}) {
        # devlib enable, I only search for backend module in ./lib
        push (@dirToScan, './lib');
    } else {
        foreach my $dir (@INC) {
            my $subdir = $dir . '/FusionInventory/Agent/Task/Inventory';
            next unless -d $subdir;
            push @dirToScan, $subdir;
        }
    }
    
    die "No directory to scan for inventory modules" if !@dirToScan;

    # find a list of modules from files in those directories
    my %modules;
    my $wanted = sub {
        return unless -f $_;
        return unless $File::Find::name =~
            m{(FusionInventory/Agent/Task/Inventory/\S+)\.pm$};
        my $module = $1;
        $module =~ s{/}{::}g;
        $modules{$module}++;
    };
    File::Find::find(
        {
            wanted      => $wanted,
            follow      => 1,
            follow_skip => 2
        },
        @dirToScan
    );

    @modules = keys %modules;
    die "No inventory module found" if !@modules;

    # First all the module are flagged as 'OK'
    foreach my $module (@modules) {
        $self->{modules}->{$module}->{inventoryFuncEnable} = 1;
    }

    foreach my $m (%modules) {
        my @runAfter;
        my @runMeIfTheseChecksFailed;
        my $enable = 1;

        if (!$self->{modules}->{$m}->{inventoryFuncEnable}) {
            next;
        }
        if (exists ($self->{modules}->{$m}->{name})) {
            $logger->debug("$m already loaded.");
            next;
        }

        my $package = $m."::";

        $m->require();
        if ($EVAL_ERROR) {
            $logger->debug ("Failed to load $m: $EVAL_ERROR");
            $enable = 0;
            next;
        }

        # required to use a string as a HASH reference
        no strict 'refs'; ## no critic

        if ($package->{isInventoryEnabled}) {
            $self->{modules}->{$m}->{isInventoryEnabledFunc} =
                $package->{isInventoryEnabled};
            $enable = $self->_runWithTimeout($m, "isInventoryEnabled");
        }
        if (!$enable) {
            $logger->debug ($m." ignored");
            foreach (keys %{$self->{modules}}) {
                $self->{modules}->{$_}->{inventoryFuncEnable} = 0
                    if /^$m($|::)/;
            }
        }

        $self->{modules}->{$m}->{name} = $m;
        $self->{modules}->{$m}->{done} = 0;
        $self->{modules}->{$m}->{inUse} = 0;
        $self->{modules}->{$m}->{inventoryFuncEnable} = $enable;

        if (!$enable) {
            $logger->debug ($m." ignored");
            foreach (keys %{$self->{modules}}) {
                $self->{modules}->{$_}->{inventoryFuncEnable} = 0
                    if /^$m($|::)/;
            }
            next;
        }

        # TODO add a isPostInventoryEnabled() function to know if we need to run
        # the postInventory() function.
        # Is that really needed?
        $self->{modules}->{$m}->{postInventoryFuncEnable} = 1;#$enable;

        $self->{modules}->{$m}->{runAfter} = $package->{runAfter};
        $self->{modules}->{$m}->{runMeIfTheseChecksFailed} =
            $package->{runMeIfTheseChecksFailed};
        $self->{modules}->{$m}->{doInventoryFunc} = $package->{doInventory};
        $self->{modules}->{$m}->{doPostInventoryFunc} =
            $package->{doPostInventory};
        $self->{modules}->{$m}->{mem} = {}; # Deprecated
        $self->{modules}->{$m}->{rpcCfg} = $package->{rpcCfg};
        # Load the Storable object is existing or return undef
        $self->{modules}->{$m}->{storage} = $storage;

    }

    # the sort is just for the presentation
    foreach my $m (sort keys %{$self->{modules}}) {
        next unless $self->{modules}->{$m}->{isInventoryEnabledFunc};
        # find modules to disable and their submodules

        next unless $self->{modules}->{$m}->{inventoryFuncEnable};

        my $enable = $self->_runWithTimeout($m, "isInventoryEnabled");

        if (!$enable) {
            $logger->debug ($m." ignored");
            foreach (keys %{$self->{modules}}) {
                $self->{modules}->{$_}->{inventoryFuncEnable} = 0
                    if /^$m($|::)/;
            }
        }

        # add submodule in the runAfter array
        my $t;
        foreach (split /::/,$m) {
            $t .= "::" if $t;
            $t .= $_;
            if (exists $self->{modules}->{$t} && $m ne $t) {
                push
                    @{$self->{modules}->{$m}->{runAfter}},
                    \%{$self->{modules}->{$t}}
            }
        }
    }

    # Remove the runMeIfTheseChecksFailed if needed
    foreach my $m (sort keys %{$self->{modules}}) {
        next unless $self->{modules}->{$m}->{inventoryFuncEnable};
        next unless $self->{modules}->{$m}->{runMeIfTheseChecksFailed};
        foreach my $condmod (@{${$self->{modules}->{$m}->{runMeIfTheseChecksFailed}}}) {
            if ($self->{modules}->{$condmod}->{inventoryFuncEnable}) {
                foreach (keys %{$self->{modules}}) {
                    next unless /^$m($|::)/ && $self->{modules}->{$_}->{inventoryFuncEnable};
                    $self->{modules}->{$_}->{inventoryFuncEnable} = 0;
                    $logger->debug(
                        "$_ disabled because of a 'runMeIfTheseChecksFailed' " .
                        "in '$m'"
                    );
                }
            }
        }
    }
}

sub _runMod {
    my ($self, $params) = @_;

    my $logger = $self->{logger};

    my $m = $params->{modname};

    return if (!$self->{modules}->{$m}->{inventoryFuncEnable});
    return if ($self->{modules}->{$m}->{done});

    $self->{modules}->{$m}->{inUse} = 1; # lock the module
    # first I run its "runAfter"

    foreach (@{$self->{modules}->{$m}->{runAfter}}) {
        if (!$_->{name}) {
            # The name is defined during module initialisation so if I
            # can't read it, I can suppose it had not been initialised.
            die
                "Module `$m' need to be runAfter a module not found.".
                "Please fix its runAfter entry or add the module.";
        }

        if ($_->{inUse}) {
            # In use 'lock' is taken during the mod execution. If a module
            # need a module also in use, we have provable an issue :).
            die "Circular dependency hell with $m and $_->{name}";
        }
        $self->_runMod({
            modname => $_->{name},
        });
    }

    $logger->debug ("Running $m");

    if ($self->{modules}->{$m}->{doInventoryFunc}) {
        $self->_runWithTimeout($m, "doInventory");
#  } else {
#      $logger->debug("$m has no doInventory() function -> ignored");
    }
    $self->{modules}->{$m}->{done} = 1;
    $self->{modules}->{$m}->{inUse} = 0; # unlock the module
}

sub _feedInventory {
    my ($self, $params) = @_;

    my $logger = $self->{logger};
    my $inventory = $self->{inventory};

    if (!keys %{$self->{modules}}) {
        $self->_initModList();
    }

    my $begin = time();
    foreach my $m (sort keys %{$self->{modules}}) {
        die ">$m Houston!!!" unless $m;
        $self->_runMod ({
            modname => $m,
        });
    }

    # Execution time
    $inventory->setHardware({ETIME => time() - $begin});

    $inventory->{isInitialised} = 1;

}

sub _runWithTimeout {
    my ($self, $m, $funcName, $timeout) = @_;

    my $logger = $self->{logger};
    my $storage = $self->{storage};

    my $ret;
    
    if (!$timeout) {
        $timeout = $self->{config}{'backend-collect-timeout'};
    }

    eval {
        local $SIG{ALRM} = sub { die "alarm\n" }; # NB: \n require
        alarm $timeout;

        my $func = $self->{modules}->{$m}->{$funcName."Func"};

        $ret = &{$func}({
            accountconfig => $self->{accountconfig},
            accountinfo => $self->{accountinfo},
            config => $self->{config},
            inventory => $self->{inventory},
            logger => $self->{logger},
            network => $self->{network},
            # Compatibiliy with agent 0.0.10 <=
            # We continue to pass params->{params}
            params => $self->{params},
            prologresp => $self->{prologresp},
            storage => $storage
        });
    };
    alarm 0;
    my $evalRet = $EVAL_ERROR;

    if ($evalRet) {
        if ($EVAL_ERROR ne "alarm\n") {
            $logger->debug("runWithTimeout(): unexpected error: $EVAL_ERROR");
        } else {
            $logger->debug("$m killed by a timeout.");
            return;
        }
    } else {
        return $ret;
    }
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Task::Inventory - The inventory task for FusionInventory 
=head1 DESCRIPTION

This task extract various hardware and software informations on the agent host.
