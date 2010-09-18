package FusionInventory::LoggerBackend::File;

use strict;
use warnings;

use English qw(-no_match_vars);

my $handle;

sub new {
    my ($class, $params) = @_;

    my $self = {
        logfile         => $params->{config}->{'logfile'},
        logfile_maxsize => $params->{config}->{'logfile-maxsize'}
    };

    bless $self, $class;

    $self->_open();

    return $self;
}

sub _open {
    my ($self) = @_;

    open $self->{handle}, '>>', $self->{logfile}
        or warn "Can't open $self->{logfile}: $ERRNO";
}


sub _watchSize {
    my ($self) = @_;

    return unless $self->{logfile_maxsize};

    my $size = (stat($self->{handle}))[7];

    if ($size > $self->{logfile_maxsize} * 1024 * 1024) {
        close $self->{handle};
        unlink($self->{logfile}) or die "$!!";
        $self->_open();
        print {$self->{handle}}
            "[".localtime()."]" .
            " max size reached, log file truncated\n";
    }

}

sub addMsg {
    my ($self, $args) = @_;

    my $level = $args->{level};
    my $message = $args->{message};
    my $handle = $self->{handle};

    return if $message =~ /^$/;

    $self->_watchSize();

    print {$self->{handle}}
        "[". localtime() ."]" .
        "[$level]" .
        " $message\n";
}

sub DESTROY {
    my ($self) = @_;

    close $self->{handle};
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

The constructor. The following named parameters are allowed:

=over

=item config (mandatory)

=back

=head2 addMsg($params)

Add a log message, with a specific level. The following arguments are allowed:

=over

=item level (mandatory)

Can be one of:

=over

=item debug

=item info

=item error

=item fault

=back

=item message (mandatory)

=back
