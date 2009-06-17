package Ocsinventory::Agent::Backend::Virtualization::Xen::XM;

use strict;

sub check { can_run('xm') }

sub run {
    my $params = shift;
    my $inventory = $params->{inventory};

# output: xm info
#
#    Name                         ID Mem(MiB) VCPUs State  Time(s)
#    Domain-0                      0       98     1 r-----  5068.6
#    Fedora3                     164      128     1 r-----     7.6
#    Fedora4                     165      128     1 ------     0.6
#    Mandrake2006                166      128     1 -b----     3.6
#    Mandrake10.2                167      128     1 ------     2.5
#    Suse9.2                     168      100     1 ------     1.8

    # remove first line
    my $i=0;

    # xm status
    my %status_list = (
	    'r' => 'running',
	    'b' => 'blocked',
	    'p' => 'paused',
	    's' => 'shutdown',
	    'c' => 'crashed',
	    'd' => 'dying',
    );

    my $vmtype    = 'xen';
    my $subsystem = 'xm';

    foreach (`xm info`) {
	if ($i) {
            my ($name, $id, $memory, $vcpu, $status, $time) = split(' ');

	    $status =~ s/-//g;
	    $status = ( $state ? $status_list{$state} : 'off');

            my $machine = {
                MEMORY    => $memory,
                NAME      => $name,
                UUID      => '',  # TODO: parse xm list -l
                STATUS    => $status,
                SUBSYSTEM => $subsystem,
                VMTYPE    => $vmtype,
                VCPU      => $vcpu,
            };

            $inventory->addVirtualMachine($machine);
        }
	$i++;
    }
}

1;

