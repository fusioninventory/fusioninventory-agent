package FusionInventory::Agent::Logger::Backend;

use strict;
use warnings;

1;
__END__

=head1 NAME

FusionInventory::Agent::Logger::Backend - An abstract logger backend

=head1 DESCRIPTION

This is an abstract base classe for logger backends.

=head1 METHODS

=head2 new(%params)

The constructor. See backends documentation for specific parameters.

=head2 addMsg($params)

Add a log message, with a specific level. The following arguments are allowed:

=over

=item I<level>

Can be one of:

=over

=item debug

=item info

=item error

=item fault

=back

=item I<message>

=back
