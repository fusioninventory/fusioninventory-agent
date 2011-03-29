package FusionInventory::Agent::Logger::Stderr;

use strict;
use warnings;

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

    return if $message =~ /^$/;

    # if STDERR has been hijacked, I take its saved ref
    my $stderr;
    if (exists ($self->{savedstderr})) {
        $stderr = $self->{savedstderr};
    } else {
        $stderr = \*STDERR;
    }

    if ($self->{color} && $OSNAME ne 'MSWin32') {
        if ($level eq 'error') {
            print $stderr  "\033[1;35m[$level]";
        } elsif ($level eq 'fault') {
            print $stderr  "\033[1;31m[$level]";
        } elsif ($level eq 'info') {
            print $stderr  "\033[1;34m[$level]\033[0m";
        } elsif ($level eq 'debug') {
            print $stderr  "\033[1;1m[$level]\033[0m";
        }
        print $stderr  " $message";
        print "\033[0m\n";
    } else {
        print $stderr "[$level] $message\n";
    }

}

1;
