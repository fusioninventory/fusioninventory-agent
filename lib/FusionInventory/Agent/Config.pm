package FusionInventory::Agent::Config;

use strict;
use warnings;

use English qw(-no_match_vars);
use File::Spec;
use Getopt::Long;
use UNIVERSAL::require;

use FusionInventory::Agent::Version;

require FusionInventory::Agent::Tools;

my $default = {
    'ca-cert-path'            => undef,
    'conf-reload-interval'    => 0,
    'debug'                   => undef,
    'logger'                  => 'Stderr',
    'logfile'                 => undef,
    'logfacility'             => 'LOG_USER',
    'logfile-maxsize'         => undef,
    'no-httpd'                => undef,
    'no-ssl-check'            => undef,
    'no-module'               => [],
    'password'                => undef,
    'proxy'                   => undef,
    'httpd-ip'                => undef,
    'httpd-port'              => 62354,
    'httpd-trust'             => [],
    'server'                  => undef,
    'tag'                     => undef,
    'timeout'                 => 180,
    'user'                    => undef,
    # deprecated options
    'ca-cert-dir'             => undef,
    'ca-cert-file'            => undef,
    'color'                   => undef,
    'delaytime'               => undef,
    'html'                    => undef,
    'local'                   => undef,
    'force'                   => undef,
    'no-compression'          => undef,
    'additional-content'      => undef,
    'backend-collect-timeout' => 180,
    'lazy'                    => undef,
    'scan-homedirs'           => undef,
    'scan-profiles'           => undef,
    'no-category'             => undef,
    'no-p2p'                  => undef,
    'no-task'                 => undef,
    'tasks'                   => undef,
};

my $deprecated = {
    'ca-cert-dir' => {
        message => 'use --ca-cert-path option instead',
        new     => 'ca-cert-path',
    },
    'ca-cert-file' => {
        message => 'use --ca-cert-path option instead',
        new     => 'ca-cert-path',
    },
    'color' => {
        message => 'color is used automatically if relevant',
    },
    'delaytime' => {
        message => 'agent enrolls immediatly at startup',
    },
    'lazy' => {
        message => 'scheduling is done on server side'
    },
    'local' => {
        message =>
            'use fusioninventory-inventory executable',
    },
    'html' => {
        message =>
            'use fusioninventory-inventory executable, with --format option',
    },
    'force' => {
        message =>
            'use fusioninventory-inventory executable to control scheduling',
    },
    'no-compression' => {
        message =>
            'communication are never compressed anymore'
    },
    'no-p2p' => {
        message => 'use fusioninventory-deploy for local control',
    },
    'additional-content' => {
        message => 'use fusioninventory-inventory for local control',
    },
    'no-category' => {
        message => 'use fusioninventory-inventory for local control',
    },
    'scan-homedirs' => {
        message => 'use fusioninventory-inventory for local control',
    },
    'scan-profiles' => {
        message => 'use fusioninventory-inventory for local control',
    },
    'no-task' => {
        message => 'use --no-module option instead',
        new     => 'no-module',
    },
    'tasks' => {
        message => 'scheduling is done on server side'
    },
};

my $confReloadIntervalMinValue = 60;

sub create {
    my ($class, %params) = @_;

    my $backend = $params{backend} || 'file';

    if ($backend eq 'registry') {
        FusionInventory::Agent::Config::Registry->require();
        return FusionInventory::Agent::Config::Registry->new();
    }

    if ($backend eq 'file') {
        FusionInventory::Agent::Config::File->require();
        return FusionInventory::Agent::Config::File->new(
            file => $params{file},
        );
    }

    if ($backend eq 'none') {
        FusionInventory::Agent::Config::None->require();
        return FusionInventory::Agent::Config::None->new();
    }

    die "Unknown configuration backend '$backend'\n";
}

sub new {
    my ($class, %params) = @_;

    my $self = {};
    bless $self, $class;

    return $self;
}

sub init {
    my ($self, %params) = @_;

    $self->_loadDefaults();
    $self->_load();
    $self->_loadUserParams($params{options});
    $self->_checkContent();
}

sub _loadDefaults {
    my ($self) = @_;

    foreach my $key (keys %$default) {
        $self->{$key} = $default->{$key};
    }
}

sub _loadUserParams {
    my ($self, $params) = @_;

    foreach my $key (keys %$params) {
        $self->{$key} = $params->{$key};
    }
}

sub _checkContent {
    my ($self) = @_;

    # check for deprecated options
    foreach my $old (keys %$deprecated) {
        next unless defined $self->{$old};

        next if $old =~ /^no-/ and !$self->{$old};

        my $handler = $deprecated->{$old};

        # notify user of deprecation
        warn "the '$old' option is deprecated, $handler->{message}\n";

        # transfer the value to the new option, if possible
        if ($handler->{new}) {
            if (ref $handler->{new} eq 'HASH') {
                # old boolean option replaced by new non-boolean options
                foreach my $key (keys %{$handler->{new}}) {
                    my $value = $handler->{new}->{$key};
                    if ($value =~ /^\+(\S+)/) {
                        # multiple values: add it to exiting one
                        $self->{$key} = $self->{$key} ?
                            $self->{$key} . ',' . $1 : $1;
                    } else {
                        # unique value: replace exiting value
                        $self->{$key} = $value;
                    }
                }
            } elsif (ref $handler->{new} eq 'ARRAY') {
                # old boolean option replaced by new boolean options
                foreach my $new (@{$handler->{new}}) {
                    $self->{$new} = $self->{$old};
                }
            } else {
                # old non-boolean option replaced by new option
                $self->{$handler->{new}} = $self->{$old};
            }
        }

        # avoid cluttering configuration
        delete $self->{$old};
    }

    # a logfile options implies a file logger backend
    if ($self->{logfile}) {
        $self->{logger} .= ',File';
    }

    # logger backend without a logfile isn't enoguh
    if ($self->{'logger'} =~ /file/i && ! $self->{'logfile'}) {
        die "usage of 'file' logger backend makes 'logfile' option mandatory\n";
    }

    # multi-values options, the default separator is a ','
    foreach my $option (qw/
            httpd-trust
            no-module
            /) {

        # Check if defined AND SCALAR
        # to avoid split a ARRAY ref or HASH ref...
        if ($self->{$option} && ref($self->{$option}) eq '') {
            $self->{$option} = [split(/,/, $self->{$option})];
        } else {
            $self->{$option} = [];
        }
    }

    # files location
    $self->{'ca-cert-path'} =
        File::Spec->rel2abs($self->{'ca-cert-path'}) if $self->{'ca-cert-path'};
    $self->{'logfile'} =
        File::Spec->rel2abs($self->{'logfile'}) if $self->{'logfile'};

    # conf-reload-interval option
    # If value is less than the required minimum, we force it to that
    # minimum because it's useless to reload the config so often and,
    # furthermore, it can cause a loss of performance
    if ($self->{'conf-reload-interval'} != 0) {
        if ($self->{'conf-reload-interval'} < 0) {
            $self->{'conf-reload-interval'} = 0;
        } elsif ($self->{'conf-reload-interval'} < $confReloadIntervalMinValue) {
            $self->{'conf-reload-interval'} = $confReloadIntervalMinValue;
        }
    }
}

sub isParamArrayAndFilled {
    my ($self, $paramName) = @_;

    return FusionInventory::Agent::Tools::isParamArrayAndFilled($self, $paramName);
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Config - Agent configuration

=head1 DESCRIPTION

This is the object used by the agent to store its configuration.

=head1 METHODS

=head2 new(%params)

The constructor. The following parameters are allowed, as keys of the %params
hash:

=over

=item I<confdir>

the configuration directory.

=item I<options>

additional options override.

=back
