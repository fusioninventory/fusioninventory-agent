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
        logfile         => $params{config}->{logfile},
        logfile_maxsize => $params{config}->{'logfile-maxsize'} ?
            $params{config}->{'logfile-maxsize'} * 1024 * 1024 : 0
    };
    bless $self, $class;

    return $self;
}

sub addMessage {
    my ($self, %params) = @_;

    my $level = $params{level};
    my $message = $params{message};

    if ($self->{logfile_maxsize}) {
        my $stat = stat($self->{logfile});
        if ($stat && $stat->size() > $self->{logfile_maxsize}) {
            unlink $self->{logfile}
                or warn "Can't unlink $self->{logfile}: $ERRNO";
        }
    }

    my $handle;
    if (open $handle, '>>', $self->{logfile}) {

        # get an exclusive lock on log file
        flock($handle, LOCK_EX)
            or die "can't get an exclusive lock on $self->{logfile}: $ERRNO";

        print {$handle}
            "[". localtime() ."]" .
            "[$level]" .
            " $message\n";

        # closing handle release the lock automatically
        close $handle;
    } else {
        die "can't open $self->{logfile}: $ERRNO";
    }

}

1;
__END__

=head1 NAME

FusionInventory::Agent::Logger::File - A file backend for the logger

=head1 DESCRIPTION

This is a file-based backend for the logger. It supports automatic filesize
limitation.
