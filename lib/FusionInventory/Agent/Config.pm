package FusionInventory::Agent::Config;

use strict;
use warnings;

use English qw(-no_match_vars);
use File::Spec;
use Getopt::Long;

use FusionInventory::Agent::Tools;

my $default = {
    'additional-content'      => undef,
    'collect-timeout'         => 180,
    'ca-cert-dir'             => undef,
    'ca-cert-file'            => undef,
    'color'                   => undef,
    'debug'                   => undef,
    'delaytime'               => 3600,
    'force'                   => undef,
    'html'                    => undef,
    'lazy'                    => undef,
    'local'                   => undef,
    'logger'                  => 'Stderr',
    'logfile'                 => undef,
    'logfacility'             => 'LOG_USER',
    'logfile-maxsize'         => undef,
    'no-category'             => [],
    'no-httpd'                => undef,
    'no-ssl-check'            => undef,
    'no-task'                 => [],
    'no-p2p'                  => undef,
    'password'                => undef,
    'proxy'                   => undef,
    'httpd-ip'                => undef,
    'httpd-port'              => 62354,
    'httpd-trust'             => [],
    'scan-homedirs'           => undef,
    'server'                  => undef,
    'tag'                     => undef,
    'timeout'                 => 180,
    'user'                    => undef,
    # deprecated options
    'backend-collect-timeout' => undef,
    # multi-values options that will be converted to array ref
    'httpd-trust'             => "",
    'no-task'                 => "",
    'no-category'             => ""
};

my $deprecated = {
    'backend-collect-timeout' => {
        message => 'use --collect-timeout option instead',
        new     => 'collect-timeout'
    },
};

sub new {
    my ($class, %params) = @_;

    my $self = {};
    bless $self, $class;
    $self->_loadDefaults();

    my $type =
        $params{options}->{'conf-file'} ? 'file'                     :
        $params{options}->{config}      ? $params{options}->{config} :
        $OSNAME eq 'MSWin32'            ? 'registry'                 :
                                          'file';
    my $backend;
    eval {
        $backend = getInstance(
            class => 'FusionInventory::Agent::Config::' . ucfirst($type),
            params => {
                file      => $params{options}->{'conf-file'},
                directory => $params{confdir},
            }
        );
    };
    die "Unable to load configuration backend $type: $EVAL_ERROR\n"
        if $EVAL_ERROR;

    my %values = $backend->getValues();
    foreach my $key (keys %values) {
        if (exists $default->{$key}) {
            $self->{$key} = $values{$key};
        } else {
            warn "unknown configuration directive $key";
        }
    }

    $self->_loadUserParams($params{options});

    $self->_checkContent();

    return $self;
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

    # ca-cert-file and ca-cert-dir are antagonists
    if ($self->{'ca-cert-file'} && $self->{'ca-cert-dir'}) {
        die "use either 'ca-cert-file' or 'ca-cert-dir' option, not both\n";
    }

    # multi-values options, the default separator is a ','
    foreach my $option (qw/
            logger
            local
            server
            httpd-trust
            no-task
            no-category
            /) {

        if ($self->{$option}) {
            $self->{$option} = [split(/,/, $self->{$option})];
        } else {
            $self->{$option} = [];
        }
    }

    # files location
    $self->{'ca-cert-file'} =
        File::Spec->rel2abs($self->{'ca-cert-file'}) if $self->{'ca-cert-file'};
    $self->{'ca-cert-dir'} =
        File::Spec->rel2abs($self->{'ca-cert-dir'}) if $self->{'ca-cert-dir'};
    $self->{'logfile'} =
        File::Spec->rel2abs($self->{'logfile'}) if $self->{'logfile'};
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
