package FusionInventory::LoggerBackend::File;

use strict;
use warnings;

use English qw(-no_match_vars);

sub new {
    my ($class, $params) = @_;

    my $self = {};
    $self->{config} = $params->{config};
    $self->{logfile} = $self->{config}->{logfile};

    bless $self, $class;

    return $self;
}

sub logFileIsFull {
    my ($self) = @_;

    my @stat = stat($self->{logfile});
    return unless @stat;

    my $size = $stat[7];
    if ($size>$self->{config}{'logfile-maxsize'}*1024*1024) {
        return 1;
    }

    return;
}

sub addMsg {
    my ($self, $args) = @_;

    my $level = $args->{level};
    my $message = $args->{message};

    return if $message =~ /^$/;

    unlink($self->{logfile}) if $self->logFileIsFull();

    my $handle;
    if (open $handle, '>>', $self->{config}->{logfile}) {
        print $handle "[".localtime()."][$level] $message\n";
        close $handle;
    } else {
        warn "Can't open $self->{config}->{logfile}: $ERRNO";
    }


}

1;
