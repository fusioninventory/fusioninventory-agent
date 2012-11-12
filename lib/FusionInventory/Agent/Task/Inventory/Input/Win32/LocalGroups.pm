package FusionInventory::Agent::Task::Inventory::Input::Win32::LocalGroups;

use strict;
use warnings;

use constant wbemFlagReturnImmediately => 0x10;
use constant wbemFlagForwardOnly => 0x20;

use English qw(-no_match_vars);
use Win32::OLE;
use Win32::OLE::Variant;
use Win32::TieRegistry (
    Delimiter   => '/',
    ArrayValues => 0,
    qw/KEY_READ/
);

Win32::OLE->Option(CP => Win32::OLE::CP_UTF8);


use FusionInventory::Agent::Tools::Win32;

my $seen;

sub isEnabled {
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    my $WMIService = Win32::OLE->GetObject("winmgmts:\\\\.\\root\\CIMV2")
        or die "WMI connection failed: " . Win32::OLE->LastError();

    my $processes = $WMIService->ExecQuery(
        "SELECT * FROM Win32_Group  Where LocalAccount = True", "WQL",
        wbemFlagReturnImmediately | wbemFlagForwardOnly ## no critic (ProhibitBitwise)
    );

 
    foreach my $group (in $processes) {
  my $members = $WMIService->ExecQuery(
        "SELECT * FROM Win32_GroupUser where GroupComponent =\"Win32_Group.Name=\"$group->{Name}\" ", "WQL",
        wbemFlagReturnImmediately | wbemFlagForwardOnly ## no critic (ProhibitBitwise)
    );
    foreach my $member (in $members) {
      print "Group: $member->{GroupComponent}\n";
      print "user: $member->{PartComponent}\n";
    } 
  print "group is $group\n";
      print "Local Account: $group->{LocalAccount}\n";
      print "Name: $group->{Name}\n";
      print "SID: $group->{SID}\n";

     
    }

}

1;
