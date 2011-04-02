package FusionInventory::Agent::Task::Inventory;

use strict;
use warnings;
use base 'FusionInventory::Agent::Task';

use Config;
use English qw(-no_match_vars);
use UNIVERSAL::require;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Transmitter;
use FusionInventory::Agent::XML::Query::Inventory;

our $VERSION = '1.0';

sub main {
    my ($self) = @_;

    if ($self->{target}->isa('FusionInventory::Agent::Target::Server')) {
        die "No server response" unless $self->{prologresp};

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
                $self->{logger}->debug("No inventory requested in the prolog");
                return;
            }
        }
    }

    $self->{modules} = {};

    my $inventory = FusionInventory::Agent::XML::Query::Inventory->new({
        # TODO, check if the accoun{info,config} are needed in localmode
#          accountinfo => $accountinfo,
#          accountconfig => $accountinfo,
        deviceid        => $self->{target}->{deviceid},
        currentDeviceid => $self->{target}->{currentDeviceid},
        last_statefile  => $self->{target}->{last_statefile},
        logger          => $self->{logger},
    });
    $self->{inventory} = $inventory;

    # Turn off localised output for commands
    $ENV{LC_ALL} = 'C'; # Turn off localised output for commands
    $ENV{LANG} = 'C'; # Turn off localised output for commands

    if (not $self->{config}->{'scan-homedirs'}) {
        $self->{logger}->debug(
            "--scan-homedirs missing. Don't scan user directories"
        );
    }

    $self->feedInventory();

    if ($self->{target}->isa('FusionInventory::Agent::Target::Stdout')) {
        print $inventory->getContent();
    } elsif ($self->{target}->isa('FusionInventory::Agent::Target::Local')) {
        my $format = $self->{target}->{format};

        my $extension = $format eq 'XML' ? '.ocs' : '.html';
        my $file =
            $self->{config}->{local} .
            "/" .
            $self->{target}->{deviceid} .
            $extension;

        if (open my $handle, '>', $file) {
            print $handle $format eq 'XML' ?
                $inventory->getContent() : $inventory->getContentAsHTML();
            close $handle;
            $self->{logger}->info("Inventory saved in $file");
        } else {
            warn "Can't open $file: $ERRNO"
        }
    } elsif ($self->{target}->isa('FusionInventory::Agent::Target::Server')) {

        # Add target ACCOUNTINFO values to the inventory
        $self->{inventory}->setAccountInfo(
            $self->{target}->getAccountInfo()
        );

        my $transmitter = FusionInventory::Agent::Transmitter->new({
            logger       => $self->{logger},
            user         => $self->{config}->{user},
            password     => $self->{config}->{password},
            proxy        => $self->{config}->{proxy},
            ca_cert_file => $self->{config}->{'ca-cert-file'},
            ca_cert_dir  => $self->{config}->{'ca-cert-dir'},
            no_ssl_check => $self->{config}->{'no-ssl-check'},
        });

        my $response = $transmitter->send({
            url     => $self->{target}->getUrl(),
            message => $inventory
        });

        return unless $response;
        $inventory->saveLastState();

        my $parsedContent = $response->getParsedContent();
        if ($parsedContent
            &&
            exists ($parsedContent->{RESPONSE})
            &&
            $parsedContent->{RESPONSE} =~ /^ACCOUNT_UPDATE$/
        ) {
            my $new = $parsedContent->{ACCOUNTINFO};
            my $current = $self->{target}->getAccountInfo();
            if (ref $new eq 'ARRAY') {
                # this a list of key value pairs
                foreach my $pair (@{$new}) {
                    $current->{$pair->{KEYNAME}} = $pair->{KEYVALUE};
                }
            } elsif (ref $new eq 'HASH') {
                # this a single key value pair
                $current->{$new->{KEYNAME}} = $new->{KEYVALUE};
            } else {
                $self->{logger}->debug("invalid ACCOUNTINFO value");
            }
        }

    }

}

sub initModList {
    my $self = shift;

    my $logger = $self->{logger};
    my $config = $self->{config};
    my $storage = $self->{storage};

    my @modules = __PACKAGE__->getModules();
    die "no inventory module found" if !@modules;

    # First all the module are flagged as 'OK'
    foreach my $m (@modules) {
        $self->{modules}->{$m}->{inventoryFuncEnable} = 1;
    }

    foreach my $m (@modules) {
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
            die
                "Module `$m' need to be runAfter a module not found.".
                "Please fix its runAfter entry or add the module.";
        }

        if ($_->{inUse}) {
            # In use 'lock' is taken during the mod execution. If a module
            # need a module also in use, we have provable an issue :).
            die "Circular dependency hell with $m and $_->{name}";
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
        die 'Missing inventory parameter.';
    }

    my $inventory = $self->{inventory};

    if (!keys %{$self->{modules}}) {
        $self->initModList();
    }

    my $begin = time();
    foreach my $m (sort keys %{$self->{modules}}) {
        die ">$m Houston!!!" unless $m;
        $self->runMod ({
            modname => $m,
        });
    }

    # Execution time
    $inventory->setHardware({ETIME => time() - $begin});

    $inventory->processChecksum();

    $inventory->checkContent();
}

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
            confdir => $self->{confdir},
            datadir => $self->{datadir},
            inventory => $self->{inventory},
            logger => $self->{logger},
            transmitter => $self->{transmitter},
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

FusionInventory::Agent::Task::Inventory - Inventory task for FusionInventory 

=head1 DESCRIPTION

This task extract various hardware and software informations on the agent host.
