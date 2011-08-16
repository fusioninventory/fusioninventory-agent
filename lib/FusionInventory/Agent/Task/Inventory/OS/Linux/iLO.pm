package FusionInventory::Agent::Task::Inventory::OS::Linux::iLO;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Network;

sub isEnabled {
    return unless canRun("hponcfg");
}

sub _parseHponcfg {
    my %params = @_;

    my $handle = getFileHandle(%params);

    return unless $handle;

    my $ipmask;
    my $ipgateway;
    my $speed;
    my $ipsubnet;
    my $ipaddress;
    my $status;
    my $error;

    while (my $line = <$handle>) {
        if ($line =~ /<IP_ADDRESS VALUE="($ip_address_pattern)"\/>/) {
            $ipaddress = $1 unless $1 eq '0.0.0.0';
        }
        if ($line =~ /<SUBNET_MASK VALUE="($ip_address_pattern)"\/>/) {
            $ipmask = $1;
        }
        if ($line =~ /<GATEWAY_IP_ADDRESS VALUE="($ip_address_pattern)"\/>/) {
            $ipgateway = $1;
        }
        if ($line =~ /<NIC_SPEED VALUE="([0-9]+)"\/>/) {
            $speed = $1;
        } 
        if ($line =~ /<ENABLE_NIC VALUE="(.)"\/>/) {
            $status = 'Up' if $1 =~ /Y/i;
        }
        if ($line =~ /not found/) {
            chomp $line;
            $params{logger}->error("error in hponcfg output: $line")
                if $params{logger};
        }
    }
    close $handle;
    $ipsubnet = getSubnetAddress($ipaddress, $ipmask);

    # Some cleanups
    if ( not $status ) { $status = 'Down' }

    return {
            DESCRIPTION => 'Management Interface - HP iLO',
            IPADDRESS   => $ipaddress,
            IPMASK      => $ipmask,
            IPSUBNET    => $ipsubnet,
            STATUS      => $status,
            TYPE        => 'Ethernet',
            SPEED       => $speed,
            IPGATEWAY   => $ipgateway,
            MANAGEMENT  => 'iLO',
        };
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $entry = _parseHponcfg(
        logger => $logger,
        command => 'hponcfg -aw -'
    );

    $inventory->addEntry(
        section => 'NETWORKS',
        entry   => $entry
    );
}

1;
