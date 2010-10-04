package FusionInventory::LoggerBackend::Stderr;

use strict;
use warnings;

use English qw(-no_match_vars);

sub new {
    my ($class, $params) = @_;

    my $self = {
        config => $params->{config}
    };
    bless $self, $class;

    return $self;
}

sub addMsg {
    my ($self, $args) = @_;

    my $config = $self->{config};

    my $level = $args->{level};
    my $message = $args->{message};

    my $format;
    if ($config->{color}) {
        if ($level eq 'error') {
            $format = "\033[1;35m[%s] %s\033[0m\n";
        } elsif ($level eq 'fault') {
            $format = "\033[1;31m[%s] %s\033[0m\n";
        } elsif ($level eq 'info') {
            $format = "\033[1;34m[%s]\033[0m %s\n";
        } elsif ($level eq 'debug') {
            $format = "\033[1;1m[%s]\033[0m %s\n";
        }
    } else {
        $format = "[%s] %s\n";
    }

    printf STDERR $format, $level, $message;

}

1;
__END__

=head1 NAME

FusionInventory::LoggerBackend::Stderr - A stderr backend for the logger

=head1 DESCRIPTION

This is a stderr-based backend for the logger. It supports coloring based on
message level on Unix platforms.

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
