#!/usr/bin/perl

use strict;
use warnings;
use FusionInventory::Agent::Tools::Linux;
use FusionInventory::Logger;
use Test::More;

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

my %cpu_tests = (
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
            'cpu MHz' => '800.000',
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
    'linux-alpha-1' => [
        {
            'platform string' => 'AlphaServer ES45 Model 3B',
            'system serial number' => 'AY31001636',
            'cpus detected' => '3',
            'page size [bytes]' => '8192',
            'BogoMIPS' => '2484.04',
            'phys. address bits' => '44',
            'cpus active' => '3',
            'L2 cache' => 'n/a',
            'cpu variation' => '7',
            'system variation' => 'Privateer',
            'user unaligned acc' => '0 (pc=0,va=0)',
            'kernel unaligned acc' => '0 (pc=0,va=0)',
            'system type' => 'Titan',
            'cycle frequency [Hz]' => '1250000000',
            'L1 Icache' => '64K, 2-way, 64b line',
            'system revision' => '0',
            'L3 cache' => 'n/a',
            'cpu serial number' => 'JA30502089',
            'cpu' => 'Alpha',
            'cpu active mask' => '0000000000000007',
            'L1 Dcache' => '64K, 2-way, 64b line',
            'cpu model' => 'EV68CB',
            'timer frequency [Hz]' => '1024.00',
            'cpu revision' => '0',
            'max. addr. space #' => '255'
        }
    ],

    'linux-armel-1' => [
        {
            'D size' => '32768',
            'I line length' => '32',
            'CPU variant' => '0x0',
            'I sets' => '32',
            'Features' => 'swp half fastmult edsp',
            'I size' => '32768',
            'BogoMIPS' => '593.10',
            'CPU implementer' => '0x69',
            'D sets' => '32',
            'Processor' => 'XScale-80219 rev 0 (v5l)',
            'CPU architecture' => '5TE',
            'D line length' => '32',
            'Cache type' => 'undefined 5',
            'Cache clean' => 'undefined 5',
            'D assoc' => '32',
            'I assoc' => '32',
            'Cache lockdown' => 'undefined 5',
            'Cache format' => 'Harvard',
            'CPU revision' => '0',
            'CPU part' => '0x2e3'
        },
        {
            'Revision' => '0000',
            'Hardware' => 'Thecus N2100',
            'Serial' => '0000000000000000'
        }
    ],
    'linux-ia64-1' => [
        {
            'cpu MHz' => '1600.000009',
            'features' => 'branchlong',
            'archrev' => '0',
            'arch' => 'IA-64',
            'processor' => '0',
            'model' => '2',
            'cpu regs' => '4',
            'siblings' => '1',
            'BogoMIPS' => '2392.06',
            'itc MHz' => '1600.009464',
            'cpu number' => '0',
            'revision' => '1',
            'vendor' => 'GenuineIntel',
            'family' => 'Itanium 2'
        },
        {
            'cpu MHz' => '1600.000009',
            'features' => 'branchlong',
            'archrev' => '0',
            'arch' => 'IA-64',
            'processor' => '1',
            'model' => '2',
            'cpu regs' => '4',
            'siblings' => '1',
            'BogoMIPS' => '2392.06',
            'itc MHz' => '1600.009464',
            'cpu number' => '0',
            'revision' => '1',
            'vendor' => 'GenuineIntel',
            'family' => 'Itanium 2'
        }
    ],
    'linux-mips-1' => [
        {
            'VCEI exceptions' => '9972559',
            'processor' => '0',
            'cpu model' => 'R4400SC V5.0  FPU V0.0',
            'VCED exceptions' => '640580539',
            'microsecond timers' => 'yes',
            'wait instruction' => 'no',
            'BogoMIPS' => '74.75',
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
        {
            'machine' => 'CHRP IBM,7029-6C3',
            'timebase' => '181495202'
        }
    ],
    'linux-sparc-1' => [
        {
            'Cpu1ClkTck' => '000000003bb94e80',
            'cpu' => 'TI UltraSparc IIIi (Jalapeno)',
            'I$ parity tl1' => '0',
            'fpu' => 'UltraSparc IIIi integrated FPU',
            'MMU Type' => 'Cheetah+',
            'Cpu0ClkTck' => '000000003bb94e80',
            'D$ parity tl1' => '0',
            'prom' => 'OBP 4.13.2 2004/03/29 10:11',
            'CPU1' => '          online',
            'type' => 'sun4u',
            'ncpus active' => '2',
            'ncpus probed' => '2',
            'CPU0' => '          online'
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

plan tests => 
    (scalar keys %udev_tests) +
    (scalar keys %cpu_tests)  +
    (scalar keys %hal_tests);

my $logger = FusionInventory::Logger->new();

foreach my $test (keys %udev_tests) {
    my $file = "resources/udev/$test";
    my $result = FusionInventory::Agent::Tools::Linux::_parseUdevEntry(
        $logger, $file, 'sda'
    );
    is_deeply($result, $udev_tests{$test}, "$test udev parsing");
}

foreach my $test (keys %cpu_tests) {
    my $file = "resources/cpuinfo/$test";
    my $cpus = getCPUsFromProc($logger, $file);
    is_deeply($cpus, $cpu_tests{$test}, "$test cpuinfo parsing");
}

foreach my $test (keys %hal_tests) {
    my $file = "resources/hal/$test";
    my $results = FusionInventory::Agent::Tools::Linux::_parseLshal($logger, $file, '<');
    is_deeply($results, $hal_tests{$test}, $test);
}
