package FusionInventory::Agent::Task::Inventory::Win32::Environment;

use strict;
use warnings;

use Storable 'dclone';

use FusionInventory::Agent::Tools::Win32;

sub isEnabled {
    my (%params) = @_;

    return !$params{no_category}->{environment};
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $wmiParams = {};
    $wmiParams->{WMIService} = dclone ($params{inventory}->{WMIService}) if $params{inventory}->{WMIService};
    my @envVars = getEnvironmentValues(%params, %$wmiParams);
    foreach my $envVar (@envVars) {
        $inventory->addEntry(
            section => 'ENVS',
            entry   => $envVar
        );
    }
}

sub getEnvironmentValues {
    my (%params) = @_;

    my @envVars = ();
    foreach my $object (getWMIObjects(
        %params,
        class      => 'Win32_Environment',
        properties => [ qw/SystemVariable Name VariableValue/ ]
    )) {

        next unless $object->{SystemVariable};

        my $envVar = {
            KEY => $object->{Name},
            VAL => $object->{VariableValue}
        };
        push @envVars, $envVar;
    }

    return @envVars;
}

1;
