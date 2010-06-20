package FusionInventory::Agent::Task::Inventory::WinRegistry;

use strict;
use warnings;

use English qw(-no_match_vars);

my @hives = qw/
HKEY_CLASSES_ROOT
HKEY_CURRENT_USER
HKEY_LOCAL_MACHINE
HKEY_USERS
HKEY_CURRENT_CONFIG
HKEY_DYN_DATA
/; 



sub isInventoryEnabled {
    return unless $OSNAME eq 'MSWin32';

    eval {
        require Win32::TieRegistry;
        Win32::TieRegistry->import(
            Delimiter   => "/",
            ArrayValues => 0
        );
    };
    return if $EVAL_ERROR;

    my $params = shift;

    my $prologresp = $params->{prologresp};

    return unless ($prologresp &&
            $prologresp->getOptionsInfoByName("REGISTRY"));

    1;
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

        if ($content ne '*') {
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
