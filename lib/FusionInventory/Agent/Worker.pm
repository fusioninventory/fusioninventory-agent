package FusionInventory::Agent::Worker;

use strict;
use warnings;
use base qw/FusionInventory::Agent/;


1;

__END__

=head1 NAME

FusionInventory::Worker - Fusion Inventory worker

=head1 DESCRIPTION

A worker object run a single task against a single target.

=head1 METHODS

=head2 new(%params)

The constructor.

=head2 run(%params)

Run the worker.
