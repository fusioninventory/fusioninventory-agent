package FusionInventory::Agent::Task::Inventory::Input::MacOS::Softwares;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isEnabled {
    my (%params) = @_;

    return
        !$params{no_category}->{software} &&
        -r '/usr/sbin/system_profiler' &&
        canLoad("Mac::SysProfile");
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    my $prof = Mac::SysProfile->new();
    my $info = $prof->gettype('SPApplicationsDataType');
    return unless ref $info eq 'HASH';

    my $softwares = _getSoftwaresList($info);
    return unless $softwares;

    foreach my $software (@$softwares) {
        $inventory->addEntry(
            section => 'SOFTWARES',
            entry   => $software
        );
    }
}

sub _getSoftwaresList {
    my ($info) = @_;

    my @softwares;
    foreach my $name (keys %$info) {
        my $app = $info->{$name};

        # Windows application found by Parallels (issue #716)
        next if
            $app->{'Get Info String'} &&
            $app->{'Get Info String'} =~ /^\S+, [A-Z]:\\/;

        push @softwares, {
            NAME      => $name,
            VERSION   => $app->{'Version'},
            COMMENTS  => $app->{'Kind'} ? '[' . $app->{'Kind'} . ']' : undef,
            PUBLISHER => $app->{'Get Info String'},
        };
    }

    return \@softwares;
}

1;
