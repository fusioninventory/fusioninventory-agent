package FusionInventory::Agent::Config;

use strict;
use warnings;

use Clone qw(clone);
use English qw(-no_match_vars);
use File::Spec;
use UNIVERSAL::require;

my $defaults = {
    'ca-cert-dir'             => '',
    'ca-cert-file'            => '',
    'conf-file'               => '',
    'color'                   => 0,
    'daemon'                  => 0,
    'no-fork'                 => 0,
    'delaytime'               => 3600, # max delay time (seconds)
    'debug'                   => 0,
    'force'                   => 0,
    'help'                    => 0,
    'info'                    => 1,
    'lazy'                    => 0,
    'local'                   => '',
    'logger'                  => undef,
    'logfile'                 => '',
    'logfile-maxsize'         => 0,
    'logfacility'             => 'LOG_USER',
    'no-www'                  => 0,
    'no-ssl-check'            => 0,
    'password'                => '',
    'proxy'                   => '',
    'server'                  => undef,
    'service'                 => 0,
    'stdout'                  => 0,
    'tag'                     => '',
    'user'                    => '',
    'version'                 => 0,
    'wait'                    => '',
    'www-ip'                  => undef,
    'www-port'                => '62354',
    'www-trust-localhost'     => 1
};

sub new {
    my ($class, %params) = @_;

    my $backend_class = $OSNAME eq 'MSWin32' ?
        'FusionInventory::Agent::Config::Registry' :
        'FusionInventory::Agent::Config::File' ;

    $backend_class->require();
    my $backend = $backend_class->new(%params);

    my $values = clone($defaults);
    $backend->load($values);
    _check($values);

    my $self = {
        values => $values
    };
    bless $self, $class;

    return $self;
}

sub getValue {
    my ($self, $name) = @_;

    return $self->{values}->{$name};
}

sub getBlock {
    my ($self, $name) = @_;

    my $block;
    foreach my $key (keys %{$self->{values}}) {
        next unless $key =~ /^$name\.(\S+)/;
        $block->{$1} = $self->{values}->{$key};
    }
    return $block;
}

sub _check {
    my ($values) = @_;

    # if a logfile is defined, add file logger
    if ($values->{logfile}) {
        $values->{logger} .= ',File'
    }

    # multi-valued attributes
    if ($values->{server}) {
        $values->{server} = [
            split(/\s*,\s*/, $values->{server})
        ];
    }

    if ($values->{logger}) {
        my %seen;
        $values->{logger} = [
            grep { !$seen{$_}++ }
            split(/\s*,\s*/, $values->{logger})
        ];
    }

    # We want only canonical path
    foreach my $value (qw/ca-cert-file ca-cert-dir logfile/) {
        next unless $values->{$value};
        $values->{$value} = File::Spec->rel2abs($values->{$value});
    }
}

1;

__END__

=head1 NAME

FusionInventory::Agent::Config - Agent configuration

=head1 DESCRIPTION

This is the object used by the agent to store its configuration.

=head1 METHODS

=head2 new($params)

The constructor. All configuration parameters can be passed.
