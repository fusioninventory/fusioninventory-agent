package FusionInventory::Agent::Task::Inventory;

use strict;
use warnings;
use base 'FusionInventory::Agent::Task';

use English qw(-no_match_vars);
use File::Find;
use UNIVERSAL::require;

use FusionInventory::Agent;
use FusionInventory::Agent::Recipient::Stdout;
use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Inventory;
use FusionInventory::Agent::Message::Outbound;

our $VERSION = $FusionInventory::Agent::VERSION;

sub getConfiguration {
    my ($self, %params) = @_;

    my $response = $params{response};
    if ($response) {
        my $content = $response->getContent();
        if (
            !$content                      ||
            !$content->{RESPONSE}          ||
            $content->{RESPONSE} ne 'SEND'
        ) {
            if ($self->{params}->{force}) {
                $self->{logger}->debug("Task not scheduled, execution forced");
            } else {
                $self->{logger}->debug("Task not scheduled");
                return;
            }
        }
    }

    my $registry = $response ?
        $response->getOptionsInfoByName('REGISTRY') : undef;

    return (
        registry => $registry,
    );
}

sub run {
    my ($self, %params) = @_;

    $self->{logger}->info("Running Inventory task");
    if ( $REAL_USER_ID != 0 ) {
        $self->{logger}->info("You should run this program as super-user.");
    }

    my $recipient =
        $params{recipient} ||
        FusionInventory::Agent::Recipient::Stdout->new();

    $self->{modules} = {};

    my $inventory = FusionInventory::Agent::Inventory->new(
        logger   => $self->{logger},
        tag      => $self->{params}->{tag}
    );

    if (not $self->{params}->{'scan-homedirs'}) {
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

    my %disabled = map { $_ => 1 } @{$self->{params}->{no_category}};

    $self->_initModulesList(\%disabled);
    $self->_feedInventory($inventory, \%disabled);

    my $message = FusionInventory::Agent::Message::Outbound->new(
        query      => 'INVENTORY',
        deviceid   => $self->{params}->{deviceid},
        stylesheet => $self->{params}->{datadir} . '/inventory.xsl',
        content    => $inventory->getContent()
    );

    $recipient->send(
        message => $message,
        hint    => $self->{params}->{deviceid},
    );
}

sub _getModules {
    my ($class, $prefix) = @_;

    # allow to be called as an instance method
    $class = ref $class ? ref $class : $class;

    # use %INC to retrieve the root directory for this task
    my $file = module2file($class);
    my $rootdir = $INC{$file};
    $rootdir =~ s/.pm$//;
    return unless -d $rootdir;

    # find a list of modules from files in this directory
    my $root = $file;
    $root =~ s/.pm$//;
    $root .= "/$prefix" if $prefix;
    my @modules;
    my $wanted = sub {
        return unless -f $_;
        return unless $File::Find::name =~ m{($root/\S+\.pm)$};
        my $module = file2module($1);
        push(@modules, $module);
    };
    File::Find::find($wanted, $rootdir);
    return @modules
}

sub _initModulesList {
    my ($self, $disabled) = @_;

    my $logger = $self->{logger};

    my @modules = __PACKAGE__->_getModules('');
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
            logger   => $logger,
            timeout  => $self->{params}->{timeout},
            params => {
                no_category   => $disabled,
                logger        => $self->{logger},
                datadir       => $self->{params}->{datadir},
                registry      => $self->{params}->{registry},
                scan_homedirs => $self->{params}->{scan_homedirs},
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
        timeout  => $self->{params}->{timeout},
        params => {
            datadir       => $self->{params}->{datadir},
            inventory     => $inventory,
            no_category   => $disabled,
            logger        => $self->{logger},
            registry      => $self->{registry},
            scan_homedirs => $self->{params}->{scan_homedirs},
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

    if (
        $self->{params}->{additional_content} &&
        -f $self->{params}->{additional_content}) {
        $self->_injectContent($self->{params}->{additional_content}, $inventory)
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
