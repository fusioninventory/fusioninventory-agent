package FusionInventory::Agent::Logger::File;

use strict;
use warnings;

use Config;
use English qw(-no_match_vars);

BEGIN {
    # threads and threads::shared must be load before
    # $lock is initialized
    if ($Config{usethreads}) {
        eval {
            require threads;
            require threads::shared;
        };
        if ($EVAL_ERROR) {
            print "[error]Failed to use threads!\n"; 
        }
    }
}

my $lock :shared;

sub new {
    my ($class, $params) = @_;

    my $self = {
        logfile         => $params->{config}->{logfile},
        logfile_maxsize => $params->{config}->{'logfile-maxsize'}
    };
    bless $self, $class;

    return $self;
}

sub logFileIsFull {
    my ($self) = @_;

    my @stat = stat($self->{logfile});
    return unless @stat;

    my $size = $stat[7];
    if ($size > $self->{logfile_maxsize}*1024*1024) {
        return 1;
    }

    return;
}

sub addMsg {
    my ($self, $args) = @_;

    lock($lock);
    my $level = $args->{level};
    my $message = $args->{message};

    if ($self->{logfile_maxsize} && $self->logFileIsFull()) {
        unlink $self->{logfile} or warn "Can't ".
        "unlink ".$self->{logfile}." $!\n";
    }

    my $handle;
    if (open $handle, '>>', $self->{logfile}) {
        print $handle "[".localtime()."][$level] $message\n";
        close $handle;
    } else {
        warn "Can't open $self->{logfile}: $ERRNO";
    }


}

1;
