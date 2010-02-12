package FusionInventory::Agent::Task::Inventory::OS::Generic::Dmidecode::Slots;

use strict;

sub doInventory {
  my $params = shift;
  my $inventory = $params->{inventory};

  my $dmidecode = `dmidecode`;
  # some versions of dmidecode do not separate items with new lines
  # so add a new line before each handle
  $dmidecode =~ s/\nHandle/\n\nHandle/g;
  my @dmidecode = split (/\n/, $dmidecode);
  # add a new line at the end
  push @dmidecode, "\n";

  s/^\s+// for (@dmidecode);

  my $flag;

  my $description;
  my $designation;
  my $name;
  my $status;


  foreach (@dmidecode) {

    if(/dmi type 9,/i) {
      $flag=1;
    } elsif ($flag && /^$/) {
      $flag=0;

      $inventory->addSlot({
	  DESCRIPTION =>  $description,
	  DESIGNATION =>  $designation,
	  NAME =>  $name,
	  STATUS =>  $status,

	  });

      $description = $designation = $name = $status = undef;

    } elsif ($flag) {

      $description = $1 if /^type\s*:\s*(.+)/i;
      $designation = $1 if /^id\s*:\s*(.+)/i;
      $name = $1 if /^designation\s*:\s*(.+)/i;
      $status = $1 if /^current usage\s*:\s*(.+)/i;

    };
  }

}

1;
