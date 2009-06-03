package Ocsinventory::Agent::Backend::OS::Generic::Lspci::Controllers;
use strict;

sub check {can_run("lspci")}

sub run {
	my $params = shift;
	my $inventory = $params->{inventory};

	my $driver;
	my $name;
	my $manufacturer;
	my $pcislot;
	my $type;


        foreach(`lspci -vvv`){
		if (/^(\S+)\s+(\w+.*?):\s(.*)/) {
			$pcislot = $1;
			$name = $2;
			$manufacturer = $3;

			if ($manufacturer =~ s/ \((rev \S+)\)//) {
				$type = $1;
			}


			$manufacturer =~ s/\ *$//; # clean up the end of the string
		}
		if ($pcislot && /^\s+Kernel driver in use: (\w+)/) {
			$driver = $1;
		}

		

		if ($pcislot && /^$/) {
			$inventory->addController({
					'DRIVER'        => $driver,
					'NAME'          => $name,
					'MANUFACTURER'  => $manufacturer,
					'PCISLOT'       => $pcislot,
					'TYPE'          => $type,
				});
			$driver = "N/A";
			$name = $pcislot = $manufacturer = $type = undef;
		}
        }

}

1
