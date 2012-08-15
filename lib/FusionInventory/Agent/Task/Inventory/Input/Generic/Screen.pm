package FusionInventory::Agent::Task::Inventory::Input::Generic::Screen;

use strict;
use warnings;

use English qw(-no_match_vars);
use MIME::Base64;
use UNIVERSAL::require;

use File::Find;
use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Screen;

# list of models with unsuited constant ASCII serial numbers
my %blacklist = (
    ACRad49 => 1
);

sub isEnabled {

    return
        $OSNAME eq 'MSWin32'                 ||
        -d '/sys'                            ||
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
            my $info = _getEdidInfo($screen->{edid}, $logger);
            $screen->{CAPTION}      = $info->{CAPTION};
            $screen->{DESCRIPTION}  = $info->{DESCRIPTION};
            $screen->{MANUFACTURER} = $info->{MANUFACTURER};
            $screen->{SERIAL}       = $info->{SERIAL};

            $screen->{BASE64} = encode_base64($screen->{edid});
            delete $screen->{edid};
        }

        $inventory->addEntry(
            section => 'MONITORS',
            entry   => $screen
        );
    }
}

sub _getEdidInfo {
    my ($raw_edid, $logger) = @_;

    my $edid = parseEdid($raw_edid);
    if (my $error = checkParsedEdid($edid)) {
        $logger->debug("bad edid: $error");
        return;
    }

    my $info = {
        CAPTION      => $edid->{monitor_name},
        DESCRIPTION  => $edid->{week} . "/" . $edid->{year},
        MANUFACTURER => getManufacturerFromCode($edid->{manufacturer_name}) ||
                        $edid->{manufacturer_name}
    };

    # they are two different serial numbers in EDID
    # - a mandatory 4 bytes numeric value
    # - an optional 13 bytes ASCII value
    # we use the ASCII value if present, and if the model is not part of an
    # exception, otherwise we use the numerical one, as an 8-length hex string
    # References:
    # http://forge.fusioninventory.org/issues/1607
    # http://forge.fusioninventory.org/issues/1614
    $info->{SERIAL} =
        $edid->{serial_number2} && !$blacklist{$edid->{EISA_ID}} ?
            $edid->{serial_number2}->[0]           :
            sprintf("%08x", $edid->{serial_number});

    return $info;
}

sub _getScreensFromWindows {
    my ($logger) = @_;

    FusionInventory::Agent::Tools::Win32->use();
    if ($EVAL_ERROR) {
        print
            "Failed to load FusionInventory::Agent::Tools::Win32: $EVAL_ERROR";
        return;
    }

    my @screens;

    # Vista and upper, able to get the second screen
    foreach my $object (getWmiObjects(
        moniker    => 'winmgmts:{impersonationLevel=impersonate,authenticationLevel=Pkt}!//./root/wmi',
        class      => 'WMIMonitorID',
        properties => [ qw/InstanceName/ ]
    )) {
        next unless $object->{InstanceName};

        $object->{InstanceName} =~ s/_\d+//;
        push @screens, {
            id => $object->{InstanceName}
        };
    }

    # The generic Win32_DesktopMonitor class, the second screen will be missing
    foreach my $object (getWmiObjects(
        class => 'Win32_DesktopMonitor',
        properties => [ qw/
            Caption MonitorManufacturer MonitorType PNPDeviceID Availability
        / ]
    )) {
        next unless $object->{Availability};
        next unless $object->{PNPDeviceID};
        next unless $object->{Availability} == 3;

        push @screens, {
            id           => $object->{PNPDeviceID},
            NAME         => $object->{Caption},
            TYPE         => $object->{MonitorType},
            MANUFACTURER => $object->{MonitorManufacturer},
            CAPTION      => $object->{Caption}
        };
    }

    foreach my $screen (@screens) {
        next unless $screen->{id};
        $screen->{edid} = getRegistryValue(
            path => "HKEY_LOCAL_MACHINE/SYSTEM/CurrentControlSet/Enum/$screen->{id}/Device Parameters/EDID",
            logger => $logger
        ) || '';
        $screen->{edid} =~ s/^\s+$//;
        delete $screen->{id};
    }

    return @screens;
}

sub _getScreensFromUnix {

    my @screens;

    if (-d '/sys/devices') {
        my $wanted = sub {
            return unless $_ eq 'edid';
            return unless -s $File::Find::name;
            my $edid = getAllLines(file => $File::Find::name);
            push @screens, { edid => $edid } if $edid;
        };

        no warnings 'File::Find';
        File::Find::find($wanted, '/sys/devices');

        return @screens if @screens;
    }

    my $edid =
        getAllLines(command => 'monitor-get-edid-using-vbe') ||
        getAllLines(command => 'monitor-get-edid');
    push @screens, { edid => $edid };

    return @screens if @screens;

    foreach (1..5) { # Sometime get-edid return an empty string...
        $edid = getFirstLine(command => 'get-edid');
        if ($edid) {
            push @screens, { edid => $edid };
            last;
        }
    }

    return @screens;
}

sub _getScreens {
    my ($logger) = @_;

    return $OSNAME eq 'MSWin32' ?
        _getScreensFromWindows($logger) : _getScreensFromUnix($logger);
}

1;
