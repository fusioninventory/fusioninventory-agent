package FusionInventory::Agent::Task::Inventory::OS::Solaris::Slots;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Solaris;

sub isInventoryEnabled {
    return can_run('prtdiag');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    my $class = getClass();

    my @slots = 
        $class == 4 ? _getSlots4() :
        $class == 5 ? _getSlots5() :
                      _getSlotsDefault() ;

    foreach my $slot (@slots) {
        $inventory->addSlot($slot);
    }
}

sub _getSlots4 {

    my @slots;

    foreach (`prtdiag`) {
        next unless /pci/;
        my @pci = split(/ +/);
        push @slots, {
            DESCRIPTION => $pci[0] . " (" . $pci[1] . ")",
            DESIGNATION => $pci[3],
            NAME        => $pci[4] . " " . $pci[5],
        };
    }

    return @slots;
}

sub _getSlots5 {

    my @slots;
    my $flag;
    my $flag_pci;
    my $name;
    my $description;
    my $designation;
    my $status;

    foreach (`prtdiag`) {
        last if(/^\=+/ && $flag_pci && $flag);

        if($flag && $flag_pci && /^\s+(\d+)/){
            $name = "LSB " . $1;
        }
        if($flag && $flag_pci && /^\s+\S+\s+(\S+)/){
            $description = $1;
        }
        if($flag && $flag_pci && /^\s+\S+\s+\S+\s+(\S+)/){
            $designation = $1;
        }

        #Debug
        #if ($flag && $flag_pci){print "$name" . "||||" . "$designation" . "||" . "$description\n";}
        #print $_."\n";

        if($flag && $flag_pci){
            push @slots, {
                DESCRIPTION =>  $description,
                DESIGNATION =>  $designation,
                NAME            =>  $name,
            };
        }
        if(/^=+\S+\s+IO Cards/){$flag_pci = 1;  }
        if($flag_pci && /^-+/){$flag = 1;}
    }

    return @slots;
}

sub _getSlotsDefault {

    my @slots;
    my $flag;
    my $flag_pci;
    my $name;
    my $description;
    my $designation;
    my $status;

    # default case
    foreach (`prtdiag`) {
        last if(/^\=+/ && $flag_pci);
        next if(/^\s+/ && $flag_pci);
        if($flag && $flag_pci && /^(\S+)\s+/){
            $name = $1;
        }
        if($flag && $flag_pci && /(\S+)\s*$/){
            $designation = $1;
        }
        if($flag && $flag_pci && /^\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+(\S+)/){
            $description = $1;
        }
        if($flag && $flag_pci && /^\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+(\S+)/){
            $status = $1;
        }
        if($flag && $flag_pci){
            push @slots, {
                DESCRIPTION =>  $description,
                DESIGNATION =>  $designation,
                NAME            =>  $name,
                STATUS          =>  $status,
            };
        }
        if(/^=+\s+IO Cards/){$flag_pci = 1;}
        if($flag_pci && /^-+/){$flag = 1;}
    }

    return @slots;
}

1;
