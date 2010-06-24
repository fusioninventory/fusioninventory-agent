package FusionInventory::LoggerBackend::Stderr;

use strict;
use warnings;

use English qw(-no_match_vars);

sub new {
    my ($class, $params) = @_;

    my $self = {};
    $self->{config} = $params->{config};

    bless $self, $class;
    return $self;
}

sub addMsg {
    my ($self, $args) = @_;

    my $config = $self->{config};

    my $level = $args->{level};
    my $message = $args->{message};

    return if $message =~ /^$/;

    if ($config->{color} && $OSNAME ne 'MSWin32') {
        if ($level eq 'error') {
            print STDERR "\033[1;35m[$level]";
        } elsif ($level eq 'fault') {
            print STDERR "\033[1;31m[$level]";
        } elsif ($level eq 'info') {
            print STDERR "\033[1;34m[$level]\033[0m";
        } elsif ($level eq 'debug') {
            print STDERR "\033[1;1m[$level]\033[0m";
        }
        print STDERR " $message";
        print "\033[0m\n";
    } else {
        print STDERR "[$level] $message\n";
    }

}

1;
