package FusionInventory::Agent::Task::Inventory::Input::MacOS::CPU;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isEnabled {
    return 
        -r '/usr/sbin/system_profiler' &&
        canLoad("Mac::SysProfile");
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    my $prof = Mac::SysProfile->new();
    my $info = $prof->gettype('SPHardwareDataType');
    return unless ref $info eq 'HASH';

    $info = $info->{'Hardware Overview'};

    my $type  = $info->{'Processor Name'} ||
                $info->{'CPU Type'};
    my $cpus  = $info->{'Number Of Processors'} ||
                $info->{'Number Of CPUs'}       ||
                1;
    my $speed = $info->{'Processor Speed'} ||
                $info->{'CPU Speed'};
    # French Mac returns 2,60 Ghz instead of 2.60 Ghz :D
    $speed =~ s/,/./;

    if ($speed =~ /GHz$/i) {
        $speed =~ s/GHz//i;
        $speed = $speed * 1000;
    } elsif ($speed =~ /MHz$/i){
        $speed =~ s/MHz//i;
    }
    $speed =~ s/\s//g;

    my $cores =
        $info->{'Total Number Of Cores'} ? $info->{'Total Number Of Cores'} / $cpus :
                                           1                                        ;

    my $manufacturer =
        $type =~ /Intel/i ? "Intel" :
        $type =~ /AMD/i   ? "AMD"   :
                            undef   ;

    foreach (1 .. $cpus) {
        $inventory->addEntry(
            section => 'CPUS',
            entry   => {
                CORE         => $cores,
                MANUFACTURER => $manufacturer,
                NAME         => $type,
                THREAD       => 1,
                SPEED        => $speed
            }
        );
    }

    ### mem convert it to meg's if it comes back in gig's
    my $mem = $info->{'Memory'};
    if ($mem =~ /GB$/){
        $mem =~ s/\sGB$//;
        $mem = ($mem * 1024);
    } elsif ($mem =~ /MB$/){
        $mem =~ s/\sMB$//;
    }

    $inventory->setHardware({
        MEMORY => $mem,
    });
}

1;
