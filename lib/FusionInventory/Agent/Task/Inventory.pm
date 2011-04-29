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

sub run {
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

    $self->_initModulesList();
    $self->_feedInventory();

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

        my $transmitter = FusionInventory::Agent::Transmitter->new(
            logger       => $self->{logger},
            user         => $self->{config}->{user},
            password     => $self->{config}->{password},
            proxy        => $self->{config}->{proxy},
            ca_cert_file => $self->{config}->{'ca-cert-file'},
            ca_cert_dir  => $self->{config}->{'ca-cert-dir'},
            no_ssl_check => $self->{config}->{'no-ssl-check'},
        );

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

sub _initModulesList {
    my $self = shift;

    my $logger = $self->{logger};
    my $config = $self->{config};
    my $storage = $self->{storage};

    my @modules = __PACKAGE__->getModules();
    die "no inventory module found" if !@modules;

    # first pass: compute all relevant modules
    foreach my $module (sort @modules) {
        # compute parent module:
        my @components = split('::', $module);
        my $parent = @components > 5 ?
            join('::', @components[0 .. $#components -1]) : '';

        # skip if parent is not allowed
        if ($parent && !$self->{modules}->{$parent}->{enabled}) {
            $logger->debug("  $module disabled: implicit dependency $parent not enabled");
            $self->{modules}->{$module}->{enabled} = 0;
            next;
        }

        $module->require();
        if ($EVAL_ERROR) {
            $logger->debug("module $module disabled: failure to load ($EVAL_ERROR)");
            $self->{modules}->{$module}->{enabled} = 0;
            next;
        }

        my $enabled = $self->_runFunction({
            module   => $module,
            function => "isInventoryEnabled",
            timeout  => $config->{'backend-collect-timeout'}
        });
        if (!$enabled) {
            $logger->debug("module $module disabled");
            $self->{modules}->{$module}->{enabled} = 0;
            next;
        }

        $self->{modules}->{$module}->{enabled} = 1;
        $self->{modules}->{$module}->{done}    = 0;
        $self->{modules}->{$module}->{used}    = 0;

        no strict 'refs'; ## no critic
        $self->{modules}->{$module}->{runAfter} = [ 
            $parent ? $parent : (),
            ${$module . '::runAfter'} ? @${$module . '::runAfter'} : ()
        ];
    }

    # second pass: disable fallback modules
    foreach my $module (@modules) {
        no strict 'refs'; ## no critic

        # skip modules already disabled
        next unless $self->{modules}->{$module}->{enabled};
        # skip non-fallback modules 
        next unless ${$module . '::runMeIfTheseChecksFailed'};

        my $failed;

        foreach my $other_module (@${$module . '::runMeIfTheseChecksFailed'}) {
            if ($self->{modules}->{$other_module}->{enabled}) {
                $failed = $other_module;
                last;
            }
        }

        unless ($failed) {
            $self->{modules}->{$module}->{enabled} = 0;
            $logger->debug("module $module disabled: no depended module failed");
        }
    }
}

sub _runModule {
    my ($self, $module) = @_;

    my $logger = $self->{logger};

    return if $self->{modules}->{$module}->{done};

    $self->{modules}->{$module}->{used} = 1; # lock the module

    # ensure all needed modules have been executed first
    foreach my $other_module (@{$self->{modules}->{$module}->{runAfter}}) {
        die "module $other_module, needed before $module, not found"
            if !$self->{modules}->{$other_module};

        die "module $other_module, needed before $module, not enabled"
            if !$self->{modules}->{$other_module}->{enabled};

        die "circular dependency between $module and $other_module"
            if $self->{modules}->{$other_module}->{used};

        $self->_runModule($other_module);
    }

    $logger->debug ("Running $module");

    $self->_runFunction({
        module   => $module,
        function => "doInventory",
        timeout  => $self->{config}->{'backend-collect-timeout'}
    });
    $self->{modules}->{$module}->{done} = 1;
    $self->{modules}->{$module}->{used} = 0; # unlock the module
}

sub _feedInventory {
    my ($self, $params) = @_;

    my $logger = $self->{logger};

    my $inventory = $self->{inventory};

    my $begin = time();
    my @modules =
        grep { $self->{modules}->{$_}->{enabled} }
        keys %{$self->{modules}};

    foreach my $module (sort @modules) {
        $self->_runModule($module);
    }

    # Execution time
    $inventory->setHardware({ETIME => time() - $begin});

    $inventory->setGlobalValues();

    $inventory->processChecksum();

    $inventory->checkContent();
}

sub _runFunction {
    my ($self, $params) = @_;

    my $module   = $params->{module};
    my $function = $params->{function};
    my $logger   = $self->{logger};

    my $result;
    
    eval {
        local $SIG{ALRM} = sub { die "alarm\n" }; # NB: \n require
        alarm $params->{timeout} if $params->{timeout};

        no strict 'refs'; ## no critic

        $result = &{$module . '::' . $function}(
            accountconfig => $self->{accountconfig},
            accountinfo   => $self->{accountinfo},
            config        => $self->{config},
            confdir       => $self->{confdir},
            datadir       => $self->{datadir},
            inventory     => $self->{inventory},
            logger        => $self->{logger},
            transmitter   => $self->{transmitter},
            prologresp    => $self->{prologresp},
            storage       => $self->{storage},
        );
    };
    alarm 0;

    if ($EVAL_ERROR) {
        if ($EVAL_ERROR ne "alarm\n") {
            $logger->debug("_runFunction(): unexpected error: $EVAL_ERROR");
        } else {
            $logger->debug("$module killed by a timeout.");
        }
    }

    return $result;
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Task::Inventory - Inventory task for FusionInventory 

=head1 DESCRIPTION

This task extract various hardware and software informations on the agent host.
