package FusionInventory::LoggerBackend::File;

use strict;
use warnings;

use English qw(-no_match_vars);
use Fcntl qw(:flock);
use File::stat;

sub new {
    my ($class, $params) = @_;

    my $self = {
        logfile         => $params->{config}->{'logfile'},
        logfile_maxsize => $params->{config}->{'logfile-maxsize'}
    };

    bless $self, $class;

    return $self;
}

sub addMsg {
    my ($self, $args) = @_;

    my $level = $args->{level};
    my $message = $args->{message};

    return if $message =~ /^$/;

    if ($self->{logfile_maxsize}) {
        my $stat = stat($self->{logfile});
        if ($stat->size() > $self->{logfile_maxsize} * 1024 * 1024) {
            unlink $self->{logfile}
                or warn "Can't unlink $self->{logfile}: $ERRNO";
        }
    }

    open my $handle, '>>', $self->{logfile}
        or warn "Can't open $self->{logfile}: $ERRNO";

    # get an exclusive lock on log file
    flock($handle, LOCK_EX)
        or die "can't get an exclusive lock on $self->{logfile}: $ERRNO";

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

FusionInventory::LoggerBackend::File - A file backend for the logger

=head1 DESCRIPTION

This is a file-based backend for the logger. It supports automatic filesize
limitation.

=head1 METHODS

=head2 new($params)

The constructor. The following parameters are allowed, as keys of the $params
hashref:

=over

=item I<config>

the agent configuration object

=back

=head2 addMsg($params)

Add a log message, with a specific level. The following arguments are allowed:

=over

=item I<level>

Can be one of:

=over

=item debug

=item info

=item error

=item fault

=back

=item I<message>

=back
