package FusionInventory::Agent::Task::Inventory::Linux::i386::CPU;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Linux;
use FusionInventory::Agent::Tools::Generic;

sub isEnabled {
    my (%params) = @_;
    return 0 if $params{no_category}->{cpu};
    return -r '/proc/cpuinfo';
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    foreach my $cpu (_getCPUs(logger => $logger)) {
        $inventory->addEntry(
            section => 'CPUS',
            entry   => $cpu
        );
    }
}

sub _getCPUs {
    my (%params) = @_;

    my @cpusFromDmidecode = $params{dmidecode} ?
        getCpusFromDmidecode(file => $params{dmidecode}) :
        getCpusFromDmidecode();
    my @cpusFromProc      = $params{cpuinfo} ?
        getCPUsFromProc(file => $params{cpuinfo}) :
        getCPUsFromProc();

    my @physicalCPUs = _getPhysicalCPUs(@cpusFromProc);
    my @baseCPUs = @cpusFromDmidecode ?
        @cpusFromDmidecode : @physicalCPUs;

    my $info = $cpusFromProc[-1];

    my $cpt = 0;
    my @cpus;

    foreach my $cpu (@baseCPUs) {

        $cpu->{MANUFACTURER} = getCanonicalManufacturer($info->{vendor_id});

        if ($info->{'model name'}) {
            $cpu->{NAME} = $info->{'model name'};
        }

        # Get directly informations from cpuinfo if not already processed
        # in dmidecode
        $cpu->{CORE} = $cpusFromProc[$cpt]{CORE}
            unless $cpu->{CORE};
        $cpu->{THREAD} = $cpusFromProc[$cpt]{THREAD}
            unless $cpu->{THREAD};
        $cpu->{STEPPING} = $cpusFromProc[$cpt]{STEPPING}
            unless $cpu->{STEPPING} ;
        $cpu->{FAMILYNUMBER} = $cpusFromProc[$cpt]{FAMILYNUMBER}
            unless $cpu->{FAMILYNUMBER};
        $cpu->{MODEL} = $cpusFromProc[$cpt]{MODEL}
            unless $cpu->{MODEL};

        if ($cpu->{NAME} =~ /([\d\.]+)s*(GHZ)/i) {
            $cpu->{SPEED} = {
               ghz => 1000,
               mhz => 1,
            }->{lc($2)} * $1;
        }

        $cpu->{ARCH} = 'i386';

        push @cpus, $cpu;
        $cpt++;
    }

    return @cpus;
}

sub _getPhysicalCPUs {
    my (@cpus) = @_;

    my @physical_cpus;

    # push all cpus without any physical CPU id directly
    foreach my $cpu (grep { !defined $_->{'physical id'} } @cpus) {
        push @physical_cpus, {
            STEPPING     => $cpu->{'stepping'},
            FAMILYNUMBER => $cpu->{'cpu family'},
            MODEL        => $cpu->{'model'},
            CORE         => 1,
            THREAD       => 1
        };
    }

    # push cpus with a physical CPU identifier once only
    my %seen;
    foreach my $cpu (grep { defined $_->{'physical id'} } @cpus) {
        next if $seen{$cpu->{'physical id'}}++;
        push @physical_cpus, {
            STEPPING     => $cpu->{'stepping'},
            FAMILYNUMBER => $cpu->{'cpu family'},
            MODEL        => $cpu->{'model'},
            CORE         => $cpu->{'cpu cores'},
            THREAD       => $cpu->{'siblings'} / ($cpu->{'cpu cores'} || 1)
        };
    }

    return @physical_cpus;
}

1;
