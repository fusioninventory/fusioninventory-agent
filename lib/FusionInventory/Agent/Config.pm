package FusionInventory::Agent::Config;

use strict;
use warnings;

use English qw(-no_match_vars);
use File::Spec;
use UNIVERSAL::require;

my $default = {
    _ => {
        'server'             => '',
        'tag'                => undef,
    },
    http => {
        'proxy'              => undef,
        'timeout'            => 180,
        'ca-cert-dir'        => undef,
        'ca-cert-file'       => undef,
        'no-ssl-check'       => undef,
        'user'               => undef,
        'password'           => undef,
    },
    httpd => {
        'disable'            => undef,
        'ip'                 => undef,
        'port'               => 62354,
        'trust'              => '',
    },
    logger => {
        'backends'           => 'Stderr',
        'logfile'            => undef,
        'logfacility'        => 'LOG_USER',
        'logfile-maxsize'    => undef,
        'debug'              => 0,
    },
    inventory => {
        'disable'            => 0,
        'additional-content' => undef,
        'timeout'            => 180,
        'no-category'        => '',
        'scan-homedirs'      => undef,
        'scan-profiles'      => undef,
    },
    deploy => {
        'disable'            => 0,
        'no-p2p'             => undef,
    },
    wakeonlan => {
        'disable'            => 0,
    },
    netinventory => {
        'disable'            => 0,
    },
    netdiscovery => {
        'disable'            => 0,
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

    my $self = {};
    bless $self, $class;

    $self->_loadDefaults();

    $self->_apply($self->_load(%params));

    $self->_apply($params{options});

    $self->_checkContent();

    return $self;
}

sub _loadDefaults {
    my ($self) = @_;

    foreach my $section (keys %{$default}) {
        foreach my $key (keys %{$default->{$section}}) {
            $self->{$section}->{$key} = $default->{$section}->{$key};
        }
    }
}

sub _apply {
    my ($self, $options) = @_;

    return unless $options;

    foreach my $section (keys %{$options}) {
        if (! exists $default->{$section}) {
            warn "unknown configuration section '$section', skipping\n";
            next;
        }
        foreach my $option (keys %{$options->{$section}}) {
            my $value = $options->{$section}->{$option};
            next unless defined $value;

            # deprecated option
            if (exists $deprecated->{$section}->{$option}) {
                my $handler = $deprecated->{$section}->{$option};

                # notify user
                warn
                    "configuration option '$option' is deprecated, " .
                    $handler->{message} . "\n";

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
                next;
            }

            # unknown option
            if (! exists $default->{$section}->{$option}) {
                warn
                    "unknown configuration option '$option' in " .
                    "section '$section', skipping\n";
                next;
            }

            # option
            $self->{$section}->{$option} = $value;
        }
    }
}

sub _checkContent {
    my ($self) = @_;

    # a logfile options implies a file logger backend
    if ($self->{logger}->{logfile}) {
        $self->{logger}->{logger} .= ',File';
    }

    # ca-cert-file and ca-cert-dir are antagonists
    if ($self->{http}->{'ca-cert-file'} && $self->{http}->{'ca-cert-dir'}) {
        die "use either 'ca-cert-file' or 'ca-cert-dir' option, not both\n";
    }

    # logger backend without a logfile isn't enoguh
    if ($self->{logger}->{backends} =~ /file/i && ! $self->{logger}->{'logfile'}) {
        die "usage of 'file' logger backend makes 'logfile' option mandatory\n";
    }

    # multi-values options, the default separator is a ','
    $self->{_}->{server}      = [split(/,/, $self->{_}->{server})];
    $self->{logger}->{backends} = [split(/,/, $self->{logger}->{backends})];
    $self->{httpd}->{'trust'}   = [split(/,/, $self->{httpd}->{'trust'})];
    $self->{inventory}->{'no-category'} = [split(/,/, $self->{inventory}->{'no-category'})];

    # files location
    $self->{http}->{'ca-cert-file'} =
        File::Spec->rel2abs($self->{http}->{'ca-cert-file'})
        if $self->{http}->{'ca-cert-file'};
    $self->{http}->{'ca-cert-dir'} =
        File::Spec->rel2abs($self->{http}->{'ca-cert-dir'})
        if $self->{http}->{'ca-cert-dir'};
    $self->{logger}->{'logfile'} =
        File::Spec->rel2abs($self->{logger}->{'logfile'})
        if $self->{logger}->{'logfile'};
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
