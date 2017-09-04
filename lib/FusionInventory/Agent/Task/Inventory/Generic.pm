package FusionInventory::Agent::Task::Inventory::Generic;

use strict;
use warnings;

use English qw(-no_match_vars);
use Net::Domain qw(hostfqdn hostdomain);

sub isEnabled {
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    my $wmiParams = {};
    $wmiParams->{WMIService} = $params{inventory}->{WMIService} ? $params{inventory}->{WMIService} : undef;

    my $fqdn = $wmiParams->{WMIService} ? '' : hostfqdn();
    my $dnsDomain = $wmiParams->{WMIService} ? '' : hostdomain();
    $inventory->setOperatingSystem({
            KERNEL_NAME => $OSNAME,
            FQDN => $fqdn,
            DNS_DOMAIN => $dnsDomain
    });
}

1;
