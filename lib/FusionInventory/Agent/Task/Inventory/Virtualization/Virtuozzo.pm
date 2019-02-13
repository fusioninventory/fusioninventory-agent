package FusionInventory::Agent::Task::Inventory::Virtualization::Virtuozzo;

use strict;
use warnings;

use parent 'FusionInventory::Agent::Task::Inventory::Module';

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Network;
use FusionInventory::Agent::Tools::Virtualization;

sub isEnabled {
    # Avoid duplicated entry with libvirt
    return if canRun('virsh');

    return canRun('vzlist');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    foreach my $vz (_parseVzlist(%params)) {
        $inventory->addEntry(
            section => 'VIRTUALMACHINES',
            entry => $vz
        );
    }
}

sub _parseVzlist {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $handle = getFileHandle(
        command => 'vzlist --all --no-header -o hostname,ctid,cpulimit,status,ostemplate',
        %params
    );

    return unless $handle;

    my $vzlist;
    my $confctid_template = $params{ctid_template} ||
        "/etc/vz/conf/__XXX__.conf";

    # no service containers in glpi
    my $line = <$handle>;

    my $hostID = $inventory->getHardware('UUID') || '';

    my %status_list = (
        'stopped'   => STATUS_OFF,
        'running'   => STATUS_RUNNING,
        'paused'    => STATUS_PAUSED,
        'mounted'   => STATUS_OFF,
        'suspended' => STATUS_PAUSED,
        'unknown'   => STATUS_OFF,
    );

    while (my $line = <$handle>) {

        chomp $line;
        my ($name, $ctid, $cpus, $status, $subsys) = split(/[ \t]+/, $line);

        my $ctid_conf = $confctid_template;
        $ctid_conf =~ s/__XXX__/$ctid/;

        my $memory = getFirstMatch(
            file    => $ctid_conf,
            pattern => qr/^SLMMEMORYLIMIT="\d+:(\d+)"$/,
            logger  => $logger,
        );
        if ($memory) {
            $memory = $memory / 1024 / 1024;
        } else {
            $memory = getFirstMatch(
                file    => $ctid_conf,
                pattern => qr/^PRIVVMPAGES="\d+:(\d+)"$/,
                logger  => $logger,
            );
            if ($memory) {
                $memory = $memory * 4 / 1024;
            } else {
                $memory = getFirstMatch(
                    file    => $ctid_conf,
                    pattern => qr/^PHYSPAGES="\d+:(\d+\w{0,1})"$/,
                    logger  => $logger,
                );
                if ($memory) {
                    $memory =~ /(\d+)(\w{0,1})/;
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

        # compute specific identifier for the guest, as CTID is
        # unique only for the local hosts
        my $uuid = $hostID . '-' . $ctid;

        push @{$vzlist}, {
            NAME      => $name,
            VCPU      => $cpus,
            UUID      => $uuid,
            MEMORY    => $memory,
            STATUS    => $status_list{$status} || STATUS_OFF,
            SUBSYSTEM => $subsys,
            VMTYPE    => "Virtuozzo",
            MAC       => _getMACs($ctid, $logger)
        };
    }

    close $handle;

    return $vzlist;
}

sub _getMACs {
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


1;
