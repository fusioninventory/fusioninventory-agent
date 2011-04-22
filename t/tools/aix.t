#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Data::Dumper;

use FusionInventory::Agent::Tools::AIX;

my %lsvpd_tests = (
    'sample1' => [
        {
            SE => '65DEDAB',
            FG => 'XXSV',
            DS => 'System VPD',
            RT => 'VSYS',
            TM => '9111-520',
            BR => 'O0',
            VK => 'ipzSeries',
            YL => 'U9111.520.65DEDAB',
            SU => '0004AC0BA763'
        },
        {
            SE => 'DPM2CW2',
            RK => '0000000000000000',
            FC => '787A-001',
            FG => 'XXEV',
            DS => 'CEC',
            RT => 'VCEN',
            TM => '787A-001',
            BR => 'O0',
            VK => 'ipzSeries',
            YL => 'U787A.001.DPM2CW2',
            CI => '9111-520 65DEDAB'
        },
        {
            CC => '522A',
            HE => '0001',
            PN => '80P6949',
            FG => 'XXBP',
            DS => 'SYSTEM BACKPLANE',
            HW => '0001',
            FN => '80P6949',
            SN => 'YL142533608A',
            RT => 'VINI',
            VK => 'ipzSeries',
            CT => '40130002',
            YL => 'U787A.001.DPM2CW2-P1',
            PR => '2300000000000000'
        },
        {
            CC => '28D7',
            HE => '0001',
            PN => '80P5315',
            FG => 'XXSP',
            DS => 'FSP',
            HW => '0001',
            FN => '80P5315',
            SN => 'YL11253320B4',
            RT => 'VINI',
            VK => 'ipzSeries',
            CT => '40B30001',
            YL => 'U787A.001.DPM2CW2-P1-C7'
        },
        {
            CC => '30D2',
            PN => '00P5767',
            FG => 'XXMS',
            DS => 'Memory DIMM',
            SZ => '512',
            FN => '00P5767',
            SN => 'YH10MS5CH923',
            RT => 'VINI',
            YL => 'U787A.001.DPM2CW2-P1-C9',
            VK => 'RS6K'
        },
        {
            CC => '30D2',
            PN => '00P5767',
            FG => 'XXMS',
            DS => 'Memory DIMM',
            SZ => '512',
            FN => '00P5767',
            SN => 'YH10MS5CH8ED',
            RT => 'VINI',
            YL => 'U787A.001.DPM2CW2-P1-C11',
            VK => 'RS6K'
        },
        {
            CC => '30D2',
            PN => '00P5767',
            FG => 'XXMS',
            DS => 'Memory DIMM',
            SZ => '512',
            FN => '00P5767',
            SN => 'YH10MS5CH8F0',
            RT => 'VINI',
            YL => 'U787A.001.DPM2CW2-P1-C14',
            VK => 'RS6K'
        },
        {
            CC => '30D2',
            PN => '00P5767',
            FG => 'XXMS',
            DS => 'Memory DIMM',
            SZ => '512',
            FN => '00P5767',
            SN => 'YH10MS5CH92C',
            RT => 'VINI',
            YL => 'U787A.001.DPM2CW2-P1-C16',
            VK => 'RS6K'
        },
        {
            CC => '528F',
            HE => '0010',
            PN => '80P3249',
            FG => 'XXAV',
            DS => 'ANCHOR',
            HW => '0001',
            FN => '80P3249',
            SN => 'YL1154018250',
            RT => 'VINI',
            VK => 'ipzSeries',
            CT => '40B40000',
            YL => 'U787A.001.DPM2CW2-P1-C20',
            PR => '8100180000000000'
        },
        {
            CC => '28E5',
            HE => '0001',
            PN => '97P4935',
            FG => 'XXOP',
            DS => 'CEC OP PANEL',
            HW => '0001',
            FN => '97P4935',
            SN => 'YL13253220E5',
            RT => 'VINI',
            VK => 'ipzSeries',
            CT => '40B50000',
            YL => 'U787A.001.DPM2CW2-D1',
            PR => 'E000000000000000'
        },
        {
            CC => '51B6',
            PN => '97P2330',
            FG => 'XXPS',
            DS => 'A IBM AC PS',
            FN => '97P2330',
            SN => 'YL1325AX0041',
            RT => 'VINI',
            YL => 'U787A.001.DPM2CW2-E1',
            VK => 'RS6K'
        },
        {
            CC => '51B6',
            PN => '97P2330',
            FG => 'XXPS',
            DS => 'A IBM AC PS',
            FN => '97P2330',
            SN => 'YL13258Z0274',
            RT => 'VINI',
            YL => 'U787A.001.DPM2CW2-E2',
            VK => 'RS6K'
        },
        {
            CC => '6B18',
            RT => 'VINI',
            VK => 'RS6K',
            YL => 'U787A.001.DPM2CW2-A1',
            FG => 'XXAM',
            DS => 'IBM Air Mover',
            FN => '97P3153'
        },
        {
            CC => '6B18',
            RT => 'VINI',
            VK => 'RS6K',
            YL => 'U787A.001.DPM2CW2-A2',
            FG => 'XXAM',
            DS => 'IBM Air Mover',
            FN => '97P3153'
        },
        {
            CC => '6B18',
            RT => 'VINI',
            VK => 'RS6K',
            YL => 'U787A.001.DPM2CW2-A3',
            FG => 'XXAM',
            DS => 'IBM Air Mover',
            FN => '97P3153'
        },
        {
            CC => '6B12',
            RT => 'VINI',
            VK => 'RS6K',
            YL => 'U787A.001.DPM2CW2-P1-C19',
            FG => 'XXRG',
            DS => 'Voltage Reg',
            FN => '97P2642'
        },
        {
            CC => '6B10',
            RT => 'VINI',
            VK => 'RS6K',
            YL => 'U787A.001.DPM2CW2-P1-C17',
            FG => 'XXRG',
            DS => 'Voltage Reg',
            FN => '44P3193'
        },
        {
            CC => '6B11',
            RT => 'VINI',
            VK => 'RS6K',
            YL => 'U787A.001.DPM2CW2-P1-C18',
            FG => 'XXRG',
            DS => 'Voltage Reg',
            FN => '24P6892'
        },
        {
            CC => '28D2',
            FS => '787A-001 DPM2CW2',
            PN => '03N5997',
            EC => 'H13944',
            FG => 'XXDB',
            DS => 'VSBPD4E1  U4SCSI',
            FN => '03N6000',
            SN => 'YL10253423B6',
            RT => 'VINI',
            VK => 'RS6K',
            YL => 'U787A.001.DPM2CW2-P3'
        },
        {
            CC => '28D1',
            PN => '03N5897',
            EC => 'H13928',
            FG => 'XXMB',
            DS => 'MEDIA BACKPLANE',
            FN => '03N6005',
            SN => 'YL1025352166',
            RT => 'VINI',
            VK => 'RS6K',
            YL => 'U787A.001.DPM2CW2-P4'
        },
        {
            YL => 'U9111.520.65DEDAB-Y1',
            MI => 'SF240_202 SF240_202 SF240_202',
            DS => 'System Firmware',
            CL => 'SPCN2 084720040818A0E00D20'
        },
        {
            CD => '33880021',
            AX => 'pci6',
            YL => 'U787A.001.DPM2CW2-P1-C2',
            DS => 'PCI Bus',
            PL => '05-08'
        },
        {
            CD => '10140233',
            PN => '80P4527',
            YL => 'U787A.001.DPM2CW2-P1-C2-T1',
            EC => 'H13284',
            DS => 'GXT135P Graphics Adapter',
            MN => 'MATROX',
            FN => '00P5758'
        },
        {
            TM => 'DROM0020541',
            AX => 'cd0',
            YL => 'U787A.001.DPM2CW2-P4-D2',
            RL => 'P633',
            DS => 'IDE DVD-ROM Drive',
            MF => 'IBM',
            PL => '08-08-00'
        },
        {
            PN => '26K5533',
            EC => 'H13979',
            DS => '16 Bit LVD SCSI Disk Drive',
            MF => 'IBM',
            FN => '03N6325',
            PL => '09-08-00-3,0',
            SN => '00060321',
            AX => 'hdisk0',
            TM => 'ST373207LC',
            YL => 'U787A.001.DPM2CW2-P1-T10-L3-L0',
            RL => '43373043'
        },
        {
            PN => '18P8777',
            EC => 'H80564',
            DS => 'LVD SCSI 4mm Tape Drive',
            MF => 'IBM',
            FN => '18P8779',
            LI => 'A170029F',
            PL => '09-08-00-6,0',
            SN => '205CW158',
            AX => 'rmt0',
            TM => 'DDS Gen5',
            YL => 'U787A.001.DPM2CW2-P1-T10-L6-L0'
        },
        {
            FS => '787A-001 DPM2CW2',
            DS => 'SCSI Enclosure Services Device',
            MF => 'IBM',
            FN => '03N6000',
            PL => '09-08-00-15,0',
            SN => '253423B6',
            AX => 'ses0',
            TM => 'VSBPD4E1  U4SCSI',
            FL => 'P3',
            YL => 'U787A.001.DPM2CW2-P1-T10-L15-L0',
            RL => '6000'
        },
        {
            PN => '26K5533',
            EC => 'H13979',
            DS => '16 Bit LVD SCSI Disk Drive',
            MF => 'IBM',
            FN => '03N6325',
            PL => '09-08-00-4,0',
            SN => '0005F82E',
            AX => 'hdisk1',
            TM => 'ST373207LC',
            YL => 'U787A.001.DPM2CW2-P1-T10-L4-L0',
            RL => '43373043'
        },
        {
            PN => '093H6540',
            EC => '0E76812',
            DS => 'IBM 8-Port EIA-232/RS-422A (PCI) Adapter',
            MF => 'AUS1391615',
            FN => '093H6541',
            PL => '0A-08',
            AX => 'sa1',
            CD => '114f0011',
            YL => 'U787A.001.DPM2CW2-P1-C3-T1'
        },
        {
            AX => 'kbd0',
            YL => 'U787A.001.DPM2CW2-P1-T8-L1-L1',
            DS => 'USB keyboard',
            PL => '1.1.1'
        },
        {
            AX => 'mouse0',
            YL => 'U787A.001.DPM2CW2-P1-T8-L1-L3',
            DS => 'USB mouse',
            PL => '1.1.3'
        },
        {
            AX => 'tty0',
            YL => 'U787A.001.DPM2CW2-P1-C3-T1-L0',
            DS => 'Asynchronous Terminal',
            PL => '0A-08-01-00'
        },
        {
            AX => 'tty1',
            YL => 'U787A.001.DPM2CW2-P1-C3-T1-L1',
            DS => 'Asynchronous Terminal',
            PL => '0A-08-01-01'
        },
        {
            AX => 'tty2',
            YL => 'U787A.001.DPM2CW2-P1-C3-T1-L5',
            DS => 'Asynchronous Terminal',
            PL => '0A-08-01-05'
        },
        {
            AX => 'tty3',
            YL => 'U787A.001.DPM2CW2-P1-C3-T1-L6',
            DS => 'Asynchronous Terminal',
            PL => '0A-08-01-06'
        },
        {
            AX => 'tty4',
            YL => 'U787A.001.DPM2CW2-P1-C3-T1-L2',
            DS => 'Asynchronous Terminal',
            PL => '0A-08-01-02'
        },
        {
            AX => 'tty5',
            YL => 'U787A.001.DPM2CW2-P1-C3-T1-L4',
            DS => 'Asynchronous Terminal',
            PL => '0A-08-01-04'
        }
    ]
);

plan tests => scalar keys %lsvpd_tests;

foreach my $test (keys %lsvpd_tests) {
    my $file = "resources/lsvpd/$test";
    my @devices = getDevicesFromLsvpd(file => $file);
    is_deeply(\@devices, $lsvpd_tests{$test}, "$test lsvpd parsing");
}
