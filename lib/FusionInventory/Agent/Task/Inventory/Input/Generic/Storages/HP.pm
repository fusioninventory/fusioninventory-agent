package FusionInventory::Agent::Task::Inventory::Input::Generic::Storages::HP;

use strict;
use warnings;

use English qw(-no_match_vars);
use UNIVERSAL::require;

use FusionInventory::Agent::Tools;
# Tested on 2.6.* kernels
#
# Cards tested :
#
# Smart Array E200
#
# HP Array Configuration Utility CLI 7.85-18.0

sub _getHpacuacliFromWinRegistry {

    my $Registry;
    Win32::TieRegistry->require();
    Win32::TieRegistry->import(
        Delimiter   => '/',
        ArrayValues => 0,
        TiedRef     => \$Registry,
    );

    my $machKey = $Registry->Open('LMachine', {
        Access => Win32::TieRegistry::KEY_READ(),
    }) or die "Can't open HKEY_LOCAL_MACHINE key: $EXTENDED_OS_ERROR";

    my $uninstallValues =
        $machKey->{'SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall/HP ACUCLI'};
    return unless $uninstallValues;

    my $uninstallString = $uninstallValues->{'/UninstallString'};
    return unless $uninstallString;

    return unless $uninstallString =~ /(.*\\)hpuninst\.exe/;
    my $hpacuacliPath = $1 . 'bin\\hpacucli.exe';
    return unless -f $hpacuacliPath;

    return $hpacuacliPath;
}

sub isEnabled {
    return
        canRun('hpacucli') ||
        ($OSNAME eq 'MSWin32' && _getHpacuacliFromWinRegistry());
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $path = canRun('hpacucli') ?
        "hpacucli":
        _getHpacuacliFromWinRegistry($logger);

    foreach my $slot (_getSlots(path => $path)) {
        foreach my $drive (_getDrives(path => $path, slot => $slot)) {

            $inventory->addEntry(
                section => 'STORAGES',
                entry   => _getStorage(
                    path => $path, slot => $slot, drive => $drive
                )
            );
        }
    }
}

sub _getSlots {
    my %params = @_;

    my $command = $params{path} ?
        "%params{path} ctrl all show" : undef;
    my $handle  = getFileHandle(%params, command => $command);
    return unless $handle;

    my @slots;
    while (my $line = <$handle>) {
        next unless $line =~ /Slot\s(\d*)/;
        push @slots, $1;
    }
    close $handle;

    return @slots;
}

sub _getDrives {
    my %params = @_;

    my $command = $params{path} && $params{slot} ?
        "%params{path} ctrl slot=$params{slot} pd all show" : undef;
    my $handle  = getFileHandle(%params, command => $command);
    next unless $handle;

    my @drives;
    while (my $line = <$handle>) {
        next unless $line =~ /physicaldrive\s(\S*)/;
        push @drives, $1;
    }
    close $handle;

    return @drives;
}

sub _getStorage {
    my %params = @_;

    my $command = $params{path} && $params{slot} && $params{drive} ?
        "%params{path} ctrl slot=$params{slot} pd $params{drive} show" : undef;
    my $handle  = getFileHandle(%params, command => $command);
    next unless $handle;

    my $storage;
    while (my $line = <$handle>) {
        if ($line =~ /Model:\s(.*)/) {
            my $model = $1;
            $model =~ s/^ATA\s+//; # ex: ATA     WDC WD740ADFD-00
            $model =~ s/\s+/ /;
            $storage->{NAME}  = $model;
            $storage->{MODEL} = $model;
            next;
        }

        if ($line =~ /Interface Type:\s(.*)/) {
            $storage->{DESCRIPTION} = $1;
            next;
        }

        if ($line =~ /Drive Type:\s(.*)/) {
            $storage->{TYPE} = $1 eq 'Data Drive' ? 'disk' : $1;
            next;
        }

        if ($line =~ /Size:\s(\S*)/) {
            $storage->{DISKSIZE} = 1000 * $1;
            next;
        }

        if ($line =~ /Serial Number:\s(.*)/) {
            my $serialnumber = $1;
            $serialnumber =~ s/^\s+//;
            $storage->{SERIALNUMBER} = $serialnumber;
            next;
        }

        if ($line =~ /Firmware Revision:\s(.*)/) {
            $storage->{FIRMWARE} = $1;
            next;
        }
    }
    close $handle;

    $storage->{MANUFACTURER} = getCanonicalManufacturer($storage->{MODEL});

    return $storage;
}

1;
