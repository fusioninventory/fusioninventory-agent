package FusionInventory::Agent::Task::Inventory::Virtualization::Lxc;

# Authors: Egor Shornikov <se@wbr.su>, Egor Morozov <akrus@flygroup.st>
# License: GPLv2+

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isEnabled {
    return canRun('lxc-ls');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{inventory};

    my $vms = _getVirtualMachines( command => '/usr/bin/lxc-ls -1', logger => $logger );
    foreach my $vm ( keys %{$vms}) {

        my $state = _getVirtualMachineState( command => "/usr/bin/lxc-info -n $vm", logger => $logger );
        my $conf = _getVirtualMachineConfig( file => "/var/lib/lxc/$vm/config", logger => $logger );

        my %entry = ();
        $entry{'NAME'} = $vm;
        $entry{'VMTYPE'} = 'LXC';
        $entry{'VMID'} = $state->{'VMID'};
        $entry{'STATUS'} = $state->{'STATUS'};
        $entry{'VCPU'} = $conf->{'VCPU'};
        $entry{'MEMORY'} = $conf->{'MEMORY'};

        $inventory->addEntry(
            section => 'VIRTUALMACHINES', entry => \%entry
        );
    }
}

sub  _getVirtualMachineState {
    my (%params) = (
        @_
    );

    my ( %state, %info );

    my $handle = getFileHandle( %params );
    return unless $handle;
    while( <$handle> ){
        chomp;
        if( $_ =~ m/^(\S+):\s*(\S+)$/ ){ $info{$1} = $2; }
    }
    close $handle;

    $state{'VMID'} = $info{'pid'};
    if ( $info{'state'} eq 'RUNNING' ){
        $state{'STATUS'} = lc( $info{'state'} );
    } elsif ( $info{'state'} eq 'FROZEN' ){
        $state{'STATUS'} = 'paused';
    } elsif ( $info{'state'} eq 'STOPPED' ){
        $state{'STATUS'} = 'off';
    } else {
        $state{'STATUS'} = $info{'state'};
    }

    return \%state;
}

sub  _getVirtualMachineConfig {
    my (%params) = (
        @_
    );

    my %conf = ();

    my $handle = getFileHandle( %params );
    return unless $handle;
    while( <$handle> ){
        chomp;
        s/^\s*//g;
        s/\s*$//g;
        s/^#.*//g;
        if ( $_ =~ m/^(\S+)\s*=\s*(\S+)\s*$/ ){
            my $key = $1;
            my $val = $2;
            if ( $key eq 'lxc.network.hwaddr' ){ $conf{'MAC'} = $val; }
            if ( $key eq 'lxc.cgroup.memory.limit_in_bytes' ){ $conf{'MEMORY'} = $val; }
            if ( $key eq 'lxc.cgroup.cpuset.cpus' ){
                ###eg: lxc.cgroup.cpuset.cpus = 0,3-5,7,2,1
                my $cpu_num = 0;
                foreach my $cpu ( split( /,/, $val ) ){
                    if ( $cpu =~ /(\d+)-(\d+)/ ){
                        my @tmp = ($1..$2);
                        $cpu_num += $#tmp + 1;
                    } else {
                        $cpu_num += 1;
                    }
                }
                $conf{'VCPU'} = $cpu_num;
            }
        }
    }
    close $handle;

    return \%conf;
}

sub  _getVirtualMachines {
    my (%params) = (
        @_
    );

    my %vms = ();

    my $handle = getFileHandle( %params );
    return unless $handle;

    while( <$handle> ){
        chomp;
        unless ( m/^(\S+)$/ ){ next; }
        $vms{$1} = 1;
    }
    close $handle;

    return \%vms;
}

1;
