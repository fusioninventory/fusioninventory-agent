package FusionInventory::Agent::Target::Server;

use strict;
use warnings;
use base 'FusionInventory::Agent::Target';

use English qw(-no_match_vars);

sub new {
    my ($class, $params) = @_;

    my $dir = $params->{path};
    $dir =~ s/\//_/g;
    # On Windows, we can't have ':' in directory path
    $dir =~ s/:/../g if $OSNAME eq 'MSWin32';

    my $self = $class->SUPER::new(
        {
            %$params,
            dir => $dir
        }
    );

    return $self;
}

sub _getMaxOffset {
    my ($self) = @_;

    return 
        $self->{prologFreq} ? $self->{prologFreq} * 3600 : 
        $self->{delayTime}  ? $self->{delayTime}         : 
                              1                          ;
}

sub getAccountInfo {
    my ($self) = @_;

    return $self->{accountinfo};
}

sub setAccountInfo {
    my ($self, $accountinfo) = @_;

    $self->{accountinfo} = $accountinfo;
    $self->_save();
}

sub setPrologFreq {
    my ($self, $prologFreq) = @_;

    $self->{prologFreq} = $prologFreq;
    $self->_save();
}

sub _load {
    my ($self) = @_;

    my $data = $self->SUPER::_load();
    $self->{accountInfo} = $data->{accountInfo};
    $self->{prologFreq}  = $data->{prologFreq};
}

sub _save {
    my ($self, $data) = @_;

    $data->{prologFreq}  = $self->{prologFreq};
    $data->{accountInfo} = $self->{accountInfo};
    $self->SUPER::_save($data);
}

1;
