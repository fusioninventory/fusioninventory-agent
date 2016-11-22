package FusionInventory::Agent::Version;

use strict;
use warnings;

our $VERSION = "2.3.19-dev";
our $PROVIDER = "FusionInventory";

1;

__END__

=head1 NAME

FusionInventory::Agent::Version - FusionInventory agent version

=head1 DESCRIPTION

This module has the only purpose to simplify the way the FusionInventory agent
is released. This file could be automatically generated and overriden during
packaging.

It permits to re-define agent VERSION and agent PROVIDER during packaging so
any distributor can simplify his distribution process and permit to identify
clearly the origin of the agent.
