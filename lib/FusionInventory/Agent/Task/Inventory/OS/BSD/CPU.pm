package FusionInventory::Agent::Task::Inventory::OS::BSD::CPU;

use strict;
use warnings;

sub isInventoryEnabled {
    return 
        -r "/dev/mem" && # why is this needed ?
        can_run('dmidecode');
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $processort;
    my $processorn;
    my $processors;

    my @cpu;

    my $in;
    my $frequency;
    my $serial;
    my $manufacturer;
    my $thread;
    my $name;
    my $family;
    foreach (`dmidecode`) {
        $in = 1 if /^\s*Processor Information/;

        if ($in) {
            $frequency = $1 if /^\s*Max Speed:\s*(\d+)\s*MHz/i;
            $frequency = $1*1000 if /^\s*Max Speed:\s*(\d+)\s*GHz/i;
            $serial = $1 if /^\s*ID:\s*(\S.+)/i;
            $manufacturer = $1 if /Manufacturer:\s*(\S.*)/;
            $thread = int($1) if /Thread Count:\s*(\S.*)/;
            $name = $1 if /Version:\s*(\S.*)/;
            $family = $1 if /Family:\s*(\S.*)/;
        }

        if ($in && /^\s*$/) {
            $in = 0;
            $serial =~ s/\s//g;
            $thread = 1 unless $thread;

            chomp(my $hwModel = `sysctl -n hw.model`);

            if ($hModel =~ /([\.\d]+)GHz/) {
                $speed = $1 * 1000;
            }
            $name =~ s/^Not Specified$//;
            push @cpu, {
                SPEED => $frequency,
                MANUFACTURER => $manufacturer,
                SERIAL => $serial,
# Thread per core according to my understanding of
# http://www.amd.com/us-en/assets/content_type/white_papers_and_tech_docs/25481.pdf
                THREAD => $thread,
                NAME => $hwModel || $name || $family
            };

	    $frequency = undef;
	    $serial = undef;
	    $manufacturer = undef;
	    $thread = undef;
	    $name = undef;
	    $family = undef;

        }
    }




    foreach (@cpu) {
        $inventory->addCPU($_);
    }

}
1;
