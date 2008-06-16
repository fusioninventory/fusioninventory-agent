#!/usr/bin/perl -w
#  main.pl
#  OCSNG
#
#  Created by Wes Young - claimid.com/saxjazman9 on 5/28/08.
#  CopyLeft Barely3am.com 2008. All rights reserved.
#
#  This code is opensource and may be copied and modified as long as the source
#  code is always made freely available.
#  Please refer to the General Public Licence http://www.gnu.org/
#

use strict;

my $file = shift;
$file =~ m/(\S+)\/\S+.pl$/;

my $path = $1;
my $cmd = 'ocsinventory-agent --debug -d';

my $ret = system($path.'/'.$cmd);
exit $ret unless(!defined($ret));
exit -1;
