package Ocsinventory::Agent::Backend::Virtualization::Qemu;
#
# initial version Nicolas EISEN
#
# With Qemu 0.10.X, some option will be exist to get more and easly information (UUID, memory, ...)

use strict;

sub check { return can_run('qemu') }

sub run {
    my $params = shift;
    my $inventory = $params->{inventory};

    foreach ( `ps -ef` ) {
        if (m/^.*((qemu|kvm).*\-([fh]d[a-d]|cdrom).*)$/) {      # match only if an qemu instance
            
            my $name;
            my $mem = 0;
            my $vmtype = $2;
                        
            my @process = split (/\-/, $1);     #separate options
            
            foreach my $option ( @process ) {
                if ($option =~ m/^([fh]d[a-d]|cdrom) (\S+)/) {
                    $name = $2;
                } elsif ($option =~ m/^m (\S+)/) {
                    $mem = $1;
                }
            }
            
            if ($mem == 0 ) {
                $mem = 128;
            }
            
            $inventory->addVirtualMachine ({
                NAME      => $name,
                VCPU      => 1,
                MEMORY    => $mem,
                STATUS    => "running",
                SUBSYSTEM => $vmtype,
                VMTYPE    => $vmtype,
            });
        }
    }
}

1;
