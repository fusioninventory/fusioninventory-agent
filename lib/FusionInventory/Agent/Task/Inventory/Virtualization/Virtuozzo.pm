package FusionInventory::Agent::Task::Inventory::Virtualization::Virtuozzo;

use strict;

sub isInventoryEnabled { return can_run('vzlist') }

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $uuid   = "";
    my $mem    = "";
    my $status = "";
    my $name   = "";
    my $subsys = "";
    my $cpus   = 1;

    my @command = `vzlist --all --no-header -o hostname,ctid,cpulimit,status,ostemplate`;
    # no service containers in glpi
    shift (@command);

    foreach my $line ( @command ) {
        chomp $line; 
        my @params = split(/[ \t]+/, $line);
        $name   = $params[0];
        $uuid   = $params[1];
        $cpus   = $params[2];
        $status = $params[3];
        $subsys = $params[4];

        if(!open(CONFIG, "</etc/vz/conf/$uuid.conf")) {
          return;
        }
        @params = <CONFIG>;
        close(CONFIG);
        @params = grep(/SLMMEMORYLIMIT/,@params);
        $mem = pop(@params);
        chomp $mem;
          if ($mem =~ m/(\d+)\"$/) {
          $mem = $1;
        }
        else {
          # non slm config, different calculation
          $mem = 0;
        }
 
        my $machine = {
            NAME      => $name,
            VCPU      => $cpus,
            UUID      => $uuid,
            MEMORY    => $mem,
            STATUS    => $status,
            SUBSYSTEM => $subsys,
            VMTYPE    => "Virtuozzo",
        };

        $inventory->addVirtualMachine($machine);
    }
}

1;

