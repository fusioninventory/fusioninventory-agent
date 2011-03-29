package FusionInventory::Agent::Logger::Stderr;

use strict;
use warnings;
use base 'FusionInventory::Agent::Logger::Backend';

use English qw(-no_match_vars);

sub new {
    my ($class, $params) = @_;

    my $self = {
        color => $params->{config}->{color},
    };
    bless $self, $class;

    return $self;
}

sub addMsg {
    my ($self, $args) = @_;

    my $level = $args->{level};
    my $message = $args->{message};

    my $format;
    if ($self->{color}) {
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
