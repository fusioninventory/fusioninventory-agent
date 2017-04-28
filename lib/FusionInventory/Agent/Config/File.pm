package FusionInventory::Agent::Config::File;

use strict;
use warnings;
use base 'FusionInventory::Agent::Config';

use Config::Tiny;
use English qw(-no_match_vars);

sub new {
    my ($class, %params) = @_;

    die 'no file parameter' unless $params{file};
    die "non-existing file $params{file}" unless -f $params{file};
    die "non-readable file $params{file}" unless -r $params{file};

    my $self = $class->SUPER::new(%params);

    $self->{file} = $params{file};

    return $self;
}

sub _load {
    my ($self, %params) = @_;

    my $config = Config::Tiny->read($self->{file});
    foreach my $section (keys %{$config}) {
        foreach my $key (keys %{$config->{$section}}) {
            my $value = $config->{$section}->{$key};
            next unless defined $value;
            $self->{$section}->{$key} = $value;
        }
    }
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Config::File - File-based configuration backend

=head1 DESCRIPTION

This is the object used by the agent to store its configuration.
