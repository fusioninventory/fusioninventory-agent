package FusionInventory::Agent::Logger::Syslog;

use strict;
use warnings;
use base 'FusionInventory::Agent::Logger::Backend';

use Sys::Syslog qw(:standard :macros);

my %syslog_levels = (
    error   => LOG_ERR,
    warning => LOG_WARNING,
    info    => LOG_INFO,
    debug   => LOG_DEBUG,
    debug2   => LOG_DEBUG
);

sub new {
    my ($class, %params) = @_;

    my $self = {};
    bless $self, $class;

    openlog("fusinv-agent", 'cons,pid', $params{config}->{logfacility});

    return $self;
}

sub addMessage {
    my ($self, %params) = @_;

    my $level = $params{level};
    my $message = $params{message};

    syslog($syslog_levels{$level}, $message);
}

sub DESTROY {
    closelog();
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Logger::Syslog - A syslog backend for the logger

=head1 DESCRIPTION

This is a syslog-based backend for the logger.

=head1 METHODS

=head2 new(%params)

The constructor. The following parameters are allowed, as keys of the %params
hash:

=over

=item I<facility>

the syslog facility to use (default: LOG_USER)

=back
