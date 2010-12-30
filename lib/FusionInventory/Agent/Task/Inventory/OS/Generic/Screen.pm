package FusionInventory::Agent::Task::Inventory::OS::Generic::Screen;

use strict;
use warnings;

use English qw(-no_match_vars);
use MIME::Base64;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Screen;

sub isInventoryEnabled {

    return
        $OSNAME eq 'MSWin32'                  ||
        can_run('monitor-get-edid-using-vbe') ||
        can_run('monitor-get-edid')           ||
        can_run('get-edid');
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

#        use constant wbemFlagReturnImmediately => 0x10;
#        use constant wbemFlagForwardOnly => 0x20;

#        my $objWMIService = Win32::OLE->GetObject("winmgmts:\\\\.\\root\\CIMV2") or $logger->fault("WMI connection failed.\n");
#        my $colItems = $objWMIService->ExecQuery("SELECT * FROM Win32_DesktopMonitor", "WQL",
#                wbemFlagReturnImmediately | wbemFlagForwardOnly);
        foreach my $objItem (FusionInventory::Agent::Task::Inventory::OS::Win32::getWmiProperties('Win32_DesktopMonitor', qw/
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
                } ) or die "Can't open HKEY_LOCAL_MACHINE key: $EXTENDED_OS_ERROR";
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
                last if (length($raw_edid) == 128 || length($raw_edid) == 256);
            }
        }
        return unless (length($raw_edid) == 128 || length($raw_edid) == 256);

        push @screens, { edid => $raw_edid };
    }

    return @screens;
}


sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    foreach my $screen (_getScreens($logger)) {

        if ($screen->{edid}) {
            my $edidInfo = parseEdid($screen->{edid});
            if (my $err = checkParsedEdid($edidInfo)) {
                $logger->debug("check failed: bad edid: $err");
            } else {
                $screen->{CAPTION} =
                    $edidInfo->{monitor_name};
                $screen->{DESCRIPTION} =
                    $edidInfo->{week} . "/" . $edidInfo->{year};
                $screen->{MANUFACTURER} =
                    getManufacturerFromCode($edidInfo->{manufacturer_name});
                $screen->{SERIAL} = $edidInfo->{serial_number2}[0];
            }
            $screen->{BASE64} = encode_base64($screen->{edid});
        }

        $inventory->addMonitor($screen);
    }
}

1;
