package FusionInventory::Agent::Task::Inventory::OS::MacOS::Bios;

use strict;
use warnings;

sub isInventoryEnabled { return can_load("Mac::SysProfile") }

sub doInventory {
        my $params = shift;
        my $inventory = $params->{inventory};

        # use Mac::SysProfile to get the respected datatype
        my $prof = Mac::SysProfile->new();
        my $nfo = $prof->gettype('SPHardwareDataType');

        # unless we get a real hash value, return with nothing
        return(undef) unless($nfo && ref($nfo) eq 'HASH');
		
		my $h = $nfo->{'Hardware Overview'};

        # set the bios informaiton from the apple system profiler
        $inventory->setBios({
                SMANUFACTURER   => 'Apple Inc', # duh
                SMODEL          => $h->{'Model Identifier'} || $h->{'Machine Model'},
        #       SSN             => $h->{'Serial Number'}
        # New method to get the SSN, because of MacOS 10.5.7 update
        # system_profiler gives 'Serial Number (system): XXXXX' where 10.5.6
        # and lower give 'Serial Number: XXXXX'
                SSN             => $h->{'Serial Number'} || $h->{'Serial Number (system)'},
                BVERSION        => $h->{'Boot ROM Version'},
        });


            $inventory->setHardware({
                    UUID => $h->{'Hardware UUID'}
                });
}

1;
