package FusionInventory::Agent::Task::Inventory::OS::Win32;

use strict;
use vars qw($runAfter);
$runAfter = ["FusionInventory::Agent::Task::Inventory::OS::Generic"];


sub getWmiProperties {
    my $wmiClass = shift;
    my @keys = @_;

    eval {' 
        use Win32::OLE qw(in CP_UTF8);
        use Win32::OLE::Const;

        Win32::OLE->Option(CP => CP_UTF8);

        use Encode qw(encode)';
    };
    if ($@) {
        print "STDERR, Failed to load Win32::OLE: $@\n";
        return;
    }

    my $WMIServices = Win32::OLE->GetObject(
            "winmgmts:{impersonationLevel=impersonate,(security)}!//./" );


    if (!$WMIServices) {
        print STDERR Win32::OLE->LastError();
    }


    my $encodeNeeded = (Win32::GetOSName() ne 'Win7');
    my @properties;
    foreach my $properties ( Win32::OLE::in( $WMIServices->InstancesOf(
                    $wmiClass ) ) )
    {
        my $tmp;
        foreach (@keys) {
            my $val = $properties->{$_};
            $val = Encode::encode($val) if $encodeNeeded;
            $tmp->{$_} = $val;
        }
        push @properties, $tmp;
    }

    return @properties;
}


sub isInventoryEnabled { $^O =~ /^MSWin32$/ }

sub doInventory {

}

1;
