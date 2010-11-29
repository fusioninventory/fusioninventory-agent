package FusionInventory::Agent::Config::File;

use strict;
use warnings;

use Config::Simple;
use English qw(-no_match_vars);

sub new {
    my ($class, %params) = @_;

    my $file = $params{file}      ? $params{file}                     :
               $params{directory} ? $params{directory} . '/agent.cfg' :
                                    undef                             ;

    die "no configuration file" unless $file;
    die "non-existing file $file" unless -f $file;
    die "non-readable file $file" unless -r $file;

    my $self = {
        file => $file
    };
    bless $self, $class;

    return $self;
}

sub load {
    my ($self, $values) = @_;

    Config::Simple->import_from($self->{file}, $values);

    # replace empty arrayrefs with undef
    foreach my $key (keys %$values) {
        next if !ref $values->{$key}; # not a list
        next if @{$values->{$key}};   # not empty
        $values->{$key} = undef;
    }

}

1;

__END__

=head1 NAME

FusionInventory::Agent::Config::File - File-based backend for configuration

=head1 DESCRIPTION

This is the object used by the agent to store its configuration.

=head1 METHODS

=head2 new($params)

The constructor. All configuration parameters can be passed.
