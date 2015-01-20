package FusionInventory::Agent::Config;

use strict;
use warnings;

use English qw(-no_match_vars);
use File::Spec;
use UNIVERSAL::require;

my $default = {
    _ => {
        'no-module'          => '',
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
        'no-httpd'           => undef,
        'httpd-ip'           => undef,
        'httpd-port'         => 62354,
        'httpd-trust'        => '',
    },
    logger => {
        'logger'             => 'Stderr',
        'logfile'            => undef,
        'logfacility'        => 'LOG_USER',
        'logfile-maxsize'    => undef,
        'debug'              => 0,
    },
    inventory => {
        'additional-content' => undef,
        'execution-timeout'  => 180,
        'no-category'        => '',
        'scan-homedirs'      => undef,
        'scan-profiles'      => undef,
    },
    deploy => {
        'no-p2p'             => undef,
    }
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
            message => "use 'no-module' option instead",
            new     => 'no-module'
        },
        'delaytime' => {
            message => 'no more used'
        },
        'lazy' => {
            message => 'use --lazy command-line option if needed'
        },
        'backend-collect-timeout' => {
            message => 'use execution-timeout option instead',
            new     => 'execution-timeout'
        },
        'color' => {
            message => 'color is now automatically used if relevant'
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

    $self->_load(%params);

    $self->_loadUserParams($params{options});

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

sub _loadUserParams {
    my ($self, $params) = @_;

    foreach my $section (keys %{$params}) {
        foreach my $key (keys %{$params->{$section}}) {
            my $value = $params->{$section}->{$key};
            next unless defined $value;
            $self->{$section}->{$key} = $value;
        }
    }
}

sub _checkContent {
    my ($self) = @_;

    # check for unknown and deprecated options
    foreach my $section (keys %{$self}) {
        foreach my $key (keys %{$self->{$section}}) {
        next if exists $default->{$section} && exists $default->{$section}->{$key};

        if (exists $deprecated->{$section}->{$key}) {
            my $handler = $deprecated->{$section}->{$key};

            # notify user of deprecation
            warn "the '$key' option is deprecated, $handler->{message}\n";

            # transfer the value to the new option, if possible
            if ($handler->{new}) {
                if (ref $handler->{new} eq 'HASH') {
                    # old boolean option replaced by new non-boolean options
                    foreach my $new (keys %{$handler->{new}}) {
                        my $value = $handler->{new}->{$new};
                        if ($value =~ /^\+(\S+)/) {
                            # multiple values: add it to exiting one
                            $self->{$new} = $self->{$new} ?
                                $self->{$new} . ',' . $1 : $1;
                        } else {
                            # unique value: replace exiting value
                            $self->{$new} = $value;
                        }
                    }
                } elsif (ref $handler->{new} eq 'ARRAY') {
                    # old boolean option replaced by new boolean options
                    foreach my $new (@{$handler->{new}}) {
                        $self->{$section}->{$new} = $self->{$section}->{$key};
                    }
                } else {
                    # old non-boolean option replaced by new option
                    $self->{$section}->{$handler->{new}} = $self->{$section}->{$key};
                }
            }
        } else {
            warn "unknown configuration option '$key' in section '$section'";
        }

        delete $self->{$section}->{$key};
        }
    }

    # a logfile options implies a file logger backend
    if ($self->{logger}->{logfile}) {
        $self->{logger}->{logger} .= ',File';
    }

    # ca-cert-file and ca-cert-dir are antagonists
    if ($self->{http}->{'ca-cert-file'} && $self->{http}->{'ca-cert-dir'}) {
        die "use either 'ca-cert-file' or 'ca-cert-dir' option, not both\n";
    }

    # logger backend without a logfile isn't enoguh
    if ($self->{logger}->{'logger'} =~ /file/i && ! $self->{logger}->{'logfile'}) {
        die "usage of 'file' logger backend makes 'logfile' option mandatory\n";
    }

    # multi-values options, the default separator is a ','
    $self->{_}->{server}      = [split(/,/, $self->{_}->{server})];
    $self->{_}->{'no-module'} = [split(/,/, $self->{_}->{'no-module'})];
    $self->{logger}->{logger} = [split(/,/, $self->{logger}->{logger})];
    $self->{httpd}->{'httpd-trust'}   = [split(/,/, $self->{httpd}->{'httpd-trust'})];
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
