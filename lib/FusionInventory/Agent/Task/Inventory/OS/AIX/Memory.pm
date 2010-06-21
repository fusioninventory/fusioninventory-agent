package FusionInventory::Agent::Task::Inventory::OS::AIX::Memory;

use strict;
use warnings;

sub isInventoryEnabled { 1 } # TODO create a better check here

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $capacity;
    my $description;
    my $numslots;
    my $speed;
    my $type;
    my $n;
    my $serial;
    my $mversion;
    my $caption;
    my $flag=0;
    #lsvpd
    my @lsvpd = `lsvpd`;
    # Remove * (star) at the beginning of lines
    s/^\*// for (@lsvpd);

    $numslots = -1; 
    for(@lsvpd){
        if(/^DS Memory DIMM/){
            $description = $_;
            $flag=1; (defined($n))?($n++):($n=0);
            $description =~ s/DS //;
            $description =~ s/\n//;
        }
        if((/^SZ (.+)/) && ($flag)) {$capacity = $1;}
        if((/^PN (.+)/) && ($flag)) {$type = $1;}
        # localisation slot dans type
        if((/^YL\s(.+)/) && ($flag)) {$caption = "Slot ".$1;}
        if((/^SN (.+)/) && ($flag)) {$serial = $1;}
        if((/^VK (.+)/) && ($flag)) {$mversion = $1};
        #print $numslots."\n";
        # On rencontre un champ FC alors c'est la fin pour ce device
        if((/^FC .+/) && ($flag)) {
            $flag=0;
            $numslots = $numslots +1;
            $inventory->addMemory({
                    CAPACITY => $capacity,	
                    DESCRIPTION => $description,
                    CAPTION => $caption,
                    NUMSLOTS => $numslots,
                    VERSION => $mversion,
                    TYPE => $type,
                    SERIALNUMBER=> $serial,	

                })
        }; 
    }

    $numslots = $numslots +1;
    # End of Loop
    # The last *FC ???????? missing
    $inventory->addMemory({
        CAPACITY => $capacity,
        DESCRIPTION => $description,
        CAPTION => $caption,
        NUMSLOTS => $numslots,
        VERSION => $mversion,
        TYPE => $type,
        SERIALNUMBER=> $serial,
    });
}

1;
