package FusionInventory::Agent::Config::File;

use strict;
use warnings;
use base 'FusionInventory::Agent::Config';

use English qw(-no_match_vars);

sub _load {
    my ($self, %params) = @_;

    my $file = $params{file};
    die "no configuration file" unless $file;
    die "non-existing file $file" unless -f $file;
    die "non-readable file $file" unless -r $file;

    my $handle;
    if (!open $handle, '<', $file) {
        warn "Config: Failed to open $file: $ERRNO";
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
