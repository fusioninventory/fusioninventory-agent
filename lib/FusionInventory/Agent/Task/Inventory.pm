package FusionInventory::Agent::Task::Inventory;

use strict;
use warnings;
use base 'FusionInventory::Agent::Task';

use Config;
use English qw(-no_match_vars);
use UNIVERSAL::require;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Inventory;
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

    my $inventory = FusionInventory::Agent::Inventory->new(
        deviceid => $self->{deviceid},
        statedir => $self->{target}->getStorage()->getDirectory(),
        logger   => $self->{logger},
    );

    # Turn off localised output for commands
    $ENV{LC_ALL} = 'C'; # Turn off localised output for commands
    $ENV{LANG} = 'C'; # Turn off localised output for commands

    if (not $self->{config}->{'scan-homedirs'}) {
        $self->{logger}->debug(
            "--scan-homedirs missing. Don't scan user directories"
        );
    }

    $self->_initModulesList();
    $self->_feedInventory($inventory);

    if ($self->{target}->isa('FusionInventory::Agent::Target::Stdout')) {
        $self->_printInventory(
            inventory => $inventory,
            handle    => \*STDOUT,
            format    => 'xml'
        );
    } elsif ($self->{target}->isa('FusionInventory::Agent::Target::Local')) {
        my $format = $self->{target}->{format};

        my $extension = $format eq 'xml' ? '.ocs' : '.html';
        my $file =
            $self->{config}->{local} .
            "/" .
            $self->{deviceid} .
            $extension;

        if (open my $handle, '>', $file) {
            $self->_printInventory(
                inventory => $inventory,
                handle    => $handle,
                format    => $format
            );
            close $handle;
            $self->{logger}->info("Inventory saved in $file");
        } else {
            warn "Can't open $file: $ERRNO"
        }
    } elsif ($self->{target}->isa('FusionInventory::Agent::Target::Server')) {

        # Add target ACCOUNTINFO values to the inventory
        $inventory->setAccountInfo(
            $self->{target}->getAccountInfo()
        );

        my $message = FusionInventory::Agent::XML::Query::Inventory->new(
            deviceid => $self->{deviceid},
            content  => $inventory->getContent()
        );

        my $response = $self->{client}->send(
            url     => $self->{target}->getUrl(),
            message => $message
        );

        return unless $response;
        $inventory->saveLastState();

        my $content = $response->getContent();
        if ($content
            &&
            $content->{RESPONSE}
            &&
            $content->{RESPONSE} eq 'ACCOUNT_UPDATE'
        ) {
            my $new = $content->{ACCOUNTINFO};
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

        my $enabled = $self->_runFunction(
            module   => $module,
            function => "isEnabled",
            timeout  => $config->{'backend-collect-timeout'},
            params => {
                datadir       => $self->{datadir},
                logger        => $self->{logger},
                prologresp    => $self->{prologresp},
                no_software   => $self->{config}->{no_software},
                no_printer    => $self->{config}->{no_printer},
                scan_homedirs => $self->{config}->{'scan-homedirs'},
            }
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
    my ($self, $module, $inventory) = @_;

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

        $self->_runModule($other_module, $inventory);
    }

    $logger->debug ("Running $module");

    $self->_runFunction(
        module   => $module,
        function => "doInventory",
        timeout  => $self->{config}->{'backend-collect-timeout'},
        params => {
            datadir       => $self->{datadir},
            inventory     => $inventory,
            logger        => $self->{logger},
            prologresp    => $self->{prologresp},
            no_software   => $self->{config}->{no_software},
            no_printer    => $self->{config}->{no_printer},
            scan_homedirs => $self->{config}->{'scan-homedirs'},
        }
    );
    $self->{modules}->{$module}->{done} = 1;
    $self->{modules}->{$module}->{used} = 0; # unlock the module
}

sub _feedInventory {
    my ($self, $inventory) = @_;

    my $begin = time();
    my @modules =
        grep { $self->{modules}->{$_}->{enabled} }
        keys %{$self->{modules}};

    foreach my $module (sort @modules) {
        $self->_runModule($module, $inventory);
    }

    $self->_injectContent($self->{config}->{'additional-content'}, $inventory)
        if -f $self->{config}->{'additional-content'};

    # Execution time
    $inventory->setHardware({ETIME => time() - $begin});

    $inventory->setGlobalValues();

    $inventory->processChecksum();

    $inventory->checkContent();
}

sub _injectContent {
    my ($self, $file, $inventory) = @_;

    return unless -f $file;

    $self->{logger}->debug(
        "importing $file file content to the inventory"
    );

    my $tree    = XML::TreePP->new()->parsefile($file);
    my $content = $tree->{REQUEST}->{CONTENT};

    if (!$content) {
        $self->{logger}->error("no suitable content found");
        return;
    }

    $inventory->mergeContent($content);
}

sub _runFunction {
    my ($self, %params) = @_;

    my $module   = $params{module};
    my $function = $params{function};
    my $params   = $params{params};
    my $logger   = $self->{logger};

    my $result;
    
    eval {
        local $SIG{ALRM} = sub { die "alarm\n" }; # NB: \n require
        alarm $params{timeout} if $params{timeout};

        no strict 'refs'; ## no critic

        $result = &{$module . '::' . $function}(%$params);
    };
    alarm 0;

    if ($EVAL_ERROR) {
        if ($EVAL_ERROR ne "alarm\n") {
            $logger->debug("unexpected error in $module: $EVAL_ERROR");
        } else {
            $logger->debug("$module killed by a timeout.");
        }
    }

    return $result;
}

sub _printInventory {
    my ($self, %params) = @_;

    SWITCH: {
        if ($params{format} eq 'xml') {

            my $tpp = XML::TreePP->new(indent => 2);
            print {$params{handle}} $tpp->write({
                REQUEST => {
                    CONTENT => $params{inventory}->{content}
                }
            });

            last SWITCH;
        }

        if ($params{format} eq 'html') {

            my $template = Text::Template->new(
                TYPE => 'FILE', SOURCE => "$self->{datadir}/html/inventory.tpl"
            );

             my $hash = {
                version  => $FusionInventory::Agent::VERSION,
                deviceid => $params{inventory}->{deviceid},
                data     => $params{inventory}->{content},
                fields   => $params{inventory}->{fields},
            };

            print {$params{handle}} $template->fill_in(HASH => $hash);

            last SWITCH;
        }

        die "unknown format $params{format}";
    }
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Task::Inventory - Inventory task for FusionInventory 

=head1 DESCRIPTION

This task extract various hardware and software informations on the agent host.
