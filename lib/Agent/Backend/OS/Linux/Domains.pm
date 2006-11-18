package Ocsinventory::Agent::Backend::OS::Linux::Domains;

use vars qw($runAfter);
$runAfter = ["Ocsinventory::Agent::Backend::OS::POSIX::Domains"];

sub check {-f "/etc/resolv.conf"}
sub run {
return;
	my $h = shift;

	# If the default domain was set by OS::POSIX::Domains I keep the original method the find the domain
	# to keep compatibilty
	my $current_domain = $h->{'CONTENT'}{'HARDWARE'}{'WORKGROUP'};

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

	$h->{'CONTENT'}{'HARDWARE'}{'WORKGROUP'} = [$domain];

}

1;
