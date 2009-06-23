package Ocsinventory::Agent::Backend::OS::Linux::Archs::PowerPC::CPU;

use strict;

#processor       : 0
#cpu             : POWER4+ (gq)
#clock           : 1452.000000MHz
#revision        : 2.1
#
#processor       : 1
#cpu             : POWER4+ (gq)
#clock           : 1452.000000MHz
#revision        : 2.1
#
#timebase        : 181495202
#machine         : CHRP IBM,7029-6C3
#
#

sub check { can_read ("/proc/cpuinfo") };


sub run {
  my $params = shift;
  my $inventory = $params->{inventory};

  my @cpus;
  my $current;
  my $isIBM;
  open CPUINFO, "</proc/cpuinfo" or warn;
  foreach(<CPUINFO>) {

    $isIBM = 1 if /^machine\s*:.*IBM/;
    $current->{TYPE} = $1 if /cpu\s+:\s+(\S.*)/;
    $current->{SPEED} = $1 if /clock\s+:\s+(\S.*)/;
    $current->{SPEED} =~ s/\.0+MHz/MHz/;

    if (/^\s*$/) {
      if ($current->{TYPE}) {
        push @cpus, $current;
      }
      $current = {};
    }
  }


  foreach my $cpu (@cpus) {
    $cpu->{MANUFACTURER} = 'IBM' if $isIBM;
    $inventory->addCPU($cpu);
  }
}

1
