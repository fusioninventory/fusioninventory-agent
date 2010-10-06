package FusionInventory::Agent::Task::Inventory::OS::Generic::Screen;

use strict;
use warnings;

use English qw(-no_match_vars);
use MIME::Base64;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Generic::Screen;

sub isInventoryEnabled {

    return
        $OSNAME eq 'MSWin32'                  ||
        can_run("monitor-get-edid-using-vbe") ||
        can_run("monitor-get-edid")           ||
        can_run("get-edid");
}

sub _getScreens {
    my ($logger) = @_;

    my @raw_edid;


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

            my $caption;
            my $description;
            my $manufacturer;
            my $serial;
            my $base64;
            next unless $objItem->{"PNPDeviceID"};
            my $name = $objItem->{"Caption"};

            my $machKey;
            {
                # Win32-specifics constants can not be loaded on non-Windows OS
                no strict 'subs'; ## no critics
                $machKey = $Registry->Open('LMachine', {
                    Access => Win32::TieRegistry::KEY_READ
                } ) or die "Can't open HKEY_LOCAL_MACHINE key: $EXTENDED_OS_ERROR";
            }

            my $edid =
                $machKey->{"SYSTEM/CurrentControlSet/Enum/$objItem->{PNPDeviceID}/Device Parameters/EDID"} || '';
            $edid =~ s/^\s+$//;

            if ($edid) {
                my $edidInfo = parseEdid($edid);
                if (my $err = checkParsedEdid($edidInfo)) {
                    $logger->debug("check failed: bad edid: $err");
                } else {

                    $caption = $edidInfo->{monitor_name};
                    $description = $edidInfo->{week}."/".$edidInfo->{year};
                    $manufacturer = getManufacturerFromCode($edidInfo->{manufacturer_name});
                    $serial = $edidInfo->{serial_number2}[0];
                }

                $base64 = encode_base64($edid);

            }


            push @raw_edid, { edid => $edid, type => $objItem->{MonitorType}, manufacturer => $objItem->{MonitorManufacturer}, caption => $objItem->{Caption}, base64 => $base64, serial => $serial };
        }

    } else {

# Mandriva
        my $raw_edid = `monitor-get-edid-using-vbe 2>/dev/null`;

# Since monitor-edid 1.15, it's possible to retrieve EDID information
# through DVI link but we need to use monitor-get-edid
        if (!$raw_edid) {
            $raw_edid = `monitor-get-edid 2>/dev/null`;
        }

        if (!$raw_edid) {
            foreach (1..5) { # Sometime get-edid return an empty string...
                $raw_edid = `get-edid 2>/dev/null`;
                last if (length($raw_edid) == 128 || length($raw_edid) == 256);
            }
        }
        return unless (length($raw_edid) == 128 || length($raw_edid) == 256);

        push @raw_edid, { edid => $raw_edid };
    }

    return @raw_edid;
}


sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};
    my $logger = $params->{logger};

    my $raw_perl = 1;
    my $verbose;
    my $MonitorsDB;

    my @screens = _getScreens($logger);

    return unless @screens;

    foreach my $screen (@screens) {

        $inventory->addMonitor ({
            BASE64 => $screen->{base64},
            CAPTION => $screen->{caption},
            DESCRIPTION => $screen->{description},
            MANUFACTURER => $screen->{manufacturer},
            SERIAL => $screen->{serial},
        });
    }
}
1;

