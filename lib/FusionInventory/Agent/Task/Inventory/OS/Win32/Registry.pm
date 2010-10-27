package FusionInventory::Agent::Task::Inventory::OS::Win32::Registry;

use strict;
use warnings;

use English qw(-no_match_vars);
use Win32::TieRegistry (
    Delimiter   => "/",
    ArrayValues => 0,
    qw/KEY_READ/
);

my @hives = qw/
    HKEY_CLASSES_ROOT
    HKEY_CURRENT_USER
    HKEY_LOCAL_MACHINE
    HKEY_USERS
    HKEY_CURRENT_CONFIG
    HKEY_DYN_DATA
/; 

sub isInventoryEnabled {
    my $params = shift;

    my $prologresp = $params->{prologresp};

    return
        $prologresp &&
        $prologresp->getOptionsInfoByName("REGISTRY");
}

sub doInventory {
    my $params = shift;

    my $inventory = $params->{inventory};
    my $prologresp = $params->{prologresp};
    my $logger = $params->{logger};

    my $options = $prologresp->getOptionsInfoByName("REGISTRY");

    foreach my $option (@$options) {
        my $name = $option->{NAME};
        my $regkey = $option->{REGKEY};
        my $regtree = $option->{REGTREE};
        my $content = $option->{content};

        my $machKey = $Win32::TieRegistry::Registry->Open( $hives[$regtree], {Access=>Win32::TieRegistry::KEY_READ(),Delimiter=>"/"} );

        my $values = $machKey->{$regkey};

        if (!$content) {
            return; # This should never append, err wait... 
        } elsif ($content ne '*') {
            $inventory->addRegistry({
                NAME => $name, 
                REGVALUE => $values->{$content}
            });
        } else {
            foreach my $keyWithDelimiter ( keys %$values ) {
                next unless $keyWithDelimiter =~ /^\/(.*)/;
                $inventory->addRegistry({
                    NAME => $name, 
                    REGVALUE => $1."=".$values->{$keyWithDelimiter}."\n"
                });
            }
        }

    }

}


1;
