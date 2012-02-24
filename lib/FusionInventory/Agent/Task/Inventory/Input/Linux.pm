package FusionInventory::Agent::Task::Inventory::Input::Linux;

use strict;
use warnings;

use English qw(-no_match_vars);
use XML::TreePP;


use FusionInventory::Agent::Tools;

our $runAfter = ["FusionInventory::Agent::Task::Inventory::Input::Generic"];

sub isEnabled {
    return $OSNAME eq 'linux';
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    my $osversion = getFirstLine(command => 'uname -r');
    my $oscomment = getFirstLine(command => 'uname -v');
    my $systemId  = _getRHNSystemId('/etc/sysconfig/rhn/systemid');

    $inventory->setHardware({
        OSVERSION  => $osversion,
        OSCOMMENTS => $oscomment,
        WINPRODID =>  $systemId,
    });

    $inventory->setOperatingSystem({
        KERNEL_VERSION => $osversion
    });

}

# Get RedHat Network SystemId
sub _getRHNSystemId {
    my ($file) = @_;

    return unless -f $file;
    my $tpp = XML::TreePP->new();
    my $h = $tpp->parsefile($file);
    eval {
        foreach (@{$h->{params}{param}{value}{struct}{member}}) {
            next unless $_->{name} eq 'system_id';
            return $_->{value}{string};
        }
    }
}

1;
