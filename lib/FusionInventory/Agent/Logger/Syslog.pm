package FusionInventory::Agent::Logger::Syslog;

use strict;
use warnings;

use Sys::Syslog qw(:standard :macros);

my %syslog_levels = (
    fault => LOG_ERR,
    error => LOG_WARNING,
    info  => LOG_INFO,
    debug => LOG_DEBUG
);

sub new {
    my ($class, $params) = @_;

    my $self = {};
    bless $self, $class;

    openlog("fusinv-agent", 'cons,pid', $params->{config}->{logfacility});

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
