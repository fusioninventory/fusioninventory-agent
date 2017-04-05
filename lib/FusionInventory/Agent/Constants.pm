package FusionInventory::Agent::Constants;

use strict;
use warnings;

use base 'Exporter';

use constant FIREWALL_STATUS_ON => 'on';
use constant FIREWALL_STATUS_OFF => 'off';

our @EXPORT = qw(
    FIREWALL_STATUS_OFF
    FIREWALL_STATUS_ON
);

1;
