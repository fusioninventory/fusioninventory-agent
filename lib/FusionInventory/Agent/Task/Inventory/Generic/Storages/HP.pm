package FusionInventory::Agent::Task::Inventory::Generic::Storages::HP;

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
        "$params{path} ctrl all show" : undef;
    my $handle  = getFileHandle(%params, command => $command);
    return unless $handle;

    my @slots;
    while (my $line = <$handle>) {
        next unless $line =~ /Slot (\d+)/;
        push @slots, $1;
    }
    close $handle;

    return @slots;
}

sub _getDrives {
    my %params = @_;

    my $command = $params{path} && defined $params{slot} ?
        "$params{path} ctrl slot=$params{slot} pd all show" : undef;
    my $handle  = getFileHandle(%params, command => $command);
    next unless $handle;

    my @drives;
    while (my $line = <$handle>) {
        next unless $line =~ /physicaldrive (\S+)/;
        push @drives, $1;
    }
    close $handle;

    return @drives;
}

sub _getStorage {
    my %params = @_;

    my $command = $params{path} && defined $params{slot} && defined $params{drive} ?
        "$params{path} ctrl slot=$params{slot} pd $params{drive} show" : undef;
    my $handle  = getFileHandle(%params, command => $command);
    next unless $handle;

    my %data;
    while (my $line = <$handle>) {
        next unless $line =~ /(\S[^:]+) : \s+ (.+)/x;
        $data{$1} = $2;
    }
    close $handle;

    my $storage = {
        DESCRIPTION  => $data{'Interface Type'},
        SERIALNUMBER => $data{'Serial Number'},
        FIRMWARE     => $data{'Firmware Revision'}
    };

    my $model = $data{'Model'};
    $model =~ s/^ATA\s+//; # ex: ATA     WDC WD740ADFD-00
    $model =~ s/\s+/ /;
    $storage->{NAME}  = $model;
    $storage->{MODEL} = $model;

    $storage->{MANUFACTURER} = getCanonicalManufacturer($model);
    $storage->{DISKSIZE} = getCanonicalSize($data{'Size'});

    $storage->{TYPE} = $data{'Drive Type'} eq 'Data Drive' ?
        'disk' : $data{'Drive Type'};

    return $storage;
}

1;
