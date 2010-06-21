package FusionInventory::Agent::Task::Inventory::OS::Solaris::CPU;

use strict;
use warnings;

sub isInventoryEnabled {
    return can_run ("memconf");
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $cpu_slot;
    my $cpu_speed;
    my $cpu_type;

    my $model;
    my $sun_class_cpu=0;
    # first, we need determinate on which model of Sun Server we run,
    # because prtdiags output (and with that memconfs output) is differend
    # from server model to server model
    # we try to classified our box in one of the known classes

    $model=`uname -i`;
    # debug print model
    # print "Model: $model";
    # cut the CR from string model
    $model = substr($model, 0, length($model)-1);
    # we map (hopfully) our server model to a known class
    #
    #	#sun_class_cpu	sample out from memconf
    #     0               (default)		generic detection with prsinfo
    #	1               Sun Microsystems, Inc. Sun Fire 880 (4 X UltraSPARC-III 750MHz)
    #	2               Sun Microsystems, Inc. Sun Fire V490 (2 X dual-thread UltraSPARC-IV 1350MHz)
    #	3               Sun Microsystems, Inc. Sun-Fire-T200 (Sun Fire T2000) (8-core quad-thread UltraSPARC-T1 1000MHz)
    #	4		Sun Microsystems, Inc. SPARC Enterprise T5220 (4-core 8-thread UltraSPARC-T2 1165MHz)
    #
    #if ($model eq "SUNW,Sun-Fire-280R") { $sun_class_cpu = 1; }
    #if ($model eq "SUNW,Sun-Fire-480R") { $sun_class_cpu = 1; }
    #if ($model eq "SUNW,Sun-Fire-V240") { $sun_class_cpu = 1; }
    #if ($model eq "SUNW,Sun-Fire-V245") { $sun_class_cpu = 1; }  
    #if ($model eq "SUNW,Sun-Fire-V250") { $sun_class_cpu = 1; }
    #if ($model eq "SUNW,Sun-Fire-V440") { $sun_class_cpu = 1; }
    #if ($model eq "SUNW,Sun-Fire-V445") { $sun_class_cpu = 1; }
    #if ($model eq "SUNW,Sun-Fire-880") { $sun_class_cpu = 1; }
    #if ($model eq "SUNW,Sun-Fire-V490") { $sun_class_cpu = 2; }
    #if ($model eq "SUNW,Netra-T12") { $sun_class_cpu = 2; }	
    #if ($model eq "SUNW,Sun-Fire-T200") { $sun_class_cpu = 3; } 
    #if ($model eq "SUNW,SPARC-Enterprise-T1000") { $sun_class_cpu = 4; }
    #if ($model eq "SUNW,SPARC-Enterprise-T5220") { $sun_class_cpu = 4; }
    #if ($model eq "SUNW,SPARC-Enterprise-T5240") { $sun_class_cpu = 4; }
    #if ($model eq "SUNW,SPARC-Enterprise-T5120") { $sun_class_cpu = 4; }
    #if ($model eq "SUNW,SPARC-Enterprise") { $sun_class_cpu = 4; } 

    if ($model  =~ /SUNW,SPARC-Enterprise-T\d/){ $sun_class_cpu = 4; }
    if ($model  =~ /SUNW,Netra-T/){ $sun_class_cpu = 2; }
    if ($model  =~ /SUNW,Sun-Fire-V/){ $sun_class_cpu = 1; }  
    if ($model  =~ /SUNW,Sun-Fire-T\d/) { $sun_class_cpu = 3; }
    if ($model  =~ /SUNW,Sun-Fire-\d/){ $sun_class_cpu = 1; }  

    if ($sun_class_cpu == 0) {
        # if our maschine is not in one of the sun classes from upside, we use psrinfo
        # a generic methode
        foreach (`psrinfo -v`) {
            if (/^\s+The\s(\w+)\sprocessor\soperates\sat\s(\d+)\sMHz,/) {
                $cpu_type = $1;
                $cpu_speed = $2;
                $cpu_slot++;
            }
        }
    }

    if ($sun_class_cpu == 1) {
        foreach (`memconf 2>&1`) {
            if(/^Sun Microsystems, Inc. Sun Fire\s+\S+\s+\((\d+)\s+X\s+(\S+)\s+(\d+)/) {
                $cpu_slot = $1;
                $cpu_type = $2;
                $cpu_speed = $3;
            } elsif (/^Sun Microsystems, Inc. Sun Fire\s+\S+\s+\((\S+)\s+(\d+)/) {
                $cpu_slot="1";
                $cpu_type=$1;
                $cpu_speed=$2;
            }
        }
    }

    if($sun_class_cpu == 2) {
        foreach (`memconf 2>&1`) {
            if(/^Sun Microsystems, Inc. Sun Fire\s+\S+\s+\((\d+)\s+X\s+(\S+)\s+(\S+)\s+(\d+)/) {
                $cpu_slot = $1;
                $cpu_type = $3 . " (" . $2 . ")";
                $cpu_speed = $4;
            }
        }
    }
    if($sun_class_cpu == 3) {
        foreach (`memconf 2>&1`) {
            if(/^Sun Microsystems, Inc.\s+\S+\s+\(\S+\s+\S+\s+\S+\)\s+\((\S+)\s+(\S+)\s+(\S+)\s+(\d+)/) {
                # T2000 has only one cCPU
                $cpu_slot = 1;
                $cpu_type = $3 . " (" . $1 . " " . $2 . ")";
                $cpu_speed = $4;
            }
        }
    }
    if ($sun_class_cpu == 4) {
        foreach (`memconf 2>&1`) {
            if(/^Sun Microsystems, Inc\..+\((\S+)\s+(\S+)\s+(\S+)\s+(\d+)(\w+)\)$/) {
                $cpu_slot = 1;
                $cpu_type = $3 . " (" . $1 . " " . $2 . ")";
                $cpu_speed = $4;
            }
        }
    }
    # for debug only
    #print "cpu_slot: " . $cpu_slot . "\n";
    #print "cpu_type: " . $cpu_type . "\n";
    #print "cpu_speed: " . $cpu_speed . "\n";

    # insert to values we have found
    $inventory->setHardware({
        PROCESSORT => $cpu_type,
        PROCESSORN => $cpu_slot,
        PROCESSORS => $cpu_speed
    });

}

1;
