package FusionInventory::Test::MockSystem::Linux1;

use strict;
use warnings;

use FusionInventory::Test::MockSystem;

my $system = FusionInventory::Test::MockSystem->new(
    commands => {
        'ps aux'         => 'resources/ps/linux',
        '/usr/bin/lshal' => 'resources/hal/dell-xt2',
        'lspci -vvv -nn' => 'resources/lspci/latitude-xt2',
        'uname -r'       => 'resources/uname/linux-a',
        'uname -m'       => 'resources/uname/linux-m',
        'uname -v'       => 'resources/uname/linux-v',
    }
);

1
