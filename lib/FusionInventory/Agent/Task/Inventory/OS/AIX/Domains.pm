package FusionInventory::Agent::Task::Inventory::OS::AIX::Domains;
use strict;

sub doInventory {
  my $params = shift;
  my $inventory = $params->{inventory};
  my $domain;

  #Domain name 
  open RESOLV, "/etc/resolv.conf";
  while(<RESOLV>){
		if (/^(domain|search)\s+(.+)/){$domain=$2;chomp($domain);}
  }
  #If no domain name and no workgroup name (samba), we send "WORKGROUP"
  #TODO:Check if samba is present and get the windows workgroup or NT domain name
  unless (defined($domain)){chomp($domain="WORKGROUP");}
  $domain=~s/^.\.(.)/$1/;

  $inventory->setHardware({
      WORKGROUP => $domain
    });

}

1;
