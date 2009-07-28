package Ocsinventory::Agent::Backend::Virtualization::VirtualBox;

# This module detects only all VMs create by the user who launch this module (root VMs).

use strict;

sub check { return can_run('VirtualBox') and can_run('VBoxManage') }

sub run {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $cmd_list_vms = "VBoxManage -nologo list vms";

    my ( $version ) = ( `VBoxManage --version` =~ m/^(\d\.\d).*$/ ) ;
    if ( $version > 2.1 ) {         # detect VirtualBox version 2.2 or higher
            $cmd_list_vms = "VBoxManage -nologo list --long vms";
    }
    
    my $in = 0;
    my $uuid;
    my $mem;
    my $status;
    my $name;
        
    foreach my $line (`$cmd_list_vms`){                 # read only the information on the first paragraph of each vm
        chomp ($line);
        if ($in == 0 and $line =~ m/^Name:\s+(.*)$/) {      # begin
            $name = $1;
            $in = 1; 
        } elsif ($in == 1 ) {
            if ($line =~ m/^\s*$/) {                        # finish
                $in = 0 ;
                
                $inventory->addVirtualMachine ({
                    NAME      => $name,
                    VCPU      => 1,
                    UUID      => $uuid,
                    MEMORY    => $mem,
                    STATUS    => $status,
                    SUBSYSTEM => "Sun xVM VirtualBox",
                    VMTYPE    => "VirtualBox",
                });
                
                $name = $status = $mem = $uuid = "N\A";     # useless but need it for security (new version, ...)
                
            } elsif ($line =~ m/^UUID:\s+(.*)/) {
                $uuid = $1;
            } elsif ($line =~ m/^Memory size:\s+(.*)/ ) {
                $mem = $1;
            } elsif ($line =~ m/^State:\s+(.*)\(.*/) {
                $status = ( $1 =~ m/off/ ? "off" : $1 );
            }
        }
    }
    
    if ($in == 1) {     # Anormal situation ! save the current vm information ...
        $inventory->addVirtualMachine ({
            NAME      => $name,
            VCPU      => 1,
            UUID      => $uuid,
            MEMORY    => $mem,
            STATUS    => $status,
            SUBSYSTEM => "Sun xVM VirtualBox",
            VMTYPE    => "VirtualBox",
        });
    }
    
    
    # try to found another VMs, not exectute by root
    
    foreach my $line ( `ps -ef` ) {
        chomp($line);
        if ( $line !~ m/^root/) {
            if ($line =~ m/^.*VirtualBox (.*)$/) {
                my @process = split (/\s*\-\-/, $1);     #separate options
                
                $name = $uuid = "N/A";
                
                foreach my $option ( @process ) {
                    print $option."\n";
                    if ($option =~ m/^comment (.*)/) {
                        $name = $1;
                    } elsif ($option =~ m/^startvm (\S+)/) {
                        $uuid = $1;
                    }
                }
                
                $inventory->addVirtualMachine ({
                    NAME      => $name,
                    VCPU      => 1,
                    UUID      => $uuid,
                    STATUS    => "running",
                    SUBSYSTEM => "Sun xVM VirtualBox",
                    VMTYPE    => "VirtualBox",
                });
            }
        }
    }
    
}

1;
