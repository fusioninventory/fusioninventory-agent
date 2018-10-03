package FusionInventory::Agent::Logger::Syslog;

use strict;
use warnings;

use parent 'FusionInventory::Agent::Logger::Backend';

use Sys::Syslog qw(:standard :macros);

use FusionInventory::Agent::Version;

my %syslog_levels = (
    error   => LOG_ERR,
    warning => LOG_WARNING,
    info    => LOG_INFO,
    debug   => LOG_DEBUG,
    debug2  => LOG_DEBUG
);

my $syslog_name = lc($FusionInventory::Agent::Version::PROVIDER)."-agent";

sub new {
    my ($class, %params) = @_;

    my $self = {};
    bless $self, $class;

    openlog($syslog_name, 'cons,pid', $params{logfacility} || 'LOG_USER');

    # Fix agent not listening on http port issue when 'syslog' logger is
    # active and Sys::Syslog is too old. Problem seen on CentOS 6.10
    Sys::Syslog::setlogsock('unix') if $Sys::Syslog::VERSION < 0.28 ;

    return $self;
}

sub addMessage {
    my ($self, %params) = @_;

    my $level   = $params{level} || 'info';
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
