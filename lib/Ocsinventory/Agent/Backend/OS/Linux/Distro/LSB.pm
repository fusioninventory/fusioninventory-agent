package Ocsinventory::Agent::Backend::OS::Linux::Distro::LSB;

sub check {can_run("lsb_release")}

sub run {
  my $params = shift;
  my $inventory = $params->{inventory};

  my $release;
  foreach (`lsb_release -d`) {
    $release = $1 if /Description:\s+(.+)/;
  }
  my $OSComment;
  chomp($OSComment =`uname -v`);

  $inventory->setHardware({ 
      OSNAME => $release,
      OSCOMMENTS => "$OSComment"
    });
}



1;
