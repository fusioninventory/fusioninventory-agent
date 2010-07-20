package FusionInventory::Agent::Task::Inventory::OS::Win32;

use strict;
use warnings;

use English qw(-no_match_vars);

our $runAfter = ["FusionInventory::Agent::Task::Inventory::OS::Generic"];

require Exporter;

our @ISA = qw(Exporter);
our @EXPORT = qw(getWmiProperties encodeFromWmi encodeFromRegistry);

use Encode;

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

    eval {
        require Win32::OLE;
        require Win32::OLE::Const;

        Win32::OLE->import(qw(in CP_UTF8));
        Win32::OLE->Option(CP => 'CP_UTF8');

        require Encode;
        Encode->import('encode');
    };
    if ($EVAL_ERROR) {
        print "STDERR, Failed to load Win32::OLE: $EVAL_ERROR\n";
        return;
    }

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


sub isInventoryEnabled {
    return $OSNAME eq 'MSWin32';
}

sub doInventory {

}

1;
