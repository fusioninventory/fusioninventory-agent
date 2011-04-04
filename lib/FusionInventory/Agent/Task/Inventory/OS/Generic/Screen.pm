package FusionInventory::Agent::Task::Inventory::OS::Generic::Screen;
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
#     Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
# Some part come from Mandriva's (great) monitor-edid
# http://svn.mandriva.com/cgi-bin/viewvc.cgi/soft/monitor-edid/trunk/
#
use strict;
use warnings;

use English qw(-no_match_vars);
use MIME::Base64;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Screen;

sub isInventoryEnabled {

    return
        $OSNAME eq 'MSWin32'                  ||
        can_run("monitor-get-edid-using-vbe") ||
        can_run("monitor-get-edid")           ||
        can_run("get-edid");
}

sub doInventory {
    my ($params) = @_;

    my $inventory = $params->{inventory};
    my $logger    = $params->{logger};

    foreach my $screen (_getScreens($logger)) {

        if ($screen->{edid}) {
            my $edid = parseEdid($screen->{edid});
            if (my $err = checkParsedEdid($edid)) {
                $params->{logger}->debug("check failed: bad edid: $err");
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

        $inventory->addMonitor ($screen);
    }
}

sub _getScreens {
    my ($logger) = @_;

    my @screens;

    if ($OSNAME eq 'MSWin32') {
        my $Registry;
        eval {
            require FusionInventory::Agent::Tools::Win32;
            require Win32::TieRegistry;
            Win32::TieRegistry->import(
                Delimiter   => '/',
                ArrayValues => 0,
                TiedRef     => \$Registry
            );
        };
        if ($EVAL_ERROR) {
            print "Failed to load Win32::OLE and Win32::TieRegistry\n";
            return;
        }

        foreach my $objItem (getWmiProperties('Win32_DesktopMonitor', qw/
            Caption MonitorManufacturer MonitorType PNPDeviceID
        /)) {

            next unless $objItem->{"PNPDeviceID"};

            my $screen = {
                MANUFACTURER => $objItem->{MonitorManufacturer},
                CAPTION      => $objItem->{Caption},
            };

            my $machKey;
            {
                # Win32-specifics constants can not be loaded on non-Windows OS
                no strict 'subs'; ## no critics
                $machKey = $Registry->Open('LMachine', {
                    Access => Win32::TieRegistry::KEY_READ
                }) or die "Can't open HKEY_LOCAL_MACHINE key: $EXTENDED_OS_ERROR";
            }

            $screen->{edid} =
                $machKey->{"SYSTEM/CurrentControlSet/Enum/$objItem->{PNPDeviceID}/Device Parameters/EDID"} || '';
            $screen->{edid} =~ s/^\s+$//;

            push @screens, $screen;
        }
    } else {
        # Mandriva
        my $raw_edid =
            getFirstLine(command => 'monitor-get-edid-using-vbe') ||
            getFirstLine(command => 'monitor-get-edid');

        if (!$raw_edid) {
            foreach (1..5) { # Sometime get-edid return an empty string...
                $raw_edid = getFirstLine(command => 'get-edid');
                last if length($raw_edid) == 128 || length($raw_edid) == 256;
            }
        }
        return unless length($raw_edid) == 128 || length($raw_edid) == 256;

        push @screens, { edid => $raw_edid };
    }

    return @screens;
}

1;
