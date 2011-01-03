package FusionInventory::Test::MockSystem::Linux2;

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
        'dpkg-query --show --showformat=\'${Package}\t${Version}\t${Installed-Size}\t${Description}\n\'' => 'resources/packaging/dpkg'

    }
);

1
