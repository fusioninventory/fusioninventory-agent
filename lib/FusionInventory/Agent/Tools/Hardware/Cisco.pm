package FusionInventory::Agent::Tools::Hardware::Cisco;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

my $models;

sub getDeviceModel {
    my (%params) = @_;

    _loadDeviceModels(%params) if !$models;

    return unless $params{id};
    return $models->{$params{id}};
}

sub _loadDeviceModels {
    my (%params) = @_;

    my $file = $params{file} ||
               $params{datadir} . '/sysobjectid.cisco.ids';
    my $handle = getFileHandle(file => $file);
    return unless $handle;

    while (my $line = <$handle>) {
        next unless $line =~ /^(\w+)\s+OBJECT IDENTIFIER ::= { ciscoProducts (\d+) }/;
        $models->{'1.' . $2} = $1;
    }

    close $handle;
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Tools::Hardware::Cisco - Cisco-specific functions

=head1 DESCRIPTION

This is a class defining some functions specific to Cisco hardware.
