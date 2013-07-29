#!/usr/bin/perl

use strict;

use Test::More;
use Test::Deep;

use FusionInventory::Agent::SNMP::Mock;
use FusionInventory::Agent::Task::NetDiscovery;
use FusionInventory::Agent::Task::NetDiscovery::Dictionary;

my %tests = (
    'ricoh/Aficio_AP3800C.walk' => [
        {
            MANUFACTURER => 'Ricoh',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'RICOH Aficio AP3800C 1.12 / RICOH Network Printer C model / RICOH Network Scanner C model',
            SNMPHOSTNAME => 'Aficio AP3800C',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Ricoh',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'RICOH Aficio AP3800C 1.12 / RICOH Network Printer C model / RICOH Network Scanner C model',
            SNMPHOSTNAME => 'Aficio AP3800C',
            MAC          => undef,
        },
    ],
    'ricoh/Aficio_MP_C2050.walk' => [
        {
            MANUFACTURER => 'Ricoh',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'RICOH Aficio MP C2050 1.17 / RICOH Network Printer C model / RICOH Network Scanner C model',
            SNMPHOSTNAME => 'Aficio MP C2050',
            MAC          => '00:00:74:F8:BA:6F',
        },
        {
            MANUFACTURER => 'Ricoh',
            TYPE         => '3',
            DESCRIPTION  => 'RICOH Aficio MP C2050 1.17 / RICOH Network Printer C model / RICOH Network Scanner C model',
            SNMPHOSTNAME => 'Aficio MP C2050',
            MAC          => '00:00:74:F8:BA:6F',
            MODELSNMP    => 'Printer0522',
            MODEL        => undef,
            SERIAL       => undef,
            FIRMWARE     => undef,
        },
    ],
    'ricoh/Aficio_SP_C420DN.1.walk' => [
        {
            MANUFACTURER => 'Ricoh',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'RICOH Aficio SP C420DN 1.05 / RICOH Network Printer C model',
            SNMPHOSTNAME => 'Aficio SP C420DN',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Ricoh',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'RICOH Aficio SP C420DN 1.05 / RICOH Network Printer C model',
            SNMPHOSTNAME => 'Aficio SP C420DN',
            MAC          => undef,
        },
    ],
    'ricoh/Aficio_SP_C420DN.2.walk' => [
        {
            MANUFACTURER => 'Ricoh',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'RICOH Aficio SP C420DN 1.05 / RICOH Network Printer C model',
            SNMPHOSTNAME => 'Aficio SP C420DN',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Ricoh',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'RICOH Aficio SP C420DN 1.05 / RICOH Network Printer C model',
            SNMPHOSTNAME => 'Aficio SP C420DN',
            MAC          => undef,
        },
    ],
    'canon/LBP7660C_P.walk' => [
        {
            MANUFACTURER => 'Canon',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Canon LBP7660C /P',
            SNMPHOSTNAME => 'LBP7660C',
            MAC          => undef,
        },
        {
            MANUFACTURER  => 'Canon',
            TYPE          => '3',
            DESCRIPTION   => 'Canon LBP7660C /P',
            SNMPHOSTNAME  => 'LBP7660C',
            MAC           => undef,
            MODELSNMP     => 'Printer0790',
            MODEL         => undef,
            FIRMWARE      => undef,
            SERIAL        => undef
        },
    ],
    'canon/MF4500_Series_P.walk' => [
        {
            MANUFACTURER => 'Canon',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Canon MF4500 Series /P',
            SNMPHOSTNAME => 'MF4500 Series',
            MAC          => undef
        },
        {
            MANUFACTURER => 'Canon',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Canon MF4500 Series /P',
            SNMPHOSTNAME => 'MF4500 Series',
            MAC          => undef
        },
    ],
    'lexmark/T622.walk' => [
        {
            MANUFACTURER => 'Lexmark',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Lexmark T622 version 54.30.06 kernel 2.4.0-test6 All-N-1',
            SNMPHOSTNAME => 'LXK3936A4',
            MAC          => '00:04:00:9C:6C:25',
        },
        {
            MANUFACTURER  => 'Lexmark',
            TYPE          => '3',
            DESCRIPTION   => 'Lexmark T622 version 54.30.06 kernel 2.4.0-test6 All-N-1',
            SNMPHOSTNAME  => 'LXK3936A4',
            MAC           => '00:04:00:9C:6C:25',
            MODELSNMP     => 'Printer0643',
            MODEL         => undef,
            FIRMWARE      => undef,
            SERIAL        => 'LXK3936A4'
        },
    ],
    'lexmark/X792.walk' => [
        {
            MANUFACTURER => 'Lexmark',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Lexmark X792 version NH.HS2.N211La kernel 2.6.28.10.1 All-N-1',
            SNMPHOSTNAME => 'ET0021B7427721',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Lexmark',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Lexmark X792 version NH.HS2.N211La kernel 2.6.28.10.1 All-N-1',
            SNMPHOSTNAME => 'ET0021B7427721',
            MAC          => undef,
        },
    ],
    'kyocera/TASKalfa-820.walk' => [
        {
            MANUFACTURER => 'Kyocera',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'TASKalfa 820',
            SNMPHOSTNAME => '',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Kyocera',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'TASKalfa 820',
            SNMPHOSTNAME => '',
            MAC          => undef,
        },
    ],
    'kyocera/TASKalfa-181.walk' => [
        {
            MANUFACTURER => 'Kyocera',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'TASKalfa 181',
            SNMPHOSTNAME => '',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Kyocera',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'TASKalfa 181',
            SNMPHOSTNAME => '',
            MAC          => undef,
        },
    ],
    'kyocera/FS-2000D.1.walk' => [
        {
            MANUFACTURER => 'Kyocera',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'FS-2000D',
            SNMPHOSTNAME => '',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Kyocera',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'FS-2000D',
            SNMPHOSTNAME => '',
            MAC          => undef,
        },
    ],
    'kyocera/FS-2000D.2.walk' => [
        {
            MANUFACTURER => 'Kyocera',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'FS-2000D',
            SNMPHOSTNAME => '',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Kyocera',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'FS-2000D',
            SNMPHOSTNAME => '',
            MAC          => undef,
        },
    ],
    'epson/AL-C4200.1.walk' => [
        {
            MANUFACTURER => 'Epson',
            TYPE         => undef,
            DESCRIPTION  => 'AL-C4200',
            SNMPHOSTNAME => 'AL-C4200-0ED50E',
            MAC          => undef
        },
        {
            MANUFACTURER => 'Epson',
            TYPE         => undef,
            DESCRIPTION  => 'AL-C4200',
            SNMPHOSTNAME => 'AL-C4200-0ED50E',
            MAC          => undef
        },
    ],
    'epson/AL-C4200.2.walk' => [
        {
            MANUFACTURER => 'Epson',
            TYPE         => undef,
            DESCRIPTION  => 'AL-C4200',
            SNMPHOSTNAME => 'AL-C4200-D14BC7',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Epson',
            TYPE         => undef,
            DESCRIPTION  => 'AL-C4200',
            SNMPHOSTNAME => 'AL-C4200-D14BC7',
            MAC          => undef,
        },
    ],
    'epson/AL-C4200.3.walk' => [
        {
            MANUFACTURER => 'Epson',
            TYPE         => undef,
            DESCRIPTION  => 'AL-C4200',
            SNMPHOSTNAME => 'AL-C4200-D1C30E',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Epson',
            TYPE         => undef,
            DESCRIPTION  => 'AL-C4200',
            SNMPHOSTNAME => 'AL-C4200-D1C30E',
            MAC          => undef,
        },
    ],
    'epson/AL-C4200.4.walk' => [
        {
            MANUFACTURER => 'Epson',
            TYPE         => undef,
            DESCRIPTION  => 'AL-C4200',
            SNMPHOSTNAME => 'AL-C4200-D362D2',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Epson',
            TYPE         => undef,
            DESCRIPTION  => 'AL-C4200',
            SNMPHOSTNAME => 'AL-C4200-D362D2',
            MAC          => undef,
        },
    ],
    'epson/AL-C3900.walk' => [
        {
            MANUFACTURER => 'Epson',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'EPSON AL-C3900',
            SNMPHOSTNAME => '',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Epson',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'EPSON AL-C3900',
            SNMPHOSTNAME => '',
            MAC          => undef,
        },
    ],
    'epson/AL-C1100.walk' => [
        {
            MANUFACTURER => 'Epson',
            TYPE         => undef,
            DESCRIPTION  => 'AL-C1100',
            SNMPHOSTNAME => 'AL-C1100-0DBECC',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Epson',
            TYPE         => undef,
            DESCRIPTION  => 'AL-C1100',
            SNMPHOSTNAME => 'AL-C1100-0DBECC',
            MAC          => undef,
        },
    ],
    'epson/AL-M2400.1.walk' => [
        {
            MANUFACTURER => 'Epson',
            TYPE         => undef,
            DESCRIPTION  => 'AL-M2400',
            SNMPHOSTNAME => 'AL-M2400-7FDDAF',
            MAC          => undef
        },
        {
            MANUFACTURER => 'Epson',
            TYPE         => undef,
            DESCRIPTION  => 'AL-M2400',
            SNMPHOSTNAME => 'AL-M2400-7FDDAF',
            MAC          => undef
        },
    ],
    'epson/AL-M2400.2.walk' => [
        {
            MANUFACTURER => 'Epson',
            TYPE         => undef,
            DESCRIPTION  => 'AL-M2400',
            SNMPHOSTNAME => 'AL-M2400-7FDDAF',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Epson',
            TYPE         => undef,
            DESCRIPTION  => 'AL-M2400',
            SNMPHOSTNAME => 'AL-M2400-7FDDAF',
            MAC          => undef,
        },
    ],
    'xerox/DocuPrint_N2125.walk' => [
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox DocuPrint N2125 Network Laser Printer - 2.12-02 ',
            SNMPHOSTNAME => '',
            MAC          => undef,
        },
        {
            MANUFACTURER  => 'Xerox',
            TYPE          => '3',
            DESCRIPTION   => 'Xerox DocuPrint N2125 Network Laser Printer - 2.12-02 ',
            SNMPHOSTNAME  => '',
            MAC           => undef,
            MODELSNMP     => 'Printer0687',
            MODEL         => undef,
            FIRMWARE      => undef,
            SERIAL        => '3510349171',
        }
    ],
    'xerox/Phaser_5550DT.1.walk' => [
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 5550DT; System 1.3.7.P, OS 8.2, PS 5.1.0, Eng 11.58.00, Net 40.46.04.03.2009, Adobe PostScript 3016.101 (14), PCL 5e/6 Version 7.0.1, Finisher 5.03.00',
            SNMPHOSTNAME => 'Phaser 5550DT',
            MAC          => undef
        },
        {
            MANUFACTURER  => 'Xerox',
            TYPE          => '3',
            DESCRIPTION   => 'Xerox Phaser 5550DT; System 1.3.7.P, OS 8.2, PS 5.1.0, Eng 11.58.00, Net 40.46.04.03.2009, Adobe PostScript 3016.101 (14), PCL 5e/6 Version 7.0.1, Finisher 5.03.00',
            SNMPHOSTNAME  => 'Phaser 5550DT',
            MAC           => undef,
            MODELSNMP     => 'Printer0688',
            MODEL         => undef,
            FIRMWARE      => undef,
            SERIAL        => 'KNB015751',
        },
    ],
    'xerox/Phaser_5550DT.2.walk' => [
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 5550DT; System 1.3.7.P, OS 8.2, PS 5.1.0, Eng 11.58.00, Net 40.46.04.03.2009, Adobe PostScript 3016.101 (14), PCL 5e/6 Version 7.0.1, Finisher 5.01.00',
            SNMPHOSTNAME => 'Phaser 5550DT-1',
            MAC          => undef,
        },
        {
            MANUFACTURER  => 'Xerox',
            TYPE          => '3',
            DESCRIPTION   => 'Xerox Phaser 5550DT; System 1.3.7.P, OS 8.2, PS 5.1.0, Eng 11.58.00, Net 40.46.04.03.2009, Adobe PostScript 3016.101 (14), PCL 5e/6 Version 7.0.1, Finisher 5.01.00',
            SNMPHOSTNAME  => 'Phaser 5550DT-1',
            MAC           => undef,
            MODELSNMP     => 'Printer0689',
            MODEL         => undef,
            FIRMWARE      => undef,
            SERIAL        => 'KNB015753',
        },
    ],
    'xerox/Phaser_6180MFP.walk' => [
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox Phaser 6180MFP-D; Net 11.74,ESS 200802151717,IOT 05.09.00,Boot 200706151125',
            SNMPHOSTNAME => 'Phaser 6180MFP-D-E360D7',
            MAC          => undef,
        },
        {
            MANUFACTURER  => 'Xerox',
            TYPE          => '3',
            DESCRIPTION   => 'Xerox Phaser 6180MFP-D; Net 11.74,ESS 200802151717,IOT 05.09.00,Boot 200706151125',
            SNMPHOSTNAME  => 'Phaser 6180MFP-D-E360D7',
            MAC           => undef,
            MODELSNMP     => 'Printer0370',
            MODEL         => undef,
            FIRMWARE      => undef,
            SERIAL        => 'GPX259705',
        },
    ],
    'xerox/WorkCentre_5632.1.walk' => [
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox WorkCentre 5632 v1 Multifunction System; System Software 025.054.055.00060, ESS 061.060.03400',
            SNMPHOSTNAME => 'SO007XN',
            MAC          => '00:00:AA:CF:9E:5A',
        },
        {
            MANUFACTURER  => 'Xerox',
            TYPE          => '3',
            DESCRIPTION   => 'Xerox WorkCentre 5632 v1 Multifunction System; System Software 025.054.055.00060, ESS 061.060.03400',
            SNMPHOSTNAME  => 'SO007XN',
            MAC           => '00:00:AA:CF:9E:5A',
            MODELSNMP     => 'Printer0705',
            MODEL         => undef,
            FIRMWARE      => undef,
            SERIAL        => '3641509891',
        },
    ],
    'xerox/WorkCentre_5632.2.walk' => [
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox WorkCentre 5632 v1 Multifunction System; System Software 025.054.055.00060, ESS 061.060.03400',
            SNMPHOSTNAME => 'SO011XN',
            MAC          => '00:00:AA:CF:84:10',
        },
        {
            MANUFACTURER  => 'Xerox',
            TYPE          => '3',
            DESCRIPTION   => 'Xerox WorkCentre 5632 v1 Multifunction System; System Software 025.054.055.00060, ESS 061.060.03400',
            SNMPHOSTNAME  => 'SO011XN',
            MAC           => '00:00:AA:CF:84:10',
            MODELSNMP     => 'Printer0705',
            MODEL         => undef,
            FIRMWARE      => undef,
            SERIAL        => '3641504792',
        },
    ],
    'xerox/WorkCentre_7125.walk' => [
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox WorkCentre 7125;System 71.21.21,ESS1.210.4,IOT 5.12.0,FIN A15.2.0,ADF 11.0.1,SJFI3.0.16,SSMI1.14.1',
            SNMPHOSTNAME => 'XEROX WorkCentre 7125',
            MAC          => undef,
        },
        {
            MANUFACTURER  => 'Xerox',
            TYPE          => '3',
            DESCRIPTION   => 'Xerox WorkCentre 7125;System 71.21.21,ESS1.210.4,IOT 5.12.0,FIN A15.2.0,ADF 11.0.1,SJFI3.0.16,SSMI1.14.1',
            SNMPHOSTNAME  => 'XEROX WorkCentre 7125',
            MAC           => undef,
            MODELSNMP     => 'Printer0690',
            MODEL         => undef,
            FIRMWARE      => undef,
            SERIAL        => '3325295030',
        },
    ],
    'xerox/WorkCentre_7435.walk' => [
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox WorkCentre 7435;System 75.3.1,ESS PS1.222.18,IOT 41.1.0,FIN B13.8.0,IIT 22.13.1,ADF 20.0.0,SJFI3.0.12,SSMI1.11.1',
            SNMPHOSTNAME => 'WorkCentre 7435',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Xerox',
            TYPE         => 'PRINTER',
            DESCRIPTION  => 'Xerox WorkCentre 7435;System 75.3.1,ESS PS1.222.18,IOT 41.1.0,FIN B13.8.0,IIT 22.13.1,ADF 20.0.0,SJFI3.0.12,SSMI1.11.1',
            SNMPHOSTNAME => 'WorkCentre 7435',
            MAC          => undef,
        },
    ],
    'hewlett-packard/LaserJet_100_colorMFP_M175nw.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet 100 colorMFP M175nw',
            SNMPHOSTNAME => 'NPIF6FA4A',
            MAC          => undef
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet 100 colorMFP M175nw',
            SNMPHOSTNAME => 'NPIF6FA4A',
            MAC          => undef
        },
    ],
    'hewlett-packard/LaserJet_400_color_M451dn.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet 400 color M451dn',
            SNMPHOSTNAME => 'NPIF67498',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet 400 color M451dn',
            SNMPHOSTNAME => 'NPIF67498',
            MAC          => undef,
        }
    ],
    'hewlett-packard/LaserJet_1320.1.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'hp LaserJet 1320 series',
            SNMPHOSTNAME => 'NPI61044B',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => '3',
            DESCRIPTION  => 'hp LaserJet 1320 series',
            SNMPHOSTNAME => 'NPI61044B',
            MAC          => undef,
            MODELSNMP    => 'Printer0597',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNHW59NG6N',
        }
    ],
    'hewlett-packard/LaserJet_1320.2.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'hp LaserJet 1320 series',
            SNMPHOSTNAME => 'NPI9A3FC7',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => '3',
            DESCRIPTION  => 'hp LaserJet 1320 series',
            SNMPHOSTNAME => 'NPI9A3FC7',
            MAC          => undef,
            MODELSNMP    => 'Printer0597',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNHW625K6Z',
        }
    ],
    'hewlett-packard/LaserJet_1320.3.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'hp LaserJet 1320 series',
            SNMPHOSTNAME => 'NPIC68F5E',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => '3',
            DESCRIPTION  => 'hp LaserJet 1320 series',
            SNMPHOSTNAME => 'NPIC68F5E',
            MAC          => undef,
            MODELSNMP    => 'Printer0597',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CNBW49FHC4',
        }
    ],
    'hewlett-packard/LaserJet_2100.1.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet 2100 Series',
            SNMPHOSTNAME => '',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet 2100 Series',
            SNMPHOSTNAME => '',
            MAC          => undef,
        },
    ],
    'hewlett-packard/LaserJet_2100.2.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet 2100 Series',
            SNMPHOSTNAME => '',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet 2100 Series',
            SNMPHOSTNAME => '',
            MAC          => undef,
        },
    ],
    'hewlett-packard/LaserJet_2600n.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP Color LaserJet 2600n',
            SNMPHOSTNAME => 'NPI1864A0',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP Color LaserJet 2600n',
            SNMPHOSTNAME => 'NPI1864A0',
            MAC          => undef,
        }
    ],
    'hewlett-packard/LaserJet_3600.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP Color LaserJet 3600',
            SNMPHOSTNAME => 'NPI6F72C5',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP Color LaserJet 3600',
            SNMPHOSTNAME => 'NPI6F72C5',
            MAC          => undef,
        },
    ],
    'hewlett-packard/LaserJet_4250.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'hp LaserJet 4250',
            SNMPHOSTNAME => 'impKirat',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'hp LaserJet 4250',
            SNMPHOSTNAME => 'impKirat',
            MAC          => undef,
        },
    ],
    'hewlett-packard/LaserJet_5550.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'hp color LaserJet 5550 ',
            SNMPHOSTNAME => 'IDD116',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'hp color LaserJet 5550 ',
            SNMPHOSTNAME => 'IDD116',
            MAC          => undef,
        }
    ],
    'hewlett-packard/LaserJet_CM1312nfi_MFP.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP Color LaserJet CM1312nfi MFP',
            SNMPHOSTNAME => 'NPI271E90',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP Color LaserJet CM1312nfi MFP',
            SNMPHOSTNAME => 'NPI271E90',
            MAC          => undef,
        }
    ],
    'hewlett-packard/LaserJet_CM1415fn.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet CM1415fn',
            SNMPHOSTNAME => 'B536-lwc237-Fax',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet CM1415fn',
            SNMPHOSTNAME => 'B536-lwc237-Fax',
            MAC          => undef,
        }
    ],
    'hewlett-packard/LaserJet_CM2320fxi_MFP.1.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP Color LaserJet CM2320fxi MFP',
            SNMPHOSTNAME => 'NPI7F5D71',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP Color LaserJet CM2320fxi MFP',
            SNMPHOSTNAME => 'NPI7F5D71',
            MAC          => undef,
        }
    ],
    'hewlett-packard/LaserJet_CM2320fxi_MFP.2.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP Color LaserJet CM2320fxi MFP',
            SNMPHOSTNAME => 'NPI7F5D71',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP Color LaserJet CM2320fxi MFP',
            SNMPHOSTNAME => 'NPI7F5D71',
            MAC          => undef,
        }
    ],
    'hewlett-packard/LaserJet_CM2320fxi_MFP.3.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP Color LaserJet CM2320fxi MFP',
            SNMPHOSTNAME => 'NPI828833',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP Color LaserJet CM2320fxi MFP',
            SNMPHOSTNAME => 'NPI828833',
            MAC          => undef,
        }
    ],
    'hewlett-packard/LaserJet_CM2320nf_MFP.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP Color LaserJet CM2320nf MFP',
            SNMPHOSTNAME => 'NPIB302A7',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP Color LaserJet CM2320nf MFP',
            SNMPHOSTNAME => 'NPIB302A7',
            MAC          => undef,
        },
    ],
    'hewlett-packard/LaserJet_CP2025dn.1.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP Color LaserJet CP2025dn',
            SNMPHOSTNAME => 'NPI2AD743',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP Color LaserJet CP2025dn',
            SNMPHOSTNAME => 'NPI2AD743',
            MAC          => undef,
        }
    ],
    'hewlett-packard/LaserJet_CP2025dn.2.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP Color LaserJet CP2025dn',
            SNMPHOSTNAME => 'NPIC3D5FF',
            MAC          => undef
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP Color LaserJet CP2025dn',
            SNMPHOSTNAME => 'NPIC3D5FF',
            MAC          => undef
        }
    ],
    'hewlett-packard/LaserJet_CP2025n.1.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP Color LaserJet CP2025n',
            SNMPHOSTNAME => 'NPI117008',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP Color LaserJet CP2025n',
            SNMPHOSTNAME => 'NPI117008',
            MAC          => undef,
        }
    ],
    'hewlett-packard/LaserJet_CP2025n.2.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP Color LaserJet CP2025n',
            SNMPHOSTNAME => 'NPI84C481',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP Color LaserJet CP2025n',
            SNMPHOSTNAME => 'NPI84C481',
            MAC          => undef,
        },
    ],
    'hewlett-packard/LaserJet_CP2025n.3.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP Color LaserJet CP2025n',
            SNMPHOSTNAME => 'NPI84C481',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP Color LaserJet CP2025n',
            SNMPHOSTNAME => 'NPI84C481',
            MAC          => undef,
        }
    ],
    'hewlett-packard/LaserJet_CP2025n.4.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP Color LaserJet CP2025n',
            SNMPHOSTNAME => 'NPI81E3A7',
            MAC          => undef
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP Color LaserJet CP2025n',
            SNMPHOSTNAME => 'NPI81E3A7',
            MAC          => undef
        }
    ],
    'hewlett-packard/LaserJet_CP2025n.5.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP Color LaserJet CP2025n',
            SNMPHOSTNAME => 'NPI8FA1DD',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP Color LaserJet CP2025n',
            SNMPHOSTNAME => 'NPI8FA1DD',
            MAC          => undef,
        }
    ],
    'hewlett-packard/LaserJet_P2015_Series.1.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P2015 Series',
            SNMPHOSTNAME => 'NPI83EC85',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P2015 Series',
            SNMPHOSTNAME => 'NPI83EC85',
            MAC          => undef,
        }
    ],
    'hewlett-packard/LaserJet_P2015_Series.2.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P2015 Series',
            SNMPHOSTNAME => 'NPI13EE63',
            MAC          => undef
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P2015 Series',
            SNMPHOSTNAME => 'NPI13EE63',
            MAC          => undef
        },
    ],
    'hewlett-packard/LaserJet_P2015_Series.3.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P2015 Series',
            MAC          => undef,
            SNMPHOSTNAME => 'NPI83EC85',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P2015 Series',
            MAC          => undef,
            SNMPHOSTNAME => 'NPI83EC85',
        }
    ],
    'hewlett-packard/LaserJet-P4014.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P4014',
            SNMPHOSTNAME => 'NPIFFF0F2',
            MAC          => '18:A9:05:FF:F0:F2',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P4014',
            SNMPHOSTNAME => 'NPIFFF0F2',
            MAC          => '18:A9:05:FF:F0:F2',
        }
    ],
    'hewlett-packard/ProCurve_J8697A_Switch_5406zl.walk' => [
        {
            MANUFACTURER => 'Hewlett Packard',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'ProCurve J8697A Switch 5406zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_',
            SNMPHOSTNAME => 'oyapock CR2',
            MAC          => '00:18:71:C1:E0:00',
        },
        {
            MANUFACTURER => 'Hewlett Packard',
            TYPE         => '2',
            DESCRIPTION  => 'ProCurve J8697A Switch 5406zl, revision K.15.04.0015m, ROM K.15.28 (/ws/swbuildm/ec_rel_charleston_qaoff/code/build/btm(ec_rel_',
            SNMPHOSTNAME => 'oyapock CR2',
            MAC          => '00:18:71:C1:E0:00',
            MODELSNMP    => 'Networking2063',
            MODEL        => undef,
            SERIAL       => 'SG707SU03Y',
            FIRMWARE     => undef
        }
    ],
    'hewlett-packard/LaserJet_CP1025nw.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet CP1025nw',
            MAC          => undef,
            SNMPHOSTNAME => 'NPIA6032E',
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet CP1025nw',
            SNMPHOSTNAME => 'NPIA6032E',
            MAC          => undef,
        }
    ],
    'hewlett-packard/LaserJet_P3005.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P3005',
            SNMPHOSTNAME => 'NPI7A5E2D',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P3005',
            SNMPHOSTNAME => 'NPI7A5E2D',
            MAC          => undef,
        },
    ],
    'hewlett-packard/LaserJet_P2055dn.1.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPI7E0932',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPI7E0932',
            MAC          => undef,
        },
    ],
    'hewlett-packard/LaserJet_P2055dn.2.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPI8DDF43',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPI8DDF43',
            MAC          => undef,
        },
    ],
    'hewlett-packard/LaserJet_P2055dn.3.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPI830993',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPI830993',
            MAC          => undef,
        },
    ],
    'hewlett-packard/LaserJet_P2055dn.4.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPI83E8D5',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPI83E8D5',
            MAC          => undef,
        },
    ],
    'hewlett-packard/LaserJet_P2055dn.5.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPI886B5B',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPI886B5B',
            MAC          => undef,
        },
    ],
    'hewlett-packard/LaserJet_P2055dn.6.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPI886B5B',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPI886B5B',
            MAC          => undef,
        },
    ],
    'hewlett-packard/LaserJet_P2055dn.7.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPI80BDD9',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPI80BDD9',
            MAC          => undef,
        },
    ],
    'hewlett-packard/LaserJet_P2055dn.8.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPICB3982',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPICB3982',
            MAC          => undef,
        },
    ],
    'hewlett-packard/LaserJet_P2055dn.9.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPIC08394',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPIC08394',
            MAC          => undef,
        },
    ],
    'hewlett-packard/LaserJet_P2055dn.10.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPICBD8B1',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPICBD8B1',
            MAC          => undef,
        },
    ],
    'hewlett-packard/LaserJet_P2055dn.11.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPIB979A2',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPIB979A2',
            MAC          => undef,
        },
    ],
    'hewlett-packard/LaserJet_P2055dn.12.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPIC93D6D',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P2055dn',
            SNMPHOSTNAME => 'NPIC93D6D',
            MAC          => undef,
        },
    ],
    'hewlett-packard/LaserJet_P4015.1.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P4015',
            SNMPHOSTNAME => 'LJ30000000000000000000----------',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P4015',
            SNMPHOSTNAME => 'LJ30000000000000000000----------',
            MAC          => undef,
        },
    ],
    'hewlett-packard/LaserJet_P4015.2.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P4015',
            SNMPHOSTNAME => 'NPI8D9896',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P4015',
            SNMPHOSTNAME => 'NPI8D9896',
            MAC          => undef,
        },
    ],
    'hewlett-packard/LaserJet_P4015.3.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P4015',
            SNMPHOSTNAME => 'NPI22C87C',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P4015',
            SNMPHOSTNAME => 'NPI22C87C',
            MAC          => undef,
        },
    ],
    'hewlett-packard/LaserJet_P4015.4.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P4015',
            SNMPHOSTNAME => 'NPI9706DE',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P4015',
            SNMPHOSTNAME => 'NPI9706DE',
            MAC          => undef,
        },
    ],
    'hewlett-packard/LaserJet_P4015.5.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P4015',
            SNMPHOSTNAME => 'NPIEADBFB',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P4015',
            SNMPHOSTNAME => 'NPIEADBFB',
            MAC          => undef,
        },
    ],
    'hewlett-packard/LaserJet_CP4520.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP Color LaserJet CP4520 Series',
            SNMPHOSTNAME => 'NPI10DB2C',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP Color LaserJet CP4520 Series',
            SNMPHOSTNAME => 'NPI10DB2C',
            MAC          => undef,
        },
    ],
    'hewlett-packard/LaserJet_CP3525.1.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP Color LaserJet CP3525',
            SNMPHOSTNAME => 'NPI85A57D',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP Color LaserJet CP3525',
            SNMPHOSTNAME => 'NPI85A57D',
            MAC          => undef,
        },
    ],
    'hewlett-packard/LaserJet_CP3525.2.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP Color LaserJet CP3525',
            SNMPHOSTNAME => 'Corinne',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP Color LaserJet CP3525',
            SNMPHOSTNAME => 'Corinne',
            MAC          => undef,
        },
    ],
    'hewlett-packard/LaserJet_P3010.1.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P3010 Series',
            SNMPHOSTNAME => 'NPI013B81',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P3010 Series',
            SNMPHOSTNAME => 'NPI013B81',
            MAC          => undef,
        },
    ],
    'hewlett-packard/LaserJet_P3010.2.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P3010 Series',
            SNMPHOSTNAME => 'NPI013B81',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet P3010 Series',
            SNMPHOSTNAME => 'NPI013B81',
            MAC          => undef,
        },
    ],
    'hewlett-packard/LaserJet_500.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet 500 color M551',
            SNMPHOSTNAME => 'NPI419F6E',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet 500 color M551',
            SNMPHOSTNAME => 'NPI419F6E',
            MAC          => undef,
        },
    ],
    'hewlett-packard/LaserJet_600.1.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet 600 M603',
            SNMPHOSTNAME => 'lj1',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet 600 M603',
            SNMPHOSTNAME => 'lj1',
            MAC          => undef,
        },
    ],
    'hewlett-packard/LaserJet_600.2.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet 600 M603',
            SNMPHOSTNAME => 'lj2',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet 600 M603',
            SNMPHOSTNAME => 'lj2',
            MAC          => undef,
        },
    ],
    'hewlett-packard/LaserJet_4000.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet 4000 Series',
            SNMPHOSTNAME => 'inspiron8',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet 4000 Series',
            SNMPHOSTNAME => 'inspiron8',
            MAC          => undef,
        },
    ],
    'hewlett-packard/LaserJet_4050.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet 4050 Series ',
            SNMPHOSTNAME => 'imprimanteBR',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'HP LaserJet 4050 Series ',
            SNMPHOSTNAME => 'imprimanteBR',
            MAC          => undef,
        },
    ],
    'hewlett-packard/LaserJet_4200.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'hp LaserJet 4200',
            SNMPHOSTNAME => 'IMP41200n0',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'hp LaserJet 4200',
            SNMPHOSTNAME => 'IMP41200n0',
            MAC          => undef,
        },
    ],
    'hewlett-packard/LaserJet_1300n.walk' => [
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'hp LaserJet 1300n',
            SNMPHOSTNAME => 'impbe94',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Hewlett-Packard',
            TYPE         => undef,
            DESCRIPTION  => 'hp LaserJet 1300n',
            SNMPHOSTNAME => 'impbe94',
            MAC          => undef,
        },
    ],
);

if (!$ENV{SNMPWALK_DATABASE}) {
    plan skip_all => 'SNMP walks database required';
} else {
    plan tests => 2 * scalar keys %tests;
}

my $dictionary = FusionInventory::Agent::Task::NetDiscovery::Dictionary->new(
    file => 'resources/dictionary.xml'
);

foreach my $test (sort keys %tests) {
    my $snmp = FusionInventory::Agent::SNMP::Mock->new(
        file => "$ENV{SNMPWALK_DATABASE}/$test"
    );
    my $sysdescr = $snmp->get('.1.3.6.1.2.1.1.1.0');
    my %device0 = FusionInventory::Agent::Task::NetDiscovery::_getDeviceBySNMP(
        $sysdescr, $snmp
    );
    my %device1 = FusionInventory::Agent::Task::NetDiscovery::_getDeviceBySNMP(
        $sysdescr, $snmp, $dictionary
    );
    cmp_deeply(\%device0, $tests{$test}->[0], $test) or print Dumper(\%device0);
    cmp_deeply(\%device1, $tests{$test}->[1], $test) or print Dumper(\%device1);
    use Data::Dumper;

}
