package Sys::Syslog;

use strict;
use warnings;

sub import {
    my $callpkg = caller();
    no strict 'refs';

    *{"$callpkg\::LOG_ERR"}     = sub {};
    *{"$callpkg\::LOG_WARNING"} = sub {};
    *{"$callpkg\::LOG_INFO"}    = sub {};
    *{"$callpkg\::LOG_DEBUG"}   = sub {};
    *{"$callpkg\::syslog"}      = sub {};
    *{"$callpkg\::openlog"}     = sub {};
    *{"$callpkg\::closelog"}    = sub {};
}

1;
