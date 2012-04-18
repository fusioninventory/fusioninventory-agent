package FusionInventory::Agent::Task::Inventory::Input::MacOS::CPU;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::MacOS;

sub isEnabled {
    return 
        -r '/usr/sbin/system_profiler';
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger = $params{logger};

    # System profiler informations
    my $infos = getSystemProfilerInfos(@_);

    # Get more informations from sysctl
    my $handle = getFileHandle (
        logger  => $logger,
        command => 'sysctl -a machdep.cpu'
    );


    # add sysctl informations into profiler informations
    my $info = $infos->{'Hardware'}->{'Hardware Overview'};

    while (my $line = <$handle>) {
        chomp $line;
        if ($line =~ /(.+) : \s (.+)/x) {
            $info->{$1}=$2;
        }
    }



    my $type  = $info->{'Processor Name'} ||
                $info->{'CPU Type'};
    my $cpus  = $info->{'Number Of Processors'} ||
                $info->{'Number Of CPUs'}       ||
                1;
    my $speed = $info->{'Processor Speed'} ||
                $info->{'CPU Speed'};

    my $stepping = $info->{'machdep.cpu.stepping'};

    my $family = $info->{'machdep.cpu.family'};

    my $model =  $info->{'machdep.cpu.model'};

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
                FAMILYNUMBER => $family,
                MODEL        => $model,
                STEPPING     => $stepping,
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
