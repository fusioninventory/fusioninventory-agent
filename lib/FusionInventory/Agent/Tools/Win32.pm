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
#    encode("UTF-8", $string); 

    return $string;
}

sub encodeFromRegistry {
    my ($string) = @_;

    return unless $string;

    if (!$localCodepage) {
	    no strict; # KEY!READ is nunknown
        my $lmachine = $Win32::TieRegistry::Registry->Open('LMachine', {
                Access => Win32::TieRegistry::KEY_READ
                }) or print "Failed to open LMachine";

        my $codepage =
	#$lmachine->{"SYSTEM/CurrentControlSet/Control/Nls/CodePage"} or warn;
            $lmachine->{"SYSTEM\\CurrentControlSet\\Control\\Nls\\CodePage"} or warn;

	    $localCodepage = "cp".$codepage->{ACP};
    }

    return encode("UTF-8", decode($localCodepage, $string));
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
    foreach my $value ( Win32::OLE::in( $WMIServices->InstancesOf(
                    $wmiClass ) ) )
    {
        my $property;
        foreach my $key (@keys) {
            $property->{$key} = encodeFromWmi($value->{$key});
        }
        push @properties, $property;
    }

    return @properties;
}

1;
