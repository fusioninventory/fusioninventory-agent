package FusionInventory::LoggerBackend::File;

use strict;
use warnings;

use English qw(-no_match_vars);

sub new {
    my ($class, $params) = @_;

    open my $handle, '>>', $params->{config}->{logfile},
        or warn "Can't open $params->{config}->{logfile}: $ERRNO";

    my $self = {
        handle => $handle
    };
    bless $self, $class;

    return $self;
}

sub addMsg {
    my ($self, $args) = @_;

    my $level = $args->{level};
    my $message = $args->{message};

    print {$self->{handle}} "[".localtime()."][$level] $message\n";
}

sub DESTROY {
    my ($self) = @_;

    close $self->{handle};
}

1;
