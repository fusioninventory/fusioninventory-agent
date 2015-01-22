#!/usr/bin/perl

use strict;
use warnings;

use English qw(-no_match_vars);
use IO::Capture::Stderr;
use File::stat;
use File::Temp qw(tempdir);
use Fcntl qw(:seek);
use Test::More;

use FusionInventory::Agent::Logger;

plan tests => 23;

my $logger = FusionInventory::Agent::Logger->new();

isa_ok(
    $logger,
    'FusionInventory::Agent::Logger',
    'logger class'
);

is(
    @{$logger->{backends}},
    1,
    'one default backend'
);

isa_ok(
    $logger->{backends}->[0],
    'FusionInventory::Agent::Logger::Stderr',
    'default backend class'
);

if ($OSNAME eq 'MSWin32') {

    $logger = FusionInventory::Agent::Logger->new(
        backends => [ qw/Stderr File/ ],
        file     => 'foo'
    );

    is(
        @{$logger->{backends}},
        2,
        'three backends'
    );

    subtest 'backends classes' => sub {
        plan tests => 2;
        isa_ok(
            $logger->{backends}->[0],
            'FusionInventory::Agent::Logger::Stderr',
            'first backend class'
        );

        isa_ok(
            $logger->{backends}->[1],
            'FusionInventory::Agent::Logger::File',
            'third backend class'
        );
    };
} else {
    $logger = FusionInventory::Agent::Logger->new(
        backends => [ qw/Stderr Syslog File/ ],
        file     => 'foo'
    );

    is(
        @{$logger->{backends}},
        3,
        'three backends'
    );

    subtest 'backends classes' => sub {
        plan tests => 3;
        isa_ok(
            $logger->{backends}->[0],
            'FusionInventory::Agent::Logger::Stderr',
            'first backend class'
        );

        isa_ok(
            $logger->{backends}->[1],
            'FusionInventory::Agent::Logger::Syslog',
            'second backend class'
        );

        isa_ok(
            $logger->{backends}->[2],
            'FusionInventory::Agent::Logger::File',
            'third backend class'
        );
    };
}

# stderr backend tests

$logger = FusionInventory::Agent::Logger->new(
    backends => [ qw/Stderr/ ]
);

ok(
    !getStderrOutput(sub { $logger->debug2('message'); }),
    'debug2 message absence'
);

ok(
    !getStderrOutput(sub { $logger->debug('message'); }),
    'debug message absence'
);

$logger = FusionInventory::Agent::Logger->new(
    backends  => [ qw/Stderr/ ],
    verbosity => 'debug'
);

ok(
    !getStderrOutput(sub { $logger->debug2('message'); }),
    'debug2 message absence'
);

ok(
    getStderrOutput(sub { $logger->debug('message'); }),
    'debug message presence'
);

is(
    getStderrOutput(sub { $logger->debug('message: %s', 'hello'); }),
    -t STDERR ?
        "\033[1;1m[debug]\033[0m message: hello" :
        "[debug] message: hello",
    'debug message formating'
);

is(
    getStderrOutput(sub { $logger->info('message: %s', 'hello'); }),
    -t STDERR ?
        "\033[1;34m[info]\033[0m message: hello" :
        "[info] message: hello",
    'info message formating'
);

is(
    getStderrOutput(sub { $logger->warning('message: %s', 'hello'); }),
    -t STDERR ?
        "\033[1;35m[warning] message: hello\033[0m" :
        "[warning] message: hello",
    'warning message formating'
);

is(
    getStderrOutput(sub { $logger->error('message: %s', 'hello'); }),
    -t STDERR ?
        "\033[1;31m[error] message: hello\033[0m" :
        "[error] message: hello",
    'error message formating'
);

$logger = FusionInventory::Agent::Logger->new(
    backends  => [ qw/Stderr/ ],
    verbosity => 'debug2'
);

ok(
    getStderrOutput(sub { $logger->debug2('message'); }),
    'debug2 message presence'
);

ok(
    getStderrOutput(sub { $logger->debug('message'); }),
    'debug message presence'
);

# file backend tests
my $tmpdir = tempdir(CLEANUP => $ENV{TEST_DEBUG} ? 0 : 1);
my $logfile;

$logfile = "$tmpdir/test1";
$logger = FusionInventory::Agent::Logger->new(
    backends => [ qw/File/ ],
    file     => $logfile
);

$logger->debug('message');

ok(
    !-f $logfile,
    'debug message absence'
);

$logfile = "$tmpdir/test2";
$logger = FusionInventory::Agent::Logger->new(
    backends  => [ qw/File/ ],
    file      => $logfile,
    verbosity => 'debug'
);
$logger->debug('message');

ok(
    -f $logfile,
    'debug message presence'
);

is(
    getFileOutput($logfile, sub { $logger->debug('message'); }),
    '[' . localtime() . '][debug] message',
    'debug message formating'
);

is(
    getFileOutput($logfile, sub { $logger->info('message'); }),
    '[' . localtime() . '][info] message',
    'info message formating'
);

is(
    getFileOutput($logfile, sub { $logger->warning('message'); }),
    '[' . localtime() . '][warning] message',
    'warning message formating'
);

is(
    getFileOutput($logfile, sub { $logger->error('message'); }),
    '[' . localtime() . '][error] message',
    'error message formating'
);

$logfile = "$tmpdir/test3";
$logger = FusionInventory::Agent::Logger->new(
    backends => [ qw/File/ ],
    file     => $logfile,
);
fillLogFile($logger);
ok(
    getFileSize($logfile) > 1024 * 1024,
    'no size limitation'
);

$logfile = "$tmpdir/test4";
$logger = FusionInventory::Agent::Logger->new(
    backends => [ qw/File/ ],
    file     => $logfile,
    maxsize  => 1
);
fillLogFile($logger);
ok(
    getFileSize($logfile) < 1024 * 1024,
    'size limitation'
);

sub getStderrOutput {
    my ($callback) = @_;

    my $capture = IO::Capture::Stderr->new();

    $capture->start();
    $callback->();
    $capture->stop();

    my $line = $capture->read();
    chomp $line if $line;

    return $line;
}

sub getFileOutput {
    my ($file, $callback) = @_;

    my $stat = stat $file;

    $callback->();

    open (my $fh, '<', $file) or die "can't open $file: $ERRNO";
    seek $fh, $stat->size(), SEEK_SET;
    my $line = <$fh>;
    close $fh;

    chomp $line;
    return $line;
}

sub fillLogFile {
    my ($logger) = @_;
    foreach my $i (0 .. 1023) {
        $logger->info(chr(65 + $i % 26) x 1024);
    }
}

sub getFileSize {
    my ($file) = @_;
    my $stat = stat $file;
    return $stat->size();
}
