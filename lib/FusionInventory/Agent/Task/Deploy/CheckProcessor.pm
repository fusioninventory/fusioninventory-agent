package FusionInventory::Agent::Task::Deploy::CheckProcessor;

use strict;
use warnings;

use constant OK => "ok";

use English qw(-no_match_vars);
use Digest::SHA;

use FusionInventory::Agent::Task::Deploy::DiskFree;

sub process {
    my ($self, %params) = @_;

    # the code to return in case of failure of the check,
    # the default is 'ko'
    my $failureCode = $params{check}->{return} || "ko";

    my $path = $params{check}->{path};
    my $info = $params{info} || [];

    # Expend the env vars from the path
    $path =~ s#\$(\w+)#$ENV{$1}#ge;
    $path =~ s#%(\w+)%#$ENV{$1}#ge;

    if ($params{check}->{type} eq 'winkeyExists') {

        push @{$info}, "Not on MSWin32";

        return $failureCode unless $OSNAME eq 'MSWin32';
        require FusionInventory::Agent::Tools::Win32;

        $path =~ s{\\}{/}g;

        my $regKey = FusionInventory::Agent::Tools::Win32::getRegistryKey(
            path => $path
        );

        # Handle missing key condition
        if (!defined($regKey)) {
            push @{$info}, "missing winkey";
            return $failureCode;
        }

        push @{$info}, "winkey present";
        return OK;
    }

    if ($params{check}->{type} eq 'winkeyEquals') {

        push @{$info}, "Not on MSWin32";

        return $failureCode unless $OSNAME eq 'MSWin32';
        require FusionInventory::Agent::Tools::Win32;

        $path =~ s{\\}{/}g;

        my $regKey = FusionInventory::Agent::Tools::Win32::getRegistryValue(
            path => $path
        );

        # Handle missing key or unexpected value conditions
        if (!defined($regKey) || $params{check}->{value} ne $regKey) {
            push @{$info}, defined($regKey) ?
                "bad winkey content: $regKey" : "missing winkey";
            return $failureCode;
        }

        push @{$info}, "Found expected winkey value";
        return OK;
    }

    if ($params{check}->{type} eq 'winkeyMissing') {
        push @{$info}, "Not on MSWin32";

        return $failureCode unless $OSNAME eq 'MSWin32';
        require FusionInventory::Agent::Tools::Win32;

        $path =~ s{\\}{/}g;

        my $regKey = FusionInventory::Agent::Tools::Win32::getRegistryKey(
            path => $path
        );

        # Handle existing key condition
        if (defined($regKey)) {
            push @{$info}, "unexpected winkey";
            return $failureCode;
        }

        push @{$info}, "Found expected winkey";
        return OK;
    }

    if ($params{check}->{type} eq 'fileExists') {
        # Handle missing file
        unless (-f $path) {
            push @{$info}, "missing file";
            return $failureCode;
        }

        push @{$info}, "file exists";
        return OK;
    }

    if ($params{check}->{type} eq 'fileSizeEquals') {
        # Handle missing file
        unless (-f $path) {
            push @{$info}, "missing file";
            return $failureCode;
        }

        my @s = stat($path);

        unless (@s) {
            push @{$info}, "file stat failure";
            return $failureCode;
        }

        # Handle wrong size file
        if ($params{check}->{value} != $s[7]) {
            push @{$info}, "wrong file size";
            return $failureCode;
        }

        push @{$info}, "expected file size";
        return OK;
    }

    if ($params{check}->{type} eq 'fileSizeGreater') {
        # Handle missing file
        unless (-f $path) {
            push @{$info}, "missing file";
            return $failureCode;
        }

        my @s = stat($path);

        unless (@s) {
            push @{$info}, "file stat failure";
            return $failureCode;
        }

        # Handle file size not greater
        if ($params{check}->{value} > $s[7]) {
            push @{$info}, "not greater file size";
            return $failureCode;
        }

        push @{$info}, "greater file size";
        return OK;
    }

    if ($params{check}->{type} eq 'fileSizeLower') {
        # Handle missing file
        unless (-f $path) {
            push @{$info}, "missing file";
            return $failureCode;
        }

        my @s = stat($path);

        unless (@s) {
            push @{$info}, "file stat failure";
            return $failureCode;
        }

        # Handle file size not lower
        if ($params{check}->{value} < $s[7]) {
            push @{$info}, "not lower file size";
            return $failureCode;
        }

        push @{$info}, "lower file size";
        return OK;
    }

    if ($params{check}->{type} eq 'fileMissing') {
        # Handle present file
        if (-f $path) {
            push @{$info}, "file exists";
            return $failureCode;
        }

        push @{$info}, "missing file";
        return OK;
    }

    if ($params{check}->{type} eq 'freespaceGreater') {
        # Handle missing path
        unless (-d $path) {
            push @{$info}, "missing path";
            return $failureCode;
        }

        my $freespace = getFreeSpace(logger => $params{logger}, path => $path);
        # Handle free space size lower
        unless ($freespace > $params{check}->{value}) {
            push @{$info}, "free space not greater";
            return $failureCode;
        }

        push @{$info}, "free space greater";
        return OK;
    }

    if ($params{check}->{type} eq 'fileSHA512') {
        # Handle missing path
        unless (-f $path) {
            push @{$info}, "missing path";
            return $failureCode;
        }

        my $sha = Digest::SHA->new('512');

        my $sha512 = "";
        eval {
            $sha->addfile($path, 'b');
            $sha512 = $sha->hexdigest;
        };

        # Handle sha512 not equal
        if ($sha512 ne $params{check}->{value}) {
            push @{$info}, "wrong sha512 file checksum";
            return $failureCode;
        }

        push @{$info}, "expected sha512 file checksum";
        return OK;
    }

    if ($params{check}->{type} eq 'directoryExists') {
        # Handle missing path
        unless (-d $path) {
            push @{$info}, "missing folder";
            return $failureCode;
        }

        push @{$info}, "folder exists";
        return OK;
    }

    if ($params{check}->{type} eq 'directoryMissing') {
        # Handle existing path
        if (-d $path) {
            push @{$info}, "folder exists";
            return $failureCode;
        }

        push @{$info}, "missing folder";
        return OK;
    }

    push @{$info}, "Unsupported ".$params{check}->{type}." check request";
    $params{logger}->info("Unsupported ".$params{check}->{type}." check request")
        if $params{logger};

    return OK;
}

1;
