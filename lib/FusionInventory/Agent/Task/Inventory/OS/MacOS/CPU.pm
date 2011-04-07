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
    my $info = $prof->gettype('SPHardwareDataType');
    return unless ref $info eq 'HASH';

    $info = $info->{'Hardware Overview'};

    ######### CPU
    my $processort  = $info->{'Processor Name'} || $info->{'CPU Type'}; # 10.5 || 10.4
    my $processorn  = $info->{'Number Of Processors'} || $info->{'Number Of CPUs'} || 1;
    my $processors  = $info->{'Processor Speed'} || $info->{'CPU Speed'};
    my $processorCore;
    if ($info->{'Total Number Of Cores'}) {
        $processorCore = $info->{'Total Number Of Cores'} / $processorn;
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
    my $mem = $info->{'Memory'};
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
