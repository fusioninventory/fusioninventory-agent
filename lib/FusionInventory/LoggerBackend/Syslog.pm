package FusionInventory::LoggerBackend::Syslog;

use strict;
use warnings;
# Not tested yet!
use Sys::Syslog qw( :DEFAULT setlogsock);

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

    return if $message =~ /^$/;

    syslog('info', $message);
}

sub DESTROY {
    closelog();
}


1;
