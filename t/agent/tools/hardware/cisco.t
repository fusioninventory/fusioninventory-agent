#!/usr/bin/perl

use strict;
use lib 't/lib';

use FusionInventory::Test::Hardware;

my %tests = (
    'cisco/C1040.walk' => [
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C1040 Software (C1140-K9W7-M), Version 12.4(25d)JA1, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2011 by Cisco Systems, Inc.
Compiled Thu 11-Aug-11 02:58 by prod_rel_team',
            SNMPHOSTNAME => 'WIFI-IPJ-etage2-82.wifi-mngt.dauphine.fr',
            MAC          => '00:00:00:00:00:00'
        },
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C1040 Software (C1140-K9W7-M), Version 12.4(25d)JA1, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2011 by Cisco Systems, Inc.
Compiled Thu 11-Aug-11 02:58 by prod_rel_team',
            SNMPHOSTNAME => 'WIFI-IPJ-etage2-82.wifi-mngt.dauphine.fr',
            MAC          => 'A4:18:75:C2:67:00',
            MODELSNMP    => 'Networking2178',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'FCZ1623Z2XQ',
        }
    ],
    'cisco/C1130.1.walk' => [
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C1130 Software (C1130-K9W7-M), Version 12.4(10b)JA3, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2008 by Cisco Systems, Inc.
Compiled Wed 19-Mar-08 18:08 by prod_rel_team',
            MAC          => '00:00:00:00:00:00',
            SNMPHOSTNAME => 'ap-CP6-BU-161.wifi-mngt.dauphine.fr'
        },
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C1130 Software (C1130-K9W7-M), Version 12.4(10b)JA3, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2008 by Cisco Systems, Inc.
Compiled Wed 19-Mar-08 18:08 by prod_rel_team',
            MAC          => '00:13:5F:FA:F2:50',
            SNMPHOSTNAME => 'ap-CP6-BU-161.wifi-mngt.dauphine.fr',
            MODELSNMP    => 'Networking2176',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'FCZ0930Q00Z',
        }
    ],
    'cisco/C1130.2.walk' => [
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C1130 Software (C1130-K9W7-M), Version 12.4(10b)JA3, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2008 by Cisco Systems, Inc.
Compiled Wed 19-Mar-08 18:08 by prod_rel_team',
            SNMPHOSTNAME => 'ap-P405-45.wifi-mngt.dauphine.fr',
            MAC          => '00:00:00:00:00:00'
        },
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C1130 Software (C1130-K9W7-M), Version 12.4(10b)JA3, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2008 by Cisco Systems, Inc.
Compiled Wed 19-Mar-08 18:08 by prod_rel_team',
            SNMPHOSTNAME => 'ap-P405-45.wifi-mngt.dauphine.fr',
            MAC          => '00:13:5F:FA:FA:50',
            MODELSNMP    => 'Networking2176',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'FCZ0930Q01A',
        }
    ],
    'cisco/C1130.3.walk' => [
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C1130 Software (C1130-K9W7-M), Version 12.4(21a)JA1, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2009 by Cisco Systems, Inc.
Compiled Wed 16-Sep-09 18:36 by prod_rel_team',
            MAC          => '00:00:00:00:00:00',
            SNMPHOSTNAME => 'ap-D416-141.wifi-mngt.dauphine.fr',
        },
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C1130 Software (C1130-K9W7-M), Version 12.4(21a)JA1, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2009 by Cisco Systems, Inc.
Compiled Wed 16-Sep-09 18:36 by prod_rel_team',
            MAC          => '00:13:5F:FA:F9:A0',
            SNMPHOSTNAME => 'ap-D416-141.wifi-mngt.dauphine.fr',
            MODELSNMP    => 'Networking2191',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'FCZ0930Q01N',
        }
    ],
    'cisco/C1130.4.walk' => [
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C1130 Software (C1130-K9W7-M), Version 12.4(21a)JA1, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2009 by Cisco Systems, Inc.
Compiled Wed 16-Sep-09 18:36 by prod_rel_team',
            SNMPHOSTNAME => 'ap-D416-141.wifi-mngt.dauphine.fr',
            MAC          => '00:00:00:00:00:00'
        },
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C1130 Software (C1130-K9W7-M), Version 12.4(21a)JA1, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2009 by Cisco Systems, Inc.
Compiled Wed 16-Sep-09 18:36 by prod_rel_team',
            SNMPHOSTNAME => 'ap-D416-141.wifi-mngt.dauphine.fr',
            MAC          => '00:13:5F:FA:F9:A0',
            MODELSNMP    => 'Networking2191',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'FCZ0930Q01N',
        }
    ],
    'cisco/C2960.1.walk' => [
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASEK9-M), Version 12.2(58)SE1, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2011 by Cisco Systems, Inc.
Compiled Thu 05-May-11 02:53 by prod_rel_team',
            MAC          => '00:24:13:EA:A7:00',
            SNMPHOSTNAME => 'CB-27.mgmt.dauphine.fr',
        },
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASEK9-M), Version 12.2(58)SE1, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2011 by Cisco Systems, Inc.
Compiled Thu 05-May-11 02:53 by prod_rel_team',
            MAC          => '00:24:13:EA:A7:00',
            SNMPHOSTNAME => 'CB-27.mgmt.dauphine.fr',
            MODELSNMP    => 'Networking2177',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'FOC1247X5DX',
        }
    ],
    'cisco/C2960.2.walk' => [
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASEK9-M), Version 12.2(58)SE1, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2011 by Cisco Systems, Inc.
Compiled Thu 05-May-11 02:53 by prod_rel_team',
            MAC          => '00:24:13:CE:D7:00',
            SNMPHOSTNAME => 'AP-P101-59.mgmt.dauphine.fr',
        },
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASEK9-M), Version 12.2(58)SE1, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2011 by Cisco Systems, Inc.
Compiled Thu 05-May-11 02:53 by prod_rel_team',
            MAC          => '00:24:13:CE:D7:00',
            SNMPHOSTNAME => 'AP-P101-59.mgmt.dauphine.fr',
            MODELSNMP    => 'Networking2177',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'FOC1247X5D4',
        }
    ],
    'cisco/C2960.3.walk' => [
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASEK9-M), Version 12.2(58)SE1, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2011 by Cisco Systems, Inc.
Compiled Thu 05-May-11 02:53 by prod_rel_team',
            MAC          => '00:1B:54:D6:39:00',
            SNMPHOSTNAME => 'CP-P101-37.mgmt.dauphine.fr',
        },
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASEK9-M), Version 12.2(58)SE1, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2011 by Cisco Systems, Inc.
Compiled Thu 05-May-11 02:53 by prod_rel_team',
            MAC          => '00:1B:54:D6:39:00',
            SNMPHOSTNAME => 'CP-P101-37.mgmt.dauphine.fr',
            MODELSNMP    => 'Networking2177',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'FOC1113X1PE',
        }
    ],
    'cisco/C2960.4.walk' => [
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASEK9-M), Version 12.2(58)SE1, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2011 by Cisco Systems, Inc.
Compiled Thu 05-May-11 02:53 by prod_rel_team',
            SNMPHOSTNAME => 'AP-P101-59.mgmt.dauphine.fr',
            MAC          => '00:24:13:CE:D7:00',
        },
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASEK9-M), Version 12.2(58)SE1, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2011 by Cisco Systems, Inc.
Compiled Thu 05-May-11 02:53 by prod_rel_team',
            SNMPHOSTNAME => 'AP-P101-59.mgmt.dauphine.fr',
            MAC          => '00:24:13:CE:D7:00',
            MODELSNMP    => 'Networking2177',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'FOC1247X5D4'
        }
    ],
    'cisco/C2960.5.walk' => [
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASEK9-M), Version 12.2(58)SE1, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2011 by Cisco Systems, Inc.
Compiled Thu 05-May-11 02:53 by prod_rel_team',
            SNMPHOSTNAME => 'AP-P101-59.mgmt.dauphine.fr',
            MAC          => '00:24:13:CE:D7:00',
        },
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASEK9-M), Version 12.2(58)SE1, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2011 by Cisco Systems, Inc.
Compiled Thu 05-May-11 02:53 by prod_rel_team',
            SNMPHOSTNAME => 'AP-P101-59.mgmt.dauphine.fr',
            MAC          => '00:24:13:CE:D7:00',
            MODELSNMP    => 'Networking2177',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'FOC1247X5D4'
        }
    ],
    'cisco/C2960.6.walk' => [
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASEK9-M), Version 12.2(58)SE1, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2011 by Cisco Systems, Inc.
Compiled Thu 05-May-11 02:53 by prod_rel_team',
            SNMPHOSTNAME => 'CP-P101-37.mgmt.dauphine.fr',
            MAC          => '00:1B:54:D6:39:00',
        },
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASEK9-M), Version 12.2(58)SE1, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2011 by Cisco Systems, Inc.
Compiled Thu 05-May-11 02:53 by prod_rel_team',
            SNMPHOSTNAME => 'CP-P101-37.mgmt.dauphine.fr',
            MAC          => '00:1B:54:D6:39:00',
            MODELSNMP    => 'Networking2177',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'FOC1113X1PE',
        }
    ],
    'cisco/C2960.7.walk' => [
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASEK9-M), Version 12.2(58)SE1, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2011 by Cisco Systems, Inc.
Compiled Thu 05-May-11 02:53 by prod_rel_team',
            SNMPHOSTNAME => 'CB-27.mgmt.dauphine.fr',
            MAC          => '00:24:13:EA:A7:00',
        },
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASEK9-M), Version 12.2(58)SE1, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2011 by Cisco Systems, Inc.
Compiled Thu 05-May-11 02:53 by prod_rel_team',
            SNMPHOSTNAME => 'CB-27.mgmt.dauphine.fr',
            MAC          => '00:24:13:EA:A7:00',
            MODELSNMP    => 'Networking2177',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'FOC1247X5DX'
        }
    ],
    'cisco/C2960.8.walk' => [
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASEK9-M), Version 15.0(1)SE3, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2012 by Cisco Systems, Inc.
Compiled Wed 30-May-12 14:26 by prod_rel_team',
            SNMPHOSTNAME => 'AP-74.mgmt.dauphine.fr',
            MAC          => 'C4:0A:CB:CD:86:00',
        },
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASEK9-M), Version 15.0(1)SE3, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2012 by Cisco Systems, Inc.
Compiled Wed 30-May-12 14:26 by prod_rel_team',
            SNMPHOSTNAME => 'AP-74.mgmt.dauphine.fr',
            MAC          => 'C4:0A:CB:CD:86:00',
            MODELSNMP    => 'Networking2179',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'FOC1511W1A2',
        }
    ],
    'cisco/C2960.9.walk' => [
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASEK9-M), Version 15.0(1)SE3, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2012 by Cisco Systems, Inc.
Compiled Wed 30-May-12 14:26 by prod_rel_team',
            MAC          => '64:D9:89:8D:B1:80',
            SNMPHOSTNAME => 'CB-C005-208.Dauphine',
        },
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASEK9-M), Version 15.0(1)SE3, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2012 by Cisco Systems, Inc.
Compiled Wed 30-May-12 14:26 by prod_rel_team',
            MAC          => '64:D9:89:8D:B1:80',
            SNMPHOSTNAME => 'CB-C005-208.Dauphine',
            MODELSNMP    => 'Networking2179',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'FOC1511W19F',
        }
    ],
    'cisco/C2960.10.walk' => [
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASEK9-M), Version 15.0(1)SE3, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2012 by Cisco Systems, Inc.
Compiled Wed 30-May-12 14:26 by prod_rel_team',
            MAC          => '2C:36:F8:7D:09:00',
            SNMPHOSTNAME => 'CB-C005-206.Dauphine',
        },
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASEK9-M), Version 15.0(1)SE3, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2012 by Cisco Systems, Inc.
Compiled Wed 30-May-12 14:26 by prod_rel_team',
            MAC          => '2C:36:F8:7D:09:00',
            SNMPHOSTNAME => 'CB-C005-206.Dauphine',
            MODELSNMP    => 'Networking2179',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'FCQ1605X4UZ',
        }
    ],
    'cisco/C2960.11.walk' => [
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASEK9-M), Version 15.0(1)SE3, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2012 by Cisco Systems, Inc.
Compiled Wed 30-May-12 14:26 by prod_rel_team',
            MAC          => '2C:36:F8:7D:06:80',
            SNMPHOSTNAME => 'CB-C005-207.Dauphine',
        },
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASEK9-M), Version 15.0(1)SE3, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2012 by Cisco Systems, Inc.
Compiled Wed 30-May-12 14:26 by prod_rel_team',
            MAC          => '2C:36:F8:7D:06:80',
            SNMPHOSTNAME => 'CB-C005-207.Dauphine',
            MODELSNMP    => 'Networking2179',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'FCQ1605X4VP',
        }
    ],
    'cisco/C2960.12.walk' => [
    {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASEK9-M), Version 15.0(1)SE3, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2012 by Cisco Systems, Inc.
Compiled Wed 30-May-12 14:26 by prod_rel_team',
            MAC          => 'C4:0A:CB:22:E5:80',
            SNMPHOSTNAME => 'CB-C005-205.Dauphine',
        },
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASEK9-M), Version 15.0(1)SE3, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2012 by Cisco Systems, Inc.
Compiled Wed 30-May-12 14:26 by prod_rel_team',
            MAC          => 'C4:0A:CB:22:E5:80',
            SNMPHOSTNAME => 'CB-C005-205.Dauphine',
            MODELSNMP    => 'Networking2179',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'FOC1511W1CB'
        }
    ],
    'cisco/C2960.13.walk' => [
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASEK9-M), Version 15.0(1)SE3, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2012 by Cisco Systems, Inc.
Compiled Wed 30-May-12 14:26 by prod_rel_team',
            SNMPHOSTNAME => 'CB-C005-208.Dauphine',
            MAC          => '64:D9:89:8D:B1:80',
        },
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASEK9-M), Version 15.0(1)SE3, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2012 by Cisco Systems, Inc.
Compiled Wed 30-May-12 14:26 by prod_rel_team',
            SNMPHOSTNAME => 'CB-C005-208.Dauphine',
            MAC          => '64:D9:89:8D:B1:80',
            MODELSNMP    => 'Networking2179',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'FOC1511W19F',
        }
    ],
    'cisco/C2960.14.walk' => [
    {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASEK9-M), Version 15.0(1)SE3, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2012 by Cisco Systems, Inc.
Compiled Wed 30-May-12 14:26 by prod_rel_team',
            SNMPHOSTNAME => 'CB-C005-205.Dauphine',
            MAC          => 'C4:0A:CB:22:E5:80',
        },
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASEK9-M), Version 15.0(1)SE3, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2012 by Cisco Systems, Inc.
Compiled Wed 30-May-12 14:26 by prod_rel_team',
            SNMPHOSTNAME => 'CB-C005-205.Dauphine',
            MAC          => 'C4:0A:CB:22:E5:80',
            MODELSNMP    => 'Networking2179',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'FOC1511W1CB'
        }
    ],
    'cisco/C2960.15.walk' => [
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASEK9-M), Version 15.0(1)SE3, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2012 by Cisco Systems, Inc.
Compiled Wed 30-May-12 14:26 by prod_rel_team',
            SNMPHOSTNAME => 'AP-74.mgmt.dauphine.fr',
            MAC          => 'C4:0A:CB:CD:86:00',
        },
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASEK9-M), Version 15.0(1)SE3, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2012 by Cisco Systems, Inc.
Compiled Wed 30-May-12 14:26 by prod_rel_team',
            SNMPHOSTNAME => 'AP-74.mgmt.dauphine.fr',
            MAC          => 'C4:0A:CB:CD:86:00',
            MODELSNMP    => 'Networking2179',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'FOC1511W1A2'
        }
    ],
    'cisco/C2960.16.walk' => [
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASEK9-M), Version 15.0(1)SE3, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2012 by Cisco Systems, Inc.
Compiled Wed 30-May-12 14:26 by prod_rel_team',
            SNMPHOSTNAME => 'CB-C005-207.Dauphine',
            MAC          => '2C:36:F8:7D:06:80',
        },
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASEK9-M), Version 15.0(1)SE3, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2012 by Cisco Systems, Inc.
Compiled Wed 30-May-12 14:26 by prod_rel_team',
            SNMPHOSTNAME => 'CB-C005-207.Dauphine',
            MAC          => '2C:36:F8:7D:06:80',
            MODELSNMP    => 'Networking2179',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'FCQ1605X4VP'
        }
    ],
    'cisco/C2960.17.walk' => [
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASEK9-M), Version 15.0(1)SE3, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2012 by Cisco Systems, Inc.
Compiled Wed 30-May-12 14:26 by prod_rel_team',
            SNMPHOSTNAME => 'CB-C005-208.Dauphine',
            MAC          => '64:D9:89:8D:B1:80',
        },
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASEK9-M), Version 15.0(1)SE3, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2012 by Cisco Systems, Inc.
Compiled Wed 30-May-12 14:26 by prod_rel_team',
            SNMPHOSTNAME => 'CB-C005-208.Dauphine',
            MAC          => '64:D9:89:8D:B1:80',
            MODELSNMP    => 'Networking2179',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'FOC1511W19F',
        }
    ],
    'cisco/C2960.18.walk' => [
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASEK9-M), Version 15.0(1)SE3, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2012 by Cisco Systems, Inc.
Compiled Wed 30-May-12 14:26 by prod_rel_team',
            SNMPHOSTNAME => 'CB-C005-205.Dauphine',
            MAC          => 'C4:0A:CB:22:E5:80',
        },
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASEK9-M), Version 15.0(1)SE3, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2012 by Cisco Systems, Inc.
Compiled Wed 30-May-12 14:26 by prod_rel_team',
            SNMPHOSTNAME => 'CB-C005-205.Dauphine',
            MAC          => 'C4:0A:CB:22:E5:80',
            MODELSNMP    => 'Networking2179',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'FOC1511W1CB',
        }
    ],
    'cisco/C2960.19.walk' => [
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASEK9-M), Version 15.0(1)SE3, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2012 by Cisco Systems, Inc.
Compiled Wed 30-May-12 14:26 by prod_rel_team',
            SNMPHOSTNAME => 'AP-74.mgmt.dauphine.fr',
            MAC          => 'C4:0A:CB:CD:86:00',
        },
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASEK9-M), Version 15.0(1)SE3, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2012 by Cisco Systems, Inc.
Compiled Wed 30-May-12 14:26 by prod_rel_team',
            SNMPHOSTNAME => 'AP-74.mgmt.dauphine.fr',
            MAC          => 'C4:0A:CB:CD:86:00',
            MODELSNMP    => 'Networking2179',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'FOC1511W1A2',
        }
    ],
    'cisco/C2960.20.walk' => [
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANLITEK9-M), Version 12.2(50)SE5, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2010 by Cisco Systems, Inc.
Compiled Tue 28-Sep-10 13:44 by prod_rel_team',
            SNMPHOSTNAME => 'CP-lt-40.mgmt.dauphine.fr',
            MAC          => '04:C5:A4:42:F2:80',
        },
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANLITEK9-M), Version 12.2(50)SE5, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2010 by Cisco Systems, Inc.
Compiled Tue 28-Sep-10 13:44 by prod_rel_team',
            SNMPHOSTNAME => 'CP-lt-40.mgmt.dauphine.fr',
            MAC          => '04:C5:A4:42:F2:80',
            MODELSNMP    => 'Networking2183',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'FOC1508V4B5',
        }
    ],
    'cisco/C2960.21.walk' => [
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANLITEK9-M), Version 12.2(50)SE5, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2010 by Cisco Systems, Inc.
Compiled Tue 28-Sep-10 13:44 by prod_rel_team',
            MAC          => '04:C5:A4:42:F2:80',
            SNMPHOSTNAME => 'default-40.mgmt.dauphine.fr',
        },
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANLITEK9-M), Version 12.2(50)SE5, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2010 by Cisco Systems, Inc.
Compiled Tue 28-Sep-10 13:44 by prod_rel_team',
            MAC          => '04:C5:A4:42:F2:80',
            SNMPHOSTNAME => 'default-40.mgmt.dauphine.fr',
            MODELSNMP    => 'Networking2183',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'FOC1508V4B5',
        }
    ],
    'cisco/C2960.22.walk' => [
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANLITEK9-M), Version 12.2(50)SE5, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2010 by Cisco Systems, Inc.
Compiled Tue 28-Sep-10 13:44 by prod_rel_team',
            SNMPHOSTNAME => 'Scol-tmp-65.mgmt.dauphine.fr',
            MAC          => 'E8:40:40:AA:73:80',
        },
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANLITEK9-M), Version 12.2(50)SE5, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2010 by Cisco Systems, Inc.
Compiled Tue 28-Sep-10 13:44 by prod_rel_team',
            SNMPHOSTNAME => 'Scol-tmp-65.mgmt.dauphine.fr',
            MAC          => 'E8:40:40:AA:73:80',
            MODELSNMP    => 'Networking2183',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'FOC1511W532'
        }
    ],
    'cisco/C2960.23.walk' => [
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANLITEK9-M), Version 12.2(50)SE5, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2010 by Cisco Systems, Inc.
Compiled Tue 28-Sep-10 13:44 by prod_rel_team',
            SNMPHOSTNAME => 'default-40.mgmt.dauphine.fr',
            MAC          => '04:C5:A4:42:F2:80',
        },
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANLITEK9-M), Version 12.2(50)SE5, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2010 by Cisco Systems, Inc.
Compiled Tue 28-Sep-10 13:44 by prod_rel_team',
            SNMPHOSTNAME => 'default-40.mgmt.dauphine.fr',
            MAC          => '04:C5:A4:42:F2:80',
            MODELSNMP    => 'Networking2183',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'FOC1508V4B5',
        }
    ],
    'cisco/C2960.24.walk' => [
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANLITEK9-M), Version 12.2(50)SE4, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2010 by Cisco Systems, Inc.
Compiled Fri 26-Mar-10 09:14 by prod_rel_team',
            SNMPHOSTNAME => 'AB-A422-7.mgmt.dauphine.fr',
            MAC          => '40:F4:EC:D6:80:00',
        },
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANLITEK9-M), Version 12.2(50)SE4, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2010 by Cisco Systems, Inc.
Compiled Fri 26-Mar-10 09:14 by prod_rel_team',
            SNMPHOSTNAME => 'AB-A422-7.mgmt.dauphine.fr',
            MAC          => '40:F4:EC:D6:80:00',
            MODELSNMP    => 'Networking2184',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'FOC1501V1PS'
        }
    ],
    'cisco/C2960.25.walk' => [
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASE-M), Version 12.2(50)SE, RELEASE SOFTWARE (fc1)
Copyright (c) 1986-2009 by Cisco Systems, Inc.
Compiled Fri 27-Feb-09 23:25 by weiliu',
            SNMPHOSTNAME => 'AP-72.mgmt.dauphine.fr',
            MAC          => 'C4:0A:CB:E6:F0:00',
        },
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASE-M), Version 12.2(50)SE, RELEASE SOFTWARE (fc1)
Copyright (c) 1986-2009 by Cisco Systems, Inc.
Compiled Fri 27-Feb-09 23:25 by weiliu',
            SNMPHOSTNAME => 'AP-72.mgmt.dauphine.fr',
            MAC          => 'C4:0A:CB:E6:F0:00',
            MODELSNMP    => 'Networking2416',
            MODEL        => undef,
            SERIAL       => undef,
            FIRMWARE     => undef,
        }
    ],
    'cisco/C2960.26.walk' => [
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASE-M), Version 12.2(50)SE, RELEASE SOFTWARE (fc1)
Copyright (c) 1986-2009 by Cisco Systems, Inc.
Compiled Fri 27-Feb-09 23:25 by weiliu',
            SNMPHOSTNAME => 'CB-243.mgmt.dauphine.fr',
            MAC          => 'C4:0A:CB:E6:E8:80',
        },
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASE-M), Version 12.2(50)SE, RELEASE SOFTWARE (fc1)
Copyright (c) 1986-2009 by Cisco Systems, Inc.
Compiled Fri 27-Feb-09 23:25 by weiliu',
            SNMPHOSTNAME => 'CB-243.mgmt.dauphine.fr',
            MAC          => 'C4:0A:CB:E6:E8:80',
            MODELSNMP    => 'Networking2416',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => undef,
        }
    ],
    'cisco/C2960.27.walk' => [
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASE-M), Version 12.2(50)SE, RELEASE SOFTWARE (fc1)
Copyright (c) 1986-2009 by Cisco Systems, Inc.
Compiled Fri 27-Feb-09 23:25 by weiliu',
            SNMPHOSTNAME => 'AB-39.mgmt.dauphine.fr',
            MAC          => 'C4:0A:CB:CD:83:00',
        },
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASE-M), Version 12.2(50)SE, RELEASE SOFTWARE (fc1)
Copyright (c) 1986-2009 by Cisco Systems, Inc.
Compiled Fri 27-Feb-09 23:25 by weiliu',
            SNMPHOSTNAME => 'AB-39.mgmt.dauphine.fr',
            MAC          => 'C4:0A:CB:CD:83:00',
            MODELSNMP    => 'Networking2416',
            MODEL        => undef,
            SERIAL       => undef,
            FIRMWARE     => undef,
        }
    ],
    'cisco/C2960.28.walk' => [
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASE-M), Version 12.2(50)SE, RELEASE SOFTWARE (fc1)
Copyright (c) 1986-2009 by Cisco Systems, Inc.
Compiled Fri 27-Feb-09 23:25 by weiliu',
            SNMPHOSTNAME => 'AB-35.mgmt.dauphine.fr',
            MAC          => 'C4:0A:CB:95:39:00',
        },
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASE-M), Version 12.2(50)SE, RELEASE SOFTWARE (fc1)
Copyright (c) 1986-2009 by Cisco Systems, Inc.
Compiled Fri 27-Feb-09 23:25 by weiliu',
            SNMPHOSTNAME => 'AB-35.mgmt.dauphine.fr',
            MAC          => 'C4:0A:CB:95:39:00',
            MODELSNMP    => 'Networking2416',
            MODEL        => undef,
            SERIAL       => undef,
            FIRMWARE     => undef,
        }
    ],
    'cisco/C2960.29.walk' => [
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASE-M), Version 12.2(50)SE, RELEASE SOFTWARE (fc1)
Copyright (c) 1986-2009 by Cisco Systems, Inc.
Compiled Fri 27-Feb-09 23:25 by weiliu',
            MAC          => 'C4:0A:CB:CD:8B:80',
            SNMPHOSTNAME => 'CP-106.mgmt.dauphine.fr'
        },
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASE-M), Version 12.2(50)SE, RELEASE SOFTWARE (fc1)
Copyright (c) 1986-2009 by Cisco Systems, Inc.
Compiled Fri 27-Feb-09 23:25 by weiliu',
            MAC          => 'C4:0A:CB:CD:8B:80',
            SNMPHOSTNAME => 'CP-106.mgmt.dauphine.fr',
            MODELSNMP    => 'Networking2416',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => undef,
        }
    ],
    'cisco/C2960.30.walk' => [
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASE-M), Version 12.2(50)SE, RELEASE SOFTWARE (fc1)
Copyright (c) 1986-2009 by Cisco Systems, Inc.
Compiled Fri 27-Feb-09 23:25 by weiliu',
            MAC          => 'C4:0A:CB:AB:68:80',
            SNMPHOSTNAME => 'AP-71.mgmt.dauphine.fr',
        },
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASE-M), Version 12.2(50)SE, RELEASE SOFTWARE (fc1)
Copyright (c) 1986-2009 by Cisco Systems, Inc.
Compiled Fri 27-Feb-09 23:25 by weiliu',
            MAC          => 'C4:0A:CB:AB:68:80',
            SNMPHOSTNAME => 'AP-71.mgmt.dauphine.fr',
            MODELSNMP    => 'Networking2416',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => undef,
        }
    ],
    'cisco/C2960.31.walk' => [
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASE-M), Version 12.2(50)SE, RELEASE SOFTWARE (fc1)
Copyright (c) 1986-2009 by Cisco Systems, Inc.
Compiled Fri 27-Feb-09 23:25 by weiliu',
            MAC          => 'C4:0A:CB:E6:E8:80',
            SNMPHOSTNAME => 'CB-243.mgmt.dauphine.fr',
        },
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASE-M), Version 12.2(50)SE, RELEASE SOFTWARE (fc1)
Copyright (c) 1986-2009 by Cisco Systems, Inc.
Compiled Fri 27-Feb-09 23:25 by weiliu',
            MAC          => 'C4:0A:CB:E6:E8:80',
            SNMPHOSTNAME => 'CB-243.mgmt.dauphine.fr',
            MODELSNMP    => 'Networking2416',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => undef
        }
    ],
    'cisco/C2960.32.walk' => [
    {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASE-M), Version 12.2(50)SE, RELEASE SOFTWARE (fc1)
Copyright (c) 1986-2009 by Cisco Systems, Inc.
Compiled Fri 27-Feb-09 23:25 by weiliu',
            MAC          => 'C4:0A:CB:CD:88:00',
            SNMPHOSTNAME => 'CP-129.mgmt.dauphine.fr',
        },
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASE-M), Version 12.2(50)SE, RELEASE SOFTWARE (fc1)
Copyright (c) 1986-2009 by Cisco Systems, Inc.
Compiled Fri 27-Feb-09 23:25 by weiliu',
            MAC          => 'C4:0A:CB:CD:88:00',
            SNMPHOSTNAME => 'CP-129.mgmt.dauphine.fr',
            MODELSNMP    => 'Networking2416',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => undef
        }
    ],
    'cisco/C2960.33.walk' => [
    {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASE-M), Version 12.2(50)SE, RELEASE SOFTWARE (fc1)
Copyright (c) 1986-2009 by Cisco Systems, Inc.
Compiled Fri 27-Feb-09 23:25 by weiliu',
            MAC          => 'C4:0A:CB:BA:6C:00',
            SNMPHOSTNAME => 'AP-73.mgmt.dauphine.fr',
        },
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASE-M), Version 12.2(50)SE, RELEASE SOFTWARE (fc1)
Copyright (c) 1986-2009 by Cisco Systems, Inc.
Compiled Fri 27-Feb-09 23:25 by weiliu',
            MAC          => 'C4:0A:CB:BA:6C:00',
            SNMPHOSTNAME => 'AP-73.mgmt.dauphine.fr',
            MODELSNMP    => 'Networking2416',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => undef
        }
    ],
    'cisco/C2960.34.walk' => [
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASE-M), Version 12.2(50)SE, RELEASE SOFTWARE (fc1)
Copyright (c) 1986-2009 by Cisco Systems, Inc.
Compiled Fri 27-Feb-09 23:25 by weiliu',
            SNMPHOSTNAME => 'CB-243.mgmt.dauphine.fr',
            MAC          => 'C4:0A:CB:E6:E8:80',
        },
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASE-M), Version 12.2(50)SE, RELEASE SOFTWARE (fc1)
Copyright (c) 1986-2009 by Cisco Systems, Inc.
Compiled Fri 27-Feb-09 23:25 by weiliu',
            SNMPHOSTNAME => 'CB-243.mgmt.dauphine.fr',
            MAC          => 'C4:0A:CB:E6:E8:80',
            MODELSNMP    => 'Networking2416',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => undef
        }
    ],
    'cisco/C2960.35.walk' => [
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASE-M), Version 12.2(50)SE, RELEASE SOFTWARE (fc1)
Copyright (c) 1986-2009 by Cisco Systems, Inc.
Compiled Fri 27-Feb-09 23:25 by weiliu',
            SNMPHOSTNAME => 'CP-138.mgmt.dauphine.fr',
            MAC          => 'C4:0A:CB:BA:6E:80',
        },
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASE-M), Version 12.2(50)SE, RELEASE SOFTWARE (fc1)
Copyright (c) 1986-2009 by Cisco Systems, Inc.
Compiled Fri 27-Feb-09 23:25 by weiliu',
            SNMPHOSTNAME => 'CP-138.mgmt.dauphine.fr',
            MAC          => 'C4:0A:CB:BA:6E:80',
            MODELSNMP    => 'Networking2416',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => undef
        }
    ],
    'cisco/C2960.36.walk' => [
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASE-M), Version 12.2(50)SE, RELEASE SOFTWARE (fc1)
Copyright (c) 1986-2009 by Cisco Systems, Inc.
Compiled Fri 27-Feb-09 23:25 by weiliu',
            SNMPHOSTNAME => 'CP-129.mgmt.dauphine.fr',
            MAC          => 'C4:0A:CB:CD:88:00',
        },
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASE-M), Version 12.2(50)SE, RELEASE SOFTWARE (fc1)
Copyright (c) 1986-2009 by Cisco Systems, Inc.
Compiled Fri 27-Feb-09 23:25 by weiliu',
            SNMPHOSTNAME => 'CP-129.mgmt.dauphine.fr',
            MAC          => 'C4:0A:CB:CD:88:00',
            MODELSNMP    => 'Networking2416',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => undef
        }
    ],
    'cisco/C2960.37.walk' => [
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASE-M), Version 12.2(50)SE, RELEASE SOFTWARE (fc1)
Copyright (c) 1986-2009 by Cisco Systems, Inc.
Compiled Fri 27-Feb-09 23:25 by weiliu',
            SNMPHOSTNAME => 'CP-106.mgmt.dauphine.fr',
            MAC          => 'C4:0A:CB:CD:8B:80',
        },
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASE-M), Version 12.2(50)SE, RELEASE SOFTWARE (fc1)
Copyright (c) 1986-2009 by Cisco Systems, Inc.
Compiled Fri 27-Feb-09 23:25 by weiliu',
            SNMPHOSTNAME => 'CP-106.mgmt.dauphine.fr',
            MAC          => 'C4:0A:CB:CD:8B:80',
            MODELSNMP    => 'Networking2416',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => undef
        }
    ],
    'cisco/C2960.38.walk' => [
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASE-M), Version 12.2(50)SE, RELEASE SOFTWARE (fc1)
Copyright (c) 1986-2009 by Cisco Systems, Inc.
Compiled Fri 27-Feb-09 23:25 by weiliu',
            SNMPHOSTNAME => 'AP-71.mgmt.dauphine.fr',
            MAC          => 'C4:0A:CB:AB:68:80',
        },
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASE-M), Version 12.2(50)SE, RELEASE SOFTWARE (fc1)
Copyright (c) 1986-2009 by Cisco Systems, Inc.
Compiled Fri 27-Feb-09 23:25 by weiliu',
            SNMPHOSTNAME => 'AP-71.mgmt.dauphine.fr',
            MAC          => 'C4:0A:CB:AB:68:80',
            MODELSNMP    => 'Networking2416',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => undef
        }
    ],
    'cisco/C2960.39.walk' => [
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASE-M), Version 12.2(50)SE, RELEASE SOFTWARE (fc1)
Copyright (c) 1986-2009 by Cisco Systems, Inc.
Compiled Fri 27-Feb-09 23:25 by weiliu',
            SNMPHOSTNAME => 'AP-72.mgmt.dauphine.fr',
            MAC          => 'C4:0A:CB:E6:F0:00'
        },
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASE-M), Version 12.2(50)SE, RELEASE SOFTWARE (fc1)
Copyright (c) 1986-2009 by Cisco Systems, Inc.
Compiled Fri 27-Feb-09 23:25 by weiliu',
            SNMPHOSTNAME => 'AP-72.mgmt.dauphine.fr',
            MAC          => 'C4:0A:CB:E6:F0:00',
            MODELSNMP    => 'Networking2416',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => undef
        }
    ],
    'cisco/C2960.40.walk' => [
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASE-M), Version 12.2(50)SE, RELEASE SOFTWARE (fc1)
Copyright (c) 1986-2009 by Cisco Systems, Inc.
Compiled Fri 27-Feb-09 23:25 by weiliu',
            SNMPHOSTNAME => 'AP-73.mgmt.dauphine.fr',
            MAC          => 'C4:0A:CB:BA:6C:00',
        },
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASE-M), Version 12.2(50)SE, RELEASE SOFTWARE (fc1)
Copyright (c) 1986-2009 by Cisco Systems, Inc.
Compiled Fri 27-Feb-09 23:25 by weiliu',
            SNMPHOSTNAME => 'AP-73.mgmt.dauphine.fr',
            MAC          => 'C4:0A:CB:BA:6C:00',
            MODELSNMP    => 'Networking2416',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => undef
        }
    ],
    'cisco/C2960.41.walk' => [
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASE-M), Version 12.2(50)SE, RELEASE SOFTWARE (fc1)
Copyright (c) 1986-2009 by Cisco Systems, Inc.
Compiled Fri 27-Feb-09 23:25 by weiliu',
            SNMPHOSTNAME => 'AP-73.mgmt.dauphine.fr',
            MAC          => 'C4:0A:CB:BA:6C:00',
        },
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASE-M), Version 12.2(50)SE, RELEASE SOFTWARE (fc1)
Copyright (c) 1986-2009 by Cisco Systems, Inc.
Compiled Fri 27-Feb-09 23:25 by weiliu',
            SNMPHOSTNAME => 'AP-73.mgmt.dauphine.fr',
            MAC          => 'C4:0A:CB:BA:6C:00',
            MODELSNMP    => 'Networking2416',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => undef
        }
    ],
    'cisco/C2960.42.walk' => [
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASE-M), Version 12.2(50)SE, RELEASE SOFTWARE (fc1)
Copyright (c) 1986-2009 by Cisco Systems, Inc.
Compiled Fri 27-Feb-09 23:25 by weiliu',
            SNMPHOSTNAME => 'AP-72.mgmt.dauphine.fr',
            MAC          => 'C4:0A:CB:E6:F0:00',
        },
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASE-M), Version 12.2(50)SE, RELEASE SOFTWARE (fc1)
Copyright (c) 1986-2009 by Cisco Systems, Inc.
Compiled Fri 27-Feb-09 23:25 by weiliu',
            SNMPHOSTNAME => 'AP-72.mgmt.dauphine.fr',
            MAC          => 'C4:0A:CB:E6:F0:00',
            MODELSNMP    => 'Networking2416',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => undef
        }
    ],
    'cisco/C2960.43.walk' => [
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASE-M), Version 12.2(50)SE, RELEASE SOFTWARE (fc1)
Copyright (c) 1986-2009 by Cisco Systems, Inc.
Compiled Fri 27-Feb-09 23:25 by weiliu',
            SNMPHOSTNAME => 'AP-71.mgmt.dauphine.fr',
            MAC          => 'C4:0A:CB:AB:68:80',
        },
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASE-M), Version 12.2(50)SE, RELEASE SOFTWARE (fc1)
Copyright (c) 1986-2009 by Cisco Systems, Inc.
Compiled Fri 27-Feb-09 23:25 by weiliu',
            SNMPHOSTNAME => 'AP-71.mgmt.dauphine.fr',
            MAC          => 'C4:0A:CB:AB:68:80',
            MODELSNMP    => 'Networking2416',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => undef
        }
    ],
    'cisco/C2960.44.walk' => [
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASE-M), Version 12.2(50)SE, RELEASE SOFTWARE (fc1)
Copyright (c) 1986-2009 by Cisco Systems, Inc.
Compiled Fri 27-Feb-09 23:25 by weiliu',
            SNMPHOSTNAME => 'CB-243.mgmt.dauphine.fr',
            MAC          => 'C4:0A:CB:E6:E8:80',
        },
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASE-M), Version 12.2(50)SE, RELEASE SOFTWARE (fc1)
Copyright (c) 1986-2009 by Cisco Systems, Inc.
Compiled Fri 27-Feb-09 23:25 by weiliu',
            SNMPHOSTNAME => 'CB-243.mgmt.dauphine.fr',
            MAC          => 'C4:0A:CB:E6:E8:80',
            MODELSNMP    => 'Networking2416',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => undef
        }
    ],
    'cisco/C2960.45.walk' => [
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASE-M), Version 12.2(50)SE, RELEASE SOFTWARE (fc1)
Copyright (c) 1986-2009 by Cisco Systems, Inc.
Compiled Fri 27-Feb-09 23:25 by weiliu',
            SNMPHOSTNAME => 'CB-242.mgmt.dauphine.fr',
            MAC          => 'C4:0A:CB:CD:73:00',
        },
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASE-M), Version 12.2(50)SE, RELEASE SOFTWARE (fc1)
Copyright (c) 1986-2009 by Cisco Systems, Inc.
Compiled Fri 27-Feb-09 23:25 by weiliu',
            SNMPHOSTNAME => 'CB-242.mgmt.dauphine.fr',
            MAC          => 'C4:0A:CB:CD:73:00',
            MODELSNMP    => 'Networking2416',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => undef
        }
    ],
    'cisco/C2960.46.walk' => [
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASE-M), Version 12.2(50)SE, RELEASE SOFTWARE (fc1)
Copyright (c) 1986-2009 by Cisco Systems, Inc.
Compiled Fri 27-Feb-09 23:25 by weiliu',
            SNMPHOSTNAME => 'CP-129.mgmt.dauphine.fr',
            MAC          => 'C4:0A:CB:CD:88:00',
        },
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960 Software (C2960-LANBASE-M), Version 12.2(50)SE, RELEASE SOFTWARE (fc1)
Copyright (c) 1986-2009 by Cisco Systems, Inc.
Compiled Fri 27-Feb-09 23:25 by weiliu',
            SNMPHOSTNAME => 'CP-129.mgmt.dauphine.fr',
            MAC          => 'C4:0A:CB:CD:88:00',
            MODELSNMP    => 'Networking2416',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => undef
        }
    ],
    'cisco/C2960S.1.walk' => [
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960S Software (C2960S-UNIVERSALK9-M), Version 12.2(58)SE1, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2011 by Cisco Systems, Inc.
Compiled Thu 05-May-11 03:03 by prod_rel_team',
            SNMPHOSTNAME => 'SALSERV-INTERUFR-149.mgmt.dauphine.fr',
            MAC          => '18:33:9D:E7:15:00',
        },
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960S Software (C2960S-UNIVERSALK9-M), Version 12.2(58)SE1, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2011 by Cisco Systems, Inc.
Compiled Thu 05-May-11 03:03 by prod_rel_team',
            SNMPHOSTNAME => 'SALSERV-INTERUFR-149.mgmt.dauphine.fr',
            MAC          => '18:33:9D:E7:15:00',
            MODELSNMP    => 'Networking2147',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'FOC1622Y2ME',
        }
    ],
    'cisco/C2960S.2.walk' => [
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960S Software (C2960S-UNIVERSALK9-M), Version 12.2(58)SE1, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2011 by Cisco Systems, Inc.
Compiled Thu 05-May-11 03:03 by prod_rel_team',
            SNMPHOSTNAME => 'CB-C005-202.mgmt.dauphine.fr',
            MAC          => 'B4:14:89:38:2D:80',
        },
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco IOS Software, C2960S Software (C2960S-UNIVERSALK9-M), Version 12.2(58)SE1, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2011 by Cisco Systems, Inc.
Compiled Thu 05-May-11 03:03 by prod_rel_team',
            SNMPHOSTNAME => 'CB-C005-202.mgmt.dauphine.fr',
            MAC          => 'B4:14:89:38:2D:80',
            MODELSNMP    => 'Networking2147',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'FOC1440Z0HG'
        }
    ],
    'cisco/C3550.1.walk' => [
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco Internetwork Operating System Software 
IOS (tm) C3550 Software (C3550-I5Q3L2-M), Version 12.1(20)EA1a, RELEASE SOFTWARE (fc1)
Copyright (c) 1986-2004 by cisco Systems, Inc.
Compiled Mon 19-Apr-04 21:50 by yenanh',
            SNMPHOSTNAME => 'CB-Federateur.mgmt.dauphine.fr',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco Internetwork Operating System Software 
IOS (tm) C3550 Software (C3550-I5Q3L2-M), Version 12.1(20)EA1a, RELEASE SOFTWARE (fc1)
Copyright (c) 1986-2004 by cisco Systems, Inc.
Compiled Mon 19-Apr-04 21:50 by yenanh',
            SNMPHOSTNAME => 'CB-Federateur.mgmt.dauphine.fr',
            MAC          => undef,
            MODELSNMP    => 'Networking2034',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CAT0647X118',
        }
    ],
    'cisco/C3550.2.walk' => [
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco Internetwork Operating System Software 
IOS (tm) C3550 Software (C3550-I5Q3L2-M), Version 12.1(20)EA1a, RELEASE SOFTWARE (fc1)
Copyright (c) 1986-2004 by cisco Systems, Inc.
Compiled Mon 19-Apr-04 21:50 by yenanh',
            SNMPHOSTNAME => 'CB-Federateur.mgmt.dauphine.fr',
            MAC          => undef,
        },
        {
            MANUFACTURER => 'Cisco',
            TYPE         => 'NETWORKING',
            DESCRIPTION  => 'Cisco Internetwork Operating System Software 
IOS (tm) C3550 Software (C3550-I5Q3L2-M), Version 12.1(20)EA1a, RELEASE SOFTWARE (fc1)
Copyright (c) 1986-2004 by cisco Systems, Inc.
Compiled Mon 19-Apr-04 21:50 by yenanh',
            SNMPHOSTNAME => 'CB-Federateur.mgmt.dauphine.fr',
            MAC          => undef,
            MODELSNMP    => 'Networking2034',
            MODEL        => undef,
            FIRMWARE     => undef,
            SERIAL       => 'CAT0647X118',
        }
    ],
);

runDiscoveryTests(%tests);
