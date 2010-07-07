package FusionInventory::LoggerBackend::File;

use strict;
use warnings;

use English qw(-no_match_vars);

sub new {
    my ($class, $params) = @_;

    my $logfile = 
        $params->{config}->{logdir} .
        '/' .
        $params->{config}->{logfile};

    open my $handle, '>>', $logfile
        or warn "Can't open $logfile: $ERRNO";

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
