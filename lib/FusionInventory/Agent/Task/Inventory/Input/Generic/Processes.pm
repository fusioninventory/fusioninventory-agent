package FusionInventory::Agent::Task::Inventory::Input::Generic::Processes;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Unix;

sub isEnabled {
    my (%params) = @_;

    return
        $OSNAME ne 'MSWin32' &&
        !$params{no_category}->{process} &&
        canRun('ps');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};
    my $command   = $OSNAME eq 'solaris' ?
        'ps -A -o user,pid,pcpu,pmem,vsz,rss,tty,s,stime,time,comm' : 'ps aux';

    foreach my $process (getProcessesFromPs(
        logger => $logger, command => $command
    )) {
        $inventory->addEntry(
            section => 'PROCESSES',
            entry   => $process
        );
    }
}

1;
