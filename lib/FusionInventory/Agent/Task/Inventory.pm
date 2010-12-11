package FusionInventory::Agent::Task::Inventory;

use strict;
use warnings;
use base 'FusionInventory::Agent::Task';

use English qw(-no_match_vars);
use File::Find;
use UNIVERSAL::require;

use FusionInventory::Agent::XML::Query::Inventory;

sub new {
    my ($class, %params) = @_;

    my $self = {
        scan_homedirs => $params{scan_homedirs},
        no_software   => $params{no_software},
        no_printer    => $params{no_printer},
        force         => $params{force},
    };
    bless $self, $class;

    return $self;
}

sub run {
    my ($self, %params) = @_;

    my $logger = $params{logger};
    my $target = $params{target};

    if ($target->isa('FusionInventory::Agent::Target::Server')) {
        my $response = $self->getPrologResponse(
            transmitter => $target->getTransmitter(),
            deviceid    => $params{deviceid},
            token       => $params{token},
        );

        if (!$response) {
            $logger->debug("No server response. Exiting...");
            return;
        }

        my $content = $response->getParsedContent();
        if (
            ! $content             ||
            ! $content->{RESPONSE} ||
            ! $content->{RESPONSE} eq 'SEND'
        ) {
            $logger->debug(
                "No inventory requested in the prolog, exiting"
            );
            return;
        }
    }

    # Turn off localised output for commands, after saving original values
    my %ENV_ORIG;
    foreach my $key (qw/LC_ALL LANG/) {
        $ENV_ORIG{$key} = $ENV{$key};
        $ENV{$key} = 'C';
    }

    # initialize modules list
    $self->_initModulesList(
        logger  => $logger,
        storage => $target->getStorage(),
    );

    my $inventory = FusionInventory::Agent::XML::Query::Inventory->new(
        logger   => $logger,
        deviceid => $params{deviceid},
        storage  => $target->getStorage()
    );

    $self->_feedInventory(
        logger    => $logger,
        inventory => $inventory
    );

    # restore original environnement, and complete inventory
    foreach my $key (qw/LC_ALL LANG/) {
        $ENV{$key} = $ENV_ORIG{$key};
        next unless $ENV{$key};
        $inventory->addEnv({ KEY => $key, VAL => $ENV{$key} });
    }

    SWITCH: {
        if (ref $target eq 'FusionInventory::Agent::Target::Stdout') {
            my $format = $target->getFormat();
            if ($format eq 'xml') {
                print $inventory->getContent();
            } else {
                print $inventory->getContentAsHTML();
            }
            last SWITCH;
        }

        if (ref $target eq 'FusionInventory::Agent::Target::Local') {
            my $format = $target->getFormat();
            my $suffix = $format eq 'html' ? '.html' : '.ocs';
            my $file =
                $target->getPath() .
                "/" .
                $params{deviceid} .
                $suffix;

            if (open my $handle, '>', $file) {
                if ($format eq 'xml') {
                    print $handle $inventory->getContent();
                } else {
                    print $handle $inventory->getContentAsHTML();
                }
                close $handle;
                $logger->info("Inventory saved in $file");
            } else {
                warn "Can't open $file: $ERRNO"
            }
            last SWITCH;
        }

        if (ref $target eq 'FusionInventory::Agent::Target::Server') {

            # Add current ACCOUNTINFO values to the inventory
            $inventory->setAccountInfo(
                $target->getAccountInfo()
            );

            my $response = $target->getTransmitter()->send(
                message => $inventory,
                url     => $target->getUrl(),
            );

            return unless $response;

            $inventory->saveState();

            my $content = $response->getParsedContent();
            if (
                $content &&
                $content->{RESPONSE} &&
                $content->{RESPONSE} eq 'ACCOUNT_UPDATE'
            ) {
                # Update current ACCOUNTINFO values
                $target->setAccountInfo($content->{ACCOUNTINFO});
            }

            last SWITCH;
        }
    }

}

sub _initModulesList {
    my ($self, %params) = @_;

    my $logger = $params{logger};

    # use first directory of @INC containing an installation tree
    my $dirToScan;
    foreach my $dir (@INC) {
        my $subdir = $dir . '/FusionInventory/Agent/Task/Inventory';
        if (-d $subdir) {
            $dirToScan = $subdir;
            last;
        }
    }
    
    die "No directory to scan for inventory modules" if !$dirToScan;

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
        $dirToScan
    );

    my @modules = keys %modules;
    die "No inventory module found" if !@modules;

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

        my $enabled = $self->_runFunction(
            module   => $module,
            function => 'isInventoryEnabled',
        );
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

        next unless ${$module . '::runMeIfTheseChecksFailed'};

        my $failed;

        foreach my $other_module (@${$module . '::runMeIfTheseChecksFailed'}) {
            if ($self->{modules}->{$other_module}->{enabled}) {
                $failed = $other_module;
                last;
            }
        }

        if ($failed) {
            $self->{modules}->{$module}->{enabled} = 1;
            $logger->debug("module $module enabled: $failed failed");
        } else {
            $self->{modules}->{$module}->{enabled} = 0;
            $logger->debug("module $module disabled: no depended module failed");
        }
    }
}

# fill the inventory
sub _feedInventory {
    my ($self, %params) = @_;

    my $begin = time();

    my @modules =
        grep { $self->{modules}->{$_}->{enabled} }
        keys %{$self->{modules}};

    foreach my $module (sort @modules) {
        $self->_runModule(
            module    => $module,
            inventory => $params{inventory},
            logger    => $params{logger},
        );
    }

    # Execution time
    $params{inventory}->setHardware({ETIME => time() - $begin});
}

# run an inventory module
sub _runModule {
    my ($self, %params) = @_;

    my $module = $params{module} or die "no module given";
    my $logger = $params{logger};

    return if ($self->{modules}->{$module}->{done});

    $self->{modules}->{$module}->{used} = 1; # lock the module
    # first I run its "runAfter"

    foreach my $other_module (@{$self->{modules}->{$module}->{runAfter}}) {
        if (!$self->{modules}->{$other_module}) {
            die "Module $other_module, needed before $module, not found";
        }

        if (!$self->{modules}->{$other_module}->{enabled}) {
            die "Module $other_module, needed before $module, not enabled";
        }

        if ($self->{modules}->{$other_module}->{used}) {
            # In use 'lock' is taken during the mod execution. If a module
            # need a module also in use, we have provable an issue :).
            die "Circular dependency between $module and  $other_module";
        }
        $self->_runModule(
            module    => $other_module,
            inventory => $params{inventory},
            logger    => $params{logger},
        );
    }

    $logger->debug("Running $module");

    $self->_runFunction(
        module    => $module,
        function  => "doInventory",
        inventory => $params{inventory},
        logger    => $params{logger},
    );
    $self->{modules}->{$module}->{done} = 1;
    $self->{modules}->{$module}->{used} = 0; # unlock the module
}

# run a single module function
sub _runFunction {
    my ($self, %params) = @_;

    my $module   = $params{module} or die "no module given";
    my $function = $params{function} or die "no function given";
    my $logger   = $params{logger};

    $params{timeout} = 180 if !defined $params{timeout};

    my $result;

    eval {
        local $SIG{ALRM} = sub { die "alarm\n" }; # NB: \n require
        alarm $params{timeout} if $params{timeout};

        no strict 'refs'; ## no critic

        $result = &{$module . '::' . $function}(
            logger    => $logger,
            confdir   => $params{confdir},
            datadir   => $params{datadir},
            inventory => $params{inventory},
            storage   => $params{storage}
        );
    };
    alarm 0;

    if ($EVAL_ERROR) {
        if ($EVAL_ERROR ne "alarm\n") {
            $logger->debug("runWithTimeout(): unexpected error: $EVAL_ERROR");
        } else {
            $logger->debug("$module killed by a timeout.");
        }
    }

    return $result;
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Task::Inventory - The inventory task for FusionInventory 
=head1 DESCRIPTION

This task extract various hardware and software informations on the agent host.
