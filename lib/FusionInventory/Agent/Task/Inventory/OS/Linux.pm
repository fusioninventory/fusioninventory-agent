package FusionInventory::Agent::Task::Inventory::OS::Linux;

use strict;
use warnings;

use English qw(-no_match_vars);
use XML::TreePP;


use FusionInventory::Agent::Tools;

our $runAfter = ["FusionInventory::Agent::Task::Inventory::OS::Generic"];

# Get RedHat Network SystemId
sub _getRHNSystemId {
    my ($file) = @_;

    return unless -f $file;
    my $tpp = XML::TreePP->new();
    my $h = $tpp->parsefile($file);
    use Data::Dumper;
    my $v;
    eval {
        foreach (@{$h->{params}{param}{value}{struct}{member}}) {
            next unless $_->{name} eq 'system_id';
            return $_->{value}{string};
        }
    }
}

sub isInventoryEnabled {
    return $OSNAME eq 'linux';
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    my $osversion = getFirstLine(command => 'uname -r');

    my ($last_user, $last_date);
    my $last = getFirstLine(command => 'last -R');
    if ($last &&
        $last =~ /^(\S+) \s+ \S+ \s+ (\S+ \s+ \S+ \s+ \S+ \s+ \S+)/x
    ) {
        $last_user = $1;
        $last_date = $2;
    }

    $inventory->setHardware({
        OSNAME             => "Linux",
        OSVERSION          => $osversion,
        LASTLOGGEDUSER     => $last_user,
        DATELASTLOGGEDUSER => $last_date,
        WINPRODID          => _getRHNSystemId('/etc/sysconfig/rhn/systemid')
    });

}

1;
