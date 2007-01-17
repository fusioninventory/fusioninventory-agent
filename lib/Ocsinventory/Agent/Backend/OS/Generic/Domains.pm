package Ocsinventory::Agent::Backend::OS::Generic::Domains;

sub check {
  my @domain = `hostname -d`;
  @domain?1:0;
}

sub run {
  my $params = shift;
  my $inventory = $params->{inventory};

  chomp(my $domain = `hostname -d`);
  # If no domain name, we send "WORKGROUP"
  $domain = 'WORKGROUP' unless $domain;
  $inventory->setHardware({
      WORKGROUP => $domain
    });

}

1;
