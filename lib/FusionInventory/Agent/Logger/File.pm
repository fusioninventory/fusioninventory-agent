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
        maxsize => $params{maxsize} ?
            $params{maxsize} * 1024 * 1024 : undef
    };

    bless $self, $class;

    return $self;
}

sub addMsg {
    my ($self, $args) = @_;

    my $level = $args->{level};
    my $message = $args->{message};

    return if $message =~ /^$/;

    if ($self->{maxsize}) {
        my $stat = stat($self->{file});
        if ($stat && $stat->size() > $self->{maxsize}) {
            unlink $self->{file}
                or warn "Can't unlink $self->{file}: $ERRNO";
        }
    }

    open my $handle, '>>', $self->{file}
        or warn "Can't open $self->{file}: $ERRNO";

    # get an exclusive lock on log file
    flock($handle, LOCK_EX)
        or die "can't get an exclusive lock on $self->{file}: $ERRNO";

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

=head1 METHODS

=head2 new(%params)

The constructor. The following parameters are allowed, as keys of the %params
hash:

=over

=item I<file>

the file to use

=item I<maxsize>

the maximum size before rotating the file

=back
