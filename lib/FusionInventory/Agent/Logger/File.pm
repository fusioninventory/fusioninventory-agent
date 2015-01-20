package FusionInventory::Agent::Logger::File;

use strict;
use warnings;
use base 'FusionInventory::Agent::Logger::Backend';

use English qw(-no_match_vars);
use Fcntl qw(:flock);
use File::stat;

sub new {
    my ($class, %params) = @_;

    my $self = {
        file    => $params{file},
        maxsize => $params{maxsize} ? $params{maxsize} * 1024 * 1024 : 0
    };
    bless $self, $class;

    return $self;
}

sub addMessage {
    my ($self, %params) = @_;

    my $level = $params{level};
    my $message = $params{message};

    my $handle;
    if ($self->{maxsize}) {
        my $stat = stat($self->{file});
        if ($stat && $stat->size() > $self->{maxsize}) {
            if (!open $handle, '>', $self->{file}) {
                warn "Can't open $self->{file}: $ERRNO";
                return;
            }
        }
    }

    if (!$handle && !open $handle, '>>', $self->{file}) {
        warn "can't open $self->{file}: $ERRNO";
        return;
    }

    my $locked;
    my $retryTill = time + 60;

    while ($retryTill > time && !$locked) {
        ## no critic (ProhibitBitwise)
        # get an exclusive lock on log file
        $locked = 1 if flock($handle, LOCK_EX|LOCK_NB);
    }

    if (!$locked) {
        die "can't get an exclusive lock on $self->{file}: $ERRNO";
    }

    print {$handle}
        "[". localtime() ."]" .
        "[$level]" .
        " $message\n";

    # closing handle release the lock automatically
    close $handle;

}

1;
__END__

=head1 NAME

FusionInventory::Agent::Logger::File - A file backend for the logger

=head1 DESCRIPTION

This is a file-based backend for the logger. It supports automatic filesize
limitation.
