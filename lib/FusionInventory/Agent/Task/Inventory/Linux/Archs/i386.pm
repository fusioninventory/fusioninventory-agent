package FusionInventory::Agent::Task::Inventory::Linux::Archs::i386;

use strict;
use warnings;

use Config;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Linux;
use FusionInventory::Agent::Tools::Generic;

sub isEnabled {
    return
        $Config{archname} =~ /^(i\d86|x86_64)/ &&
        (
            -r '/proc/cpuinfo'
        );
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

        if ($info->{vendor_id}) {
            $info->{vendor_id} =~ s/Genuine//;
            $info->{vendor_id} =~ s/(TMx86|TransmetaCPU)/Transmeta/;
            $info->{vendor_id} =~ s/CyrixInstead/Cyrix/;
            $info->{vendor_id} =~ s/CentaurHauls/VIA/;
            $info->{vendor_id} =~ s/AuthenticAMD/AMD/;

            $cpu->{MANUFACTURER} = $info->{vendor_id};
        }

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
    my %cpus;

    foreach my $cpu (@cpus) {
        my $id = $cpu->{'physical id'};
        if (defined $id) {
            $cpus{$id}{STEPPING}     = $cpu->{'stepping'};
            $cpus{$id}{FAMILYNUMBER} = $cpu->{'cpu family'};
            $cpus{$id}{MODEL}        = $cpu->{'model'};
            $cpus{$id}{CORE}         = $cpu->{'cpu cores'};
            $cpus{$id}{THREAD}       = $cpu->{'siblings'} / ($cpu->{'cpu cores'} || 1);
        } else {
            push @physical_cpus, {
                STEPPING     => $cpu->{'stepping'},
                FAMILYNUMBER => $cpu->{'cpu family'},
                MODEL        => $cpu->{'model'},
                CORE         => 1,
                THREAD       => 1
            }
        }
    }

    # physical id may not start at 0!
    push @physical_cpus, values %cpus if %cpus;

    return @physical_cpus;
}

1;
