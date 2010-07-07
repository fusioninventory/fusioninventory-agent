package FusionInventory::LoggerBackend::File;

use strict;
use warnings;

use English qw(-no_match_vars);

my $handle;

sub new {
    my ($class, $params) = @_;

    my $logfile = 
        $params->{config}->{logdir} .
        '/' .
        $params->{config}->{logfile};

    my $self = {};
    bless $self, $class;

    open $handle, '>>', $logfile
        or warn "Can't open $logfile: $ERRNO";

    return $self;
}

sub addMsg {
    my ($self, $args) = @_;

    my $level = $args->{level};
    my $message = $args->{message};

    print $handle "[".localtime()."][$level] $message\n";
}

sub DESTROY {
    close $handle;
}

1;
