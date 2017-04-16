package FusionInventory::Agent::Config::File;

use strict;
use warnings;
use base 'FusionInventory::Agent::Config';

use English qw(-no_match_vars);

sub new {
    my ($class, %params) = @_;

    my $self = $class->SUPER::new(%params);

    $self->{file} = $params{file},

    return $self;
}

sub _load {
    my ($self, %params) = @_;

    if ($self->{file}) {
        die "non-existing file $self->{file}" unless -f $self->{file};
        die "non-readable file $self->{file}" unless -r $self->{file};
    } else {
        die "no configuration file";
    }

    my $handle;
    if (!open $handle, '<', $self->{file}) {
        warn "Config: Failed to open $self->{file}: $ERRNO";
        return;
    }

    while (my $line = <$handle>) {
        $line =~ s/#.+//;
        if ($line =~ /([\w-]+)\s*=\s*(.+)/) {
            my $key = $1;
            my $val = $2;

            # Remove the quotes
            $val =~ s/\s+$//;
            $val =~ s/^'(.*)'$/$1/;
            $val =~ s/^"(.*)"$/$1/;

            $self->{$key} = $val;
        }
    }
    close $handle;
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Config::File - File-based configuration backend

=head1 DESCRIPTION

This is the object used by the agent to store its configuration.
