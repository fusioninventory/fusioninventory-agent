package FusionInventory::Device::Computer;

use strict;
use warnings;

use Config;
use Data::Dumper;
use Digest::MD5 qw(md5_base64);
use English qw(-no_match_vars);
use UNIVERSAL::require;
use XML::TreePP;
use JSON::PP;

use FusionInventory::Agent::Logger;
use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Version;

# Always sort keys in Dumper while computing checksum on HASH
$Data::Dumper::Sortkeys = 1;

my %fields = (
    BIOS             => [ qw/SMODEL SMANUFACTURER SSN BDATE BVERSION
                             BMANUFACTURER MMANUFACTURER MSN MMODEL ASSETTAG
                             ENCLOSURESERIAL BIOSSERIAL
                             TYPE SKUNUMBER/ ],
    HARDWARE         => [ qw/USERID OSVERSION PROCESSORN OSCOMMENTS CHECKSUM
                             PROCESSORT NAME PROCESSORS SWAP ETIME TYPE OSNAME
                             IPADDR WORKGROUP DESCRIPTION MEMORY UUID DNS
                             LASTLOGGEDUSER USERDOMAIN DATELASTLOGGEDUSER
                             DEFAULTGATEWAY VMSYSTEM WINOWNER WINPRODID
                             WINPRODKEY WINCOMPANY WINLANG CHASSIS_TYPE
                             VMNAME VMHOSTSERIAL/ ],
    OPERATINGSYSTEM  => [ qw/KERNEL_NAME KERNEL_VERSION NAME VERSION FULL_NAME
                             SERVICE_PACK INSTALL_DATE FQDN DNS_DOMAIN HOSTID
                             SSH_KEY ARCH BOOT_TIME TIMEZONE/ ],
    ACCESSLOG        => [ qw/USERID LOGDATE/ ],

    ANTIVIRUS        => [ qw/COMPANY ENABLED GUID NAME UPTODATE VERSION
                             DATFILECREATION DATFILEVERSION ENGINEVERSION32
                             ENGINEVERSION64/ ],
    BATTERIES        => [ qw/CAPACITY CHEMISTRY DATE NAME SERIAL MANUFACTURER
                             VOLTAGE/ ],
    CONTROLLERS      => [ qw/CAPTION DRIVER NAME MANUFACTURER PCICLASS VENDORID
                             PRODUCTID PCISUBSYSTEMID PCISLOT TYPE REV/ ],
    CPUS             => [ qw/CACHE CORE DESCRIPTION MANUFACTURER NAME THREAD
                             SERIAL STEPPING FAMILYNAME FAMILYNUMBER MODEL
                             SPEED ID EXTERNAL_CLOCK ARCH CORECOUNT/ ],
    DRIVES           => [ qw/CREATEDATE DESCRIPTION FREE FILESYSTEM LABEL
                             LETTER SERIAL SYSTEMDRIVE TOTAL TYPE VOLUMN/ ],
    ENVS             => [ qw/KEY VAL/ ],
    INPUTS           => [ qw/NAME MANUFACTURER CAPTION DESCRIPTION INTERFACE
                             LAYOUT POINTINGTYPE TYPE/ ],
    FIREWALL         => [ qw/PROFILE STATUS DESCRIPTION IPADDRESS IPADDRESS6/ ],
    LICENSEINFOS     => [ qw/NAME FULLNAME KEY COMPONENTS TRIAL UPDATE OEM
                             ACTIVATION_DATE PRODUCTID/ ],
    LOCAL_GROUPS     => [ qw/ID MEMBER NAME/ ],
    LOCAL_USERS      => [ qw/HOME ID LOGIN NAME SHELL/ ],
    LOGICAL_VOLUMES  => [ qw/LV_NAME VG_NAME ATTR SIZE LV_UUID SEG_COUNT
                             VG_UUID/ ],
    MEMORIES         => [ qw/CAPACITY CAPTION FORMFACTOR REMOVABLE PURPOSE
                             SPEED SERIALNUMBER TYPE DESCRIPTION NUMSLOTS
                             MEMORYCORRECTION MANUFACTURER/ ],
    MODEMS           => [ qw/DESCRIPTION NAME TYPE MODEL/ ],
    MONITORS         => [ qw/BASE64 CAPTION DESCRIPTION MANUFACTURER SERIAL
                             UUENCODE NAME TYPE ALTSERIAL PORT/ ],
    NETWORKS         => [ qw/DESCRIPTION MANUFACTURER MODEL MANAGEMENT TYPE
                             VIRTUALDEV MACADDR WWN DRIVER FIRMWARE PCIID
                             PCISLOT PNPDEVICEID MTU SPEED STATUS SLAVES BASE
                             IPADDRESS IPSUBNET IPMASK IPDHCP IPGATEWAY
                             IPADDRESS6 IPSUBNET6 IPMASK6 WIFI_BSSID WIFI_SSID
                             WIFI_MODE WIFI_VERSION/ ],
    PHYSICAL_VOLUMES => [ qw/DEVICE PV_PE_COUNT PV_UUID FORMAT ATTR
                             SIZE FREE PE_SIZE VG_UUID/ ],
    PORTS            => [ qw/CAPTION DESCRIPTION NAME TYPE/ ],
    PRINTERS         => [ qw/COMMENT DESCRIPTION DRIVER NAME NETWORK PORT
                             RESOLUTION SHARED STATUS ERRSTATUS SERVERNAME
                             SHARENAME PRINTPROCESSOR SERIAL/ ],
    PROCESSES        => [ qw/USER PID CPUUSAGE MEM VIRTUALMEMORY TTY STARTED
                             CMD/ ],
    REGISTRY         => [ qw/NAME REGVALUE HIVE/ ],
    REMOTE_MGMT      => [ qw/ID TYPE/ ],
    RUDDER           => [ qw/AGENT UUID HOSTNAME SERVER_ROLES AGENT_CAPABILITIES/ ],
    SLOTS            => [ qw/DESCRIPTION DESIGNATION NAME STATUS/ ],
    SOFTWARES        => [ qw/COMMENTS FILESIZE FOLDER FROM HELPLINK INSTALLDATE
                            NAME NO_REMOVE RELEASE_TYPE PUBLISHER
                            UNINSTALL_STRING URL_INFO_ABOUT VERSION
                            VERSION_MINOR VERSION_MAJOR GUID ARCH USERNAME
                            USERID SYSTEM_CATEGORY/ ],
    SOUNDS           => [ qw/CAPTION DESCRIPTION MANUFACTURER NAME/ ],
    STORAGES         => [ qw/DESCRIPTION DISKSIZE INTERFACE MANUFACTURER MODEL
                            NAME TYPE SERIAL SERIALNUMBER FIRMWARE SCSI_COID
                            SCSI_CHID SCSI_UNID SCSI_LUN WWN/ ],
    VIDEOS           => [ qw/CHIPSET MEMORY NAME RESOLUTION PCISLOT PCIID/ ],
    USBDEVICES       => [ qw/VENDORID PRODUCTID MANUFACTURER CAPTION SERIAL
                            CLASS SUBCLASS NAME/ ],
    USERS            => [ qw/LOGIN DOMAIN/ ],
    VIRTUALMACHINES  => [ qw/MEMORY NAME UUID STATUS SUBSYSTEM VMTYPE VCPU
                             MAC COMMENT OWNER SERIAL IMAGE/ ],
    VOLUME_GROUPS    => [ qw/VG_NAME PV_COUNT LV_COUNT ATTR SIZE FREE VG_UUID
                             VG_EXTENT_SIZE/ ],
    VERSIONPROVIDER  => [ qw/NAME VERSION COMMENTS PERL_EXE PERL_VERSION PERL_ARGS
                             PROGRAM PERL_CONFIG PERL_INC PERL_MODULE/ ]
);

my %checks = (
    STORAGES => {
        INTERFACE => qr/^(SCSI|HDC|IDE|USB|1394|Serial-ATA|SAS)$/
    },
    VIRTUALMACHINES => {
        STATUS => qr/^(running|blocked|idle|paused|shutdown|crashed|dying|off)$/
    },
    SLOTS => {
        STATUS => qr/^(free|used)$/
    },
    NETWORKS => {
        TYPE => qr/^(ethernet|wifi|infiniband|aggregate|alias|dialup|loopback|bridge|fibrechannel)$/
    },
    CPUS => {
        ARCH => qr/^(MIPS|MIPS64|Alpha|SPARC|SPARC64|m68k|i386|x86_64|PowerPC|PowerPC64|ARM|AArch64)$/
    }
);

# convert fields list into fields hashes, for fast lookup
foreach my $section (keys %fields) {
    $fields{$section} = { map { $_ => 1 } @{$fields{$section}} };
}

sub new {
    my ($class, %params) = @_;

    my $self = {
        deviceid       => $params{deviceid},
        logger         => $params{logger} || FusionInventory::Agent::Logger->new(),
        fields         => \%fields,
        content        => {
            HARDWARE => {
                VMSYSTEM => "Physical" # Default value
            },
            VERSIONCLIENT => $FusionInventory::Agent::AGENT_STRING ||
                $FusionInventory::Agent::Version::PROVIDER."-Inventory_v".$FusionInventory::Agent::Version::VERSION
        }
    };
    bless $self, $class;

    $self->setTag($params{tag});

    return $self;
}

sub getRemote {
    my ($self) = @_;

    return $self->{_remote} || '';
}

sub setRemote {
    my ($self, $task) = @_;

    $self->{_remote} = $task || '';

    return $self->{_remote};
}

sub getFields {
    my ($self) = @_;

    return $self->{fields};
}

sub getContent {
    my ($self) = @_;

    return $self->{content};
}

sub getSection {
    my ($self, $section) = @_;
    ## no critic (ExplicitReturnUndef)
    my $content = $self->getContent() or return undef;
    return exists($content->{$section}) ? $content->{$section} : undef ;
}

sub getField {
    my ($self, $section, $field) = @_;
    ## no critic (ExplicitReturnUndef)
    $section = $self->getSection($section) or return undef;
    return exists($section->{$field}) ? $section->{$field} : undef ;
}

sub mergeContent {
    my ($self, $content) = @_;

    die "no content" unless $content;

    foreach my $section (keys %$content) {
        if (ref $content->{$section} eq 'ARRAY') {
            # a list of entry
            foreach my $entry (@{$content->{$section}}) {
                $self->addEntry(section => $section, entry => $entry);
            }
        } else {
            # single entry
            SWITCH: {
                if ($section eq 'HARDWARE') {
                    $self->setHardware($content->{$section});
                    last SWITCH;
                }
                if ($section eq 'OPERATINGSYSTEM') {
                    $self->setOperatingSystem($content->{$section});
                    last SWITCH;
                }
                if ($section eq 'BIOS') {
                    $self->setBios($content->{$section});
                    last SWITCH;
                }
                if ($section eq 'ACCESSLOG') {
                    $self->setAccessLog($content->{$section});
                    last SWITCH;
                }
                $self->addEntry(
                    section => $section, entry => $content->{$section}
                );
            }
        }
    }
}

sub addEntry {
    my ($self, %params) = @_;

    my $entry = $params{entry};
    die "no entry" unless $entry;

    my $section = $params{section};
    my $fields = $fields{$section};
    my $checks = $checks{$section};
    die "unknown section $section" unless $fields;

    foreach my $field (keys %$entry) {
        if (!$fields->{$field}) {
            # unvalid field, log error and remove
            $self->{logger}->debug("unknown field $field for section $section");
            delete $entry->{$field};
            next;
        }
        if (!defined $entry->{$field}) {
            # undefined value, remove
            delete $entry->{$field};
            next;
        }
        # sanitize value
        my $value = getSanitizedString($entry->{$field});
        # check value if appliable
        if ($checks->{$field}) {
            $self->{logger}->debug(
                "invalid value $value for field $field for section $section"
            ) unless $value =~ $checks->{$field};
        }
        $entry->{$field} = $value;
    }

    # avoid duplicate entries
    if ($params{noDuplicated}) {
        my $md5 = md5_base64(Dumper($entry));
        return if $self->{seen}->{$section}->{$md5};
        $self->{seen}->{$section}->{$md5} = 1;
    }

    if ($section eq 'STORAGES') {
        $entry->{SERIALNUMBER} = $entry->{SERIAL} if !$entry->{SERIALNUMBER}
    }

    push @{$self->{content}{$section}}, $entry;
}

sub getHardware {
    my ($self, $field) = @_;
    return $self->getField('HARDWARE', $field);
}

sub setHardware {
    my ($self, $args) = @_;

    foreach my $field (keys %$args) {
        if (!$fields{HARDWARE}->{$field}) {
            $self->{logger}->debug("unknown field $field for section HARDWARE");
            next
        }

        # Do not overwrite existing value with undef
        next unless $args->{$field};

        $self->{content}->{HARDWARE}->{$field} =
            getSanitizedString($args->{$field});
    }
}

sub setOperatingSystem {
    my ($self, $args) = @_;

    foreach my $field (keys %$args) {
        if (!$fields{OPERATINGSYSTEM}->{$field}) {
            $self->{logger}->debug(
                "unknown field $field for section OPERATINGSYSTEM"
            );
            next
        }
        $self->{content}->{OPERATINGSYSTEM}->{$field} =
            getSanitizedString($args->{$field});
    }
}

sub getBios {
    my ($self, $field) = @_;
    return $self->getField('BIOS', $field);
}

sub setBios {
    my ($self, $args) = @_;

    foreach my $field (keys %$args) {
        if (!$fields{BIOS}->{$field}) {
            $self->{logger}->debug("unknown field $field for section BIOS");
            next
        }

        $self->{content}->{BIOS}->{$field} =
            getSanitizedString($args->{$field});
    }
}

sub setAccessLog {
    my ($self, $args) = @_;

    foreach my $field (keys %$args) {
        if (!$fields{ACCESSLOG}->{$field}) {
            $self->{logger}->debug(
                "unknown field $field for section ACCESSLOG"
            );
            next
        }

        $self->{content}->{ACCESSLOG}->{$field} =
            getSanitizedString($args->{$field});
    }
}

sub setTag {
    my ($self, $tag) = @_;

    return unless $tag;

    $self->{content}{ACCOUNTINFO} = [{
        KEYNAME  => "TAG",
        KEYVALUE => $tag
    }];

}

sub as_json {
    my ($self) = @_;

    my $json = JSON::PP->new()->pretty();

    return $json->encode( $self->{content} );
}

sub as_xml {
    my ($self) = @_;

    my $tpp = XML::TreePP->new(indent => 2);

    return $tpp->write({ COMPUTER => $self->{content} });
}

1;
__END__

=head1 NAME

FusionInventory::Device::Computer - Computer data structure

=head1 DESCRIPTION

This is a data structure corresponding to a computer-type device.

=head1 METHODS

=head2 new(%params)

The constructor. The following parameters are allowed, as keys of the
%params hash:

=over

=item I<logger>

a logger object

=item I<tag>

an arbitrary label, used for server-side filtering

=back

=head2 getContent()

Get content attribute.

=head2 getSection($section)

Get full machine inventory section.

=head2 getField($section,$field)

Get a field from a full machine inventory section.

=head2 mergeContent($content)

Merge content to the inventory.

=head2 addEntry(%params)

Add a new entry to the inventory. The following parameters are allowed, as keys
of the %params hash:

=over

=item I<section>

the entry section (mandatory)

=item I<entry>

the entry (mandatory)

=item I<noDuplicated>

ignore entry if already present

=back

=head2 setTag($tag)

Set inventory tag, an arbitrary label used for filtering on server side.

=head2 getHardware($field)

Get machine global information from known machine inventory.

=head2 setHardware()

Save global information regarding the machine.

=head2 setOperatingSystem()

Operating System information.

=head2 getBios($field)

Get BIOS information from known inventory.

=head2 setBios()

Set BIOS information.

=head2 setAccessLog()

What is that for? :)

=head2 getRemote()

Method to get the parent task remote status.

Returns the string set by setRemote() API or an empty string.

=head2 setRemote([$task])

Method to set or reset the parent task remote status.

Without $task parameter, the API resets the parent remote status to an empty string.
