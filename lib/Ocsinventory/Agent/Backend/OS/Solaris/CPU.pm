package Ocsinventory::Agent::Backend::OS::Solaris::CPU;

use strict;

sub check {
  `psrinfo -v >&1`;
  return if ($? >> 8)!=0;
  1;
}

sub run {
  my $params = shift;
  my $inventory = $params->{inventory};

  my $cpu_slot;
  my $cpu_speed;
  my $cpu_type;

  foreach (`psrinfo -v`) {
    if (/^\s+The\s(\w+)\sprocessor\soperates\sat\s(\d+)\sMHz,/) {
      $cpu_type = $1;
      $cpu_speed = $2;
      $cpu_slot++;
      }
  }


  $inventory->setHardware({
      PROCESSORT => $cpu_type,
      PROCESSORN => $cpu_slot,
      PROCESSORS => $cpu_speed
      });

}

1;
