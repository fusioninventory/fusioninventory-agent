package FusionInventory::Agent::Task::Inventory;

use strict;
use warnings;
use base 'FusionInventory::Agent::Task';

use English qw(-no_match_vars);
use UNIVERSAL::require;

use FusionInventory::Agent;
use FusionInventory::Agent::Recipient::Inventory::Stdout;
use FusionInventory::Agent::Recipient::Inventory::Filesystem;
use FusionInventory::Agent::Recipient::Inventory::Server;
use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Inventory;

our $VERSION = $FusionInventory::Agent::VERSION;

sub isEnabled {
    my ($self, %params) = @_;

    # always enabled for local target
    return 1 unless
        $self->{target}->isa('FusionInventory::Agent::Target::Server');

    if ($self->{config}->{force}) {
        $self->{logger}->debug("Prolog response ignored");
        return 1;
    }

    my $response = $params{response};

    my $content = $response->getContent();
    if (!$content || !$content->{RESPONSE} || $content->{RESPONSE} ne 'SEND') {
        $self->{logger}->debug("No inventory requested in the prolog response");
        return;
    }

    $self->{registry} = $response->getOptionsInfoByName('REGISTRY');
    return 1;
}

sub run {
    my ($self, %params) = @_;

    $self->{logger}->debug("running FusionInventory Inventory task");

    # use given output recipient, otherwise use either local or server recipient,
    # according to target type
    my $recipient;
    if ($params{recipient}) {
        $recipient = $params{recipient};
    } elsif ($self->{target}->isa('FusionInventory::Agent::Target::Local')) {
        my $path = $self->{target}->getPath();
        if ($path eq '-') {
            $recipient = FusionInventory::Agent::Recipient::Inventory::Stdout->new(
                deviceid => $self->{deviceid},
            );
        } else {
            $recipient = FusionInventory::Agent::Recipient::Inventory::Filesystem->new(
                target   => $self->{target}->getPath(),
                format   => $self->{target}->{format},
                datadir  => $self->{datadir},
                deviceid => $self->{deviceid},
            );
        }
    } elsif ($self->{target}->isa('FusionInventory::Agent::Target::Server')) {
        $recipient = FusionInventory::Agent::Recipient::Inventory::Server->new(
            target       => $self->{target}->getUrl(),
            deviceid     => $self->{deviceid},
            logger       => $self->{logger},
            user         => $params{user},
            password     => $params{password},
            proxy        => $params{proxy},
            ca_cert_file => $params{ca_cert_file},
            ca_cert_dir  => $params{ca_cert_dir},
            no_ssl_check => $params{no_ssl_check},
        );
    }

    $self->{modules} = {};

    my $inventory = FusionInventory::Agent::Inventory->new(
        logger   => $self->{logger},
        tag      => $self->{config}->{'tag'}
    );

    if (not $self->{config}->{'scan-homedirs'}) {
        $self->{logger}->debug(
            "--scan-homedirs missing. Don't scan user directories"
        );
    }

    if (not $ENV{PATH}) {
        # set a minimal PATH if none is set (#1129, #1747)
        $ENV{PATH} =
            '/sbin:/usr/sbin:/usr/local/sbin:/bin:/usr/bin:/usr/local/bin';
        $self->{logger}->debug(
            "PATH is not set, using $ENV{PATH} as default"
        );
    }

    my %disabled = map { $_ => 1 } @{$self->{config}->{'no-category'}};

    $self->_initModulesList(\%disabled);
    $self->_feedInventory($inventory, \%disabled);

    my $response = $recipient->send(inventory => $inventory);
}

sub _initModulesList {
    my ($self, $disabled) = @_;

    my $logger = $self->{logger};
    my $config = $self->{config};

    my @modules = __PACKAGE__->getModules('');
    die "no inventory module found" if !@modules;

    # first pass: compute all relevant modules
    foreach my $module (sort @modules) {
        # compute parent module:
        my @components = split('::', $module);
        my $parent = @components > 5 ?
            join('::', @components[0 .. $#components -1]) : '';

        # skip if parent is not allowed
        if ($parent && !$self->{modules}->{$parent}->{enabled}) {
            $logger->debug2("  $module disabled: implicit dependency $parent not enabled");
            $self->{modules}->{$module}->{enabled} = 0;
            next;
        }

        $module->require();
        if ($EVAL_ERROR) {
            $logger->debug("module $module disabled: failure to load ($EVAL_ERROR)");
            $self->{modules}->{$module}->{enabled} = 0;
            next;
        }

        my $enabled = runFunction(
            module   => $module,
            function => "isEnabled",
            logger => $logger,
            timeout  => $config->{'collect-timeout'},
            params => {
                no_category   => $disabled,
                datadir       => $self->{datadir},
                logger        => $self->{logger},
                registry      => $self->{registry},
                scan_homedirs => $self->{config}->{'scan-homedirs'},
            }
        );
        if (!$enabled) {
            $logger->debug2("module $module disabled");
            $self->{modules}->{$module}->{enabled} = 0;
            next;
        }

        $self->{modules}->{$module}->{enabled} = 1;
        $self->{modules}->{$module}->{done}    = 0;
        $self->{modules}->{$module}->{used}    = 0;

        no strict 'refs'; ## no critic (ProhibitNoStrict)
        $self->{modules}->{$module}->{runAfter} = [
            $parent ? $parent : (),
            ${$module . '::runAfter'} ? @${$module . '::runAfter'} : ()
        ];
    }

    # second pass: disable fallback modules
    foreach my $module (@modules) {
        ## no critic (ProhibitProlongedStrictureOverride)
        no strict 'refs'; ## no critic (ProhibitNoStrict)

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

        if ($failed) {
            $self->{modules}->{$module}->{enabled} = 0;
            $logger->debug("module $module disabled because of $failed");
        }
    }
}

sub _runModule {
    my ($self, $module, $inventory, $disabled) = @_;

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

        $self->_runModule($other_module, $inventory, $disabled);
    }

    $logger->debug("Running $module");

    runFunction(
        module   => $module,
        function => "doInventory",
        logger => $logger,
        timeout  => $self->{config}->{'backend-collect-timeout'},
        params => {
            datadir       => $self->{datadir},
            inventory     => $inventory,
            no_category   => $disabled,
            logger        => $self->{logger},
            registry      => $self->{registry},
            scan_homedirs => $self->{config}->{'scan-homedirs'},
        }
    );
    $self->{modules}->{$module}->{done} = 1;
    $self->{modules}->{$module}->{used} = 0; # unlock the module
}

sub _feedInventory {
    my ($self, $inventory, $disabled) = @_;

    my $begin = time();
    my @modules =
        grep { $self->{modules}->{$_}->{enabled} }
        keys %{$self->{modules}};

    foreach my $module (sort @modules) {
        $self->_runModule($module, $inventory, $disabled);
    }

    if (-d $self->{confdir} . '/softwares') {
        $self->{logger}->info(
            "using custom scripts for adding softwares to inventory is " .
            "deprecated, use --additional-content option insted"
        );
    }

    if ($self->{config}->{'additional-content'} && -f $self->{config}->{'additional-content'}) {
        $self->_injectContent($self->{config}->{'additional-content'}, $inventory)
    }

    # Execution time
    $inventory->setHardware({ETIME => time() - $begin});

    $inventory->computeLegacyValues();
    $inventory->computeChecksum();
}

sub _injectContent {
    my ($self, $file, $inventory) = @_;

    return unless -f $file;

    $self->{logger}->debug(
        "importing $file file content to the inventory"
    );

    my $content;
    SWITCH: {
        if ($file =~ /\.xml$/) {
            eval {
                my $tree = XML::TreePP->new()->parsefile($file);
                $content = $tree->{REQUEST}->{CONTENT};
            };
            last SWITCH;
        }
        die "unknown file type $file";
    }

    if (!$content) {
        $self->{logger}->error("no suitable content found");
        return;
    }

    $inventory->mergeContent($content);
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Task::Inventory - Inventory task for FusionInventory

=head1 DESCRIPTION

This task extract various hardware and software information on the agent host.
