package FusionInventory::Agent::Task::Inventory::IpDiscover::Nmap;

use strict;
use warnings;

use FusionInventory::Agent::Regexp;
use FusionInventory::Agent::Tools;

our $runMeIfTheseChecksFailed = ["FusionInventory::Agent::Task::Inventory::IpDiscover::IpDiscover"];

sub isInventoryEnabled {
    my $params = shift;

    return unless can_run("nmap");

    # warning, nmap output has two lines
    my $version = `nmap -V`;
    my ($major, $minor) = $version =~ /^Nmap version (\d+)\.(\d+)/m;

    # we need at least version 3.90
    return compareVersion($major, $minor, 3, 90);
}


sub doInventory {
    my $params = shift;

    my $inventory = $params->{inventory};
    my $prologresp = $params->{prologresp};
    my $logger = $params->{logger};

    # Let's find network interfaces and call ipdiscover on it
    my $options = $prologresp->getOptionsInfoByName("IPDISCOVER");

    my $network;
    if ($options->[0] && exists($options->[0]->{content})) {
        $network = $options->[0]->{content};
    } else {
        return;
    }

    return unless $network =~ /^\d+\.\d+\.\d+\.\d+$/;
    $logger->debug("scanning the $network network");

    my $ip;
    my $cmd = "nmap -n -sP -PR $network/24";
    foreach (`$cmd`) {
        print;
        if (/^Host ($ip_address_pattern)/) {
            $ip = $1;
        } elsif ($ip && /MAC Address: ($mac_address_pattern)/) {
            $inventory->addIpDiscoverEntry({
                IPADDRESS => $ip,
                MACADDR => lc($1),
            });
            $ip = undef;
        } else {
            $ip = undef;
        }
    }
}

1;
