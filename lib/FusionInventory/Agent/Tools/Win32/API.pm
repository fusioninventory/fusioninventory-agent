package FusionInventory::Agent::Tools::Win32::API;

use warnings;
use strict;

use English qw(-no_match_vars);
use UNIVERSAL::require;

use FusionInventory::Agent::Logger;

sub new {
    my ($class, %params) = @_;

    my $self = {
        logger  => $params{logger} || FusionInventory::Agent::Logger->new()
    };
    bless $self, $class;

    # Load Win32::API as late as possible
    Win32::API->require() or return;

    my $api;
    eval {
        $api = Win32::API->new(@{$params{win32api}});
    };
    $self->{logger}->debug2("win32 api load failure: $EVAL_ERROR") if $EVAL_ERROR;

    $self->{_api} = $api if $api;

    return $self;
}

sub Call {
    my $self = shift;

    return unless $self->{_api};

    my $ret;
    eval {
        $ret = $self->{_api}->Call(@_);
    };
    $self->{logger}->debug2("win32 api call failure: $EVAL_ERROR") if $EVAL_ERROR;

    return $ret;
}

1;
