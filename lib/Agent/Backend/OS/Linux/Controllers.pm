package Ocsinventory::Agent::Backend::OS::Linux::Controllers;
use strict;

sub check {
	my @pci = `lspci 2>>/dev/null`;
	return 1 if @pci;
	0
}

sub run {
	my $inventory = shift;

        foreach(`lspci`){
                /^\S+\s([^:]+):\s*(.+?)(?:\(([^()]+)\))?$/i;
                $inventory->addControler({
                        'NAME'          => $1,
                        'MANUFACTURER'  => $2,
                        'TYPE'          => $3,
                });
        }

}

1
