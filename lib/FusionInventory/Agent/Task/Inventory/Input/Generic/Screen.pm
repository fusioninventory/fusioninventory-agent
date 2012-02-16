package FusionInventory::Agent::Task::Inventory::Input::Generic::Screen;
#     Copyright (C) 2005 Mandriva
#     Copyright (C) 2007 Gonéri Le Bouder <goneri@rulezlan.org> 
#     This program is free software; you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation; either version 2 of the License, or
#     (at your option) any later version.

#     This program is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.

#     You should have received a copy of the GNU General Public License
#     along with this program; if not, write to the Free Software
#     Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#
# Some part come from Mandriva's (great) monitor-edid
# http://svn.mandriva.com/cgi-bin/viewvc.cgi/soft/monitor-edid/trunk/
#
use strict;
use warnings;

use English qw(-no_match_vars);
use MIME::Base64;
use UNIVERSAL::require;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Screen;

sub isEnabled {

    return
        $OSNAME eq 'MSWin32'                 ||
        canRun('monitor-get-edid-using-vbe') ||
        canRun('monitor-get-edid')           ||
        canRun('get-edid');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    foreach my $screen (_getScreens($logger)) {

        if ($screen->{edid}) {
            my $edid = parseEdid($screen->{edid});
            if (my $err = checkParsedEdid($edid)) {
                $logger->debug("check failed: bad edid: $err");
            } else {
                $screen->{CAPTION} =
                    $edid->{monitor_name};
                $screen->{DESCRIPTION} =
                    $edid->{week} . "/" . $edid->{year};
                $screen->{MANUFACTURER} =
                    getManufacturerFromCode($edid->{manufacturer_name});
                $screen->{SERIAL} = $edid->{serial_number2}->[0];
            }
            $screen->{BASE64} = encode_base64($screen->{edid});
        }

        $inventory->addEntry(
            section => 'MONITORS',
            entry   => $screen
        );
    }
}

sub _getScreensFromWindows {
    my ($logger) = @_;

    FusionInventory::Agent::Tools::Win32->require();
    if ($EVAL_ERROR) {
        print
            "Failed to load FusionInventory::Agent::Tools::Win32: $EVAL_ERROR";
        return;
    }

    my @screens;

    # Vista and upper, able to get the second screen
    foreach my $object (FusionInventory::Agent::Tools::Win32::getWmiObjects(
        moniker    => 'winmgmts:{impersonationLevel=impersonate,authenticationLevel=Pkt}!//./root/wmi',
        class      => 'WMIMonitorID',
        properties => [ qw/InstanceName/ ]
    )) {
        next unless $object->{InstanceName};

        my $PNPDeviceID = $object->{InstanceName};
        $PNPDeviceID =~ s/_\d+//;
        push @screens, {
            id => $object->{PNPDeviceID}
        };
    }

    # The generic Win32_DesktopMonitor class, the second screen will be missing
    foreach my $object (FusionInventory::Agent::Tools::Win32::getWmiObjects(
        class => 'Win32_DesktopMonitor',
        properties => [ qw/
            Caption MonitorManufacturer MonitorType PNPDeviceID
        / ]
    )) {
        next unless $object->{Availability};
        next unless $object->{PNPDeviceID};
        next unless $object->{Availability} == 3;

        push @screens, {
            id           => $object->{PNPDeviceID},
            name         => $object->{Caption},
            type         => $object->{MonitorType},
            manufacturer => $object->{MonitorManufacturer},
            caption      => $object->{Caption}
        };
    }

    my $Registry;
    Win32::TieRegistry->require();
    Win32::TieRegistry->import(
        Delimiter   => '/',
        ArrayValues => 0,
        TiedRef     => \$Registry
    );

    my $access = FusionInventory::Agent::Tools::Win32::is64bit() ?
	Win32::TieRegistry::KEY_READ() |
	    FusionInventory::Agent::Tools::Win32::KEY_WOW64_64() :
	Win32::TieRegistry::KEY_READ();

    foreach my $screen (@screens) {

        my $machKey = $Registry->Open('LMachine', {
            Access => $access
        } ) or $logger->fault(
            "Can't open HKEY_LOCAL_MACHINE key: $EXTENDED_OS_ERROR"
        );

        $screen->{edid} =
            $machKey->{"SYSTEM/CurrentControlSet/Enum/$screen->{id}/Device Parameters/EDID"} || '';
        $screen->{edid} =~ s/^\s+$//;

    }

    return @screens;
}

sub _getScreensFromUnix {

    my $raw_edid =
        getFirstLine(command => 'monitor-get-edid-using-vbe') ||
        getFirstLine(command => 'monitor-get-edid');

    if (!$raw_edid) {
        foreach (1..5) { # Sometime get-edid return an empty string...
            $raw_edid = getFirstLine(command => 'get-edid');
            last if $raw_edid && (length($raw_edid) == 128 || length($raw_edid) == 256);
        }
    }
    return unless length($raw_edid) == 128 || length($raw_edid) == 256;

    return ( { edid => $raw_edid } );
}

sub _getScreens {
    my ($logger) = @_;

    return $OSNAME eq 'MSWin32' ?
        _getScreensFromWindows($logger) : _getScreensFromUnix($logger);
}

1;
