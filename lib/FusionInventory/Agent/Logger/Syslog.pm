package FusionInventory::Agent::Logger::Syslog;

use strict;
use warnings;
use base 'FusionInventory::Agent::Logger';

use Sys::Syslog qw(:standard :macros);

my %syslog_levels = (
    error   => LOG_ERR,
    warning => LOG_WARNING,
    info    => LOG_INFO,
    debug   => LOG_DEBUG,
    debu2   => LOG_DEBUG
);

sub new {
    my ($class, %params) = @_;

    my $self = $class->SUPER::new(%params);

    openlog("fusinv-agent", 'cons,pid', $params{facility});

    return $self;
}

sub _log {
    my ($self, %params) = @_;

    my $level   = $params{level} || 'info';
    my $message = $params{message};

    return unless $message;

    chomp($message);

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
