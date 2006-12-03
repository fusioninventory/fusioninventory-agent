package Ocsinventory::Agent::Backend::OS::Linux::Domains;
use strict;

use vars qw($runAfter);
$runAfter = ["Ocsinventory::Agent::Backend::OS::POSIX::Domains"];

sub check {-f "/etc/resolv.conf"}
sub run {
	my $inventory = shift;

	# If the default domain was set by OS::POSIX::Domains I keep the
	# value. Else I use the method used in linux-agent to find the domain
	my $current_domain =
	$inventory->{h}{'CONTENT'}{'HARDWARE'}{'WORKGROUP'}[0];

	return unless ((!$current_domain) || $current_domain =~ /^WORKGROUP$/);
	my %domain;

        open RESOLV, "/etc/resolv.conf" or warn;
        while(<RESOLV>){
                $domain{$2} = 1 if (/^(domain|search)\s+(.+)/);
        }
	close RESOLV;

	my $domain = join "/", keys %domain;
        
	# If no domain name, we send "WORKGROUP"
        $domain = 'WORKGROUP' unless $domain;

	$inventory->setHardware({
	    WORKGROUP => $domain
	  });

}

1;
