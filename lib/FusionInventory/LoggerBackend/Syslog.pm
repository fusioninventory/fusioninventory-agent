package FusionInventory::LoggerBackend::Syslog;

use strict;
use warnings;
# Not tested yet!
use Sys::Syslog qw(:standard :macros);

my %syslog_levels = (
    fault => LOG_CRIT,
    error => LOG_ERR,
    info  => LOG_INFO,
    debug => LOG_DEBUG
);

sub new {
    my ($class, $params) = @_;

    my $self = {};

    openlog("fusinv-agent", 'cons,pid', $params->{config}->{logfacility});

    bless $self, $class;
    return $self;
}

sub addMsg {
    my (undef, $args) = @_;

    my $level = $args->{level};
    my $message = $args->{message};

    syslog($syslog_levels{$level}, $message);
}

sub DESTROY {
    closelog();
}


1;
