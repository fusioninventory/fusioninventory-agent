package FusionInventory::Agent::Task::Inventory::OS::BSD::Storages;

use strict;

sub isInventoryEnabled {-r '/etc/fstab'}

sub doInventory {
  my $params = shift;
  my $inventory = $params->{inventory};

  my @values;
  my @devices;
  
  open FSTAB, "/etc/fstab";
  while(<FSTAB>){
    if(/^\/dev\/(\D+\d)/) {
	push @devices, $1 unless grep(/^$1$/, @devices);
    }
  }
  for my $dev (@devices) {
    my ($model,$capacity,$found, $manufacturer);
    for(`dmesg`){
      if(/^$dev/) { $found = 1;}
      if(/^$dev.*<(.*)>/) { $model = $1; }
      if(/^$dev.*\s+(\d+)\s*MB/) { $capacity = $1;}
    }

    if ($model =~ s/^(SGI|SONY|WDC|ASUS|LG|TEAC|SAMSUNG|PHILIPS|PIONEER|MAXTOR|PLEXTOR|SEAGATE|IBM|SUN|SGI|DEC|FUJITSU|TOSHIBA|YAMAHA|HITACHI|VERITAS)\s*//i) {
	$manufacturer = $1;
    }

    # clean up the model
    $model =~ s/^(\s|,)*//;
    $model =~ s/(\s|,)*$//;

    $inventory->addStorages({
	MANUFACTURER => $manufacturer,
	MODEL => $model,
	DESCRIPTION => $dev,
	TYPE => '',
	DISKSIZE => $capacity
      });
  }
}
1;
