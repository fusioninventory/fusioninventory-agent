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

sub getAccountInfo {
    my ($self) = @_;

    return $self->{accountInfo};
}

sub setAccountInfo {
    my ($self, $accountInfo) = @_;

    return if $self->_isSameHash($accountInfo, $self->{accountInfo});

    $self->{accountInfo} = $accountInfo;
    $self->_save();
}

sub _load {
    my ($self) = @_;

    my $data = $self->SUPER::_load();
    $self->{accountInfo} = $data->{accountInfo} if $data->{accountInfo};
}

sub _save {
    my ($self, $data) = @_;

    $data->{accountInfo} = $self->{accountInfo};
    $self->SUPER::_save($data);
}

1;
