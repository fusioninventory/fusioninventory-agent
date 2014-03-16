package FusionInventory::Agent::Task::Inventory::Virtualization::Virtuozzo;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Network;

sub isEnabled {
    # Avoid duplicated entry with libvirt
    return if canRun('virsh');

    return canRun('vzlist');
}

sub getMACs {
    my ($ctid, $logger) = @_;

    my @ipLines = getAllLines(
            command => "vzctl exec '$ctid' 'ip -0 a'",
            logger  => $logger
            );

    my @macs;
    foreach my $line (@ipLines) {
        next unless $line =~ /^\s+link\/ether ($mac_address_pattern)\s/;
        push @macs, $1;
    }

    return join('/', @macs);
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $handle = getFileHandle(
        command => 'vzlist --all --no-header -o hostname,ctid,cpulimit,status,ostemplate',
        logger  => $logger
    );

    return unless $handle;

    # no service containers in glpi
    my $line = <$handle>;

    while (my $line = <$handle>) {

        chomp $line;
        my ($name, $ctid, $cpus, $status, $subsys) = split(/[ \t]+/, $line);

        my $memory = getFirstMatch(
            file    => "/etc/vz/conf/$ctid.conf",
            pattern => qr/^SLMMEMORYLIMIT="\d+:(\d+)"$/,
            logger  => $logger,
            );
        if ($memory) {
            $memory = $memory / 1024 / 1024;
        } else {
            $memory = getFirstMatch(
                file    => "/etc/vz/conf/$ctid.conf",
                pattern => qr/^PRIVVMPAGES="\d+:(\d+)"$/,
                logger  => $logger,
                );
            if ($memory) {
                $memory = $memory * 4 / 1024;
            } else {
                $memory = getFirstMatch(
                    file    => "/etc/vz/conf/$ctid.conf",
                    pattern => qr/^PHYSPAGES="\d+:(\d+\w{0,1})"$/,
                    logger  => $logger,
                    );
                if ($memory) {
                    $memory =~ /:(\d+)(\w{0,1})/;
                    if ($2 eq "M") {
                        $memory=$1;
                    } elsif ($2 eq "G") {
                        $memory=$1*1024;
                    } elsif ($2 eq "K") {
                        $memory=$1/1024;
                    } else {
                        $memory=$1/1024/1024;
                    }
                }
            }
        }

        $inventory->addEntry(
            section => 'VIRTUALMACHINES',
            entry => {
                NAME      => $name,
                VCPU      => $cpus,
                UUID      => $ctid,
                MEMORY    => $memory,
                STATUS    => $status,
                SUBSYSTEM => $subsys,
                VMTYPE    => "Virtuozzo",
                MAC       => getMACs($ctid, $logger)
            }
        );

    }

    close $handle;
}

1;
