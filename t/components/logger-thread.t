#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 4;

use File::Temp qw(tempdir);
use File::stat;
use FusionInventory::Agent::Logger::File;

use English qw(-no_match_vars);

use threads;
use threads::shared;

my $failure :shared;

my $maxsize = 1; # 1MB

my $fileTemp = tempdir( CLEANUP => 0 ).'/file.log'; 
my $logger = FusionInventory::Agent::Logger::File->new(
    config => {
        'logfile' => $fileTemp,
        'logfile-maxsize' => $maxsize,
    }
);

sub _func {

    eval {
        for (my $i = 0; $i< 4000; $i++) {
            $logger->addMessage(level => 'debug', message => 'message');
        }
    };
    $failure = 1 if $EVAL_ERROR;

}

my @threadList;
while (@threadList < 10) {
    push @threadList, threads->create( '_func'  );
}
foreach (@threadList) {
    $_->join();
}

my $s = stat($fileTemp);

ok($s, 'stat()');
ok(!$failure, 'flock()');
ok(! -z $fileTemp, 'log is not empty');
ok($maxsize * 1024 * 1024 > $s->size , 'logfile-maxsize');
