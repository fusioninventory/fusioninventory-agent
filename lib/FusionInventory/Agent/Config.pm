package FusionInventory::Agent::Config;

use strict;
use warnings;

use English qw(-no_match_vars);
use File::Spec;
use UNIVERSAL::require;

my $defaults = {
    'logger.backends'      => 'Stderr',
    'logger.file'          => '',
    'logger.file-maxsize'  => 0,
    'logger.facility'      => 'LOG_USER',
    'logger.color'         => 0,
    'www.ip'               => undef,
    'www.port'             => 62354,
    'www.trust-localhost'  => 1,
};

sub new {
    my ($class, %params) = @_;

    my $backend_class = $OSNAME eq 'MSWin32' ?
        'FusionInventory::Agent::Config::Registry' :
        'FusionInventory::Agent::Config::File' ;

    $backend_class->require();
    my $backend = $backend_class->new(%params);

    my $values;
    foreach my $key (keys %$defaults) {
        $values->{$key} = $defaults->{$key};
    }
    $backend->load($values);

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
