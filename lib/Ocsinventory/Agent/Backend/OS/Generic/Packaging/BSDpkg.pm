package Ocsinventory::Agent::Backend::OS::Generic::Packaging::BSDpkg;

sub check {
  `which pkg_info 2>&1`;
  return if ($? >> 8)!=0;
  `pkg_info 2>&1`;
  return if ($? >> 8)!=0;
  1;
}

sub run {
  my $params = shift;
  my $inventory = $params->{inventory};

  foreach(`pkg_info`){
      /^(\S+)-(\d+\S*)\s+(.*)/;
      my $name = $1;
      my $version = $2;
      my $comments = $3;
      
      $inventory->addSoftwares({
	  'COMMENTS' => $comments,
	  'NAME' => $name,
	  'VERSION' => $version
      });
  }
}

1;
