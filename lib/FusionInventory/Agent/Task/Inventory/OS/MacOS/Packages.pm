package FusionInventory::Agent::Task::Inventory::OS::MacOS::Packages;

use strict;
use warnings;

sub isInventoryEnabled {
    my $params = shift;

    return unless can_load("Mac::SysProfile");
    # Do not run an package inventory if there is the --nosoft parameter
    return if ($params->{config}->{nosoft});

    1;
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $prof = Mac::SysProfile->new();
    my $apps = $prof->gettype('SPApplicationsDataType'); # might need to check version of darwin

    return unless($apps && ref($apps) eq 'HASH');

    # for each app, normalize the information, then add it to the inventory stack
    foreach my $app (keys %$apps){
        my $a = $apps->{$app};

        next unless ref($a) eq 'HASH';

# http://forge.fusioninventory.org/issues/716
        if ($a->{'Get Info String'} && $a->{'Get Info String'} =~ /\S+, [C-Z]:\\\S+/) {
            # Windows application found by Parallels
            next;
        }

        my $kind = $a->{'Kind'} ? $a->{'Kind'} : 'UNKNOWN';
        my $comments = '['.$kind.']';
        $inventory->addSoftware({
            'NAME'      => $app,
            'VERSION'   => $a->{'Version'} || 'unknown',
            'COMMENTS'  => $comments,
            'PUBLISHER' => $a->{'Get Info String'} || 'unknown',
        });
    }
}

1;
