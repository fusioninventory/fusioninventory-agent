package Ocsinventory::Agent::Backend::OS::Generic::Dmidecode::Slots;

use strict;

sub check { `which dmidecode`; ($? >> 8)?0:1 }

sub run {
  my $params = shift;
  my $inventory = $params->{inventory};

  my @dmidecode = `dmidecode`; # TODO retrive error
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

      $inventory->addSlots({
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
