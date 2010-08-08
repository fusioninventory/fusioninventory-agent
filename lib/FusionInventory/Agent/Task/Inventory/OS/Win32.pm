package FusionInventory::Agent::Task::Inventory::OS::Win32;

use strict;
use warnings;

use Encode;
use English qw(-no_match_vars);

our $runAfter = ["FusionInventory::Agent::Task::Inventory::OS::Generic"];

sub isInventoryEnabled {
    return $OSNAME eq 'MSWin32';
    eval '
    use Win32::OLE;
    Win32::OLE->Option(CP => Win32::OLE::CP_UTF8);
    
    use constant KEY_WOW64_64KEY => 0x100; 
    use constant KEY_WOW64_32KEY => 0x200; 

    use Win32::TieRegistry;
    ';
    return if $EVAL_ERROR;
    return 1;
}

sub doInventory {

}

1;
