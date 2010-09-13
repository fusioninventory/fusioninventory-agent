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

    foreach my $module (sort @modules) {
        # compute parent module:
        my @components = split('::', $module);
        my $parent = @components > 5 ?
            join('::', @components[0 .. $#components -1]) : '';

        # skip if parent is not allowed
        if ($parent && !$self->{modules}->{$parent}->{enabled}) {
            $logger->debug("module $module disabled: implicit dependency $parent not enabled");
            $self->{modules}->{$module}->{enabled} = 0;
            next;
        }

        $module->require();
        if ($EVAL_ERROR) {
            $logger->debug("module $module disabled: failure to load ($EVAL_ERROR)");
            $self->{modules}->{$module}->{enabled} = 0;
            next;
        }

        my $enabled = $self->_runWithTimeout($module, "isInventoryEnabled");
        if (!$enabled) {
            $logger->debug("module $module disabled");
            $self->{modules}->{$module}->{enabled} = 0;
            next;
        }

        $self->{modules}->{$module}->{enabled} = 1;
        $self->{modules}->{$module}->{name}    = $module;
        $self->{modules}->{$module}->{done}    = 0;
        $self->{modules}->{$module}->{inUse}   = 0;

        # required to use a string as a HASH reference
        no strict 'refs'; ## no critic

        my $package = $module."::";

        $self->{modules}->{$module}->{runAfter} =
            $package->{runAfter};
        $self->{modules}->{$module}->{runMeIfTheseChecksFailed} =
            $package->{runMeIfTheseChecksFailed};
    }

    # the sort is just for the presentation
    foreach my $module (sort keys %{$self->{modules}}) {
        next unless $self->{modules}->{$module}->{enabled};
        # add submodule in the runAfter array
        my $t;
        foreach (split /::/,$module) {
            $t .= "::" if $t;
            $t .= $_;
            if (exists $self->{modules}->{$t} && $module ne $t) {
                push
                    @{$self->{modules}->{$module}->{runAfter}},
                    \%{$self->{modules}->{$t}}
            }
        }
    }

    # Remove the runMeIfTheseChecksFailed if needed
    foreach my $module (sort keys %{$self->{modules}}) {
        next unless $self->{modules}->{$module}->{enabled};
        next unless $self->{modules}->{$module}->{runMeIfTheseChecksFailed};
        foreach my $condmod (@{${$self->{modules}->{$module}->{runMeIfTheseChecksFailed}}}) {
            if ($self->{modules}->{$condmod}->{enabled}) {
                foreach (keys %{$self->{modules}}) {
                    next unless /^$module($|::)/ && $self->{modules}->{$_}->{inventoryFuncEnable};
                    $self->{modules}->{$_}->{enabled} = 0;
                    $logger->debug(
                        "$_ disabled because of a 'runMeIfTheseChecksFailed' " .
                        "in '$module'"
                    );
                }
            }
        }
    }
}

sub _runMod {
    my ($self, $params) = @_;

    my $logger = $self->{logger};

    my $module = $params->{modname};

    return if (!$self->{modules}->{$module}->{enabled});
    return if ($self->{modules}->{$module}->{done});

    $self->{modules}->{$module}->{inUse} = 1; # lock the module
    # first I run its "runAfter"

    foreach (@{$self->{modules}->{$module}->{runAfter}}) {
        if (!$_->{name}) {
            # The name is defined during module initialisation so if I
            # can't read it, I can suppose it had not been initialised.
            die
                "Module `$module' need to be runAfter a module not found.".
                "Please fix its runAfter entry or add the module.";
        }

        if ($_->{inUse}) {
            # In use 'lock' is taken during the mod execution. If a module
            # need a module also in use, we have provable an issue :).
            die "Circular dependency hell with $module and $_->{name}";
        }
        $self->_runMod({
            modname => $_->{name},
        });
    }

    $logger->debug ("Running $module");

    $self->_runWithTimeout($module, "doInventory");
    $self->{modules}->{$module}->{done} = 1;
    $self->{modules}->{$module}->{inUse} = 0; # unlock the module
}

sub _feedInventory {
    my ($self, $params) = @_;

    my $logger = $self->{logger};
    my $inventory = $self->{inventory};

    if (!keys %{$self->{modules}}) {
        $self->_initModList();
    }

    my $begin = time();
    foreach my $module (sort keys %{$self->{modules}}) {
        die ">$module Houston!!!" unless $module;
        $self->_runMod ({
            modname => $module,
        });
    }

    # Execution time
    $inventory->setHardware({ETIME => time() - $begin});

    $inventory->{isInitialised} = 1;

}

sub _runWithTimeout {
    my ($self, $module, $function, $timeout) = @_;

    my $logger = $self->{logger};
    my $storage = $self->{storage};

    my $ret;
    
    if (!$timeout) {
        $timeout = $self->{config}{'backend-collect-timeout'};
    }

    eval {
        local $SIG{ALRM} = sub { die "alarm\n" }; # NB: \n require
        alarm $timeout;

        no strict 'refs';

        $ret = &{$module . '::' . $function}({
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
            $logger->debug("$module killed by a timeout.");
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
