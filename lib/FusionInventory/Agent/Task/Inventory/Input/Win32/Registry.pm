package FusionInventory::Agent::Task::Inventory::Input::Win32::Registry;

use strict;
use warnings;

use English qw(-no_match_vars);
use Win32::TieRegistry (
    Delimiter   => "/",
    ArrayValues => 0,
    qw/KEY_READ/
);

use FusionInventory::Agent::Tools;

my @hives = qw/
    HKEY_CLASSES_ROOT
    HKEY_CURRENT_USER
    HKEY_LOCAL_MACHINE
    HKEY_USERS
    HKEY_CURRENT_CONFIG
    HKEY_DYN_DATA
/; 

sub isEnabled {
    my (%params) = @_;

    return $params{registry};
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    foreach my $option (@{$params{registry}}) {
        my $name = $option->{NAME};
        my $regkey = $option->{REGKEY};
        my $regtree = $option->{REGTREE};
        my $content = $option->{content};

        # This should never append, err wait... 
        next unless $content;

        my $machKey = $Registry->Open(
            $hives[$regtree], { Access => KEY_READ }
        ) or die "Can't open $hives[$regtree]: $EXTENDED_OS_ERROR";

        my $values = $machKey->{$regkey};

        if ($content eq '*') {
            foreach my $keyWithDelimiter ( keys %$values ) {
                next unless $keyWithDelimiter =~ /^\/(.*)/;
                $inventory->addRegistry({
                    NAME => $name, 
                    REGVALUE => $1."=".$values->{$keyWithDelimiter}."\n"
                });
            }
        } else {
            $inventory->addRegistry({
                NAME => $name, 
                REGVALUE => $values->{$content}
            });
        }
    }

}

1;
