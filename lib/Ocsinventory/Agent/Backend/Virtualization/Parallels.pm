package Ocsinventory::Agent::Backend::Virtualization::Parallels;

use strict;

sub check { return can_run('prlctl') }

sub run {
    my $params = shift;
    my $inventory = $params->{inventory};

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

    my $lscommand = "ls /Users";
    foreach my $lsuser ( `$lscommand` ) {
        chomp ($lsuser);
        if ($lsuser !~ m/Shared|^\./) {	
            push(@users,$lsuser);
        }
    }

    foreach my $user (@users) {
        my @command = `sudo -u $user prlctl list -a`;
        shift (@command);

        foreach my $line ( @command ) {
            chomp $line; 
            my @params = split( /  /, $line);
            $uuid = $params[0];
            #$status = $params[1];
            $status = $status_list{$params[1]};
            $name = $params[4];

            foreach my $infos ( `sudo -u $user prlctl list -i $uuid`) {
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
                SUBSYSTEM => "",
                VMTYPE    => "Parallels",
            });
    }
}
}

1;
