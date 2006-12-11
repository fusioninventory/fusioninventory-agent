package Ocsinventory::Agent::Backend::OS::Linux::Controllers;
use strict;

sub check {
	my @pci = `lspci 2>>/dev/null`;
	return 1 if @pci;
	0
}

sub run {
	my $params = shift;
	my $inventory = $params->{inventory};

        foreach(`lspci`){
                /^\S+\s([^:]+):\s*(.+?)(?:\(([^()]+)\))?$/i;

		my $name = $1;
		my $manufacturer = $2;
		my $type = $3;

		
		$manufacturer =~ s/\ *$//; # clean up the end of the string

                $inventory->addController({
                        'NAME'          => $name,
                        'MANUFACTURER'  => $manufacturer,
                        'TYPE'          => $type,
                });
        }

}

1
