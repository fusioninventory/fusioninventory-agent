#!/usr/bin/perl

use strict;
use warnings;
use lib 't/lib';

use English qw(-no_match_vars);
use Test::More;
use Test::MockModule;
use Test::Deep;

use File::Temp qw(tempdir);

BEGIN {
    # use mock modules for non-available ones
    push @INC, 't/lib/fake/windows' if $OSNAME ne 'MSWin32';
}

use Config;
# check thread support availability, only really needed for winkey tests
if (!$Config{usethreads} || $Config{usethreads} ne 'define') {
    plan skip_all => 'thread support required';
}

use FusionInventory::Agent::Logger;

use FusionInventory::Agent::Task::Deploy::CheckProcessor;

sub base_object {
    my $subclass = shift;
    my $hash = shift || {};

    $hash->{logger}  = undef unless $hash->{logger};
    $hash->{message} = 'no message' unless $hash->{message};
    $hash->{status}  = 'ok';
    $hash->{return}  = 'ko'  unless $hash->{return};
    $hash->{type}    = 'n/a' unless $hash->{type};
    $hash->{path}    = '~~ no path given ~~' unless $hash->{path};

    my $class = "FusionInventory::Agent::Task::Deploy::CheckProcessor";
    $class .= "::$subclass" if $subclass;
    bless $hash, $class;
}

my $testdir = tempdir(CLEANUP => $ENV{TEST_DEBUG} ? 0 : 1);
my $notadir = tempdir(CLEANUP => $ENV{TEST_DEBUG} ? 0 : 1);
rmdir($notadir);
my $testfile = "$testdir/test.txt";
my $notafile = "$testdir/missing.txt";
open TEST, ">$testfile" or die "Can't create test file: $!";
print TEST "x" x 256;
close TEST;
my $filesha1 = '53dab551701657356ed8b75653865a2e7a9c2f42';
my $filesha512 = '03748e1db37e66afeab7f7e93bd7716ae4379158fcc1f7846e49c061e99b5891b55ee7f808bd039b1deef9d0161f390531d8d08654679405ed887ed93058e3b2';
my $testreg = "HKEY_LOCAL_MACHINE\\HARDWARE\\DESCRIPTION\\System\\CentralProcessor\\0";
my $badreg = "HKEY_BAD_ROOT\\HARDWARE\\DESCRIPTION\\System\\Central___wrong_key___Processor";

# We will need to fake OSNAME so we can also test Win32 related CheckProcessors
our $OSNAME;
my $RealOSNAME = $OSNAME;

my $logger = FusionInventory::Agent::Logger->new(
    backends => [ 'Test' ]
);

my %checkcb = (
    'dir-exists' => sub {
        my ( $check ) = shift ;
        $check->{on_success} =~ /directory exists/ && $check->{on_failure} =~ /directory is missing/;
    },
    'dir-missing' => sub {
        my ( $check ) = shift ;
        $check->{on_failure} =~ /directory exists/ && $check->{on_success} =~ /directory is missing/;
    },
    'file-exists' => sub {
        my ( $check ) = shift ;
        $check->{on_success} =~ /file exists/ && $check->{on_failure} =~ /file is missing/;
    },
    'file-missing' => sub {
        my ( $check ) = shift ;
        $check->{on_failure} =~ /file exists/ && $check->{on_success} =~ /file is missing/;
    },
    'file-size-eq' => sub {
        my ( $check ) = shift ;
        $check->{on_failure} =~ /is missing|no value provided|file stat failure|file size not found|wrong file size/
            && $check->{on_success} =~ /expected file size/;
    },
    'file-size-greater' => sub {
        my ( $check ) = shift ;
        $check->{on_failure} =~ /is missing|no value provided|file stat failure|file size not found|file size not greater/
            && (!defined($check->{on_success}) || $check->{on_success} =~ /file size is greater/);
    },
    'file-size-lower' => sub {
        my ( $check ) = shift ;
        $check->{on_failure} =~ /is missing|no value provided|file stat failure|file size not found|file size not lower/
            && (!defined($check->{on_success}) || $check->{on_success} =~ /file size is lower/);
    },
    'file-sha' => sub {
        my ( $check ) = shift ;
        $check->{on_failure} =~ /is missing|no value provided|sha512 hash computing|wrong sha512 file hash/
            && $check->{on_success} =~ /got expected sha512 file hash/;
    },
    'file-sha-mismatch' => sub {
        my ( $check ) = shift ;
        $check->{on_success} =~ /is missing|no value provided|sha512 hash computing|sha512 file hash mismatch/
            && (!defined($check->{on_failure}) || $check->{on_failure} =~ /sha512 file hash match/);
    },
    'freespace-greater' => sub {
        my ( $check ) = shift ;
        $check->{on_failure} =~ /no value provided|free space not found|free space not greater/
            && (!defined($check->{on_success}) || $check->{on_success} =~ /free space is greater/);
    },
    'winkey-exists' => sub {
        my ( $check ) = shift ;
        $check->{on_success} =~ /winkey found/
            && $check->{on_failure} =~ /not on MSWin32|failed to load Win32|missing winkey/;
    },
    'winkey-missing' => sub {
        my ( $check ) = shift ;
        $check->{on_success} =~ /missing winkey/
            && $check->{on_failure} =~ /not on MSWin32|failed to load Win32|winkey found/;
    },
    'winkey-value' => sub {
        my ( $check ) = shift ;
        $check->{on_success} =~ /found expected winkey value/
            && $check->{on_failure} =~ /not on MSWin32|no value provided|failed to load Win32|missing winkey|bad winkey content/;
    },
);

my %processors = (
    'unsupported-empty' => {
        __expect => base_object(),
        __ctrl_cb => sub { # Callback to check result
            my $check = shift ;
            $check->{message} =~ /unknown reason/;
        },
        __result => 'ok'
    },
    'directory-exists-0' => {
        type      => "directoryExists",
        __expect  => base_object("DirectoryExists", {
            type   => "directoryExists",
        }),
        __ctrl_cb => $checkcb{'dir-exists'},
        __result  => 'ko'
    },
    'directory-exists-1' => {
        type      => "directoryExists",
        return    => "skip",
        __expect  => base_object("DirectoryExists", {
            type   => "directoryExists",
            return => "skip",
        }),
        __ctrl_cb => $checkcb{'dir-exists'},
        __result  => 'skip'
    },
    'directory-exists-2' => {
        type      => "directoryExists",
        path      => ".",
        __logger  => $logger,
        __expect  => base_object("DirectoryExists", {
            type   => "directoryExists",
            logger => $logger,
            path   => "."
        }),
        __ctrl_cb => $checkcb{'dir-exists'},
        __result  => 'ok'
    },
    'directory-exists-3' => {
        type      => "directoryExists",
        path      => $testdir,
        __expect  => base_object("DirectoryExists", {
            type   => "directoryExists",
            path   => $testdir
        }),
        __ctrl_cb => $checkcb{'dir-exists'},
        __result  => 'ok'
    },
    'directory-exists-4' => {
        type      => "directoryExists",
        path      => $notadir,
        __expect  => base_object("DirectoryExists", {
            type   => "directoryExists",
            path   => $notadir
        }),
        __ctrl_cb => $checkcb{'dir-exists'},
        __result  => 'ko'
    },
    'directory-exists-5' => {
        type      => "directoryExists",
        path      => $testfile,
        __expect  => base_object("DirectoryExists", {
            type   => "directoryExists",
            path   => $testfile
        }),
        __ctrl_cb => $checkcb{'dir-exists'},
        __result  => 'ko'
    },
    'directory-exists-6' => {
        type      => "directoryExists",
        path      => $testfile,
        return    => "skip",
        __expect  => base_object("DirectoryExists", {
            type   => "directoryExists",
            path   => $testfile,
            return => "skip"
        }),
        __ctrl_cb => $checkcb{'dir-exists'},
        __result  => 'skip'
    },
    'directory-missing-0' => {
        type      => "directoryMissing",
        path      => $testdir,
        __expect  => base_object("DirectoryMissing", {
            type   => "directoryMissing",
            path   => $testdir
        }),
        __ctrl_cb => $checkcb{'dir-missing'},
        __result  => 'ko'
    },
    'directory-missing-1' => {
        type      => "directoryMissing",
        path      => $notadir,
        __expect  => base_object("DirectoryMissing", {
            type   => "directoryMissing",
            path   => $notadir
        }),
        __ctrl_cb => $checkcb{'dir-missing'},
        __result  => 'ok'
    },
    'directory-missing-2' => {
        type      => "directoryMissing",
        path      => $testfile,
        __expect  => base_object("DirectoryMissing", {
            type   => "directoryMissing",
            path   => $testfile
        }),
        __ctrl_cb => $checkcb{'dir-missing'},
        __result  => 'ok'
    },
    'directory-missing-3' => {
        type      => "directoryMissing",
        path      => ".",
        __expect  => base_object("DirectoryMissing", {
            type   => "directoryMissing",
            path   => "."
        }),
        __ctrl_cb => $checkcb{'dir-missing'},
        __result  => 'ko'
    },
    'file-exists-0' => {
        type      => "fileExists",
        __expect  => base_object("FileExists", {
            type   => "fileExists",
        }),
        __ctrl_cb => $checkcb{'file-exists'},
        __result  => 'ko'
    },
    'file-exists-1' => {
        type      => "fileExists",
        path      => $testfile,
        __expect  => base_object("FileExists", {
            type   => "fileExists",
            path   => $testfile
        }),
        __ctrl_cb => $checkcb{'file-exists'},
        __result  => 'ok'
    },
    'file-exists-2' => {
        type      => "fileExists",
        path      => $testdir,
        __expect  => base_object("FileExists", {
            type   => "fileExists",
            path   => $testdir
        }),
        __ctrl_cb => $checkcb{'file-exists'},
        __result  => 'ko'
    },
    'file-missing-0' => {
        type      => "fileMissing",
        __expect  => base_object("FileMissing", {
            type   => "fileMissing",
        }),
        __ctrl_cb => $checkcb{'file-missing'},
        __result  => 'ok'
    },
    'file-missing-1' => {
        type      => "fileMissing",
        path      => $testfile,
        __expect  => base_object("FileMissing", {
            type   => "fileMissing",
            path   => $testfile
        }),
        __ctrl_cb => $checkcb{'file-missing'},
        __result  => 'ko'
    },
    'file-missing-2' => {
        type      => "fileMissing",
        path      => $testdir,
        __expect  => base_object("FileMissing", {
            type   => "fileMissing",
            path   => $testdir
        }),
        __ctrl_cb => $checkcb{'file-missing'},
        __result  => 'ok'
    },
    'file-missing-3-error' => {
        type      => "fileMissing",
        path      => $testfile,
        return    => 'error',
        __expect  => base_object("FileMissing", {
            type   => "fileMissing",
            path   => $testfile,
            return => 'error'
        }),
        __ctrl_cb => $checkcb{'file-missing'},
        __result  => 'error'
    },
    'file-missing-4-skip' => {
        type      => "fileMissing",
        path      => $testfile,
        return    => 'skip',
        __expect  => base_object("FileMissing", {
            type   => "fileMissing",
            path   => $testfile,
            return => 'skip'
        }),
        __ctrl_cb => $checkcb{'file-missing'},
        __result  => 'skip'
    },
    'file-missing-5-warning' => {
        type      => "fileMissing",
        path      => $testfile,
        return    => 'warning',
        __expect  => base_object("FileMissing", {
            type   => "fileMissing",
            path   => $testfile,
            return => 'warning'
        }),
        __ctrl_cb => $checkcb{'file-missing'},
        __result  => 'warning'
    },
    'file-size-eq-0' => {
        type      => "fileSizeEquals",
        __expect  => base_object("FileSizeEquals", {
            type   => "fileSizeEquals",
        }),
        __ctrl_cb => $checkcb{'file-size-eq'},
        __result  => 'ko'
    },
    'file-size-eq-1' => {
        type      => "fileSizeEquals",
        path      => $testfile,
        __expect  => base_object("FileSizeEquals", {
            type   => "fileSizeEquals",
            path   => $testfile
        }),
        __ctrl_cb => $checkcb{'file-size-eq'},
        __result  => 'ko'
    },
    'file-size-eq-2' => {
        type      => "fileSizeEquals",
        path      => $testdir,
        __expect  => base_object("FileSizeEquals", {
            type   => "fileSizeEquals",
            path   => $testdir
        }),
        __ctrl_cb => $checkcb{'file-size-eq'},
        __result  => 'ko'
    },
    'file-size-eq-3' => {
        type      => "fileSizeEquals",
        path      => $notafile,
        __expect  => base_object("FileSizeEquals", {
            type   => "fileSizeEquals",
            path   => $notafile
        }),
        __ctrl_cb => $checkcb{'file-size-eq'},
        __result  => 'ko'
    },
    'file-size-eq-4' => {
        type      => "fileSizeEquals",
        path      => $notafile,
        value     => 256,
        __expect  => base_object("FileSizeEquals", {
            type   => "fileSizeEquals",
            path   => $notafile,
            value  => 256,
        }),
        __ctrl_cb => $checkcb{'file-size-eq'},
        __result  => 'ko'
    },
    'file-size-eq-5' => {
        type      => "fileSizeEquals",
        path      => $testfile,
        value     => 256,
        __expect  => base_object("FileSizeEquals", {
            type   => "fileSizeEquals",
            path   => $testfile,
            value  => 256,
        }),
        __ctrl_cb => $checkcb{'file-size-eq'},
        __result  => 'ok'
    },
    'file-size-eq-6' => {
        type      => "fileSizeEquals",
        path      => $testfile,
        value     => undef,
        __expect  => base_object("FileSizeEquals", {
            type   => "fileSizeEquals",
            path   => $testfile,
            value  => undef,
        }),
        __ctrl_cb => $checkcb{'file-size-eq'},
        __result  => 'ko'
    },
    'file-size-eq-7' => {
        type      => "fileSizeEquals",
        path      => $testfile,
        value     => 500,
        __expect  => base_object("FileSizeEquals", {
            type   => "fileSizeEquals",
            path   => $testfile,
            value  => 500,
        }),
        __ctrl_cb => $checkcb{'file-size-eq'},
        __result  => 'ko'
    },
    'file-greater-0' => {
        type      => "fileSizeGreater",
        __expect  => base_object("FileSizeGreater", {
            type   => "fileSizeGreater",
        }),
        __ctrl_cb => $checkcb{'file-size-greater'},
        __result  => 'ko'
    },
    'file-greater-1' => {
        type      => "fileSizeGreater",
        path      => $testfile,
        __expect  => base_object("FileSizeGreater", {
            type   => "fileSizeGreater",
            path   => $testfile
        }),
        __ctrl_cb => $checkcb{'file-size-greater'},
        __result  => 'ko'
    },
    'file-greater-2' => {
        type      => "fileSizeGreater",
        path      => $testdir,
        __expect  => base_object("FileSizeGreater", {
            type   => "fileSizeGreater",
            path   => $testdir
        }),
        __ctrl_cb => $checkcb{'file-size-greater'},
        __result  => 'ko'
    },
    'file-greater-3' => {
        type      => "fileSizeGreater",
        path      => $notafile,
        __expect  => base_object("FileSizeGreater", {
            type   => "fileSizeGreater",
            path   => $notafile
        }),
        __ctrl_cb => $checkcb{'file-size-greater'},
        __result  => 'ko'
    },
    'file-greater-4' => {
        type      => "fileSizeGreater",
        path      => $notafile,
        value     => 256,
        __expect  => base_object("FileSizeGreater", {
            type   => "fileSizeGreater",
            path   => $notafile,
            value  => 256,
        }),
        __ctrl_cb => $checkcb{'file-size-greater'},
        __result  => 'ko'
    },
    'file-greater-5' => {
        type      => "fileSizeGreater",
        path      => $testfile,
        value     => 256,
        __expect  => base_object("FileSizeGreater", {
            type   => "fileSizeGreater",
            path   => $testfile,
            value  => 256,
        }),
        __ctrl_cb => $checkcb{'file-size-greater'},
        __result  => 'ko'
    },
    'file-greater-6' => {
        type      => "fileSizeGreater",
        path      => $testfile,
        value     => undef,
        __expect  => base_object("FileSizeGreater", {
            type   => "fileSizeGreater",
            path   => $testfile,
            value  => undef,
        }),
        __ctrl_cb => $checkcb{'file-size-greater'},
        __result  => 'ko'
    },
    'file-greater-7' => {
        type      => "fileSizeGreater",
        path      => $testfile,
        value     => 500,
        __expect  => base_object("FileSizeGreater", {
            type   => "fileSizeGreater",
            path   => $testfile,
            value  => 500,
        }),
        __ctrl_cb => $checkcb{'file-size-greater'},
        __result  => 'ko'
    },
    'file-greater-8' => {
        type      => "fileSizeGreater",
        path      => $testfile,
        value     => 200,
        __expect  => base_object("FileSizeGreater", {
            type   => "fileSizeGreater",
            path   => $testfile,
            value  => 200,
        }),
        __ctrl_cb => $checkcb{'file-size-greater'},
        __result  => 'ok'
    },
    'file-lower-0' => {
        type      => "fileSizeLower",
        __expect  => base_object("FileSizeLower", {
            type   => "fileSizeLower",
        }),
        __ctrl_cb => $checkcb{'file-size-lower'},
        __result  => 'ko'
    },
    'file-lower-1' => {
        type      => "fileSizeLower",
        path      => $testfile,
        __expect  => base_object("FileSizeLower", {
            type   => "fileSizeLower",
            path   => $testfile
        }),
        __ctrl_cb => $checkcb{'file-size-lower'},
        __result  => 'ko'
    },
    'file-lower-2' => {
        type      => "fileSizeLower",
        path      => $testdir,
        __expect  => base_object("FileSizeLower", {
            type   => "fileSizeLower",
            path   => $testdir
        }),
        __ctrl_cb => $checkcb{'file-size-lower'},
        __result  => 'ko'
    },
    'file-lower-3' => {
        type      => "fileSizeLower",
        path      => $notafile,
        __expect  => base_object("FileSizeLower", {
            type   => "fileSizeLower",
            path   => $notafile
        }),
        __ctrl_cb => $checkcb{'file-size-lower'},
        __result  => 'ko'
    },
    'file-lower-4' => {
        type      => "fileSizeLower",
        path      => $notafile,
        value     => 256,
        __expect  => base_object("FileSizeLower", {
            type   => "fileSizeLower",
            path   => $notafile,
            value  => 256,
        }),
        __ctrl_cb => $checkcb{'file-size-lower'},
        __result  => 'ko'
    },
    'file-lower-5' => {
        type      => "fileSizeLower",
        path      => $testfile,
        value     => 256,
        __expect  => base_object("FileSizeLower", {
            type   => "fileSizeLower",
            path   => $testfile,
            value  => 256,
        }),
        __ctrl_cb => $checkcb{'file-size-lower'},
        __result  => 'ko'
    },
    'file-lower-6' => {
        type      => "fileSizeLower",
        path      => $testfile,
        value     => undef,
        __expect  => base_object("FileSizeLower", {
            type   => "fileSizeLower",
            path   => $testfile,
            value  => undef,
        }),
        __ctrl_cb => $checkcb{'file-size-lower'},
        __result  => 'ko'
    },
    'file-lower-7' => {
        type      => "fileSizeLower",
        path      => $testfile,
        value     => 500,
        __expect  => base_object("FileSizeLower", {
            type   => "fileSizeLower",
            path   => $testfile,
            value  => 500,
        }),
        __ctrl_cb => $checkcb{'file-size-lower'},
        __result  => 'ok'
    },
    'file-lower-8' => {
        type      => "fileSizeLower",
        path      => $testfile,
        value     => 200,
        __expect  => base_object("FileSizeLower", {
            type   => "fileSizeLower",
            path   => $testfile,
            value  => 200,
        }),
        __ctrl_cb => $checkcb{'file-size-lower'},
        __result  => 'ko'
    },
    'file-sha-0' => {
        type      => "fileSHA512",
        __expect  => base_object("FileSHA512", {
            type   => "fileSHA512",
        }),
        __ctrl_cb => $checkcb{'file-sha'},
        __result  => 'ko'
    },
    'file-sha-1' => {
        type      => "fileSHA512",
        path      => $testfile,
        __expect  => base_object("FileSHA512", {
            type   => "fileSHA512",
            path   => $testfile
        }),
        __ctrl_cb => $checkcb{'file-sha'},
        __result  => 'ko'
    },
    'file-sha-2' => {
        type      => "fileSHA512",
        path      => $testdir,
        __expect  => base_object("FileSHA512", {
            type   => "fileSHA512",
            path   => $testdir
        }),
        __ctrl_cb => $checkcb{'file-sha'},
        __result  => 'ko'
    },
    'file-sha-3' => {
        type      => "fileSHA512",
        path      => $notafile,
        __expect  => base_object("FileSHA512", {
            type   => "fileSHA512",
            path   => $notafile
        }),
        __ctrl_cb => $checkcb{'file-sha'},
        __result  => 'ko'
    },
    'file-sha-4' => {
        type      => "fileSHA512",
        path      => $notafile,
        value     => $filesha1,
        __expect  => base_object("FileSHA512", {
            type   => "fileSHA512",
            path   => $notafile,
            value  => $filesha1,
        }),
        __ctrl_cb => $checkcb{'file-sha'},
        __result  => 'ko'
    },
    'file-sha-5' => {
        type      => "fileSHA512",
        path      => $testfile,
        value     => $filesha1,
        __expect  => base_object("FileSHA512", {
            type   => "fileSHA512",
            path   => $testfile,
            value  => $filesha1,
        }),
        __ctrl_cb => $checkcb{'file-sha'},
        __result  => 'ko'
    },
    'file-sha-6' => {
        type      => "fileSHA512",
        path      => $testfile,
        value     => undef,
        __expect  => base_object("FileSHA512", {
            type   => "fileSHA512",
            path   => $testfile,
            value  => undef,
        }),
        __ctrl_cb => $checkcb{'file-sha'},
        __result  => 'ko'
    },
    'file-sha-7' => {
        type      => "fileSHA512",
        path      => $testfile,
        value     => $filesha512,
        __expect  => base_object("FileSHA512", {
            type   => "fileSHA512",
            path   => $testfile,
            value  => $filesha512,
        }),
        __ctrl_cb => $checkcb{'file-sha'},
        __result  => 'ok'
    },
    'file-sha-mismatch-0' => {
        type      => "fileSHA512mismatch",
        __expect  => base_object("FileSHA512Mismatch", {
            type   => "fileSHA512mismatch",
        }),
        __ctrl_cb => $checkcb{'file-sha-mismatch'},
        __result  => 'ok'
    },
    'file-sha-mismatch-1' => {
        type      => "fileSHA512mismatch",
        path      => $testfile,
        __expect  => base_object("FileSHA512Mismatch", {
            type   => "fileSHA512mismatch",
            path   => $testfile
        }),
        __ctrl_cb => $checkcb{'file-sha-mismatch'},
        __result  => 'ok'
    },
    'file-sha-mismatch-2' => {
        type      => "fileSHA512mismatch",
        path      => $testdir,
        __expect  => base_object("FileSHA512Mismatch", {
            type   => "fileSHA512mismatch",
            path   => $testdir
        }),
        __ctrl_cb => $checkcb{'file-sha-mismatch'},
        __result  => 'ok'
    },
    'file-sha-mismatch-3' => {
        type      => "fileSHA512mismatch",
        path      => $notafile,
        __expect  => base_object("FileSHA512Mismatch", {
            type   => "fileSHA512mismatch",
            path   => $notafile
        }),
        __ctrl_cb => $checkcb{'file-sha-mismatch'},
        __result  => 'ok'
    },
    'file-sha-mismatch-4' => {
        type      => "fileSHA512mismatch",
        path      => $notafile,
        value     => $filesha1,
        __expect  => base_object("FileSHA512Mismatch", {
            type   => "fileSHA512mismatch",
            path   => $notafile,
            value  => $filesha1,
        }),
        __ctrl_cb => $checkcb{'file-sha-mismatch'},
        __result  => 'ok'
    },
    'file-sha-mismatch-5' => {
        type      => "fileSHA512mismatch",
        path      => $testfile,
        value     => $filesha1,
        __expect  => base_object("FileSHA512Mismatch", {
            type   => "fileSHA512mismatch",
            path   => $testfile,
            value  => $filesha1,
        }),
        __ctrl_cb => $checkcb{'file-sha-mismatch'},
        __result  => 'ok'
    },
    'file-sha-mismatch-6' => {
        type      => "fileSHA512mismatch",
        path      => $testfile,
        value     => undef,
        __expect  => base_object("FileSHA512Mismatch", {
            type   => "fileSHA512mismatch",
            path   => $testfile,
            value  => undef,
        }),
        __ctrl_cb => $checkcb{'file-sha-mismatch'},
        __result  => 'ok'
    },
    'file-sha-mismatch-7' => {
        type      => "fileSHA512mismatch",
        path      => $testfile,
        value     => $filesha512,
        __expect  => base_object("FileSHA512Mismatch", {
            type   => "fileSHA512mismatch",
            path   => $testfile,
            value  => $filesha512,
        }),
        __ctrl_cb => $checkcb{'file-sha-mismatch'},
        __result  => 'ko'
    },
    'freespace-greater-0' => {
        type      => "freespaceGreater",
        __expect  => base_object("FreeSpaceGreater", {
            type   => "freespaceGreater",
        }),
        __ctrl_cb => $checkcb{'freespace-greater'},
        __result  => 'ko'
    },
    'freespace-greater-1' => {
        type      => "freespaceGreater",
        path      => $testfile,
        __expect  => base_object("FreeSpaceGreater", {
            type   => "freespaceGreater",
            path   => $testfile
        }),
        __ctrl_cb => $checkcb{'freespace-greater'},
        __result  => 'ko'
    },
    'freespace-greater-2' => {
        type      => "freespaceGreater",
        path      => $testdir,
        __expect  => base_object("FreeSpaceGreater", {
            type   => "freespaceGreater",
            path   => $testdir
        }),
        __ctrl_cb => $checkcb{'freespace-greater'},
        __result  => 'ko'
    },
    'freespace-greater-3' => {
        type      => "freespaceGreater",
        path      => $notafile,
        __expect  => base_object("FreeSpaceGreater", {
            type   => "freespaceGreater",
            path   => $notafile
        }),
        __ctrl_cb => $checkcb{'freespace-greater'},
        __result  => 'ko'
    },
    'freespace-greater-4' => {
        type      => "freespaceGreater",
        path      => $notafile,
        value     => 256,
        __expect  => base_object("FreeSpaceGreater", {
            type   => "freespaceGreater",
            path   => $notafile,
            value  => 256,
        }),
        __ctrl_cb => $checkcb{'freespace-greater'},
        __result  => 'ko'
    },
    'freespace-greater-5' => {
        type      => "freespaceGreater",
        path      => $testfile,
        value     => 256,
        __expect  => base_object("FreeSpaceGreater", {
            type   => "freespaceGreater",
            path   => $testfile,
            value  => 256,
        }),
        __ctrl_cb => $checkcb{'freespace-greater'},
        __result  => 'ko'
    },
    'freespace-greater-6' => {
        type      => "freespaceGreater",
        path      => $testfile,
        value     => undef,
        __expect  => base_object("FreeSpaceGreater", {
            type   => "freespaceGreater",
            path   => $testfile,
            value  => undef,
        }),
        __ctrl_cb => $checkcb{'freespace-greater'},
        __result  => 'ko'
    },
    'freespace-greater-7' => {
        type      => "freespaceGreater",
        path      => $testdir,
        value     => -1,
        __expect  => base_object("FreeSpaceGreater", {
            type   => "freespaceGreater",
            path   => $testdir,
            value  => -1,
        }),
        __ctrl_cb => $checkcb{'freespace-greater'},
        __result  => 'ok'
    },
    'winkey-exists-0' => {
        type      => "winkeyExists",
        __expect  => base_object("WinKeyExists", {
            type   => "winkeyExists",
        }),
        __ctrl_cb => $checkcb{'winkey-exists'},
        __result  => 'ko'
    },
    'winkey-exists-1' => {
        type      => "winkeyExists",
        path      => $testreg,
        __expect  => base_object("WinKeyExists", {
            type   => "winkeyExists",
            path   => $testreg
        }),
        __ctrl_cb => $checkcb{'winkey-exists'},
        __result  => 'ok'
    },
    'winkey-exists-2' => {
        type      => "winkeyExists",
        path      => $badreg,
        __expect  => base_object("WinKeyExists", {
            type   => "winkeyExists",
            path   => $badreg
        }),
        __ctrl_cb => $checkcb{'winkey-exists'},
        __result  => 'ko'
    },
    'winkey-missing-0' => {
        type      => "winkeyMissing",
        __expect  => base_object("WinKeyMissing", {
            type   => "winkeyMissing",
        }),
        __ctrl_cb => $checkcb{'winkey-missing'},
        __result  => 'ok'
    },
    'winkey-missing-1' => {
        type      => "winkeyMissing",
        path      => $testreg,
        __expect  => base_object("WinKeyMissing", {
            type   => "winkeyMissing",
            path   => $testreg
        }),
        __ctrl_cb => $checkcb{'winkey-missing'},
        __result  => 'ko'
    },
    'winkey-missing-2' => {
        type      => "winkeyMissing",
        path      => $badreg,
        __expect  => base_object("WinKeyMissing", {
            type   => "winkeyMissing",
            path   => $badreg
        }),
        __ctrl_cb => $checkcb{'winkey-missing'},
        __result  => 'ok'
    },
    'winkey-value-0' => {
        type      => "winkeyEquals",
        __expect  => base_object("WinKeyEquals", {
            type   => "winkeyEquals",
        }),
        __ctrl_cb => $checkcb{'winkey-value'},
        __result  => 'ko'
    },
    'winkey-value-1' => {
        type      => "winkeyEquals",
        path      => $testreg,
        __expect  => base_object("WinKeyEquals", {
            type   => "winkeyEquals",
            path   => $testreg
        }),
        __ctrl_cb => $checkcb{'winkey-value'},
        __result  => 'ko'
    },
    'winkey-value-2' => {
        type      => "winkeyEquals",
        path      => $badreg,
        __expect  => base_object("WinKeyEquals", {
            type   => "winkeyEquals",
            path   => $badreg
        }),
        __ctrl_cb => $checkcb{'winkey-value'},
        __result  => 'ko'
    },
    'winkey-value-3' => {
        type      => "winkeyEquals",
        path      => $testreg."\\VendorIdentifier",
        value     => undef,
        __expect  => base_object("WinKeyEquals", {
            type   => "winkeyEquals",
            path   => $testreg."\\VendorIdentifier",
            value  => undef,
        }),
        __ctrl_cb => $checkcb{'winkey-value'},
        __result  => 'ko'
    },
    'winkey-value-4' => {
        type      => "winkeyEquals",
        path      => $testreg."\\VendorIdentifier",
        value     => "Not a Vendor",
        __expect  => base_object("WinKeyEquals", {
            type   => "winkeyEquals",
            path   => $testreg."\\VendorIdentifier",
            value  => "Not a Vendor",
        }),
        __ctrl_cb => $checkcb{'winkey-value'},
        __result  => 'ko'
    },
    'winkey-value-5' => {
        type      => "winkeyEquals",
        path      => $testreg."\\VendorIdentifier",
        value     => "GenuineIntel",
        __expect  => base_object("WinKeyEquals", {
            type   => "winkeyEquals",
            path   => $testreg."\\VendorIdentifier",
            value  => "GenuineIntel",
        }),
        __ctrl_cb => $checkcb{'winkey-value'},
        __result  => 'ok'
    },
);

plan tests => 4 * scalar keys %processors ;

# Emulated registry
my %register = (
    'HKEY_LOCAL_MACHINE/HARDWARE/DESCRIPTION/System/CentralProcessor' => {
        '0' => {
            '/VendorIdentifier'   => 'GenuineIntel'
        }
    }
);

my $module = Test::MockModule->new(
    'FusionInventory::Agent::Tools::Win32'
);

$module->mock(
    '_getRegistryKey', sub {
        my (%params) = @_;
        return unless ($params{root} && defined($params{keyName}));
        return unless exists($register{$params{root}});
        my $root = $register{$params{root}};
        return unless exists($root->{$params{keyName}});
        my $key = { %{$root->{$params{keyName}}} };
        # Bless leaf as expected
        map { bless $key->{$_}, 'Win32::TieRegistry' }
            grep { ref($key->{$_}) eq 'HASH' } keys %{$key};
        bless $key, 'Win32::TieRegistry';
        return $key;
    }
);

my $diskFreeModule = Test::MockModule->new(
    'FusionInventory::Agent::Task::Deploy::DiskFree'
);
$diskFreeModule->mock(
    'getFreeSpace', sub {
        return 200;
    }
);

foreach my $proc (keys %processors) {
    my $check  = $processors{$proc};
    my $expect = $check->{__expect};
    my $ctrlcb = $check->{__ctrl_cb} || sub {};
    my $result = $check->{__result} || 0;
    delete $check->{__expect};
    delete $check->{__ctrl_cb};
    delete $check->{__result};

    # Fake OSNAME when necessary
    $OSNAME = $proc =~ /^winkey/ ? "MSWin32" : $RealOSNAME;

    FusionInventory::Agent::Task::Deploy::CheckProcessor->new(
        check  => $check,
        logger => $check->{__logger}
    );
    delete $check->{__logger};

    ok( defined($check), "defined $proc" );
    cmp_deeply($check, $expect, "$proc object");

    my $status = $check->process();
    ok( &{$ctrlcb}($check), "$proc object control callback after process() ok");

    ok( $status eq $result, "$proc object status result ok");
}