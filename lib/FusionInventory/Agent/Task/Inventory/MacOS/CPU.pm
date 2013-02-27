package FusionInventory::Agent::Task::Inventory::MacOS::CPU;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::MacOS;

sub isEnabled {
    return canRun('/usr/sbin/system_profiler');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger = $params{logger};

    my $sysprofile = getSystemProfilerInfos(@_);



    foreach my $cpu (_getCpus(logger => $logger)) {
        $inventory->addEntry(
            section => 'CPUS',
            entry   => $cpu
        );
    }


    ### mem convert it to meg's if it comes back in gig's
    my $mem = $sysprofile->{'Hardware'}{'Hardware Overview'}{'Memory'};
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

sub _getCpus{

    my (%params) = @_;
    my $logger = $params{logger};
    my $sysctlfile  = $params{sysctl};

   # Get more informations from sysctl
    my $sysctl = getFileHandle (
        logger  => $logger,
        command => 'sysctl -a machdep.cpu',
        file    => $sysctlfile
    );

    # System profiler informations
    my $sysprofile = getSystemProfilerInfos(@_);


    #add sysctl informations into profiler informations
    my $info = $sysprofile->{'Hardware'}->{'Hardware Overview'};

    while (my $line = <$sysctl>) {
        chomp $line;
        if ($line =~ /(.+) : \s (.+)/x) {
            $info->{$1} = $2;
        }
    }

    my $type  = $info->{'Processor Name'} ||
                $info->{'CPU Type'};
    my $procs = $info->{'Number Of Processors'} ||
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
        $info->{'Total Number Of Cores'} ? $info->{'Total Number Of Cores'} / $procs :
                                           $info->{'machdep.cpu.core_count'};

    my $threads = $info->{'machdep.cpu.thread_count'};


    my $manufacturer =
        $type =~ /Intel/i ? "Intel" :
        $type =~ /AMD/i   ? "AMD"   :
                            undef   ;

    my @cpus;
    my $cpu={
        CORE         => $cores,
        MANUFACTURER => $manufacturer,
        NAME         => $type,
        THREAD       => $threads,
        FAMILYNUMBER => $family,
        MODEL        => $model,
        STEPPING     => $stepping,
        SPEED        => $speed
    };

    for (my $i=0;$i<$procs;$i++) {
        push @cpus, $cpu;
    }

    return @cpus;

}



1;
