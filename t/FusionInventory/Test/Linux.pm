package FusionInventory::Test::Linux;

use strict;
use warnings;

use Hook::LexWrap;
use FusionInventory::Agent::Tools;

wrap 'FusionInventory::Agent::Tools::getFileHandle', pre => \&mock_commands;

my %commands = (
    'ps aux'         => 'resources/ps/linux',
    '/usr/bin/lshal' => 'resources/hal/dell-xt2',
    'lspci -vvv -nn' => 'resources/lspci/latitude-xt2',
    'uname -r'       => 'resources/uname/linux-a',
    'uname -m'       => 'resources/uname/linux-m',
    'uname -v'       => 'resources/uname/linux-v',
);

sub mock_commands {
    # scan arguments
    foreach my $i (0 .. $#_) {
        next unless $_[$i];
        next unless $_[$i] eq 'command';

        # check if command output exists
        my $command = $_[$i + 1];
        my $file = $commands{$command};
        print STDERR "command '$command' used\n";
        next unless $file;

        # replace command argument with file argument
        $_[$i] = 'file';
        $_[$i + 1] = $file;
        print STDERR "command '$command' replaced with file '$file'\n";
    }
}

1
