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

    my @dmidecodeInfos = $params{dmidecode} ?
        getCpusFromDmidecode(file => $params{dmidecode}) :
        getCpusFromDmidecode();

    my $count = 0;
    my @cpus;
    my %seen;

    foreach my $logicalCpu (getCPUsFromProc(@_)) {
        my $cpuId = $logicalCpu->{'physical id'};
        my ($core, $thread);
        if (defined $cpuId) {
            next if $seen{$cpuId}++;
            $core   = $logicalCpu->{'cpu cores'};
            $thread = $logicalCpu->{'siblings'};
        } else {
            $cpuId  = $count;
            $core   = 1;
            $thread = 1;
        }

        my $dmidecodeInfo = $dmidecodeInfos[$cpuId];

        my $cpu = {
            ARCH           => 'i386',
            MANUFACTURER   => getCanonicalManufacturer($logicalCpu->{vendor_id}),
            STEPPING       => $logicalCpu->{'stepping'} ||
                              $dmidecodeInfo->{STEPPING},
            FAMILYNUMBER   => $logicalCpu->{'cpu family'} ||
                              $dmidecodeInfo->{FAMILYNUMBER},
            MODEL          => $logicalCpu->{'model'} ||
                              $dmidecodeInfo->{MODEL},
            NAME           => $logicalCpu->{'model name'},
            CORE           => $core   || $dmidecodeInfo->{CORE}, 
            THREAD         => $thread || $dmidecodeInfo->{THREAD}
        };

        $cpu->{ID}     = $dmidecodeInfo->{ID} if $dmidecodeInfo->{ID};
        $cpu->{SERIAL} = $dmidecodeInfo->{SERIAL} if $dmidecodeInfo->{SERIAL};
        $cpu->{EXTERNAL_CLOCK} = $dmidecodeInfo->{EXTERNAL_CLOCK} if $dmidecodeInfo->{EXTERNAL_CLOCK};
        $cpu->{FAMILYNAME} = $dmidecodeInfo->{FAMILYNAME} if $dmidecodeInfo->{FAMILYNAME};

        if ($cpu->{NAME} =~ /([\d\.]+)s*(GHZ)/i) {
            $cpu->{SPEED} = {
               ghz => 1000,
               mhz => 1,
            }->{lc($2)} * $1;
        }

        push @cpus, $cpu;
        $count++;
    }

    return @cpus;
}

1;
