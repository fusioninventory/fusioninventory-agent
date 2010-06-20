package FusionInventory::Agent::Task::Inventory::OS::AIX::Domains;

use strict;
use warnings;

use English qw(-no_match_vars);

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};
    my $domain;

    #Domain name
    my $handle;
    if (!open $handle, '<', '/etc/resolv.conf') {
        warn "Can't open /etc/resolv.conf: $ERRNO";
        return;
    }

    while(<$handle>){
        if (/^(domain|search)\s+(.+)/){$domain=$2;chomp($domain);}
    }
    close $handle;
    #If no domain name and no workgroup name (samba), we send "WORKGROUP"
    #TODO:Check if samba is present and get the windows workgroup or NT domain name
    unless (defined($domain)){chomp($domain="WORKGROUP");}
    $domain=~s/^.\.(.)/$1/;

    $inventory->setHardware({
        WORKGROUP => $domain
    });

}

1;
