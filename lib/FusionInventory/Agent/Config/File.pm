package FusionInventory::Agent::Config::File;

use strict;
use warnings;

use base qw(FusionInventory::Agent::Config::Backend);

use English qw(-no_match_vars);

sub new {
    my ($class, %params) = @_;

    my $file =
        $params{file}      ? $params{file}                     :
        $params{directory} ? $params{directory} . '/agent.cfg' :
                            'agent.cfg';

    if ($file) {
        die "non-existing file $file" unless -f $file;
        die "non-readable file $file" unless -r $file;
    } else {
        die "no configuration file";
    }

    my $self = {
        file => $file
    };
    bless $self, $class;

    return $self;
}

sub getValues {
    my ($self) = @_;

    my $handle;
    if (!open $handle, '<', $self->{file}) {
        warn "Config: Failed to open $self->{file}: $ERRNO";
        return;
    }

    my %values;

    while (my $line = <$handle>) {
        $line =~ s/#.+//;
        if ($line =~ /([\w-]+)\s*=\s*(.+)/) {
            my $key = $1;
            my $value = $2;

            # remove the quotes
            $value =~ s/\s+$//;
            $value =~ s/^'(.*)'$/$1/;
            $value =~ s/^"(.*)"$/$1/;

            $values{$key} = $value;
        }
    }
    close $handle;

    return %values;
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Config::File - File-based configuration backend

=head1 DESCRIPTION

This is a plain old configuration file backend.
