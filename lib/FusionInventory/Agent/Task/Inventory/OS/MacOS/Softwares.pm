package FusionInventory::Agent::Task::Inventory::OS::MacOS::Softwares;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    my ($params) = @_;

    return
        !$params->{config}->{no_software} &&
        -r '/usr/sbin/system_profiler' &&
        can_load("Mac::SysProfile");
}

sub doInventory {
    my ($params) = @_;

    my $inventory = $params->{inventory};

    my $prof = Mac::SysProfile->new();
    my $info = $prof->gettype('SPApplicationsDataType');
    return unless ref $info eq 'HASH';

    # for each app, normalize the information, then add it to the inventory stack
    foreach my $app (keys %$info){
        my $a = $info->{$app};

        next unless ref($a) eq 'HASH';

        my $kind = $a->{'Kind'} ? $a->{'Kind'} : 'UNKNOWN';
        my $comments = '['.$kind.']';
        $inventory->addEntry({
            section => 'SOFTWARES',
            entry   => {
                NAME      => $app,
                VERSION   => $a->{'Version'} || 'unknown',
                COMMENTS  => $comments,
                PUBLISHER => $a->{'Get Info String'} || 'unknown',
            }
        });
    }
}

1;
