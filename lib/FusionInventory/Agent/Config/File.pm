package FusionInventory::Agent::Config::File;

use strict;
use warnings;
use base 'FusionInventory::Agent::Config';

use Config::Tiny;
use English qw(-no_match_vars);

sub _load {
    my ($self, %params) = @_;

    my $file = $params{file};
    die "no configuration file" unless $file;
    die "non-existing file $file" unless -f $file;
    die "non-readable file $file" unless -r $file;

    my $config = Config::Tiny->read($file);
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
