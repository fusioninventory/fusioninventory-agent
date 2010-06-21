package FusionInventory::Agent::Task::Inventory::Virtualization::Parallels;

use strict;
use warnings;

sub isInventoryEnabled {
    return can_run('prlctl');
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};
    my $config = $params->{config};

    my %status_list = (
        'running' => 'running',
        'blocked' => 'blocked',
        'paused' => 'paused',
        'suspended' => 'suspended',
        'crashed' => 'crashed',
        'dying' => 'dying',
    );

    my $uuid="";
    my $mem="";
    my $status="";
    my $name="";
    my $cpus = 1;
    my @users = ();

    # We don't want to scan user directories unless --scan-homedirs is used
    return unless $config->{'scan-homedirs'};

    foreach my $lsuser ( glob("/Users/*") ) {
        $lsuser =~ s/.*\///; # Just keep the login
        next if /Shared/i;
        next if /^\./i; # Ignore hidden directory
        next if /\ /; # Ignore directory with space in the name
        next if /'/; # Ignore directory with space in the name

        push(@users,$lsuser);
    }

    foreach my $user (@users) {
        my @command = `su '$user' -c "prlctl list -a"`;
        shift (@command);

        foreach my $line ( @command ) {
            chomp $line; 
            my @params = split(/  /, $line);
            $uuid = $params[0];
            #$status = $params[1];
            $status = $status_list{$params[1]};
            $name = $params[4];

            # Avoid security risk. Should never appends
            next if $uuid =~ /(;\||&)/;

            foreach my $infos ( `sudo -u '$user' prlctl list -i $uuid`) {
            if ($infos =~ m/^\s\smemory\s(.*)Mb/) {
                $mem = $1;
            }
            elsif ($infos =~ m/^\s\scpu\s([0-9]{1,2})/) {
                $cpus= $1;
            }
        }

        $inventory->addVirtualMachine ({
                NAME      => $name,
                VCPU      => $cpus,
                UUID      => $uuid,
                MEMORY    => $mem,
                STATUS    => $status,
                SUBSYSTEM => "Parallels",
                VMTYPE    => "Parallels",
            });
    }
}
}

1;
