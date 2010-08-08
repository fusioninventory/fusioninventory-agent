package FusionInventory::LoggerBackend::File;

use strict;
use warnings;

use English qw(-no_match_vars);

my $handle;

sub new {
    my ($class, $params) = @_;

    my $self = {};
    $self->{config} = $params->{config};
    $self->{logfile} = $self->{config}->{logfile};

    bless $self, $class;

    $self->open();

    return $self;
}

sub open {
    my ($self) = @_;

    open $self->{handle}, '>>', $self->{logfile}
        or warn "Can't open ".$self->{logfile}.": $ERRNO";

}


sub watchSize {
    my ($self) = @_;

    my $config = $self->{config};
    my $handle = $self->{handle};

    return unless $config->{'logfile-maxsize'};

    my $size = (stat($handle))[7];

    if ($size>$config->{'logfile-maxsize'}*1024*1024) {
        close($self->{handle});
        unlink($self->{logfile}) or die "$!!";
        $self->open();
        print $handle "max size reached. log file truncated (".localtime(time).")\n";
    }

}

sub addMsg {
    my ($self, $args) = @_;

    my $level = $args->{level};
    my $message = $args->{message};
    my $handle = $self->{handle};

    return if $message =~ /^$/;

    $self->watchSize();

    print $handle "[".localtime()."][$level] $message\n";
}

sub DESTROY {
    my ($self) = @_;

    close $self->{handle};
}

1;
