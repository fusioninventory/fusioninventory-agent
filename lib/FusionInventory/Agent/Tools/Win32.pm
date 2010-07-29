package FusionInventory::Agent::Tools::Win32;

use strict;
use warnings;
use base 'Exporter';

use Encode;
use English qw(-no_match_vars);
use Win32::OLE qw(in CP_UTF8);
use Win32::OLE::Const;

Win32::OLE->Option(CP => 'CP_UTF8');

our @EXPORT = qw(
    getWmiProperties
    encodeFromWmi
    encodeFromRegistry
);

# We don't need to encode to UTF-8 on Win7
sub encodeFromWmi {
    my ($string) = @_;

#  return (Win32::GetOSName() ne 'Win7')?encode("UTF-8", $string):$string; 
    encode("UTF-8", $string); 

    return $string;
}

sub encodeFromRegistry {
    my ($string) = @_;

    encode("UTF-8", $string); 

    return $string;
}

sub getWmiProperties {
    my $wmiClass = shift;
    my @keys = @_;

    my $WMIServices = Win32::OLE->GetObject(
        "winmgmts:{impersonationLevel=impersonate,(security)}!//./" );

    if (!$WMIServices) {
        print STDERR Win32::OLE->LastError();
    }

    my @properties;
    foreach my $value (Win32::OLE::in(
        $WMIServices->InstancesOf($wmiClass)
    )) {
    my $property;
        foreach my $key (@keys) {
            $property->{$key} = encodeFromWmi($value->{$key});
        }
        push @properties, $property;
    }

    return @properties;
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Tools::Win32 - Win32 generic functions

=head1 DESCRIPTION

This module provides some generic functions for Win32.

=head1 FUNCTIONS

=head2 getWmiProperties($class, @properties)

Returns the list of given properties from given WMI class, properly encoded.

=head2 encodeFromWmi($string)

Ensure given WMI content is properly encoded to utf-8.

=head2 encodeFromRegistry($string)

Ensure given registry content is properly encoded to utf-8.

