package Ocsinventory::Agent::Backend::OS::Win32;

use strict;
use vars qw($runAfter);
$runAfter = ["Ocsinventory::Agent::Backend::OS::Generic"];

sub check { $^O =~ /^MSWin32$/ }

sub run {

}

1;
