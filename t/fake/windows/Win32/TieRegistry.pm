package Win32::TieRegistry;

use strict;
use warnings;

our $Registry;

sub import {
    my $callpkg = caller();
    no strict 'refs';

    *{"$callpkg\::Registry"} = \$Registry;
    *{"$callpkg\::KEY_READ"} = sub {};
}

1;
