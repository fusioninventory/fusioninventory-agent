package FusionInventory::Agent::Config;

use strict;
use warnings;

use English qw(-no_match_vars);
use File::Spec;
use UNIVERSAL::require;

my $valid = {
        _ => {
            'server'             => 'list',
            'tag'                => 'string'
        },
        http => {
            'proxy'              => 'string',
            'timeout'            => 'integer',
            'ca-cert-dir'        => 'path',
            'ca-cert-file'       => 'path',
            'no-ssl-check'       => 'boolean',
            'user'               => 'string',
            'password'           => 'string'
        },
        httpd => {
            'disable'            => 'boolean',
            'ip'                 => 'string',
            'port'               => 'integer',
            'trust'              => 'list',
        },
        logger => {
            'backend'            => 'string',
            'file'               => 'path',
            'facility'           => 'string',
            'maxsize'            => 'integer',
            'verbosity'          => 'string'
        },
        inventory => {
            'disable'            => 'boolean',
            'additional-content' => 'file',
            'timeout'            => 'integer',
            'no-category'        => 'list',
            'scan-homedirs'      => 'boolean',
            'scan-profiles'      => 'boolean'
        },
        deploy => {
            'disable'            => 'boolean',
            'no-p2p'             => 'boolean',
        },
        wakeonlan => {
            'disable'            => 'boolean',
        },
        netinventory => {
            'disable'              => 'boolean',
            'trunk_pvid'           => 'integer',
            'aggregation_as_trunk' => 'boolean',
        },
        netdiscovery => {
            'disable'            => 'boolean',
        },
        collect => {
            'disable'            => 'boolean',
        },
};

my $deprecated = {
    _ => {
        'html' => {
            message => 'process the result with provided XSLT stylesheet if needed'
        },
        'force' => {
            message => 'use dedicated fusioninventory-inventory executable'
        },
        'local' => {
            message => 'use dedicated fusioninventory-inventory executable'
        },
        'no-task' => {
            message => "use '<module>/disable' options instead",
            new => sub {
                my ($self, $value) = @_;
                foreach my $module (split(/,/, $value)) {
                    $self->{$module}->{disable} = 1;
                }
            }
        },
        'delaytime' => {
            message => 'no more used'
        },
        'lazy' => {
            message => 'use --lazy command-line option if needed'
        },
        'color' => {
            message => 'color is now automatically used if relevant'
        },
        'debug' => {
            message => "use 'logger/debug' option instead",
            new => sub {
                my ($self, $value) = @_;
                $self->{logger}->{verbosity} = $value + 3;
            }
        },
        'no-httpd' => {
            message => "use 'httpd/disable' option instead",
            new     => { section => 'httpd',  option => 'disable' },
        },
        'httpd-ip' => {
            message => "use 'httpd/ip' option instead",
            new     => { section => 'httpd',  option => 'ip' },
        },
        'httpd-port' => {
            message => "use 'httpd/port' option instead",
            new     => { section => 'httpd',  option => 'port' },
        },
        'httpd-trust' => {
            message => "use 'httpd/trust' option instead",
            new     => { section => 'httpd',  option => 'trust' },
        },
        'user' => {
            message => "use 'http/user' option instead",
            new     => { section => 'http',  option => 'user' },
        },
        'password' => {
            message => "use 'http/password' option instead",
            new     => { section => 'http',  option => 'password' },
        },
        'proxy' => {
            message => "use 'http/proxy' option instead",
            new     => { section => 'http',  option => 'proxy' },
        },
        'timeout' => {
            message => "use 'http/timeout' option instead",
            new     => { section => 'http',  option => 'timeout' },
        },
        'no-ssl-check' => {
            message => "use 'http/no-ssl-check' option instead",
            new     => { section => 'http',  option => 'no-ssl-check' },
        },
        'ca-cert-file' => {
            message => "use 'http/ca-cert-file' option instead",
            new     => { section => 'http',  option => 'ca-cert-file' },
        },
        'ca-cert-dir' => {
            message => "use 'http/ca-cert-dir' option instead",
            new     => { section => 'http',  option => 'ca-cert-dir' },
        },
        'logger' => {
            message => "use 'logger/backends' option instead",
            new     => { section => 'logger',  option => 'backends' },
        },
        'logfile' => {
            message => "use 'logger/logfile' option instead",
            new     => { section => 'logger',  option => 'logfile' },
        },
        'logfile-maxsize' => {
            message => "use 'logger/logfile-maxsize' option instead",
            new     => { section => 'logger',  option => 'logfile-maxsize' },
        },
        'logfacility' => {
            message => "use 'logger/logfacility' option instead",
            new     => { section => 'logger',  option => 'logfacility' },
        },
        'debug' => {
            message => "use 'logger/debug' option instead",
            new     => { section => 'logger',  option => 'debug' },
        },
        'backend-collect-timeout' => {
            message => "use 'inventory/timeout' option instead",
            new     => { section => 'inventory',  option => 'timeout' },
        },
        'additional-content' => {
            message => "use 'inventory/additional-content' option instead",
            new     => { section => 'inventory',  option => 'additional-content' },
        },
        'scan-profiles' => {
            message => "use 'inventory/scan-profiles' option instead",
            new     => { section => 'inventory',  option => 'scan-profiles' },
        },
        'scan-homedirs' => {
            message => "use 'inventory/scan-homedirs' option instead",
            new     => { section => 'inventory',  option => 'scan-homedirs' },
        },
        'no-category' => {
            message => "use 'inventory/no-category' option instead",
            new     => { section => 'inventory',  option => 'no-category' },
        },
    }
};

sub create {
    my ($class, %params) = @_;

    my $backend = $params{backend} || 'file';

    if ($backend eq 'registry') {
        FusionInventory::Agent::Config::Registry->require();
        return FusionInventory::Agent::Config::Registry->new(
            options => $params{options}
        );
    }

    if ($backend eq 'file') {
        FusionInventory::Agent::Config::File->require();
        return FusionInventory::Agent::Config::File->new(
            file    => $params{file},
            options => $params{options}
        );
    }

    if ($backend eq 'none') {
        FusionInventory::Agent::Config::None->require();
        return FusionInventory::Agent::Config::None->new(
            options => $params{options}
        );
    }

    die "Unknown configuration backend '$backend'\n";
}

sub new {
    my ($class, %params) = @_;

    my $self = {
        _ => {
            'server'             => [],
            'tag'                => undef,
        },
        http => {
            'proxy'              => undef,
            'timeout'            => 30,
            'ca-cert-dir'        => undef,
            'ca-cert-file'       => undef,
            'no-ssl-check'       => 0,
            'user'               => undef,
            'password'           => undef,
        },
        httpd => {
            'disable'            => 0,
            'ip'                 => undef,
            'port'               => 62354,
            'trust'              => [],
        },
        logger => {
            'backend'            => 'Stderr',
            'file'               => undef,
            'facility'           => 'LOG_USER',
            'maxsize'            => undef,
            'verbosity'          => 'info',
        },
        inventory => {
            'disable'            => 0,
            'additional-content' => undef,
            'timeout'            => 30,
            'no-category'        => [],
            'scan-homedirs'      => 0,
            'scan-profiles'      => 0,
        },
        deploy => {
            'disable'            => 0,
            'no-p2p'             => 0,
        },
        wakeonlan => {
            'disable'            => 0,
        },
        netinventory => {
            'disable'              => 0,
            'trunk_pvid'           => 0,
            'aggregation_as_trunk' => 0,
        },
        netdiscovery => {
            'disable'            => 0,
        },
        collect => {
            'disable'            => 0,
        },
    };

    bless $self, $class;

    $self->_apply($self->_load(%params));

    $self->_apply($params{options});

    return $self;
}

sub _apply {
    my ($self, $options) = @_;

    return unless $options;

    foreach my $section (keys %{$options}) {
        if (! exists $self->{$section}) {
            warn "unknown configuration section '$section', skipping\n";
            next;
        }
        foreach my $option (keys %{$options->{$section}}) {
            my $value = $options->{$section}->{$option};
            next unless defined $value && $value ne '';

            my $type = $valid->{$section}->{$option};
            if ($type) {
                $self->_handle_valid_option($section, $option, $value, $type)
            } else {
                my $handler = $deprecated->{$section}->{$option};
                if ($handler) {
                    $self->_handle_deprecated_option($section, $option, $value, $handler)
                } else {
                    $self->_handle_unknown_option($section, $option, $value)
                }
            }
        }
    }
}

sub _handle_deprecated_option {
    my ($self, $section, $option, $value, $handler) = @_;

    # notify user
    warn
        "configuration option '$option' is deprecated, $handler->{message}\n";

    # transfer the value to the new option, if possible
    if ($handler->{new}) {
        if (ref $handler->{new} eq 'HASH') {
            my $new_section = $handler->{new}->{section};
            my $new_option  = $handler->{new}->{option};
            $self->{$new_section}->{$new_option} = $value;
        }
        if (ref $handler->{new} eq 'CODE') {
            $handler->{new}->($self, $value);
        }
    }
}

sub _handle_unknown_option {
    my ($self, $section, $option) = @_;

    warn
        "unknown configuration option '$option' in section '$section', ".
        "skipping\n";
}

sub _handle_valid_option {
    my ($self, $section, $option, $value, $type) = @_;

         if ($type eq 'string') {
        $self->{$section}->{$option} = $value;
    } elsif ($type eq 'integer') {
        warn
            "invalid value '$value' for configuration option '$option': " .
            "not an integer\n" if $value !~ /^\d+$/;
        $self->{$section}->{$option} = $value;
    } elsif ($type eq 'boolean') {
        $self->{$section}->{$option} =
            $value eq 'true'  ? 1      :
            $value eq 'false' ? 0      :
                                $value ;
    } elsif ($type eq 'path') {
        $self->{$section}->{$option} = File::Spec->rel2abs($value);
    } elsif ($type eq 'list') {
        $self->{$section}->{$option} =
            ref $value ? $value : [ split(/,/, $value) ];
    }
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
