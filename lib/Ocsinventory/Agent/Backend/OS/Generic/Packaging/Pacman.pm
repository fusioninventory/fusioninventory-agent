package Ocsinventory::Agent::Backend::OS::Generic::Packaging::Pacman;

sub check {can_run("pacman")}

sub run {
  my $params = shift;
  my $inventory = $params->{inventory};

  foreach(`pacman -Q`){
      /^(\S+)\s+(\S+)/;
      my $name = $1;
      my $version = $2;
     
      $inventory->addSoftware({
      'NAME' => $name,
      'VERSION' => $version
      });
  }
}

1;
