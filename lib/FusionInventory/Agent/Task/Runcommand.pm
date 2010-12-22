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

    my $storage = $self->{storage};

    foreach (@{$storage->{done}}) {
	return 1 if $_ eq $order->{id};
    }

    return 0;
}

sub main {
    my $self = FusionInventory::Agent::Task::Runcommand->new();

    my $storage = $self->{storage};
    # The list of processed packages
    if (!$storage->{done}) {
	$storage->{done} = [];
    }

    my @order;
    foreach my $option (@{$self->{prologresp}->{parsedcontent}->{OPTION}}) {
	next unless $option->{NAME} eq 'RUNCOMMAND';
	print Dumper($option);


	# With XML::Simple, depending on the number of XML entry, a key
	# can either by a array or a scalar
	if (defined($option->{PARAM})) {
	    my $tmp = $option->{PARAM};
	    if (ref($tmp) eq 'ARRAY' && !$self->orderIsDone(@$tmp)) {
		@order = @$tmp;
	    } elsif ($self->orderIsDone($tmp)){
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

    
}

1;
