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

    my ($serialnumber, $model, $capacity, $firmware, $description, $media, $manufacturer);

    my $hpacuacliPath = canRun('hpacucli') ?
        "hpacucli":
        _getHpacuacliFromWinRegistry($logger);

    my $handle1 = getFileHandle(
        logger => $logger,
        command => "$hpacuacliPath ctrl all show"
    );

    return unless $handle1;

# Example output :
#    
# Smart Array E200 in Slot 2    (sn: PA6C90K9SUH1ZA)
    while (my $line1 = <$handle1>) {
        next unless $line1 =~ /Slot\s(\d*)/;

        my $slot = $1;
        my $handle2 = getFileHandle(
            logger => $logger,
            command => "$hpacuacliPath ctrl slot=$slot pd all show"
        );
        next unless $handle2;

# Example output :
#
# Smart Array E200 in Slot 2
#
#   array A
#
#      physicaldrive 2I:1:1 (port 2I:box 1:bay 1, SATA, 74.3 GB, OK)
#      physicaldrive 2I:1:2 (port 2I:box 1:bay 2, SATA, 74.3 GB, OK)
        while (my $line2 = <$handle2>) {
            next unless $line2 =~ /physicaldrive\s(\S*)/;

            my $pd = $1;
            my $handle3 = getFileHandle(
                logger => $logger,
                command => "$hpacuacliPath ctrl slot=$slot pd $pd show"
            );
            next unless $handle3;

# Example output :
#  
# Smart Array E200 in Slot 2
#
#   array A
#
#      physicaldrive 1:1
#         Port: 2I
#         Box: 1
#         Bay: 1
#         Status: OK
#         Drive Type: Data Drive
#         Interface Type: SATA
#         Size: 74.3 GB
#         Firmware Revision: 21.07QR4
#         Serial Number:      WD-WMANS1732855
#         Model: ATA     WDC WD740ADFD-00
#         SATA NCQ Capable: False
#         PHY Count: 1        
            while (my $line3 = <$handle3>) {
                $model = $1 if $line3 =~ /Model:\s(.*)/;
                $description = $1 if $line3 =~ /Interface Type:\s(.*)/;
                $media = $1 if $line3 =~ /Drive Type:\s(.*)/;
                $capacity = 1000*$1 if $line3 =~ /Size:\s(.*)/;
                $serialnumber = $1 if $line3 =~ /Serial Number:\s(.*)/;
                $firmware = $1 if $line3 =~ /Firmware Revision:\s(.*)/;
            }
            close $handle3;
            $serialnumber =~ s/^\s+//;
            $model =~ s/^ATA\s+//; # ex: ATA     WDC WD740ADFD-00
            $model =~ s/\s+/ /;
            $manufacturer = getCanonicalManufacturer($model);
            if ($media eq 'Data Drive') {
                $media = 'disk';
            }

            $inventory->addEntry(
                section => 'STORAGES',
                entry   => {
                    NAME         => $model,
                    MANUFACTURER => $manufacturer,
                    MODEL        => $model,
                    DESCRIPTION  => $description,
                    TYPE         => $media,
                    DISKSIZE     => $capacity,
                    SERIALNUMBER => $serialnumber,
                    FIRMWARE     => $firmware
                }
            ); 
        }
        close $handle2;
    }
    close $handle1;
}

1;
