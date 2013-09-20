package Win32::TieRegistry;

use strict;
use warnings;

our $Registry;
our $Error;

sub import {
    my $callpkg = caller();
    no strict 'refs';

    *{"$callpkg\::Registry"} = \$Registry;
    *{"$callpkg\::KEY_READ"} = sub {};
    *{"$callpkg\::EXTENDED_OS_ERROR"} = \$Error;
}

1;
