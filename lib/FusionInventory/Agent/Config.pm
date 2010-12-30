package FusionInventory::Agent::Config;

use strict;
use warnings;

use Clone qw(clone);
use English qw(-no_match_vars);
use File::Spec;
use UNIVERSAL::require;

my $defaults = {
    'target.local'         => '',
    'target.server'        => undef,
    'target.stdout'        => 0,
    'network.ca-cert-dir'  => '',
    'network.ca-cert-file' => '',
    'network.no-ssl-check' => 0,
    'network.user'         => '',
    'network.password'     => '',
    'network.proxy'        => '',
    'logger.backends'      => 'Stderr',
    'logger.file'          => '',
    'logger.file-maxsize'  => 0,
    'logger.facility'      => 'LOG_USER',
    'logger.color'         => 0,
    'www.ip'               => undef,
    'www.port'             => 62354,
    'www.trust-localhost'  => 1,
    'www.no'               => 0,
};

sub new {
    my ($class, %params) = @_;

    my $backend_class = $OSNAME eq 'MSWin32' ?
        'FusionInventory::Agent::Config::Registry' :
        'FusionInventory::Agent::Config::File' ;

    $backend_class->require();
    my $backend = $backend_class->new(%params);

    # TODO: Do we need a new dependency just for this clone() call?
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

sub getValues {
    my ($self, $name) = @_;

    my $value = $self->getValue($name);

    # undefined
    return
        ! defined $value ? ()       :
        ! ref $value     ? ($value) :
                           @$value  ;
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

=head2 new(%params)

The constructor. The following parameters are allowed, as keys of the %params
hash:

=over

=item I<directory>

The directory to use for searching configuration file.

=item I<file>

The configuration file to use.

=back
