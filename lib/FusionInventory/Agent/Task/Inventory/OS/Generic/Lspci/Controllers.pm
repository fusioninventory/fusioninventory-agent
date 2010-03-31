package FusionInventory::Agent::Task::Inventory::OS::Generic::Lspci::Controllers;
use strict;

sub isInventoryEnabled {can_run("lspci")}

sub doInventory {
	my $params = shift;
	my $inventory = $params->{inventory};

	my $driver;
	my $name;
	my $manufacturer;
  my $pciclass;
  my $pciid;
	my $pcislot;
	my $type;


  foreach(`lspci -vvv -nn`){
		if (/^(\S+)\s+(\w+.*?):\s(.*)/) {
			$pciclass = $1;
			$pcislot = $1;
			$name = $2;
			$manufacturer = $3;

            if ($name =~ s/\[(\S+)\]$//) {
                $pciclass = $1;
            }

			if ($manufacturer =~ s/ \((rev \S+)\)//) {
				$type = $1;
			}
			$manufacturer =~ s/\ *$//; # clean up the end of the string
			$manufacturer =~ s/\s+\(prog-if \d+ \[.*?\]\)$//; # clean up the end of the string

			if ($manufacturer =~ s/ \[([A-z\d]+:[A-z\d]+)\]$//) {
        $pciid = $1;
      }
		}
		if ($pcislot && /^\s+Kernel driver in use: (\w+)/) {
			$driver = $1;
		}

		

		if ($pcislot && /^$/) {
			$inventory->addController({
					'DRIVER'        => $driver,
					'NAME'          => $name,
					'MANUFACTURER'  => $manufacturer,
					'PCICLASS'       => $pciclass,
					'PCIID'       => $pciid,
					'PCISLOT'       => $pcislot,
					'TYPE'          => $type,
				});
			$driver = $name = $pciclass = $pciid = $pcislot = $manufacturer = $type = undef;
		}
  }

}

1
