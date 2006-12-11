package Ocsinventory::Agent::Backend::OS::POSIX::Dmidecode::Ports;
use strict;
sub check {
  my $dmipath = `which dmidecode`;
  return 1 if $dmipath =~ /\w+/;
  0
}

sub run {
  my $params = shift;
  my $inventory = $params->{inventory};

  my @dmidecode = `dmidecode`; # TODO retrive error
  s/^\s+// for (@dmidecode);

  my $flag;

  my $caption;
  my $description;
  my $name;
  my $type;

  foreach (@dmidecode) {

    if(/dmi type 8,/i) {
      $flag = 1;


    } elsif ($flag && /^$/){ # end of section
      $flag = 0;

      $inventory->addPorts({

	  CAPTION => $caption,
	  DESCRIPTION => $description,
	  NAME => $name,
	  TYPE => $type,

	});

      $caption = $description = $name = $type = undef;
    } elsif ($flag) {

      $caption = $1 if /^external connector type\s*:\s*(.+)/i;
      $description = $1 if /^internal connector type\s*:\s*(.+)/i;
      $name = $1 if /^internal reference designator\s*:\s*(.+)/i;
      $type = $1 if /^port type\s*:\s*(.+)/i;

    }
  }
}

1;
