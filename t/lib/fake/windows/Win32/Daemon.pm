package Win32::Daemon;

use warnings;
use strict;

use parent 'Exporter';

# Constant values imported from winsvc.h
use constant {
    SERVICE_STOPPED                 => 0x00000001,
    SERVICE_START_PENDING           => 0x00000002,
    SERVICE_STOP_PENDING            => 0x00000003,
    SERVICE_RUNNING                 => 0x00000004,
    SERVICE_CONTINUE_PENDING        => 0x00000005,
    SERVICE_PAUSE_PENDING           => 0x00000006,
    SERVICE_PAUSED                  => 0x00000007,

    SERVICE_ACCEPT_STOP             => 0x00000001,
    SERVICE_ACCEPT_PAUSE_CONTINUE   => 0x00000002,
    SERVICE_ACCEPT_SHUTDOWN         => 0x00000004,

    SERVICE_CONTROL_INTERROGATE     => 0x00000004,

    SERVICE_NOT_READY               => 0x00000000,
};

our @EXPORT =
    map { /^Win32::Daemon::(\S+)$/ ; $1 } grep { /^Win32::Daemon::(\S+)$/ }
        keys(%constant::declared);

1;
