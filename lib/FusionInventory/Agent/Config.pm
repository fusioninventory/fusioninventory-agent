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
    _ => {
        'no-module'            => [],
        'server'               => undef,
        'tag'                  => undef,
        'conf-reload-interval' => 0,
    },
    http => {
        'ca-cert-path'         => undef,
        'no-ssl-check'         => undef,
        'proxy'                => undef,
        'password'             => undef,
        'timeout'              => 180,
        'user'                 => undef,
    },
    httpd => {
        'no-httpd'             => undef,
        'httpd-ip'             => undef,
        'httpd-port'           => 62354,
        'httpd-trust'          => [],
    },
    logger => {
        'logger'               => 'Stderr',
        'logfile'              => undef,
        'logfacility'          => 'LOG_USER',
        'logfile-maxsize'      => undef,
        'debug'                => undef,
    },
};

my $deprecated = {
    _ => {
        'ca-cert-dir' => {
            message => 'use http/ca-cert-path option instead',
            new     => sub {
                my ($config, $value) = @_;
                $config->{http}->{'ca-cert-path'} = $value;
            },
        },
        'ca-cert-file' => {
            message => 'use http/ca-cert-path option instead',
            new     => sub {
                my ($config, $value) = @_;
                $config->{http}->{'ca-cert-path'} = $value;
            },
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
            message => 'use no-module option instead',
            new     => sub {
                my ($config, $value) = @_;
                $config->{_}->{'no-module'} = $value;
            },
        },
        'tasks' => {
            message => 'scheduling is done on server side'
        },
    }
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

    foreach my $section (keys %{$default}) {
        foreach my $key (keys %{$default->{$section}}) {
            $self->{$section}->{$key} = $default->{$section}->{$key};
        }
    }
}

sub _loadUserParams {
    my ($self, $params) = @_;

    foreach my $section (keys %{$params}) {
        foreach my $key (keys %{$params->{$section}}) {
            $self->{$section}->{$key} = $params->{$section}->{$key};
        }
    }
}

sub _checkContent {
    my ($self) = @_;

    # check for deprecated options
    foreach my $section (keys %{$deprecated}) {
    foreach my $old (keys %{$deprecated->{$section}}) {
        next unless defined $self->{$section}->{$old};

        next if $old =~ /^no-/ and !$self->{$old};

        my $handler = $deprecated->{$section}->{$old};

        # notify user of deprecation
        warn "the '$old' option is deprecated, $handler->{message}\n";

        # transfer the value to the new option, if possible
        $handler->{new}->($self, $self->{$section}->{$old}) if $handler->{new};

        # avoid cluttering configuration
        delete $self->{$section}->{$old};
    }
    }

    # a logfile options implies a file logger backend
    if ($self->{logger}->{logfile}) {
        $self->{logger}->{logger} .= ',File';
    }

    # logger backend without a logfile isn't enoguh
    if ($self->{logger}->{logger} =~ /file/i && ! $self->{logger}->{logfile}) {
        die "usage of 'file' logger backend makes 'logfile' option mandatory\n";
    }

    # multi-values options, the def{ault separator is a ','
    $self->{_}->{'no-module'} =
        $self->{_}->{'no-module'} &&
        ! ref $self->{_}->{'no-module'} ?
            [ split(/,/, $self->{_}->{'no-module'}) ] : [] ;
    $self->{httpd}->{'httpd-trust'} =
        $self->{httpd}->{'httpd-trust'} &&
        ! ref $self->{httpd}->{'httpd-trust'} ?
            [ split(/,/, $self->{httpd}->{'httpd-trust'}) ] : [];

    # files location
    $self->{http}->{'ca-cert-path'} =
        File::Spec->rel2abs($self->{http}->{'ca-cert-path'})
        if $self->{http}->{'ca-cert-path'};
    $self->{logger}->{'logfile'} =
        File::Spec->rel2abs($self->{logger}->{'logfile'})
        if $self->{logger}->{'logfile'};

    # conf-reload-interval option
    # If value is less than the required minimum, we force it to that
    # minimum because it's useless to reload the config so often and,
    # furthermore, it can cause a loss of performance
    if ($self->{_}->{'conf-reload-interval'} != 0) {
        if ($self->{_}->{'conf-reload-interval'} < 0) {
            $self->{_}->{'conf-reload-interval'} = 0;
        } elsif ($self->{_}->{'conf-reload-interval'} < $confReloadIntervalMinValue) {
            $self->{_}->{'conf-reload-interval'} = $confReloadIntervalMinValue;
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
