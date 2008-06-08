package Ocsinventory::Agent::Backend::OS::MacOS::Bios;
use strict;

sub check { return can_load("Mac::SysProfile") }

sub run {
        my $params = shift;
        my $inventory = $params->{inventory};

        # use Mac::SysProfile to get the respected datatype
        my $prof = Mac::SysProfile->new();
        my $nfo = $prof->gettype('SPHardwareDataType');

        # unless we get a real hash value, return with nothing
        return(undef) unless($nfo && ref($nfo) eq 'HASH');

        # set the bios informaiton from the apple system profiler
        $inventory->setBios({
                SMANUFACTURER   => 'Apple Inc', # duh
                SMODEL          => $nfo->{'Hardware Overview'}->{'Model Identifier'},
                SSN             => $nfo->{'Hardware Overview'}->{'Serial Number'},
                BVERSION        => $nfo->{'Hardware Overview'}->{'Boot ROM Version'},
        });
}

1;
