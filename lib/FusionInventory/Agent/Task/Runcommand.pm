package FusionInventory::Agent::Task::Runcommand;

use strict;
use warnings;
use base 'FusionInventory::Agent::Task::Base';

use English qw(-no_match_vars);

use FusionInventory::Agent::AccountInfo;
use FusionInventory::Agent::Config;
use FusionInventory::Agent::Network;
use FusionInventory::Agent::Storage;
use FusionInventory::Agent::XML::Query::SimpleMessage;
use FusionInventory::Agent::XML::Response::Prolog;
use FusionInventory::Logger;

use Data::Dumper;

sub orderIsDone {
    my ($self, $order) = @_;

    my $logger = $self->{logger};

    foreach (@{$self->{myData}->{done}}) {
	$logger->debug("order ".$order->{ID}." is already done, ignored");
	return 1 if $_ eq $order->{ID};
    }

    return 0;
}

sub orderIsValide {
    my ($self, $order) = @_;

    my $logger = $self->{logger};

    if (ref($order) ne 'HASH' || !defined($order->{ID})) {
	$logger->error("order with no ID, ignored");
	return 0;
    }


    return 1;
}

sub main {
    my $self = FusionInventory::Agent::Task::Runcommand->new();

    # The list of processed packages
    if (!$self->{myData}->{done}) {
	$self->{myData}->{done} = [];
    }
    # We only keep the 1000 last entry in the stack
    while (@{$self->{myData}->{done}} > 1000) {
	pop @{$self->{myData}->{done}};
    }

    my @order;
    foreach my $option (@{$self->{prologresp}->{parsedcontent}->{OPTION}}) {
	next unless $option->{NAME} eq 'RUNCOMMAND';


	# With XML::Simple, depending on the number of XML entry, a key
	# can either by a array or a scalar
	if (defined($option->{PARAM})) {
	    my $tmp = $option->{PARAM};
	    if (ref($tmp) eq 'ARRAY' && $self->orderIsValide(@$tmp)) {
		@order = @$tmp;
	    } elsif ($self->orderIsValide($tmp)){
		push @order, $tmp;
	    }
	}

	last;
    }

    foreach (@order) {
	$self->processOrder($_);
    }

    exit(0);
}

sub processOrder {
    my ($self, $order) = @_; 

    print Dumper($order);

    return if $self->orderIsDone($order);

    push @{$self->{myData}->{done}}, $order->{ID};

    print Dumper($self->{myData}->{done});
    $self->{storage}->save({ data => $self->{myData} });
    
}

1;
