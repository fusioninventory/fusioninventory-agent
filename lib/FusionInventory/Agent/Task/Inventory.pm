package FusionInventory::Agent::Task::Inventory;

=head1 NAME

FusionInventory::Agent::Task::Inventory - The Inventory module for FusionInventory 

=head1 DESCRIPTION

This module load and run the submodules needed to get the informations
regarding the Hardware and Software installation.

=cut

use strict;
use warnings;
use base 'FusionInventory::Agent::Task::Base';

use English qw(-no_match_vars);
use UNIVERSAL::require;

use FusionInventory::Agent::AccountInfo;
use FusionInventory::Agent::Config;
use FusionInventory::Agent::Network;
use FusionInventory::Agent::Storage;
use FusionInventory::Agent::XML::Response::Prolog;
use FusionInventory::Agent::XML::Query::Inventory;
use FusionInventory::Logger;

sub main {
    my $self = FusionInventory::Agent::Task::Inventory->new();

    if ($self->{target}->{type} eq 'server' &&
        (
            !exists($self->{prologresp}->{parsedcontent}->{RESPONSE}) ||
            $self->{prologresp}->{parsedcontent}->{RESPONSE} !~ /^SEND$/
        )
    ) {
        $self->{logger}->debug(
            '<RESPONSE>SEND</RESPONSE> no found in PROLOG, do not send an ' .
            'inventory.'
        );
        exit(0);
    }

    $self->{modules} = {};

    if (!$self->{target}) {
        $self->{logger}->fault("target is undef");
    }

    my $inventory = FusionInventory::Agent::XML::Query::Inventory->new({
        # TODO, check if the accoun{info,config} are needed in localmode
#          accountinfo => $accountinfo,
#          accountconfig => $accountinfo,
        target => $self->{target},
        config => $self->{config},
        logger => $self->{logger},
    });
    $self->{inventory} = $inventory;

    if (!$self->{config}->{stdout} && !$self->{config}->{local}) {
        $self->{logger}->fault("No prologresp!") unless $self->{prologresp};

        if ($self->{config}->{force}) {
            $self->{logger}->debug(
                "Force enable, ignore prolog and run inventory."
            );
        } elsif (!$self->{prologresp}->isInventoryAsked()) {
            $self->{logger}->debug("No inventory requested in the prolog...");
            exit(0);
        }
    }

    $self->feedInventory();


    if ($self->{target}->{type} eq 'stdout') {
        $self->{inventory}->printXML();
    } elsif ($self->{target}->{type} eq 'local') {
        if ($self->{target}->{format} eq 'XML') {
            $self->{inventory}->writeXML();
        } else {
            $self->{inventory}->writeHTML();
        }
    } elsif ($self->{target}->{type} eq 'server') {

        my $accountinfo = $self->{target}->{accountinfo};

        # Put ACCOUNTINFO values in the inventory
        $accountinfo->setAccountInfo($self->{inventory});

        my $network = FusionInventory::Agent::Network->new({
            logger => $self->{logger},
            config => $self->{config},
            target => $self->{target},
        });

        my $response = $network->send({message => $inventory});

        return unless $response;
        $inventory->saveLastState();

        my $parsedContent = $response->getParsedContent();
        if ($parsedContent
            &&
            exists ($parsedContent->{RESPONSE})
            &&
            $parsedContent->{RESPONSE} =~ /^ACCOUNT_UPDATE$/
        ) {
            $accountinfo->reSetAll($parsedContent->{ACCOUNTINFO});
        }

    }

    exit(0);
}

sub initModList {
    my $self = shift;

    my $logger = $self->{logger};
    my $config = $self->{config};
    my $storage = $self->{storage};

    my @dirToScan;
    my @installed_mods;
    my @installed_files;


    # Hackish. The function we want to export
    # in the module
    my $backendSharedFuncs = {

        # TODO replace that by the standard can_run()
        can_run => sub {
            my $binary = shift;

            my $ret;
            if ($OSNAME eq 'MSWin32') {
                MAIN: foreach (split/$Config::Config{path_sep}/, $ENV{PATH}) {
                    foreach my $ext (qw/.exe .bat/) {
                        if (-f $_.'/'.$binary.$ext) {
                            $ret = 1;
                            last MAIN;
                        }
                    }
                }
            } else {
                chomp(my $binpath=`which $binary 2>/dev/null`);
                $ret = -x $binpath;
            }

            return $ret;
        },
        can_load => sub {
            my $module = shift;
            return $module->require();
        },
        can_read => sub {
            my $file = shift;
            return unless -r $file;
            1;
        },
        runcmd => sub {
            my $cmd = shift;
            return unless $cmd;

            # $self->{logger}->debug(" - run $cmd");

            return `$cmd`;
        }
    };

    # This is a workaround for PAR::Packer. Since it resets @INC
    # I can't find the backend modules to load dynamically. So
    # I prepare a list and include it.
    eval {
        require FusionInventory::Agent::Task::Inventory::ModuleToLoad;
    };
    if (!$EVAL_ERROR) {
        $logger->debug(
            "use FusionInventory::Agent::Task::Inventory::ModuleToLoad to " . 
            "get the modules to load. This should not append unless you use " .
            "the standalone agent built with PAR::Packer (pp)"
        );
        push
            @installed_mods,
            @FusionInventory::Agent::Task::Inventory::ModuleToLoad::list;
    }

    if ($config->{devlib}) {
        # devlib enable, I only search for backend module in ./lib
        push (@dirToScan, './lib');
    } else {
        foreach (@INC) {
            next if ! -d || (-l && -d readlink) || /^(\.|lib)$/;
            next if ! -d $_.'/FusionInventory/Agent/Task/Inventory';
            push @dirToScan, $_;
        }
    }
    if (@dirToScan) {
        eval {
            require File::Find;
        };
        if ($EVAL_ERROR) {
            $logger->debug("Failed to load File::Find");
        } else {
            # here I need to use $d to avoid a bug with AIX 5.2's perl 5.8.0. It
            # changes the @INC content if i use $_ directly
            # thanks to @rgs on irc.perl.org
            File::Find::find(
                {
                    wanted => sub {
                        push @installed_files, $File::Find::name if $File::Find::name =~
                        /FusionInventory\/Agent\/Task\/Inventory\/.*\.pm$/;
                    },
                    follow => 1,
                    follow_skip => 2
                }
                , @dirToScan);
        }
    }

    foreach my $file (@installed_files) {
        my $t = $file;
        next unless $t =~ s!.*?(FusionInventory/Agent/Task/Inventory/)(.*?)\.pm$!$1$2!;
        my $m = join ('::', split /\//, $t);
        push @installed_mods, $m unless grep (/^$m$/, @installed_mods);
    }

    if (!@installed_mods) {
        $logger->info(
            "ZERO backend module found! Is FusionInventory-Agent correctly " .
            "installed? Use the --devlib flag if you want to run the agent " .
            "directly from the source directory."
        )
    }

    # First all the module are flagged as 'OK'
    foreach my $m (@installed_mods) {
        $self->{modules}->{$m}->{inventoryFuncEnable} = 1;
    }

    foreach my $m (@installed_mods) {
        my @runAfter;
        my @runMeIfTheseChecksFailed;
        my $enable = 1;

        if (!$self->{modules}->{$m}->{inventoryFuncEnable}) {
            next;
        }
        if (exists ($self->{modules}->{$m}->{name})) {
            $logger->debug($m." already loaded.");
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

        # Load in the module the backendSharedFuncs
        foreach my $func (keys %{$backendSharedFuncs}) {
            $package->{$func} = $backendSharedFuncs->{$func};
        }

        if ($package->{isInventoryEnabled}) {
            $self->{modules}->{$m}->{isInventoryEnabledFunc} =
                $package->{isInventoryEnabled};
            $enable = $self->runWithTimeout($m, "isInventoryEnabled");
        }
        if (!$enable) {
            $logger->debug ($m." ignored");
            foreach (keys %{$self->{modules}}) {
                $self->{modules}->{$_}->{inventoryFuncEnable} = 0
                    if /^$m($|::)/;
            }
        }

        if ($package->{check}) {
            $logger->error(
                "$m: check() function is deprecated, please rename it to ".
                "isInventoryEnabled()"
            );
        }
        if ($package->{run}) {
            $logger->error(
                "$m: run() function is deprecated, please rename it to ".
                "doInventory()"
            );
        }
        if ($package->{longRun}) {
            $logger->error(
                "$m: longRun() function is deprecated, please rename it to ".
                "postInventory()"
            );
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

        my $enable = $self->runWithTimeout($m, "isInventoryEnabled");

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

sub runMod {
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
            $logger->fault(
                "Module `$m' need to be runAfter a module not found.".
                "Please fix its runAfter entry or add the module."
            );
        }

        if ($_->{inUse}) {
            # In use 'lock' is taken during the mod execution. If a module
            # need a module also in use, we have provable an issue :).
            $logger->fault("Circular dependency hell with $m and $_->{name}");
        }
        $self->runMod({
            modname => $_->{name},
        });
    }

    $logger->debug ("Running $m");

    if ($self->{modules}->{$m}->{doInventoryFunc}) {
        $self->runWithTimeout($m, "doInventory");
#  } else {
#      $logger->debug("$m has no doInventory() function -> ignored");
    }
    $self->{modules}->{$m}->{done} = 1;
    $self->{modules}->{$m}->{inUse} = 0; # unlock the module
}

sub feedInventory {
    my ($self, $params) = @_;

    my $logger = $self->{logger};

    if (!$self->{inventory}) {
        $logger->fault('Missing inventory parameter.');
    }

    my $inventory = $self->{inventory};

    if (!keys %{$self->{modules}}) {
        $self->initModList();
    }

    my $begin = time();
    foreach my $m (sort keys %{$self->{modules}}) {
        $logger->fault(">$m Houston!!!") unless $m;
        $self->runMod ({
            modname => $m,
        });
    }

    # Execution time
    $inventory->setHardware({ETIME => time() - $begin});

    $inventory->{isInitialised} = 1;

}

#=item runWithTimeout()
#
#Run a function with a timeout.
#
#=cut
sub runWithTimeout {
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
