package FusionInventory::LoggerBackend::File;

use strict;
use warnings;

use English qw(-no_match_vars);

my $handle;

sub new {
    my ($class, $params) = @_;

    my $self = {};
    $self->{config} = $params->{config};
    $self->{logfile} = $self->{config}->{logdir}."/".$self->{config}->{logfile};

    open $handle, '>>', $self->{config}->{logfile}
        or warn "Can't open $self->{config}->{logfile}: $ERRNO";

    bless $self, $class;
    return $self;
}

sub addMsg {
    my ($self, $args) = @_;

    my $level = $args->{level};
    my $message = $args->{message};

    return if $message =~ /^$/;

    print $handle "[".localtime()."][$level] $message\n";
}

sub DESTROY {
    close $handle;
}

1;
