package Ocsinventory::Agent::Backend::OS::POSIX::Domains;

sub check {
  my @domain = `hostname -d`;
  @domain?1:0;
}

sub run {
	my $inventory = shift;

	chomp(my $domain = `hostname -d`);
	# If no domain name, we send "WORKGROUP"
        $domain = 'WORKGROUP' unless $domain;
	$inventory->setHardware({
	    WORKGROUP => $domain
	  });

}

1;
