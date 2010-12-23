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

    my $description;
    my $designation;
    my $name;
    my $status;
    my @pci;
    my $flag;
    my $flag_pci;

    my $class = getClass();

    SWITCH: {
        if ($class == 4) {
            foreach (`prtdiag`) {
                if (/pci/) {
                    @pci = split(/ +/);
                    $name=$pci[4]." ".$pci[5];
                    $description=$pci[0]." (".$pci[1].")";
                    $designation=$pci[3];
                    $status="";
                    $inventory->addSlot({
                        DESCRIPTION =>  $description,
                        DESIGNATION =>  $designation,
                        NAME            =>  $name,
                        STATUS          =>  $status,
                    });
                }
            }
            last SWITCH;
        }

        if ($class == 5) {
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
                $status = " ";

                #Debug
                #if ($flag && $flag_pci){print "$name" . "||||" . "$designation" . "||" . "$description\n";}
                #print $_."\n";

                if($flag && $flag_pci){
                    $inventory->addSlot({
                            DESCRIPTION =>  $description,
                            DESIGNATION =>  $designation,
                            NAME            =>  $name,
                            STATUS          =>  $status,
                        });
                }
                if(/^=+\S+\s+IO Cards/){$flag_pci = 1;  }
                if($flag_pci && /^-+/){$flag = 1;}
            }
            last SWITCH;
        }

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
                $inventory->addSlot({
                        DESCRIPTION =>  $description,
                        DESIGNATION =>  $designation,
                        NAME            =>  $name,
                        STATUS          =>  $status,
                    });
            }
            if(/^=+\s+IO Cards/){$flag_pci = 1;}
            if($flag_pci && /^-+/){$flag = 1;}
        }
    }
}

1;
