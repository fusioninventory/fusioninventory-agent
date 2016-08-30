package FusionInventory::Agent::Task::Inventory::Generic::Screen;

use strict;
use warnings;

use English qw(-no_match_vars);
use MIME::Base64;
use UNIVERSAL::require;

use File::Find;
use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Generic;

sub isEnabled {
    my (%params) = @_;
    return 0 if $params{no_category}->{monitor};
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};
    my $datadir   = $params{datadir};

    foreach my $screen (_getScreens(logger => $logger, datadir => $datadir)) {
        $inventory->addEntry(
            section => 'MONITORS',
            entry   => $screen
        );
    }
}

sub _getEdidInfo {
    my (%params) = @_;

    Parse::EDID->require();
    if ($EVAL_ERROR) {
        $params{logger}->debug(
            "Parse::EDID Perl module not available, unable to parse EDID data"
        ) if $params{logger};
        return;
    }

    my $edid = Parse::EDID::parse_edid($params{edid});
    if (my $error = Parse::EDID::check_parsed_edid($edid)) {
        $params{logger}->debug("bad edid: $error") if $params{logger};
        return;
    }

    my $info = {
        CAPTION      => $edid->{monitor_name},
        DESCRIPTION  => $edid->{week} . "/" . $edid->{year},
        MANUFACTURER => getEDIDVendor(
                            id      => $edid->{manufacturer_name},
                            datadir => $params{datadir}
                        ) || $edid->{manufacturer_name}
    };

    # they are two different serial numbers in EDID
    # - a mandatory 4 bytes numeric value
    # - an optional 13 bytes ASCII value
    # we use the ASCII value if present, the numeric value as an hex string
    # unless for a few list of known exceptions deserving specific handling
    # References:
    # http://forge.fusioninventory.org/issues/1607
    # http://forge.fusioninventory.org/issues/1614
    if (
        $edid->{EISA_ID} &&
        $edid->{EISA_ID} =~ /^ACR(0018|0020|0024|00A8|0330|7883|ad49|adaf)$/
    ) {
        $info->{SERIAL} =
            substr($edid->{serial_number2}->[0], 0, 8) .
            sprintf("%08x", $edid->{serial_number})    .
            substr($edid->{serial_number2}->[0], 8, 4) ;
    } elsif (
        $edid->{EISA_ID} &&
        $edid->{EISA_ID} eq 'GSM4b21'
    ) {
        # split serial in two parts
        my ($high, $low) = $edid->{serial_number} =~ /(\d+) (\d\d\d)$/x;

        # translate the first part using a custom alphabet
        my @alphabet = split(//, "0123456789ABCDEFGHJKLMNPQRSTUVWXYZ");
        my $base     = scalar @alphabet;

        $info->{SERIAL} =
            $alphabet[$high / $base] . $alphabet[$high % $base] .
            $low;
    } else {
        $info->{SERIAL} = $edid->{serial_number2} ?
            $edid->{serial_number2}->[0]           :
            sprintf("%08x", $edid->{serial_number});
    }

    return $info;
}

sub _getScreensFromWindows {
    my (%params) = @_;

    FusionInventory::Agent::Tools::Win32->use();

    my @screens;

    # Vista and upper, able to get the second screen
    foreach my $object (getWMIObjects(
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
    foreach my $object (getWMIObjects(
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
            logger => $params{logger}
        ) || '';
        $screen->{edid} =~ s/^\s+$//;
        delete $screen->{id};
    }

    return @screens;
}

sub _getScreensFromUnix {
    my (%params) = @_;

    my $logger = $params{logger};
    $logger->debug("retrieving EDID data:");

    if (-d '/sys/devices') {
        my @screens;
        my $wanted = sub {
            return unless $_ eq 'edid';
            return unless -e $File::Find::name;
            my $edid = getAllLines(file => $File::Find::name);
            push @screens, { edid => $edid } if $edid;
        };

        no warnings 'File::Find';
        File::Find::find($wanted, '/sys/devices');

        $logger->debug_result(
            action => 'reading /sys/devices content',
            data   => scalar @screens
        );

        return @screens if @screens;
    } else {
        $logger->debug_result(
            action => 'reading /sys/devices content',
            status => 'directory not available'
        );
    }

    if (canRun('monitor-get-edid-using-vbe')) {
        my $edid = getAllLines(command => 'monitor-get-edid-using-vbe');
        $logger->debug_result(
            action => 'running monitor-get-edid-using-vbe command',
            data   => $edid
        );
        return { edid => $edid } if $edid;
    } else {
        $logger->debug_result(
            action => 'running monitor-get-edid-using-vbe command',
            status => 'command not available'
        );
    }

    if (canRun('monitor-get-edid')) {
        my $edid = getAllLines(command => 'monitor-get-edid');
        $logger->debug_result(
            action => 'running monitor-get-edid command',
            data   => $edid
        );
        return { edid => $edid } if $edid;
    } else {
        $logger->debug_result(
            action => 'running monitor-get-edid command',
            status => 'command not available'
        );
    }

    if (canRun('get-edid')) {
        my $edid;
        foreach (1..5) { # Sometime get-edid return an empty string...
            $edid = getFirstLine(command => 'get-edid');
            last if $edid;
        }
        $logger->debug_result(
            action => 'running get-edid command',
            data   => $edid
        );
        return { edid => $edid } if $edid;
    } else {
        $logger->debug_result(
            action => 'running get-edid command',
            status => 'command not available'
        );
    }

    return;
}

sub _getScreens {
    my (%params) = @_;

    my @screens = $OSNAME eq 'MSWin32' ?
        _getScreensFromWindows(%params) :
        _getScreensFromUnix(%params);

    foreach my $screen (@screens) {
        next unless $screen->{edid};

        my $info = _getEdidInfo(
            edid    => $screen->{edid},
            logger  => $params{logger},
            datadir => $params{datadir},
        );
        $screen->{CAPTION}      = $info->{CAPTION};
        $screen->{DESCRIPTION}  = $info->{DESCRIPTION};
        $screen->{MANUFACTURER} = $info->{MANUFACTURER};
        $screen->{SERIAL}       = $info->{SERIAL};

        $screen->{BASE64} = encode_base64($screen->{edid});

        delete $screen->{edid};
    }

    return @screens;
}

1;
