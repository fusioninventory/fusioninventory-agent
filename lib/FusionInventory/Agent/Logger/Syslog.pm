package FusionInventory::Agent::Logger::Syslog;

use strict;
use warnings;

use Sys::Syslog qw(:DEFAULT setlogsock);

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

    return if $message =~ /^$/;

    syslog('info', $message);
}

sub DESTROY {
    closelog();
}


1;
