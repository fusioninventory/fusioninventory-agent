package FusionInventory::Agent::Task::Inventory::OS::MacOS::CPU;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return 
        -r '/usr/sbin/system_profiler' &&
        can_load("Mac::SysProfile");
}

sub doInventory {
    my ($params) = @_;

    my $inventory = $params->{inventory};

    my $prof = Mac::SysProfile->new();
    my $h = $prof->gettype('SPHardwareDataType');
    return unless ref($h) eq 'HASH';

    $h = $h->{'Hardware Overview'};

    ######### CPU
    my $processort  = $h->{'Processor Name'} || $h->{'CPU Type'}; # 10.5 || 10.4
    my $processorn  = $h->{'Number Of Processors'} || $h->{'Number Of CPUs'} || 1;
    my $processors  = $h->{'Processor Speed'} || $h->{'CPU Speed'};
    my $processorCore;
    if ($h->{'Total Number Of Cores'}) {
        $processorCore = $h->{'Total Number Of Cores'} / $processorn;
    } else {
        $processorCore = 1;
    }
    my $manufacturer;
    if ($processort =~ /Intel/i) {
        $manufacturer = "Intel";
    } elsif ($processort =~ /AMD/i) { # Maybe one day :)
        $manufacturer = "AMD";
    }
# French Mac returns 2,60 Ghz instead of
# 2.60 Ghz :D
    $processors =~ s/,/./;

    # lamp spits out an sql error if there is something other than an int (MHZ) here....
    if($processors =~ /GHz$/i){
            $processors =~ s/GHz//i;
            $processors = ($processors * 1000);
    } elsif($processors =~ /MHz$/i){
            $processors =~ s/MHz//i;
    }
    $processors =~ s/\s//g;


    foreach(1..$processorn) {
        $inventory->addCPU ({
            CORE => $processorCore,
            MANUFACTURER => $manufacturer,
            NAME => $processort,
            THREAD => 1,
            SPEED => $processors
        });
    }

    ### mem convert it to meg's if it comes back in gig's
    my $mem = $h->{'Memory'};
    if($mem =~ /GB$/){
        $mem =~ s/\sGB$//;
        $mem = ($mem * 1024);
    }
    if($mem =~ /MB$/){
        $mem =~ s/\sMB$//;
    }


    $inventory->setHardware({
        MEMORY => $mem,
    });
}

1;
