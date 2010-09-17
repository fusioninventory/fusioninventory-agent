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

    my $logger = $self->{logger};
    my $config = $self->{config};


    my $storage = $self->{storage};
    my $data = $storage->restore();

    if ($data->{nextRunDate}) {
        $logger->debug (
            "[$self->{path}] Next server contact planned for ".
            localtime($data->{nextRunDate})
        );
        ${$self->{nextRunDate}} = $data->{nextRunDate};
    }

    $self->{accountinfo} = $data->{accountinfo};

    return $self;

}

sub getAccountInfo {
    my ($self) = @_;

    return $self->{accountinfo};
}

sub setAccountInfo {
    my ($self, $accountinfo) = @_;

    return $self->{accountinfo} = $accountinfo;
    $self->_save();
}

sub setPrologFreq {
    my ($self, $prologFreq) = @_;

    my $logger = $self->{logger};

    return unless $prologFreq;

    if ($self->{prologFreq}) {
        return if $self->{prologFreq} eq $prologFreq;
        $logger->info(
            "PROLOG_FREQ has changed since last process ". 
            "(old=$self->{myData}{prologFreq},new=$prologFreq)"
        );
    } else {
        $logger->info("PROLOG_FREQ has been set: $prologFreq");
    }

    $self->{prologFreq} = $prologFreq;

    $self->_save();
}

sub _save {
    my ($self, $prologFreq) = @_;

    $self->{storage}->save({ data => {
        prologFreq => $self->{prologFreq},
        accountInfo => $self->{accountInfo},
        nextRunDate => $self->{nextRunDate}
    }});
}

1;
