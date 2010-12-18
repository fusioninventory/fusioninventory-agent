package FusionInventory::Agent::Task::Runcommand;

use strict;
use warnings;
use base 'FusionInventory::Agent::Task::Base';

use constant ETH_P_ALL => 0x0003;
use constant PF_PACKET => 17;
use constant SOCK_PACKET => 10;

use English qw(-no_match_vars);
use Socket;

use FusionInventory::Agent::AccountInfo;
use FusionInventory::Agent::Config;
use FusionInventory::Agent::Network;
use FusionInventory::Agent::Storage;
use FusionInventory::Agent::XML::Query::SimpleMessage;
use FusionInventory::Agent::XML::Response::Prolog;
use FusionInventory::Logger;

sub main {
    my $self = FusionInventory::Agent::Task::Runcommand->new();

    my $continue = 0;
    foreach my $option (@{$self->{prologresp}->{parsedcontent}->{OPTION}}) {
	use Data::Dumper;
	print Dumper($option);
    }

    $self->{network} = FusionInventory::Agent::Network->new({
        logger => $self->{logger},
        config => $self->{config},
        target => $self->{target},
    });

    exit(0);
}


1;
