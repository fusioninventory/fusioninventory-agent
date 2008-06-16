package Ocsinventory::Agent::Backend::OS::MacOS::Packages;

use strict;
use warnings;

sub check {
    my $params = shift;

    return unless can_load("Mac::SysProfile");
    # Do not run an package inventory if there is the --nosoft parameter
    return if ($params->{params}->{nosoft});

    1;
}

sub run {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $prof = Mac::SysProfile->new();
    my $apps = $prof->gettype('SPApplicationsDataType'); # might need to check version of darwin

    return unless($apps && ref($apps) eq 'HASH');

    # for each app, normalize the information, then add it to the inventory stack
    foreach my $app (keys %$apps){
        my $a = $apps->{$app};
        my $kind = $a->{'Kind'} ? $a->{'Kind'} : 'UNKNOWN';
        my $comments = '['.$kind.']';
        $inventory->addSoftwares({
            'NAME'      => $app,
            'VERSION'   => $a->{'Version'} || 'unknown',
            'COMMENTS'  => $comments,
            'PUBLISHER' => $a->{'Get Info String'} || 'unknown',
        });
    }
}

1;
