#!/usr/bin/perl

use strict;

use Test::More;
use Test::Deep;

use FusionInventory::Agent::SNMP::Mock;
use FusionInventory::Agent::Task::NetDiscovery;
use FusionInventory::Agent::Task::NetDiscovery::Dictionary;

my %tests = (
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
    cmp_deeply(\%device0, $tests{$test}->[0], $test);
    cmp_deeply(\%device1, $tests{$test}->[1], $test);
}
