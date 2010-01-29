package Ocsinventory::Agent::Backend::OS::Generic::Dmidecode::UUID;

use strict;

sub check { return can_run('dmidecode') }

sub run {
  my $params = shift;
  my $inventory = $params->{inventory};

  my $uuid;

  $uuid = `dmidecode -s system-uuid`;
  chomp($uuid);
  $uuid =~ s/\s+$//g;

   $inventory->setHardware({
      UUID => $uuid,
   });

}

1;
