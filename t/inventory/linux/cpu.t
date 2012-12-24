#!/usr/bin/perl

use strict;
use warnings;

use Test::Deep;
use Test::More;

use FusionInventory::Agent::Task::Inventory::Input::Linux::Archs::i386;
use FusionInventory::Agent::Task::Inventory::Input::Linux::Archs::Alpha;
use FusionInventory::Agent::Task::Inventory::Input::Linux::Archs::SPARC;
use FusionInventory::Agent::Task::Inventory::Input::Linux::Archs::MIPS;
use FusionInventory::Agent::Task::Inventory::Input::Linux::Archs::ARM;
use FusionInventory::Agent::Task::Inventory::Input::Linux::Archs::PowerPC;

my %i386 = (
    'linux-686-1' => {
        procs => {
          'cache size'    => '2048 KB',
          'clflush size'  => '64',
          'model'         => '13',
          'cpu family'    => '6',
          'bogomips'      => '3462.27',
          'hlt_bug'       => 'no',
          'cpu mhz'       => '1729.038',
          'stepping'      => '8',
          'cpuid level'   => '2',
          'flags'         => 'fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat clflush dts acpi mmx fxsr sse sse2 ss tm pbe nx bts est tm2',
          'processor'     => '0',
          'vendor_id'     => 'GenuineIntel',
          'model name'    => 'Intel(R) Pentium(R) M processor 1.73GHz',
          'fpu'           => 'yes',
          'f00f_bug'      => 'no',
          'fpu_exception' => 'yes',
          'fdiv_bug'      => 'no',
          'coma_bug'      => 'no',
          'wp'            => 'yes'
        },
        cores => [
            {
                STEPPING     => 8,
                FAMILYNUMBER => 6,
                MODEL        => 13,
                THREAD       => 1,
                CORE         => 1
            }
        ]
    },
    'linux-686-samsung-nc10-1' => {
        procs => {
          'cache size'      => '512 KB',
          'address sizes'   => '32 bits physical, 32 bits virtual',
          'clflush size'    => '64',
          'physical id'     => '0',
          'model'           => '28',
          'cpu family'      => '6',
          'bogomips'        => '3192.61',
          'hlt_bug'         => 'no',
          'cpu mhz'         => '800.000',
          'cache_alignment' => '64',
          'stepping'        => '2',
          'cpuid level'     => '10',
          'core id'         => '0',
          'flags'           => 'fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe constant_tsc arch_perfmon pebs bts aperfmperf pni dtes64 monitor ds_cpl est tm2 ssse3 xtpr pdcm movbe lahf_lm',
          'processor'       => '1',
          'vendor_id'       => 'GenuineIntel',
          'cpu cores'       => 1,
          'initial apicid'  => '1',
          'model name'      => 'Intel(R) Atom(TM) CPU N270   @ 1.60GHz',
          'fpu'             => 'yes',
          'siblings'        => 2,
          'apicid'          => '1',
          'fpu_exception'   => 'yes',
          'f00f_bug'        => 'no',
          'fdiv_bug'        => 'no',
          'wp'              => 'yes',
          'coma_bug'        => 'no'
        },
        cores => [
            {
                STEPPING     => 2,
                FAMILYNUMBER => 6,
                MODEL        => 28,
                THREAD => '2',
                CORE   => '1'
            }
        ]
    },
    'linux-2.6.35-1-core-2-thread' => {
        procs => {
            'cache size'      => '512 KB',
            'address sizes'   => '32 bits physical, 32 bits virtual',
            'clflush size'    => '64',
            'physical id'     => '0',
            'model'           => '28',
            'cpu family'      => '6',
            'bogomips'        => '3191.96',
            'hlt_bug'         => 'no',
            'cpu mhz'         => '800.000',
            'cache_alignment' => '64',
            'stepping'        => '2',
            'cpuid level'     => '10',
            'core id'         => '0',
            'flags'           => 'fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe nx constant_tsc arch_perfmon pebs bts aperfmperf pni dtes64 monitor ds_cpl est tm2 ssse3 xtpr pdcm movbe lahf_lm',
            'processor'       => '1',
            'vendor_id'       => 'GenuineIntel',
            'cpu cores'       => 1,
            'initial apicid'  => '1',
            'model name'      => 'Intel(R) Atom(TM) CPU N270   @ 1.60GHz',
            'fpu'             => 'yes',
            'siblings'        => 2,
            'apicid'          => '1',
            'fpu_exception'   => 'yes',
            'f00f_bug'        => 'no',
            'fdiv_bug'        => 'no',
            'wp'              => 'yes',
            'coma_bug'        => 'no'
        },
        cores => [
            {
                STEPPING     => 2,
                FAMILYNUMBER => 6,
                MODEL        => 28,
                THREAD => '2',
                CORE => '1'
            }
        ]
    },

# IMPORTANT : this /proc/cpuinfo is _B0RKEN_, physical_id are not correct
# please see bug: #505
    'linux-hp-dl180' => {
        procs => {
            'cache size'      => '4096 KB',
            'address sizes'   => '40 bits physical, 48 bits virtual',
            'clflush size'    => '64',
            'physical id'     => '1',
            'model'           => '26',
            'cpu family'      => '6',
            'bogomips'        => '4000.00',
            'hlt_bug'         => 'no',
            'cpu mhz'         => '2000.090',
            'cache_alignment' => '64',
            'stepping'        => '5',
            'cpuid level'     => '11',
            'core id'         => '2',
            'flags'           => 'fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe nx rdtscp lm con$',
            'processor'       => '2',
            'vendor_id'       => 'GenuineIntel',
            'cpu cores'       => 4,
            'initial apicid'  => '20',
            'model name'      => 'Intel(R) Xeon(R) CPU           E5504  @ 2.00GHz',
            'fpu'             => 'yes',
            'siblings'        => 4,
            'apicid'          => '20',
            'fpu_exception'   => 'yes',
            'f00f_bug'        => 'no',
            'fdiv_bug'        => 'no',
            'wp'              => 'yes',
            'coma_bug'        => 'no'
        },
        cores => [
            {
                STEPPING     => 5,
                FAMILYNUMBER => 6,
                MODEL        => 26,
                THREAD => '1',
                CORE   => '4'
            }
        ]
    },
    'toshiba-r630-2-core' => {
        procs => {
            'cache size'      => '3072 KB',
            'address sizes'   => '36 bits physical, 48 bits virtual',
            'clflush size'    => '64',
            'physical id'     => '0',
            'model'           => '37',
            'cpu family'      => '6',
            'bogomips'        => '4521.44',
            'cpu mhz'         => '933.000',
            'cache_alignment' => '64',
            'stepping'        => '5',
            'core id'         => '2',
            'cpuid level'     => '11',
            'flags'           => 'fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx rdtscp lm constant_tsc arch_perfmon pebs bts rep_good xtopology nonstop_tsc aperfmperf pni dtes64 monitor ds_cpl vmx est tm2 ssse3 cx16 xtpr pdcm sse4_1 sse4_2 popcnt lahf_lm arat tpr_shadow vnmi flexpriority ept vpid',
            'processor'       => '3',
            'vendor_id'       => 'GenuineIntel',
            'cpu cores'       => 2,
            'initial apicid'  => '5',
            'model name'      => 'Intel(R) Core(TM) i3 CPU       M 350  @ 2.27GHz',
            'fpu'             => 'yes',
            'siblings'        => 4,
            'apicid'          => '5',
            'fpu_exception'   => 'yes',
            'wp'              => 'yes'
        },
        cores => [
            {
                STEPPING     => 5,
                FAMILYNUMBER => 6,
                MODEL        => 37,
                THREAD => '2',
                CORE   => '2'
            }
        ]
    }
);

my %alpha = (
    'linux-alpha-1' => [
        {
            SERIAL => 'JA30502089',
            ARCH   => 'Alpha',
            SPEED  => '1250',
            TYPE   => undef
        }
    ]
);

my %sparc = (
    'linux-sparc-1' => [
        {
            ARCH => 'SPARC',
            TYPE => 'TI UltraSparc IIIi (Jalapeno)'
        },
        {
            ARCH => 'SPARC',
            TYPE => 'TI UltraSparc IIIi (Jalapeno)'
        }
    ]
);

my %arm = (
    'linux-armel-1' => [
        {
            ARCH  => 'ARM',
            TYPE  => 'XScale-80219 rev 0 (v5l)'
        }
    ],
    'linux-armel-2' => [
        {
            ARCH  => 'ARM',
            TYPE  => 'Feroceon 88FR131 rev 1 (v5l)'
        }
    ]
);

my %mips = (
    'linux-mips-1' => [
        {
            NAME => 'R4400SC V5.0  FPU V0.0',
            ARCH => 'MIPS'
        }
    ]
);

my %ppc = (
    'linux-ppc-1' => [
        {
            NAME         => '604r',
            MANUFACTURER => undef,
            SPEED        => undef
        }
    ],
    'linux-ppc-2' => [
        {
            NAME         => 'POWER4+ (gq)',
            MANUFACTURER => undef,
            SPEED        => '1452'
        },
        {
            NAME         => 'POWER4+ (gq)',
            MANUFACTURER => undef,
            SPEED        => '1452'
        }
    ],
    'linux-ppc-3' => [
        {
            NAME         => 'PPC970FX, altivec supported',
            MANUFACTURER => undef,
            SPEED        => '2700'
        },
        {
            NAME         => 'PPC970FX, altivec supported',
            MANUFACTURER => undef,
            SPEED        => '2700'
        }
    ]
);

plan tests =>
    (scalar keys %alpha) +
    (scalar keys %sparc) +
    (scalar keys %arm)   +
    (scalar keys %mips)  +
    (scalar keys %ppc)   +
    (2 * scalar keys %i386);

foreach my $test (keys %i386) {
    my $file = "resources/linux/proc/cpuinfo/$test";
    my ($procs, $cores) = FusionInventory::Agent::Task::Inventory::Input::Linux::Archs::i386::_getCPUsFromProc(file => $file);
    cmp_deeply($procs, $i386{$test}->{procs}, "procs: ".$test);
    cmp_deeply($cores, $i386{$test}->{cores}, "cores: ".$test);
}

foreach my $test (keys %alpha) {
    my $file = "resources/linux/proc/cpuinfo/$test";
    my @cpus = FusionInventory::Agent::Task::Inventory::Input::Linux::Archs::Alpha::_getCPUsFromProc(file => $file);
    cmp_deeply(\@cpus, $alpha{$test}, $test);
}

foreach my $test (keys %sparc) {
    my $file = "resources/linux/proc/cpuinfo/$test";
    my @cpus = FusionInventory::Agent::Task::Inventory::Input::Linux::Archs::SPARC::_getCPUsFromProc(file => $file);
    cmp_deeply(\@cpus, $sparc{$test}, $test);
}

foreach my $test (keys %mips) {
    my $file = "resources/linux/proc/cpuinfo/$test";
    my @cpus = FusionInventory::Agent::Task::Inventory::Input::Linux::Archs::MIPS::_getCPUsFromProc(file => $file);
    cmp_deeply(\@cpus, $mips{$test}, $test);
}

foreach my $test (keys %arm) {
    my $file = "resources/linux/proc/cpuinfo/$test";
    my @cpus = FusionInventory::Agent::Task::Inventory::Input::Linux::Archs::ARM::_getCPUsFromProc(file => $file);
    cmp_deeply(\@cpus, $arm{$test}, $test);
}

foreach my $test (keys %ppc) {
    my $file = "resources/linux/proc/cpuinfo/$test";
    my @cpus = FusionInventory::Agent::Task::Inventory::Input::Linux::Archs::PowerPC::_getCPUsFromProc(file => $file);
    cmp_deeply(\@cpus, $ppc{$test}, $test);
}
