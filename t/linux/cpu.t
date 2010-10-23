#!/usr/bin/perl

use strict;
use warnings;
use FusionInventory::Agent::Task::Inventory::OS::Linux::Archs::i386::CPU;
use FusionInventory::Logger;
use Test::More;

my %tests = (
    'linux-686-1' => {
        procs => [
            {
                'cache size' => '2048 KB',
                'clflush size' => '64',
                'model' => '13',
                'cpu family' => '6',
                'bogomips' => '3462.27',
                'hlt_bug' => 'no',
                'stepping' => '8',
                'cpuid level' => '2',
                'flags' => 'fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat clflush dts acpi mmx fxsr sse sse2 ss tm pbe nx bts est tm2',
                'cpu MHz' => '1729.038',
                'processor' => '0',
                'vendor_id' => 'GenuineIntel',
                'model name' => 'Intel(R) Pentium(R) M processor 1.73GHz',
                'fpu' => 'yes',
                'f00f_bug' => 'no',
                'fpu_exception' => 'yes',
                'fdiv_bug' => 'no',
                'coma_bug' => 'no',
                'wp' => 'yes'
            },
        ],
        cores => undef
    },
    'linux-686-samsung-nc10-1' => {
        procs => [
            {
                'cache size' => '512 KB',
                'address sizes' => '32 bits physical, 32 bits virtual',
                'clflush size' => '64',
                'physical id' => '0',
                'model' => '28',
                'cpu family' => '6',
                'bogomips' => '3192.61',
                'hlt_bug' => 'no',
                'cache_alignment' => '64',
                'stepping' => '2',
                'cpuid level' => '10',
                'core id' => '0',
                'flags' => 'fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe constant_tsc arch_perfmon pebs bts aperfmperf pni dtes64 monitor ds_cpl est tm2 ssse3 xtpr pdcm movbe lahf_lm',
                'cpu MHz' => '800.000',
                'processor' => '1',
                'vendor_id' => 'GenuineIntel',
                'cpu cores' => '1',
                'initial apicid' => '1',
                'model name' => 'Intel(R) Atom(TM) CPU N270   @ 1.60GHz',
                'fpu' => 'yes',
                'siblings' => '2',
                'apicid' => '1',
                'fpu_exception' => 'yes',
                'f00f_bug' => 'no',
                'fdiv_bug' => 'no',
                'wp' => 'yes',
                'coma_bug' => 'no'
            }
        ],
        cores => [ 1 ]
    },
    'linux-2.6.35-1-core-2-thread' => {
        procs => [
            {
                'cache size' => '512 KB',
                'address sizes' => '32 bits physical, 32 bits virtual',
                'clflush size' => '64',
                'physical id' => '0',
                'model' => '28',
                'cpu family' => '6',
                'bogomips' => '3191.96',
                'hlt_bug' => 'no',
                'cache_alignment' => '64',
                'stepping' => '2',
                'cpuid level' => '10',
                'core id' => '0',
                'flags' => 'fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe nx constant_tsc arch_perfmon pebs bts aperfmperf pni dtes64 monitor ds_cpl est tm2 ssse3 xtpr pdcm movbe lahf_lm',
                'cpu MHz' => '800.000',
                'processor' => '1',
                'vendor_id' => 'GenuineIntel',
                'cpu cores' => '1',
                'initial apicid' => '1',
                'model name' => 'Intel(R) Atom(TM) CPU N270   @ 1.60GHz',
                'fpu' => 'yes',
                'siblings' => '2',
                'apicid' => '1',
                'fpu_exception' => 'yes',
                'f00f_bug' => 'no',
                'fdiv_bug' => 'no',
                'wp' => 'yes',
                'coma_bug' => 'no'
            }
        ],
        cores => [ 1 ]
    }

);

plan tests => 2 * scalar keys %tests;

my $logger = FusionInventory::Logger->new();
foreach my $test (keys %tests) {
    my $file = "resources/cpuinfo/$test";
    my ($procs, $cores) = FusionInventory::Agent::Task::Inventory::OS::Linux::Archs::i386::CPU::_getInfosFromProc($logger, $file);
    is_deeply($procs, $tests{$test}->{procs}, $test);
    is_deeply($cores, $tests{$test}->{cores}, $test);
}
