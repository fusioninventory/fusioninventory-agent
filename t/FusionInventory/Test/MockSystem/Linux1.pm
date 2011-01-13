package FusionInventory::Test::MockSystem::Linux1;

use strict;
use warnings;

use FusionInventory::Test::MockSystem;

mock(
    commands => {
        'ps aux'         => 'resources/ps/linux',
        'lshal'          => 'resources/hal/dell-xt2',
        'lspci -vvv -nn' => 'resources/lspci/latitude-xt2',
        'uname -r'       => 'resources/uname/linux-a',
        'uname -m'       => 'resources/uname/linux-m',
        'uname -v'       => 'resources/uname/linux-v',
        'rpm -qa --queryformat \'%{NAME}\t%{VERSION}-%{RELEASE}\t%{INSTALLTIME:date}\t%{SIZE}\t%{SUMMARY}\n\'' => 'resources/packaging/rpm'
    },
    files => {
        '/etc/mandriva-release' => 'resources/release/mandriva'
    }
);

1
