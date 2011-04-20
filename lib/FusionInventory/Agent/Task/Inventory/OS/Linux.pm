package FusionInventory::Agent::Task::Inventory::OS::Linux;

use strict;
use warnings;
use English qw(-no_match_vars);
use XML::Simple;


our $runAfter = ["FusionInventory::Agent::Task::Inventory::OS::Generic"];

# Get RedHat Network SystemId
sub _getRHNSystemId {
    my ($file) = @_;

    return unless -f $file;
    my $h = XMLin($file);
    return eval {$h->{param}{value}{struct}{member}{system_id}{value}{string}};
}

sub isInventoryEnabled {
    return $OSNAME =~ /^linux$/;
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    chomp (my $osversion = `uname -r`);

    my $lastloggeduser;
    my $datelastlog;
    my @query = runcmd("last -R");

    foreach ($query[0]) {
        if ( s/^(\S+)\s+\S+\s+(\S+\s+\S+\s+\S+\s+\S+)\s+.*// ) {
            $lastloggeduser = $1;
            $datelastlog = $2;
        }
    }

    # This will probably be overwritten by a Linux::Distro module.
    $inventory->setHardware({
        OSNAME => "Linux",
        OSCOMMENTS => "Unknown Linux distribution",
        OSVERSION => $osversion,
        WINPRODID => _getRHNSystemId('/etc/sysconfig/rhn/systemid') || '',
        LASTLOGGEDUSER => $lastloggeduser,
        DATELASTLOGGEDUSER => $datelastlog
    });
}

1;
