package Ocsinventory::Agent::Backend::OS::Generic::Packaging::BSDpkg;

sub check {can_run("pkg_info")}

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
