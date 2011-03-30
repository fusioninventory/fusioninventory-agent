package FusionInventory::Agent::XML::Query::Inventory;
# TODO: resort the functions
use strict;
use warnings;
use base 'FusionInventory::Agent::XML::Query';

use Config;
use Data::Dumper;
use Digest::MD5 qw(md5_base64);
use Encode qw/encode/;
use English qw(-no_match_vars);
use XML::TreePP;

use FusionInventory::Agent::Tools;

my %fields = (
    ANTIVIRUS   => [ qw/COMPANY NAME GUID ENABLED UPTODATE VERSION/ ],
    BATTERIES   => [ qw/CAPACITY CHEMISTRY DATE NAME SERIAL MANUFACTURER
                        VOLTAGE/ ],
    CONTROLLERS => [ qw/CAPTION DRIVER NAME MANUFACTURER PCICLASS PCIID
                        PCISUBSYSTEMID PCISLOT TYPE REV/ ],
    CPUS        => [ qw/CACHE CORE DESCRIPTION MANUFACTURER NAME THREAD SERIAL
                        SPEED ID/ ],
    DRIVES      => [ qw/CREATEDATE DESCRIPTION FREE FILESYSTEM LABEL LETTER 
                        SERIAL SYSTEMDRIVE TOTAL TYPE VOLUMN/ ],
    ENVS        => [ qw/KEY VAL/ ],
    INPUTS      => [ qw/CAPTION DESCRIPTION INTERFACE LAYOUT POINTTYPE TYPE/ ],
    MEMORIES    => [qw/CAPACITY CAPTION FORMFACTOR REMOVABLE PURPOSE SPEED
                       SERIALNUMBER TYPE DESCRIPTION NUMSLOTS/ ],
    MODEMS      => [ qw/DESCRIPTION NAME/ ],
    MONITORS    => [ qw/BASE64 CAPTION DESCRIPTION MANUFACTURER SERIAL
                        UUENCODE/ ],
    NETWORKS    => [ qw/DESCRIPTION DRIVER IPADDRESS IPADDRESS6 IPDHCP IPGATEWAY
                        IPMASK IPSUBNET MACADDR MTU PCISLOT STATUS TYPE 
                        VIRTUALDEV SLAVES SPEED MANAGEMENT/ ],
    PORTS       => [ qw/CAPTION DESCRIPTION NAME TYPE/ ],
    PROCESSES   => [ qw/USER PID CPUUSAGE MEM VIRTUALMEMORY TTY STARTED CMD/ ],
    REGISTRY    => [ qw/NAME REGVALUE HIVE/ ],
    SLOTS       => [ qw/DESCRIPTION DESIGNATION NAME STATUS/ ],
    SOFTWARES   => [ qw/COMMENTS FILESIZE FOLDER FROM HELPLINK INSTALLDATE NAME
                        NO_REMOVE RELEASE_TYPE PUBLISHER UNINSTALL_STRING 
                        URL_INFO_ABOUT VERSION VERSION_MINOR VERSION_MAJOR 
                        IS64BIT GUID/ ],
    SOUNDS      => [ qw/DESCRIPTION MANUFACTURER NAME/ ],
    STORAGES    => [ qw/DESCRIPTION DISKSIZE INTERFACE MANUFACTURER MODEL NAME
                        TYPE SERIAL SERIALNUMBER FIRMWARE SCSI_COID SCSI_CHID
                        SCSI_UNID SCSI_LUN WWN/ ],
    VIDEOS      => [ qw/CHIPSET MEMORY NAME RESOLUTION PCISLOT/ ],
    USBDEVICES  => [ qw/VENDORID PRODUCTID SERIAL CLASS SUBCLASS NAME/ ],
    USERS       => [ qw/LOGIN DOMAIN/ ],
    PRINTERS    => [ qw/COMMENT DESCRIPTION DRIVER NAME NETWORK PORT RESOLUTION
                        SHARED STATUS ERRSTATUS SERVERNAME SHARENAME 
                        PRINTPROCESSOR SERIAL/ ],
    VIRTUALMACHINES => [ qw/MEMORY NAME UUID STATUS SUBSYSTEM VMTYPE VCPU
                            VMID/ ],
);

sub new {
    my ($class, $params) = @_;

    my $self = $class->SUPER::new($params);

    $self->{last_statefile} = $params->{last_statefile};

    $self->{h}->{QUERY} = 'INVENTORY';
    $self->{h}->{CONTENT} = {
        HARDWARE => {
            # TODO move that in a backend module
            ARCHNAME => $Config{archname},
            VMSYSTEM => "Physical" # Default value
        },
        VERSIONCLIENT => $FusionInventory::Agent::AGENT_STRING
    };

    return $self;
}

sub _addEntry {
    my ($self, $params) = @_;

    my $section = $params->{section};
    my $values = $params->{values};
    my $noDuplicated = $params->{noDuplicated};

    my $newEntry;
    my $fields = $fields{$section};
    die "Unknown section $section" unless $fields;

    foreach my $field (@$fields) {
        next unless defined $values->{$field};
        $newEntry->{$field} = getSanitizedString($values->{$field});
    }

    # avoid duplicate entries
    if ($noDuplicated) {
        my $md5 = md5_base64(Dumper($newEntry));
        return if $self->{seen}->{$section}->{$md5};
        $self->{seen}->{$section}->{$md5} = 1;
    }

    push @{$self->{h}{CONTENT}{$section}}, $newEntry;

    return 1;
}

sub addController {
    my ($self, $args) = @_;

    $self->_addEntry({
        section => 'CONTROLLERS',
        values  => $args,
    });
}

sub addModem {
    my ($self, $args) = @_;

    $self->_addEntry({
        section => 'MODEMS',
        values  => $args,
    });
}

sub addDrive {
    my ($self, $args) = @_;

    $self->_addEntry({
        section => 'DRIVES',
        values  => $args,
    });
}

sub addStorage {
    my ($self, $args) = @_;

    my $logger = $self->{logger};

    my $values = $args;
    if (!$values->{SERIALNUMBER}) {
        $values->{SERIALNUMBER} = $values->{SERIAL}
    }

    my $filter = '^(SCSI|HDC|IDE|USB|1394|Serial-ATA|SAS)$';
    if ($values->{INTERFACE} && $values->{INTERFACE} !~ /$filter/) {
        $logger->debug("STORAGES/INTERFACE doesn't match /$filter/, ".
        "this is not an error but the situation should be improved");
    }

    $self->_addEntry({
        section => 'STORAGES',
        values  => $values,
    });
}

sub addMemory {
    my ($self, $args) = @_;

    $self->_addEntry({
        section => 'MEMORIES',
        values  => $args,
    });
}

sub addPort {
    my ($self, $args) = @_;

    $self->_addEntry({
        section => 'PORTS',
        values  => $args,
    });
}

sub addSlot {
    my ($self, $args) = @_;

    $self->_addEntry({
        section => 'SLOTS',
        values  => $args,
    });
}

sub addSoftware {
    my ($self, $args) = @_;


    $self->_addEntry({
        section      => 'SOFTWARES',
        values       => $args,
        noDuplicated => 1
    });
}

sub addMonitor {
    my ($self, $args) = @_;

    $self->_addEntry({
        section => 'MONITORS',
        values  => $args,
    });
}

sub addVideo {
    my ($self, $args) = @_;

    $self->_addEntry({
        section      => 'VIDEOS',
        values       => $args,
        noDuplicated => 1
    });

}

sub addSound {
    my ($self, $args) = @_;

    $self->_addEntry({
        section => 'SOUNDS',
        values  => $args,
    });
}

sub addNetwork {
    my ($self, $args) = @_;

    $self->_addEntry({
        section      => 'NETWORKS',
        values       => $args,
        noDuplicated => 1
    });
}

sub setHardware {
    my ($self, $args) = @_;

    foreach my $key (qw/USERID OSVERSION PROCESSORN OSCOMMENTS CHECKSUM
        PROCESSORT NAME PROCESSORS SWAP ETIME TYPE OSNAME IPADDR WORKGROUP
        DESCRIPTION MEMORY UUID DNS LASTLOGGEDUSER USERDOMAIN
        DATELASTLOGGEDUSER DEFAULTGATEWAY VMSYSTEM WINOWNER WINPRODID
        WINPRODKEY WINCOMPANY WINLANG/) {
# WINLANG: Windows Language, see MSDN Win32_OperatingSystem documentation
        if (exists $args->{$key}) {
            my $string = getSanitizedString($args->{$key});
            $self->{h}{CONTENT}{HARDWARE}{$key} = $string;
        }
    }
}

sub setBios {
    my ($self, $args) = @_;

    foreach my $key (qw/SMODEL SMANUFACTURER SSN BDATE BVERSION BMANUFACTURER
        MMANUFACTURER MSN MMODEL ASSETTAG ENCLOSURESERIAL BASEBOARDSERIAL
        BIOSSERIAL TYPE SKUNUMBER/) {

        if (exists $args->{$key}) {
            my $string = getSanitizedString($args->{$key});
            $self->{h}{CONTENT}{BIOS}{$key} = $string;
        }
    }
}

sub addCPU {
    my ($self, $args) = @_;

    $self->_addEntry({
        section => 'CPUS',
        values  => $args,
    });

    # For the compatibility with HARDWARE/PROCESSOR*
    my $processorn = int @{$self->{h}{CONTENT}{CPUS}};
    my $processors = $self->{h}{CONTENT}{CPUS}[0]{SPEED};
    my $processort = $self->{h}{CONTENT}{CPUS}[0]{NAME};

    $self->setHardware ({
        PROCESSORN => $processorn,
        PROCESSORS => $processors,
        PROCESSORT => $processort,
    });
}

sub addUser {
    my ($self, $args) = @_;

    return unless $args->{LOGIN};

    return unless $self->_addEntry({
        section      => 'USERS',
        values       => $args,
        noDuplicated => 1
    });

    # Compare with old system 
    my $userString = $self->{h}{CONTENT}{HARDWARE}{USERID} || "";
    my $domainString = $self->{h}{CONTENT}{HARDWARE}{USERDOMAIN} || "";

    $userString .= '/' if $userString;
    $domainString .= '/' if $domainString;

    my $login = $args->{LOGIN}; 
    my $domain = $args->{DOMAIN} || '';
# TODO: I don't think we should change the parameter this way. 
    if ($login =~ /(.*\\|)(\S+)/) {
        $domainString .= $domain;
        $userString .= $2;
    } else {
        $domainString .= $domain;
        $userString .= $login;
    }

    $self->setHardware ({
        USERID     => $userString,
        USERDOMAIN => $domainString,
    });
}

sub addPrinter {
    my ($self, $args) = @_;

    $self->_addEntry({
        section => 'PRINTERS',
        values  => $args,
    });
}

sub addVirtualMachine {
    my ($self, $args) = @_;

    my $logger = $self->{logger};

    if (!$args->{STATUS}) {
        $logger->error("status not set by ".caller(0));
    } elsif (!$args->{STATUS} =~ /(running|idle|paused|shutdown|crashed|dying|off)/) {
        $logger->error("Unknown status '".$args->{status}."' from ".caller(0));
    }

    $self->_addEntry({
        section => 'VIRTUALMACHINES',
        values  => $args,
    });

}

sub addProcess {
    my ($self, $args) = @_;

    $self->_addEntry({
        section => 'PROCESSES',
        values  => $args,
    });
}

sub addInput {
    my ($self, $args) = @_;


    $self->_addEntry({
        section => 'INPUTS',
        values  => $args,
    });
}

sub addEnv {
    my ($self, $args) = @_;

    $self->_addEntry({
        section => 'ENVS',
        values  => $args,
    });
}

sub addUSBDevice {
    my ($self, $args) = @_;

    $self->_addEntry({
        section      => 'USBDEVICES',
        values       => $args,
        noDuplicated => 1
    });
}

sub addBattery {
    my ($self, $args) = @_;

    $self->_addEntry({
        section => 'BATTERIES',
        values  => $args,
    });
}

sub addRegistry {
    my ($self, $args) = @_;

    $self->_addEntry({
        section => 'REGISTRY',
        values  => $args,
    });
}

sub addAntiVirus {
    my ($self, $args) = @_;

    $self->_addEntry({
        section      => 'ANTIVIRUS',
        values       => $args,
        noDuplicated => 1
    });
}

sub setAccessLog {
    my ($self, $args) = @_;

    foreach my $key (qw/USERID LOGDATE/) {

        if (exists $args->{$key}) {
            $self->{h}{CONTENT}{ACCESSLOG}{$key} = $args->{$key};
        }
    }
}

sub addIpDiscoverEntry {
    my ($self, $args) = @_;

    my $ipaddress = $args->{IPADDRESS};
    my $macaddr = $args->{MACADDR};
    my $name = $args->{NAME};

    if (!$self->{h}{CONTENT}{IPDISCOVER}{H}) {
        $self->{h}{CONTENT}{IPDISCOVER}{H} = [];
    }

    push @{$self->{h}{CONTENT}{IPDISCOVER}{H}}, {
        # If I or M is undef, the server will ingore the host
        I => [$ipaddress?$ipaddress:""],
        M => [$macaddr?$macaddr:""],
        N => [$name?$name:"-"], # '-' is the default value reteurned by ipdiscover
    };
}

sub addSoftwareDeploymentPackage {
    my ($self, $args) = @_;

    push
        @{$self->{h}{CONTENT}{DOWNLOAD}{HISTORY}->{PACKAGE}},
        { ID => $args->{ORDERID} };
}

sub checkContent {
    my ($self, $args) = @_;

    my $logger = $self->{logger};

    my $missing = 0;
    my $content = $self->{h}->{CONTENT};

    if (!$content->{NETWORKS}->[0]->{MACADDR}) {
        $logger->debug('Missing value: MAC address of first network card');
        $missing++;
    }
    if (!$content->{BIOS}->{SSN}) {
        $logger->debug('Missing value: serial number');
        $missing++;
    }
    if (!$content->{HARDWARE}->{NAME}) {
        $logger->debug('Missing value: hostname');
        $missing++;
    }
    if (!$content->{HARDWARE}->{UUID}) {
        $logger->debug('Missing value: UUID');
        $missing++;
    }

    if ($missing) {
        $logger->debug(
            'Important value(s) to identify the computer are missing. ' .
            'Depending on how the server identify duplicated machine, ' .
            'this may create zombie computer in your data base.'
        );
    }

}

sub getContentAsHTML {
    my ($self, $args) = @_;

    my $htmlHeader = <<EOF;
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta content="text/html; charset=UTF-8" http-equiv="content-type" />
    <title>FusionInventory-Agent $self->{deviceid} - <a href="http://www.FusionInventory.org">http://www.FusionInventory.org</a></title>
    <style type="text/css">
<!--/* <![CDATA[ */
 tr.odd { 
    background-color:white;
}
tr.even { 
    background-color:silver;
}
/* ]]> */-->
    </style>
</head>
<body>
<h1>Inventory for $self->{deviceid}</h1>
FusionInventory Agent $FusionInventory::Agent::VERSION<br />
<small>DEVICEID $self->{deviceid}</small>
EOF

    my $htmlFooter = <<EOF;
</body>
</html>
EOF

    my $htmlBody;

    foreach my $section (sort keys %{$self->{h}{CONTENT}}) {
        next if $section eq 'VERSIONCLIENT';

        $htmlBody .= "<h2>$section</h2>\n";

        my $content = $self->{h}{CONTENT}->{$section};

        if (ref($content) eq 'ARRAY') {
            my $fields = $fields{$section};
            $htmlBody .= "<table width=\"100\%\">\n";
            $htmlBody .= "<tr>\n";
            foreach my $field (@$fields) {
                $htmlBody .= "<th>" . lc($field). "</th>\n";
            }
            $htmlBody .= "</tr>\n";
            my $count = 0;
            foreach my $item (@$content) {
                my $class = $count++ % 2 ? 'odd' : 'even';      
                $htmlBody .= "<tr class=\"$class\">\n";
                foreach my $field (@$fields) {
                    $htmlBody .= "<td>" . ($item->{$field} || "" ). "</td>\n";
                }
                $htmlBody .= "</tr>\n";

            }
            $htmlBody .= "</table>\n";
        } else {
            $htmlBody .= "<ul>\n";
            foreach my $key (sort keys %{$content}) {
                $htmlBody .= "<li>$key: $content->{$key}</li>\n";
            }
            $htmlBody .= "</ul>\n<br />\n";
        }
    }

    return $htmlHeader . $htmlBody . $htmlFooter;
}

sub processChecksum {
    my $self = shift;

    my $logger = $self->{logger};

#To apply to $checksum with an OR
    my %mask = (
        HARDWARE      => 1,
        BIOS          => 2,
        MEMORIES      => 4,
        SLOTS         => 8,
        REGISTRY      => 16,
        CONTROLLERS   => 32,
        MONITORS      => 64,
        PORTS         => 128,
        STORAGES      => 256,
        DRIVES        => 512,
        INPUT         => 1024,
        MODEMS        => 2048,
        NETWORKS      => 4096,
        PRINTERS      => 8192,
        SOUNDS        => 16384,
        VIDEOS        => 32768,
        SOFTWARES     => 65536,
        VIRTUALMACHINES => 131072,
    );
    # TODO CPUS is not in the list

    my $checksum = 0;

    if ($self->{last_statefile}) {
        if (-f $self->{last_statefile}) {
            $self->{last_state_content} = XML::TreePP->parsefile(
                $self->{last_statefile}
            );
        } else {
            $logger->debug(
                "last state file '$self->{last_statefile}' doesn't exist"
            );
        }
    }

    foreach my $section (keys %mask) {
        #If the checksum has changed...
        my $hash =
            md5_base64(Dumper($self->{h}{CONTENT}{$section}));
        if (!$self->{last_state_content}->{$section} || $self->{last_state_content}->{$section} ne $hash ) {
            $logger->debug ("Section $section has changed since last inventory");
            #We make OR on $checksum with the mask of the current section
            $checksum |= $mask{$section};
        }
        # Finally I store the new value.
        $self->{last_state_content}->{$section} = $hash;
    }


    $self->setHardware({CHECKSUM => $checksum});
}

sub saveLastState {
    my ($self, $args) = @_;

    my $logger = $self->{logger};

    if (!defined($self->{last_state_content})) {
        $self->processChecksum();
    }

    if ($self->{last_statefile}) {
        XML::TreePP->new()->writefile(
            $self->{last_state_content}, $self->{last_statefile}
        );
    } else {
        $logger->debug(
            "last state file is not defined, last state not saved"
        );
    }

    my $tpp = XML::TreePP->new();
}

sub addSection {
    my ($self, $args) = @_;
    my $logger = $self->{logger};
    my $multi = $args->{multi};
    my $tagname = $args->{tagname};

    $logger->debug("Please, don't use addSection(). This function may be ".
        "dropped in the future.");

    for( keys %{$self->{h}{CONTENT}} ){
        if( $tagname eq $_ ){
            $logger->debug("Tag name `$tagname` already exists - Don't add it");
            return 0;
        }
    }

    if($multi){
        $self->{h}{CONTENT}{$tagname} = [];
    }
    else{
        $self->{h}{CONTENT}{$tagname} = {};
    }
    return 1;
}

1;
__END__

=head1 NAME

FusionInventory::Agent::XML::Query::Inventory - Inventory agent message

=head1 DESCRIPTION

This is an inventory message sent by the agent to the server, using OCS
Inventory XML format.

=head1 METHODS

=head2 new($params)

The constructor. See base class C<FusionInventory::Agent::XML::Query> for
allowed parameters.

=over

=item I<last_statefile>

a path to a file containing the last serialized inventory

=back

=head2 addController()

Add a controller in the inventory.

=head2 addModem()

Add a modem in the inventory.

=head2 addDrive()

Add a partition in the inventory.

=head2 addStorage()

Add a storage system (hard drive, USB key, SAN volume, etc) in the inventory.

=head2 addMemory()

Add a memory module in the inventory.

=head2 addPort()

Add a port module in the inventory.

=head2 addSlot()

=head2 addSoftware()

Register a software in the inventory.

=head2 addMonitor()

Add a monitor (screen) in the inventory.

=head2 addVideo()

Add a video card in the inventory.

=head2 addSound()

Add a sound card in the inventory.

=head2 addNetwork()

Register a network interface in the inventory.

=head2 setHardware()

Save global information regarding the machine.

=head2 setBios()

Set BIOS informations.

=head2 addCPU()

Add a CPU in the inventory.

=head2 addUser()

Add an user in the list of logged user.

=head2 addPrinter()

Add a printer in the inventory.

=head2 addVirtualMachine()

Add a Virtual Machine in the inventory.

=head2 addProcess()

Record a running process in the inventory.

=head2 addInput()

Add an input device (mouse/keyboard) in the inventory.

=head2 addEnv()

Register an environment variable.

=head2 addUSBDevice()

USB device

=head2 addBattery()

Battery

=head2 addRegistry()

Windows Registry key

=head2 addAntiVirus()

Registered Anti-Virus on Windows

=head2 setAccessLog()

What is that for? :)

=head2 addIpDiscoverEntry()

IpDiscover is used to identify network interface on the local network. This
is done on the ARP level.

This function adds a network interface in the inventory.

=head2 addSoftwareDeploymentPackage()

This function is for software deployment.

Order sent to the agent are recorded on the client side and then send back
to the server in the inventory.

=head2 checkContent()

Check inventory content.

=head2 getContent()

Return the inventory as an HTML string.

=head2 processChecksum()

Compute the <CHECKSUM/> field. This information is used by the server to
know which parts of the XML have changed since the last inventory.

The is done thanks to the last_file file. It has MD5 prints of the previous
inventory. 

=head2 saveLastState()

At the end of the process IF the inventory was saved
correctly, the last_state is saved.

=head2 addSection()

A generic way to save a section in the inventory. Please avoid this
solution.

=over

=head1 XML STRUCTURE

This section presents the XML structure used by FusionInventory. The schema
is based on OCS Inventory XML with various additions.

=head2 BIOS

=over 4

=item SMODEL

=item SMANUFACTURER

System manufacturer

=item SSN

=item BDATE

=item BVERSION

The BIOS revision

=item BMANUFACTURER

BIOS manufacturer

=item MMANUFACTURER

Motherboard Manufacturer

=item MSN

Motherboard Serial

=item MMODEL

Motherboard model

=item ASSETTAG

=item ENCLOSURESERIAL

=item BASEBOARDSERIAL

=item BIOSSERIAL

The optional asset tag for this machine.

=back

=head2 CONTROLLERS

=over 4

=item CAPTION

Windows CAPTION field or subsystem Name from the pci.ids table

=item DRIVER

=item NAME

The device name, the on from the PCIIDs DB

=item MANUFACTURER

The manifacturer name, the on from the PCIIDs DB

=item PCICLASS

The PCI class ID

=item PCIID

The PCI ID, e.g: 8086:2a40 (only for PCI device)

=item PCISUBSYSTEMID

The PCI subsystem ID, e.g: 8086:2a40 (only for PCI device)

=item PCISLOT

The PCI slot, e.g: 00:02.1 (only for PCI device)

=item TYPE

The controller revision, e.g: rev 02. This field may be renamed
in the future.

=item REV

Revision of the device in the XX format (e.g: 04)

=back

=head2 MEMORIES

=over 4

=item CAPACITY

=item CAPTION

E.g: Physical Memory

=item DESCRIPTION

=item FORMFACTOR

Only available on Windows, See Win32_PhysicalMemory documentation on MSDN.

=item REMOVABLE

=item PURPOSE

Only avalaible on Windows, See Win32_PhysicalMemory documentation on MSDN.

=item SPEED

In Mhz, e.g: 800

=item TYPE

=item NUMSLOTS

Eg. 2, start at 1, not 0

=item SERIALNUMBER

=back

=head2 CPUS

=over 4

=item CACHESIZE

The total CPU cache size in KB. e.g: 3072

=item CORE

Number of core.

=item DESCRIPTION

=item MANUFACTURER

AMD/Intel/Transmeta/Cyrix/VIA

=item NAME

The name of the CPU, e.g: Intel(R) Core(TM)2 Duo CPU     P8600  @ 2.40GHz

=item THREAD

Number of thread per core.

=item SERIAL

Serial number

=item SPEED

Frequency in MHz

=item ID

The CPU ID: http://en.wikipedia.org/wiki/CPUID

=back

=head2 DRIVES

Drive is actually a filesystem. Virtual filesystem like /proc or /sys are ignored.

=over 4

=item CREATEDATE

Date of creation of the filesystem in DD/MM/YYYY format.

=item DESCRIPTION

=item FREE

Free space (MB)

=item FILESYSTEM

File system name. e.g: ext3

=item LABEL

Name of the partition given by the user.

=item LETTER

Windows driver letter. Windows only

=item SERIAL

Partition serial number or UUID

=item SYSTEMDRIVE

Boolean. Is this the system partition?

=item TOTAL

Total space available (MB)

=item TYPE

The mount point on UNIX.

=item VOLUMN

System name of the partition (e.g: /dev/sda1 or server:/directory for NFS)

=back

=head2 HARDWARE

=over 4

=item USERID

The current user list, '/' is the delimiter. This field is deprecated, you
should use the USERS section instead.

=item OSVERSION

=item PROCESSORN

=item OSCOMMENTS

Service Pack on Windows, kernel build date on Linux

=item CHECKSUM

Deprecated, OCS only.

=item PROCESSORT

Deprecated, OCS only.

=item NAME

=item PROCESSORS

The processor speed in MHz, this field is deprecated, see CPUS instead.

=item SWAP

The swap space in MB.

=item ETIME

The time needed to run the inventory on the agent side.

=item TYPE

=item OSNAME

=item IPADDR

=item WORKGROUP

=item DESCRIPTION

Computer description (Windows only so far)

=item MEMORY

Total system memory in MB

=item UUID

=item DNS

=item LASTLOGGEDUSER

The login of the last logged user.

=item USERDOMAIN

This field is deprecated, you should use the USERS section instead.

=item DATELASTLOGGEDUSER

=item DEFAULTGATEWAY

=item VMSYSTEM

The virtualization technologie used if the machine is a virtual machine.

Can by: Physical (default), Xen, VirtualBox, Virtual Machine, VMware, QEMU, SolarisZone

=item WINOWNER

=item WINPRODID

=item WINPRODKEY

=item WINCOMPANY

=item WINLANG

=back

=head2 MONITORS

=over 4

=item BASE64

The uuencoded EDID trame. Optional.

=item CAPTION

=item DESCRIPTION

=item MANUFACTURER

The manufacturer retrieved from the EDID trame.

=item SERIAL

The serial number retrieved from the EDID trame.

=item UUENCODE

The uuencoded EDID trame. Optional.

=back

=head2 PORTS

Serial, Parallel, SATA, etc

=over 4

=item CAPTION

=item DESCRIPTION

=item NAME

=item TYPE

=back

=head2 SLOTS

Represents physical connection points including ports, motherboard slots and peripherals, and proprietary connection points.

This information is hardly reliable.

=over 4

=item CAPACITY

=item CAPTION

=item FORMFACTOR

=item REMOVABLE

=item PURPOSE

=item TYPE

=item DESCRIPTION

=back

=head2 STORAGES

=over 4

=item DESCRIPTION

The long name of the device displayed to the user.

=item DISKSIZE

The disk size in MB.

=item INTERFACE

INTERFACE can be SCSI/HDC/IDE/USB/1394/Serial-ATA/SAS or empty if unknown

=item MANUFACTURER

=item MODEL

The commercial name of the device

=item NAME

The name of the device as seen by the system. E.g: hda (Linux), \\.\PHYSICALDRIVE0 (Windows)

=item TYPE

The kind of device. There is no standard for the format of the string in this field.

=item SERIAL

The harddrive serial number

=item SERIALNUMBER

Deprecated. The harddrive serial number, same as SERIAL.

=item FIRMWARE

=item SCSI_COID

=item SCSI_CHID

=item SCSI_UNID

=item SCSI_LUN

=item WWN

World Wide Name http://fr.wikipedia.org/wiki/World_Wide_Name

=back

=head2 SOFTWARES

=over 4

=item COMMENTS

=item FILESIZE

=item FOLDER

=item FROM

Where the information about the software came from, can be:
registry, rpm, deb, etc

=item HELPLINK

=item INSTALLDATE

Installation day in DD/MM/YYYY format. Windows only.

=item NAME

=item NO_REMOVE

=item RELEASE_TYPE

Windows only for now, come from the registry

=item PUBLISHER

=item UNINSTALL_STRING

Windows only, come from the registry

=item URL_INFO_ABOUT

=item VERSION

=item VERSION_MINOR

Windows only, come from the registry

=item VERSION_MAJOR

Windows only, come from the registry

=item IS64BIT

If the software is in 32 or 64bit, (1/0)

=item GUID

Windows software GUID

=back

=head2 USERS

=over 4

=item LOGIN

=item DOMAIN

The Windows domain of the user, if available.

=back

=head2 VIDEOS

=over 4

=item CHIPSET

=item MEMORY

Video card memory in MB

=item NAME

=item RESOLUTION

Resolution in pixel. 1024x768.

=item PCISLOT

The local PCI slot ID if the video card use PCI.

=back

=head2 VIRTUALMACHINES

=over 4

=item MEMORY

Memory size, in MB.

=item NAME

The name of the virtual machine.

=item UUID

=item STATUS

The VM status: running, idle, paused, shutdown, crashed, dying, off

=item SUBSYSTEM

The virtualisation software.
E.g: VmWare ESX

=item VMTYPE

The name of the virtualisation system family. The same type found is HARDWARE/VMSYSTEM

=item VCPU

Number of CPU affected to the virtual machine

=item VMID

The ID of virtual machine in the virtual managment system.

=back

=head2 SOUNDS

=over 4

=item DESCRIPTION

=item MANUFACTURER

=item NAME

=back

=head2 MODEMS

=over 4

=item DESCRIPTION

=item NAME

=back

=head2 ENVS

Environment variables

=over 4

=item KEY

=item VAL

=back

=head2 UPDATES 

Windows updates

=over 4

=item ID 

Update Id

=item KB

List of KB, delimiter is '/'

=back

=head2 USBDEVICES 

USB Devices

=over 4

=item VENDORID 

Vendor USB ID. 4 hexa char.

=item PRODUCTID 

Product USB ID. 4 hexa char.

=item SERIAL

=item CLASS

USB Class (e.g: 8 for Mass Storage)

=item SUBCLASS

USB Sub Class

=item NAME

The name of the device (optional)

=back

=head2 NETWORKS

A network configuration.

=over 4

=item DESCRIPTION

The name of the interface as seen in the OS settings, e.g: eth0 (Linux) or AMD PCNET Family Ethernet Adapter (Windows)

=item DRIVER

The name of the driver used by the network interface

=item IPADDRESS

=item IPADDRESS6

=item IPDHCP

The IP address of the DHCP server (optional).

=item IPGATEWAY

=item IPMASK

=item IPSUBNET

=item MACADDR

=item MTU

=item PCISLOT

The PCI slot name.

=item STATUS

Up or Down

=item TYPE

deprecated

=item VIRTUALDEV

If the interface exist or not (1 or empty)

=item SLAVES

Bonded interfaces list in the eth0/eth1/eth2 format (/ is the separator).

=item MANAGEMENT

Whether or not it is a HP iLO, Sun SC, HP MP or other kind of Remote Management Interface

=item SPEED

Interface speed in Mb/s

=back

=head2 BATTERIES

=over 4

=item CAPACITY

Battery capacity in mWh

=item DATE

Manufacture date in DD/MM/YYYY format

=item NAME

Name of the device

=item SERIAL

Serial number

=item MANUFACTURER

Battery manufacturer

=item VOLTAGE

Voltage in mV

=back

=head2 PRINTERS

=over 4

=item COMMENT

=item DESCRIPTION

=item DRIVER

=item NAME

=item NETWORK

Network: True (1) if it's a network printer

=item PORT

=item RESOLUTION

Resolution: eg. 600x600

=item SHARED

Shared: True if the printer is shared (Win32)

=item STATUS

Status: See Win32_Printer.PrinterStatus

=item ERRSTATUS

ErrStatus: See Win32_Printer.ExtendedDetectedErrorState

=item SERVERNAME

=item SHARENAME

=item PRINTPROCESSOR

=back

=head2 PROCESSES

=over 4

=item USER

The process owner

=item PID

The process Id

=item CPUUSAGE

The CPU usage.

=item MEM

The memory.

=item VIRTUALMEMORY

=item TTY

=item STARTED

When the process has been started in YYYY/MM/DD HH:MM format

=item CMD

The command.

=back

=head2 ANTIVIRUS

=over 4

=item COMPANY

Comapny name

=item NAME

=item GUID

Unique ID

=item ENABLED

1 if the antivirus is enabled.

=item UPTODATE

1 if the antivirus is up to date.

=item VERSION
