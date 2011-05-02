#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use FusionInventory::Agent::Tools::Linux;

my %udev_tests = (
    'ssd' => {
        NAME         => 'sda',
        FIRMWARE     => 'VBM24DQ1',
        SCSI_UNID    => '0',
        SERIALNUMBER => 'DFW1W11002SE002B3117',
        TYPE         => 'disk',
        SCSI_CHID    => '0',
        SCSI_COID    => '0',
        SCSI_LUN     => '0',
        DESCRIPTION  => 'ata',
        MODEL        => 'SAMSUNG_SSD_PM800_TM_128GB'
    },
);

my %cpuinfo_tests = (
    'linux-686-1' => [
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
            'cpu mhz' => '1729.038',
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
    'linux-686-samsung-nc10-1' => [
        {
            'cache size' => '512 KB',
            'address sizes' => '32 bits physical, 32 bits virtual',
            'clflush size' => '64',
            'physical id' => '0',
            'model' => '28',
            'cpu family' => '6',
            'bogomips' => '3192.60',
            'hlt_bug' => 'no',
            'cache_alignment' => '64',
            'stepping' => '2',
            'cpuid level' => '10',
            'core id' => '0',
            'flags' => 'fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe constant_tsc arch_perfmon pebs bts aperfmperf pni dtes64 monitor ds_cpl est tm2 ssse3 xtpr pdcm movbe lahf_lm',
            'cpu mhz' => '800.000',
            'processor' => '0',
            'vendor_id' => 'GenuineIntel',
            'cpu cores' => '1',
            'initial apicid' => '0',
            'model name' => 'Intel(R) Atom(TM) CPU N270   @ 1.60GHz',
            'fpu' => 'yes',
            'siblings' => '2',
            'apicid' => '0',
            'fpu_exception' => 'yes',
            'f00f_bug' => 'no',
            'fdiv_bug' => 'no',
            'wp' => 'yes',
            'coma_bug' => 'no'
          },
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
            'cpu mhz' => '800.000',
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
    'linux-alpha-1' => [
        {
            'platform string' => 'AlphaServer ES45 Model 3B',
            'system serial number' => 'AY31001636',
            'cpus detected' => '3',
            'page size [bytes]' => '8192',
            'bogomips' => '2484.04',
            'phys. address bits' => '44',
            'cpus active' => '3',
            'l2 cache' => 'n/a',
            'cpu variation' => '7',
            'system variation' => 'Privateer',
            'user unaligned acc' => '0 (pc=0,va=0)',
            'kernel unaligned acc' => '0 (pc=0,va=0)',
            'system type' => 'Titan',
            'cycle frequency [hz]' => '1250000000',
            'l1 icache' => '64K, 2-way, 64b line',
            'system revision' => '0',
            'l3 cache' => 'n/a',
            'cpu serial number' => 'JA30502089',
            'cpu' => 'Alpha',
            'cpu active mask' => '0000000000000007',
            'l1 dcache' => '64K, 2-way, 64b line',
            'cpu model' => 'EV68CB',
            'timer frequency [hz]' => '1024.00',
            'cpu revision' => '0',
            'max. addr. space #' => '255'
        }
    ],
    'linux-armel-1' => [
        {
            'd size' => '32768',
            'i line length' => '32',
            'cpu variant' => '0x0',
            'i sets' => '32',
            'features' => 'swp half fastmult edsp',
            'i size' => '32768',
            'bogomips' => '593.10',
            'cpu implementer' => '0x69',
            'd sets' => '32',
            'processor' => 'XScale-80219 rev 0 (v5l)',
            'cpu architecture' => '5TE',
            'd line length' => '32',
            'cache type' => 'undefined 5',
            'cache clean' => 'undefined 5',
            'd assoc' => '32',
            'i assoc' => '32',
            'cache lockdown' => 'undefined 5',
            'cache format' => 'Harvard',
            'cpu revision' => '0',
            'cpu part' => '0x2e3'
        },
    ],
    'linux-ia64-1' => [
        {
            'cpu mhz' => '1600.000009',
            'features' => 'branchlong',
            'archrev' => '0',
            'arch' => 'IA-64',
            'processor' => '0',
            'model' => '2',
            'cpu regs' => '4',
            'siblings' => '1',
            'bogomips' => '2392.06',
            'itc mhz' => '1600.009464',
            'cpu number' => '0',
            'revision' => '1',
            'vendor' => 'GenuineIntel',
            'family' => 'Itanium 2'
        },
        {
            'cpu mhz' => '1600.000009',
            'features' => 'branchlong',
            'archrev' => '0',
            'arch' => 'IA-64',
            'processor' => '1',
            'model' => '2',
            'cpu regs' => '4',
            'siblings' => '1',
            'bogomips' => '2392.06',
            'itc mhz' => '1600.009464',
            'cpu number' => '0',
            'revision' => '1',
            'vendor' => 'GenuineIntel',
            'family' => 'Itanium 2'
        }
    ],
    'linux-mips-1' => [
        {
            'vcei exceptions' => '9972559',
            'processor' => '0',
            'cpu model' => 'R4400SC V5.0  FPU V0.0',
            'vced exceptions' => '640580539',
            'microsecond timers' => 'yes',
            'wait instruction' => 'no',
            'bogomips' => '74.75',
            'shadow register sets' => '1',
            'tlb_entries' => '48',
            'hardware watchpoint' => 'yes',
            'system type' => 'SGI Indigo2',
            'extra interrupt vector' => 'no'
        }
    ],
    'linux-ppc-1' => [
        {
            'l2 cache' => '512KiB, parity disabled SRAM:synchronous, pipelined, no parity',
            'revision' => '49.2 (pvr 0009 3102)',
            'cpu' => '604r',
            'clock' => '???',
            'processor' => '0',
            'machine' => 'PReP Utah (Powerstack II Pro4000)',
            'bogomips' => '299.00'
          }
    ],
    'linux-ppc-2' => [
        {
            'revision' => '2.1',
            'cpu' => 'POWER4+ (gq)',
            'clock' => '1452.000000MHz',
            'processor' => '0'
        },
        {
            'revision' => '2.1',
            'cpu' => 'POWER4+ (gq)',
            'clock' => '1452.000000MHz',
            'processor' => '1'
        },
    ],
    'linux-ppc-3' => [
        {
            'revision' => '3.1 (pvr 003c 0301)',
            'cpu' => 'PPC970FX, altivec supported',
            'clock' => '2700.000000MHz',
            'processor' => '0'
        },
        {
            'revision' => '3.1 (pvr 003c 0301)',
            'cpu' => 'PPC970FX, altivec supported',
            'clock' => '2700.000000MHz',
            'processor' => '1'
        }
    ],
    'linux-sparc-1' => [
        {
            'cpu1clktck' => '000000003bb94e80',
            'cpu' => 'TI UltraSparc IIIi (Jalapeno)',
            'i$ parity tl1' => '0',
            'fpu' => 'UltraSparc IIIi integrated FPU',
            'mmu type' => 'Cheetah+',
            'cpu0clktck' => '000000003bb94e80',
            'd$ parity tl1' => '0',
            'prom' => 'OBP 4.13.2 2004/03/29 10:11',
            'cpu1' => '          online',
            'type' => 'sun4u',
            'ncpus active' => '2',
            'ncpus probed' => '2',
            'cpu0' => '          online'
          },
          ],
    'linux-2.6.35-1-core-2-thread' => [
          {
            'cache size' => '512 KB',
            'address sizes' => '32 bits physical, 32 bits virtual',
            'clflush size' => '64',
            'physical id' => '0',
            'model' => '28',
            'cpu family' => '6',
            'bogomips' => '3192.08',
            'hlt_bug' => 'no',
            'cpu mhz' => '800.000',
            'cache_alignment' => '64',
            'stepping' => '2',
            'cpuid level' => '10',
            'core id' => '0',
            'flags' => 'fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe constant_tsc arch_perfmon pebs bts aperfmperf pni dtes64 monitor ds_cpl est tm2 ssse3 xtpr pdcm movbe lahf_lm',
            'processor' => '0',
            'vendor_id' => 'GenuineIntel',
            'cpu cores' => '1',
            'initial apicid' => '0',
            'model name' => 'Intel(R) Atom(TM) CPU N270   @ 1.60GHz',
            'fpu' => 'yes',
            'siblings' => '2',
            'apicid' => '0',
            'fpu_exception' => 'yes',
            'f00f_bug' => 'no',
            'fdiv_bug' => 'no',
            'wp' => 'yes',
            'coma_bug' => 'no'
          },
          {
            'cache size' => '512 KB',
            'address sizes' => '32 bits physical, 32 bits virtual',
            'clflush size' => '64',
            'physical id' => '0',
            'model' => '28',
            'cpu family' => '6',
            'bogomips' => '3191.96',
            'hlt_bug' => 'no',
            'cpu mhz' => '800.000',
            'cache_alignment' => '64',
            'stepping' => '2',
            'cpuid level' => '10',
            'core id' => '0',
            'flags' => 'fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe nx constant_tsc arch_perfmon pebs bts aperfmperf pni dtes64 monitor ds_cpl est tm2 ssse3 xtpr pdcm movbe lahf_lm',
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
        'linux-hp-dl180' => [
          {
            'cache size' => '4096 KB',
            'address sizes' => '40 bits physical, 48 bits virtual',
            'clflush size' => '64',
            'physical id' => '1',
            'model' => '26',
            'cpu family' => '6',
            'bogomips' => '4000.18',
            'hlt_bug' => 'no',
            'cpu mhz' => '2000.090',
            'cache_alignment' => '64',
            'stepping' => '5',
            'cpuid level' => '11',
            'core id' => '0',
            'flags' => 'fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe nx rdtscp lm con$',
            'processor' => '0',
            'vendor_id' => 'GenuineIntel',
            'cpu cores' => '4',
            'initial apicid' => '16',
            'model name' => 'Intel(R) Xeon(R) CPU           E5504  @ 2.00GHz',
            'fpu' => 'yes',
            'siblings' => '4',
            'apicid' => '16',
            'fpu_exception' => 'yes',
            'f00f_bug' => 'no',
            'fdiv_bug' => 'no',
            'wp' => 'yes',
            'coma_bug' => 'no'
          },
          {
            'cache size' => '4096 KB',
            'address sizes' => '40 bits physical, 48 bits virtual',
            'clflush size' => '64',
            'physical id' => '1',
            'model' => '26',
            'cpu family' => '6',
            'bogomips' => '4000.00',
            'hlt_bug' => 'no',
            'cpu mhz' => '2000.090',
            'cache_alignment' => '64',
            'stepping' => '5',
            'cpuid level' => '11',
            'core id' => '1',
            'flags' => 'fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe nx rdtscp lm con$',
            'processor' => '1',
            'vendor_id' => 'GenuineIntel',
            'cpu cores' => '4',
            'initial apicid' => '18',
            'model name' => 'Intel(R) Xeon(R) CPU           E5504  @ 2.00GHz',
            'fpu' => 'yes',
            'siblings' => '4',
            'apicid' => '18',
            'fpu_exception' => 'yes',
            'f00f_bug' => 'no',
            'fdiv_bug' => 'no',
            'wp' => 'yes',
            'coma_bug' => 'no'
          },
          {
            'cache size' => '4096 KB',
            'address sizes' => '40 bits physical, 48 bits virtual',
            'clflush size' => '64',
            'physical id' => '1',
            'model' => '26',
            'cpu family' => '6',
            'bogomips' => '4000.00',
            'hlt_bug' => 'no',
            'cpu mhz' => '2000.090',
            'cache_alignment' => '64',
            'stepping' => '5',
            'cpuid level' => '11',
            'core id' => '2',
            'flags' => 'fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe nx rdtscp lm con$',
            'processor' => '2',
            'vendor_id' => 'GenuineIntel',
            'cpu cores' => '4',
            'initial apicid' => '20',
            'model name' => 'Intel(R) Xeon(R) CPU           E5504  @ 2.00GHz',
            'fpu' => 'yes',
            'siblings' => '4',
            'apicid' => '20',
            'fpu_exception' => 'yes',
            'f00f_bug' => 'no',
            'fdiv_bug' => 'no',
            'wp' => 'yes',
            'coma_bug' => 'no'
          }
        ],
        'toshiba-r630-2-core' => [
          {
            'cache size' => '3072 KB',
            'address sizes' => '36 bits physical, 48 bits virtual',
            'clflush size' => '64',
            'physical id' => '0',
            'model' => '37',
            'cpu family' => '6',
            'bogomips' => '4521.44',
            'cpu mhz' => '933.000',
            'cache_alignment' => '64',
            'stepping' => '5',
            'core id' => '0',
            'cpuid level' => '11',
            'flags' => 'fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx rdtscp lm constant_tsc arch_perfmon pebs bts rep_good xtopology nonstop_tsc aperfmperf pni dtes64 monitor ds_cpl vmx est tm2 ssse3 cx16 xtpr pdcm sse4_1 sse4_2 popcnt lahf_lm arat tpr_shadow vnmi flexpriority ept vpid',
            'processor' => '0',
            'vendor_id' => 'GenuineIntel',
            'cpu cores' => '2',
            'initial apicid' => '0',
            'model name' => 'Intel(R) Core(TM) i3 CPU       M 350  @ 2.27GHz',
            'fpu' => 'yes',
            'siblings' => '4',
            'apicid' => '0',
            'fpu_exception' => 'yes',
            'wp' => 'yes'
          },
          {
            'cache size' => '3072 KB',
            'address sizes' => '36 bits physical, 48 bits virtual',
            'clflush size' => '64',
            'physical id' => '0',
            'model' => '37',
            'cpu family' => '6',
            'bogomips' => '4521.44',
            'cpu mhz' => '933.000',
            'cache_alignment' => '64',
            'stepping' => '5',
            'core id' => '0',
            'cpuid level' => '11',
            'flags' => 'fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx rdtscp lm constant_tsc arch_perfmon pebs bts rep_good xtopology nonstop_tsc aperfmperf pni dtes64 monitor ds_cpl vmx est tm2 ssse3 cx16 xtpr pdcm sse4_1 sse4_2 popcnt lahf_lm arat tpr_shadow vnmi flexpriority ept vpid',
            'processor' => '1',
            'vendor_id' => 'GenuineIntel',
            'cpu cores' => '2',
            'initial apicid' => '1',
            'model name' => 'Intel(R) Core(TM) i3 CPU       M 350  @ 2.27GHz',
            'fpu' => 'yes',
            'siblings' => '4',
            'apicid' => '1',
            'fpu_exception' => 'yes',
            'wp' => 'yes'
          },
          {
            'cache size' => '3072 KB',
            'address sizes' => '36 bits physical, 48 bits virtual',
            'clflush size' => '64',
            'physical id' => '0',
            'model' => '37',
            'cpu family' => '6',
            'bogomips' => '4521.44',
            'cpu mhz' => '933.000',
            'cache_alignment' => '64',
            'stepping' => '5',
            'core id' => '2',
            'cpuid level' => '11',
            'flags' => 'fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx rdtscp lm constant_tsc arch_perfmon pebs bts rep_good xtopology nonstop_tsc aperfmperf pni dtes64 monitor ds_cpl vmx est tm2 ssse3 cx16 xtpr pdcm sse4_1 sse4_2 popcnt lahf_lm arat tpr_shadow vnmi flexpriority ept vpid',
            'processor' => '2',
            'vendor_id' => 'GenuineIntel',
            'cpu cores' => '2',
            'initial apicid' => '4',
            'model name' => 'Intel(R) Core(TM) i3 CPU       M 350  @ 2.27GHz',
            'fpu' => 'yes',
            'siblings' => '4',
            'apicid' => '4',
            'fpu_exception' => 'yes',
            'wp' => 'yes'
          },
          {
            'cache size' => '3072 KB',
            'address sizes' => '36 bits physical, 48 bits virtual',
            'clflush size' => '64',
            'physical id' => '0',
            'model' => '37',
            'cpu family' => '6',
            'bogomips' => '4521.44',
            'cpu mhz' => '933.000',
            'cache_alignment' => '64',
            'stepping' => '5',
            'core id' => '2',
            'cpuid level' => '11',
            'flags' => 'fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx rdtscp lm constant_tsc arch_perfmon pebs bts rep_good xtopology nonstop_tsc aperfmperf pni dtes64 monitor ds_cpl vmx est tm2 ssse3 cx16 xtpr pdcm sse4_1 sse4_2 popcnt lahf_lm arat tpr_shadow vnmi flexpriority ept vpid',
            'processor' => '3',
            'vendor_id' => 'GenuineIntel',
            'cpu cores' => '2',
            'initial apicid' => '5',
            'model name' => 'Intel(R) Core(TM) i3 CPU       M 350  @ 2.27GHz',
            'fpu' => 'yes',
            'siblings' => '4',
            'apicid' => '5',
            'fpu_exception' => 'yes',
            'wp' => 'yes'
          }
    ]
);

my %hal_tests = (
    'dell-xt2' => [
        {
            NAME         => 'sda',
            FIRMWARE     => 'VBM24DQ1',
            DISKSIZE     => 122104,
            MANUFACTURER => 'ATA',
            MODEL        => 'SAMSUNG SSD PM80',
            SERIALNUMBER => 'SAMSUNG_SSD_PM800_TM_128GB_DFW1W11002SE002B3117',
            TYPE         => 'disk'
        }
    ]
);

my %smartctl_tests = (
    'dell-xt2' => 'DFW1W11002SE002B3117'
);

plan tests => 
    (scalar keys %udev_tests) +
    (scalar keys %cpuinfo_tests)  +
    (scalar keys %hal_tests)  +
    (scalar keys %smartctl_tests);

foreach my $test (keys %udev_tests) {
    my $file = "resources/udev/$test";
    my $result = FusionInventory::Agent::Tools::Linux::_parseUdevEntry(
        file => $file, device => 'sda'
    );
    is_deeply($result, $udev_tests{$test}, "$test udev parsing");
}

foreach my $test (keys %cpuinfo_tests) {
    my $file = "resources/cpuinfo/$test";
    my @cpus = getCPUsFromProc(file => $file);
    is_deeply(\@cpus, $cpuinfo_tests{$test}, "$test cpuinfo parsing");
}

foreach my $test (keys %hal_tests) {
    my $file = "resources/hal/$test";
    my @devices = getDevicesFromHal(file => $file);
    is_deeply(\@devices, $hal_tests{$test}, "$test hal parsing");
}

foreach my $test (keys %smartctl_tests) {
    my $file = "resources/smartctl/$test";
    my $result = getSerialnumber(file => $file);
    is($result, $smartctl_tests{$test}, "$test smartctl parsing");
}
