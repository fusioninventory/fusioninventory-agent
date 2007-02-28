package Ocsinventory::Agent::Backend::OS::Generic::Dmidecode::Memory;
use strict;
sub check {1}


sub run {
  my $params = shift;
  my $inventory = $params->{inventory};

  my $dmidecode = `dmidecode`; # TODO retrieve error
  # some versions of dmidecode do not separate items with new lines
  # so add a new line before each handle
  $dmidecode =~ s/\nHandle/\n\nHandle/g;
  my @dmidecode = split (/\n/, $dmidecode);
  # add a new line at the end
  push @dmidecode, "\n";

  s/^\s+// for (@dmidecode);

  my $flag;

  my $capacity;
  my $speed;
  my $type;
  my $description;
  my $numslots;

  foreach (@dmidecode) {

    if (/dmi type 17,/i) { # begining of Memory Device section
      $flag = 1; 
    } elsif ($flag && /^$/) { # end of section
      $flag = 0;

      $inventory->addMemories({

	  CAPACITY => $capacity,	
	  DESCRIPTION => $description,
	  NUMSLOTS => $numslots,
	  SPEED => $speed,
	  TYPE => $type,

	});

      $capacity = $description = $numslots = $type = $type = undef;
    } elsif ($flag) { # in the section

      $capacity = $1 if /^size\s*:\s*(\S+)/i;
      $description = $1 if /^Form Factor\s*:\s*(.+)/i;
      $numslots = $1 if /^Locator\s*:\s*(.+)/i;
      $speed = $1 if /^speed\s*:\s*(.+)/i;
      $type = $1 if /^type\s*:\s*(.+)/i;

    }
  }
}

1;
