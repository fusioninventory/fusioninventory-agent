package Ocsinventory::Agent::Backend::OS::MacOS::Domains;
use strict;

# straight up theft from the other modules...

sub check {
    my $hostname;
    chomp ($hostname = `hostname`);
    my @domain = split (/\./, $hostname);
    shift (@domain);
    return 1 if @domain;
    -f "/etc/resolv.conf"
 }
sub run {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $domain;
    my $hostname;
    chomp ($hostname = `hostname`);
    my @domain = split (/\./, $hostname);
    shift (@domain);
    $domain = join ('.',@domain);

    if (!$domain) {
      my %domain;

      open RESOLV, "/etc/resolv.conf" or warn;
      while(<RESOLV>){
        $domain{$2} = 1 if (/^(domain|search)\s+(.+)/);
      }
      close RESOLV;

      $domain = join "/", keys %domain;
    }

    # If no domain name, we send "WORKGROUP"
    $domain = 'WORKGROUP' unless $domain;

    $inventory->setHardware({
        WORKGROUP => $domain
    });
}

1;
