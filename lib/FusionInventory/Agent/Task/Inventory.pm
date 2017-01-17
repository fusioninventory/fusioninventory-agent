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

use FusionInventory::Agent::Task::Inventory::Version;

our $VERSION = FusionInventory::Agent::Task::Inventory::Version::VERSION;

sub isEnabled {
    my ($self, $response) = @_;

    # always enabled for local target
    return 1 unless
        $self->{target}->isa('FusionInventory::Agent::Target::Server');

    my $content = $response->getContent();
    if (!$content || !$content->{RESPONSE} || $content->{RESPONSE} ne 'SEND') {
        if ($self->{config}->{force}) {
            $self->{logger}->debug("Inventory task execution not requested, but execution forced");
        } else {
            $self->{logger}->debug("Inventory task execution not requested");
            return;
        }
    }

    $self->{registry} = [ $response->getOptionsInfoByName('REGISTRY') ];
    return 1;
}

sub run {
    my ($self, %params) = @_;

    if ( $REAL_USER_ID != 0 ) {
        $self->{logger}->warning(
            "You should execute this task as super-user"
        );
    }

    $self->{modules} = {};

    my $inventory = FusionInventory::Agent::Inventory->new(
        statedir => $self->{target}->getStorage()->getDirectory(),
        logger   => $self->{logger},
        tag      => $self->{config}->{'tag'}
    );

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

    if ($self->{target}->isa('FusionInventory::Agent::Target::Local')) {
        my $path   = $self->{target}->getPath();
        my $format = $self->{target}->{format};
        my ($file, $handle);

        SWITCH: {
            if ($path eq '-') {
                $handle = \*STDOUT;
                last SWITCH;
            }

            if (-d $path) {
                $file =
                    $path . "/" . $self->{deviceid} .
                    ($format eq 'xml' ? '.ocs' : '.html');
                last SWITCH;
            }

            $file = $path;
        }

        if ($file) {
            if (Win32::Unicode::File->require()) {
                $handle = Win32::Unicode::File->new('w', $file);
            } else {
                open($handle, '>', $file);
            }
            $self->{logger}->error("Can't write to $file: $ERRNO")
                unless $handle;
        }

        binmode $handle, ':encoding(UTF-8)';

        $self->_printInventory(
            inventory => $inventory,
            handle    => $handle,
            format    => $format
        );

        if ($file) {
            $self->{logger}->info("Inventory saved in $file");
            close $handle;
        }

    } elsif ($self->{target}->isa('FusionInventory::Agent::Target::Server')) {
        my $client = FusionInventory::Agent::HTTP::Client::OCS->new(
            logger       => $self->{logger},
            user         => $params{user},
            password     => $params{password},
            proxy        => $params{proxy},
            ca_cert_file => $params{ca_cert_file},
            ca_cert_dir  => $params{ca_cert_dir},
            no_ssl_check => $params{no_ssl_check},
            no_compress  => $params{no_compress},
        );

        my $message = FusionInventory::Agent::XML::Query::Inventory->new(
            deviceid => $self->{deviceid},
            content  => $inventory->getContent()
        );

        my $response = $client->send(
            url     => $self->{target}->getUrl(),
            message => $message
        );

        return unless $response;
        $inventory->saveLastState();

    }

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

        # Just skip Version package as not an inventory package module
        if ($module =~ /FusionInventory::Agent::Task::Inventory::Version$/) {
            $self->{modules}->{$module}->{enabled} = 0;
            next;
        }

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
            timeout  => $config->{'backend-collect-timeout'},
            params => {
                no_category   => $disabled,
                datadir       => $self->{datadir},
                logger        => $self->{logger},
                registry      => $self->{registry},
                scan_homedirs => $self->{config}->{'scan-homedirs'},
                scan_profiles => $self->{config}->{'scan-profiles'},
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
            scan_profiles => $self->{config}->{'scan-profiles'},
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
            "deprecated, use --additional-content option instead"
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

sub _printInventory {
    my ($self, %params) = @_;

    SWITCH: {
        if ($params{format} eq 'xml') {

            my $tpp = XML::TreePP->new(
                indent          => 2,
                utf8_flag       => 1,
                output_encoding => 'UTF-8'
            );
            print {$params{handle}} $tpp->write({
                REQUEST => {
                    CONTENT => $params{inventory}->{content},
                    DEVICEID => $self->{deviceid},
                    QUERY => "INVENTORY",
                }
            });

            last SWITCH;
        }

        if ($params{format} eq 'html') {
            Text::Template->require();
            my $template = Text::Template->new(
                TYPE => 'FILE', SOURCE => "$self->{datadir}/html/inventory.tpl"
            );

             my $hash = {
                version  => $FusionInventory::Agent::Version::VERSION,
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

This task extract various hardware and software information on the agent host.
