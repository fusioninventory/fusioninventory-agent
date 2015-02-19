package FusionInventory::Agent::Task::Inventory;

use strict;
use warnings;
use base 'FusionInventory::Agent::Task';

use Config;
use English qw(-no_match_vars);
use List::Util qw(first);
use UNIVERSAL::require;

use FusionInventory::Agent;
use FusionInventory::Agent::Inventory;
use FusionInventory::Agent::Message::Outbound;
use FusionInventory::Agent::Tools;

our $VERSION = $FusionInventory::Agent::VERSION;

sub getConfiguration {
    my ($self, %params) = @_;

    return ();
}

sub run {
    my ($self, %params) = @_;

    my $target = $params{target} or die "no target provided, aborting";

    if ( $REAL_USER_ID != 0 ) {
        $self->{logger}->warning(
            "You should execute this task as super-user"
        );
    }

    $self->{modules} = {};

    my $inventory = FusionInventory::Agent::Inventory->new(
        logger   => $self->{logger},
        tag      => $self->{config}->{tag}
    );

    if (not $ENV{PATH}) {
        # set a minimal PATH if none is set (#1129, #1747)
        $ENV{PATH} =
            '/sbin:/usr/sbin:/usr/local/sbin:/bin:/usr/bin:/usr/local/bin';
        $self->{logger}->debug(
            "PATH is not set, using $ENV{PATH} as default"
        );
    }

    my %disabled = map { $_ => 1 } @{$self->{config}->{no_category}};

    $self->_initModulesList(\%disabled);
    $self->_feedInventory($inventory, \%disabled);

    my $message = FusionInventory::Agent::Message::Outbound->new(
        query      => 'INVENTORY',
        deviceid   => $self->{config}->{deviceid},
        stylesheet => $self->{config}->{datadir} . 'html/inventory.xsl',
        content    => $inventory->getContent()
    );

    $target->send(
        message  => $message,
        filename => sprintf('inventory_%s.xml', $self->{config}->{deviceid})
    );
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
            timeout  => $config->{'execution-timeout'},
            params => {
                no_category   => $disabled,
                logger        => $self->{logger},
                dbdir         => $self->{config}->{dbdir},
                scan_homedirs => $self->{config}->{scan_homedirs},
                scan_profiles => $self->{config}->{scan_profiles},
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
        timeout  => $self->{config}->{timeout},
        params => {
            inventory     => $inventory,
            no_category   => $disabled,
            logger        => $self->{logger},
            dbdir         => $self->{config}->{dbdir},
            scan_homedirs => $self->{config}->{scan_homedirs},
            scan_profiles => $self->{config}->{scan_profiles},
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

    if ($self->{config}->{additional_content} && -f $self->{config}->{additional_content}) {
        $self->_injectContent($self->{config}->{additional_content}, $inventory)
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

FusionInventory::Agent::Task::Inventory - Local inventory support

=head1 DESCRIPTION

This modules allows the FusionInventory agent to retrieve an inventory of its
own host.
