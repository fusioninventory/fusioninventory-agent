#!/usr/bin/perl -w

use strict;
use warnings;

open VMWARECONFIG, "</etc/vmware/config";
foreach(<VMWARECONFIG>) {
    print;
}
close VMWARECONFIG;
