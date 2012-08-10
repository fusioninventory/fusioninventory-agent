package FusionInventory::Agent::Task::Inventory::Input::Generic::Screen;

use strict;
use warnings;

use English qw(-no_match_vars);
use MIME::Base64;
use UNIVERSAL::require;

use File::Find;
use FusionInventory::Agent::Tools;

my %manufacturers = (
    ACR => "Acer America Corp.",
    ACT => "Targa",
    ADI => "ADI Corporation http://www.adi.com.tw",
    AOC => "AOC International (USA) Ltd.",
    API => "Acer America Corp.",
    APP => "Apple Computer, Inc.",
    ART => "ArtMedia",
    AST => "AST Research",
    AUO => "AU Optronics",
    CPL => "Compal Electronics, Inc. / ALFA",
    CPQ => "COMPAQ Computer Corp.",
    CTX => "CTX - Chuntex Electronic Co.",
    DEC => "Digital Equipment Corporation",
    DEL => "Dell Computer Corp.",
    DPC => "Delta Electronics, Inc.",
    DWE => "Daewoo Telecom Ltd",
    ECS => "ELITEGROUP Computer Systems",
    EIZ => "EIZO",
    EPI => "Envision Peripherals, Inc.",
    FCM => "Funai Electric Company of Taiwan",
    FUS => "Fujitsu Siemens",
    GSM => "LG Electronics Inc. (GoldStar Technology, Inc.)",
    GWY => "Gateway 2000",
    HEI => "Hyundai Electronics Industries Co., Ltd.",
    HIT => "Hitachi",
    HSL => "Hansol Electronics",
    HTC => "Hitachi Ltd. / Nissei Sangyo America Ltd.",
    HWP => "Hewlett Packard",
    IBM => "IBM PC Company",
    ICL => "Fujitsu ICL",
    IVM => "Idek Iiyama North America, Inc.",
    KDS => "KDS USA",
    KFC => "KFC Computek",
    LEN => "Lenovo",
    LGD => "LG Display",
    LKM => "ADLAS / AZALEA",
    LNK => "LINK Technologies, Inc.",
    LTN => "Lite-On",
    MAG => "MAG InnoVision",
    MAX => "Maxdata Computer GmbH",
    MEI => "Panasonic Comm. & Systems Co.",
    MEL => "Mitsubishi Electronics",
    MIR => "miro Computer Products AG",
    MTC => "MITAC",
    NAN => "NANAO",
    NEC => "NEC Technologies, Inc.",
    NOK => "Nokia",
    OQI => "OPTIQUEST",
    PBN => "Packard Bell",
    PGS => "Princeton Graphic Systems",
    PHL => "Philips Consumer Electronics Co.",
    REL => "Relisys",
    SAM => "Samsung",
    SEC => "Seiko Epson Corporation",
    SMI => "Smile",
    SMC => "Samtron",
    SNI => "Siemens Nixdorf",
    SNY => "Sony Corporation",
    SPT => "Sceptre",
    SRC => "Shamrock Technology",
    STN => "Samtron",
    STP => "Sceptre",
    TAT => "Tatung Co. of America, Inc.",
    TRL => "Royal Information Company",
    TSB => "Toshiba, Inc.",
    UNM => "Unisys Corporation",
    VSC => "ViewSonic Corporation",
    WTC => "Wen Technology",
    ZCM => "Zenith Data Systems",
    ___ => "Targa",
    BNQ => "BenQ Corporation",
    LPL => "LG Philips",
    PCK => "Daewoo",
    NVD => "Nvidia", #Nvidia
    HIQ => "Hyundai ImageQuest",
    BMM => "BMM",
    AMW => "AMW",
    IFS => "InFocus",
    BOE => "BOE Display Technology",
    IQT => "Hyundai",
    HSD => "Hannspree Inc",
    PRT => "Princeton",
    PDC => "Polaroid"
);

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

    Parse::EDID->require();
    return if $EVAL_ERROR;

    my $edid = Parse::EDID::parse_edid($raw_edid);
    if (my $error = Parse::EDID::check_parsed_edid($edid)) {
        $logger->debug("bad edid: $error");
        return;
    }

    my $info = {
        CAPTION      => $edid->{monitor_name},
        DESCRIPTION  => $edid->{week} . "/" . $edid->{year},
        MANUFACTURER => $manufacturers{$edid->{manufacturer_name}} ||
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

    if (-d '/sys') {
        my $wanted = sub {
            return unless $File::Find::name =~ m{/edid$};
            open my $handle, '<', $File::Find::name;
            my $edid = <$handle>;
            close $handle;

            push @screens, { edid => $edid } if $edid;
        };

        no warnings 'File::Find';
        File::Find::find($wanted, '/sys');

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
