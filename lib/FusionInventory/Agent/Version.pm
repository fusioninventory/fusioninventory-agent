package FusionInventory::Agent::Version;

use strict;
use warnings;

# For CPAN releases right versions ordering, as 2.6 is evaluated to v2.600 by
# version module for versions comparaison, 2.6 following versions should be:
# - kept as major.minor (2.7, 2.8, ...)
# - or use the "alpha" notation to set revision: 2.6_01 is evaluated to v2.601
our $VERSION = "2.6";
our $PROVIDER = "FusionInventory";
our $COMMENTS = [];

1;

__END__

=head1 NAME

FusionInventory::Agent::Version - FusionInventory agent version

=head1 DESCRIPTION

This module has the only purpose to simplify the way the FusionInventory agent
is released. This file could be automatically generated and overridden during
packaging.

It permits to re-define agent VERSION and agent PROVIDER during packaging so
any distributor can simplify his distribution process and permit to identify
clearly the origin of the agent.

It also permits to put build comments in $COMMENTS. Each array ref element will
be reported in putput while using on --version for commands. This will be seen
in logs.
The idea is to authorize the provider to put useful information needed while
agent issue is reported.
One very useful information should be first defined like in that example:

our $COMMENTS = [
    "Based on FusionInventory Agent v2.5.1"
];
