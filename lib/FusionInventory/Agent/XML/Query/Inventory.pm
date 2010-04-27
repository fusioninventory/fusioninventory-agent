package FusionInventory::Agent::XML::Query::Inventory;
# TODO: resort the functions
use strict;
use warnings;

=head1 NAME

FusionInventory::Agent::XML::Query::Inventory - the XML abstraction layer

=head1 DESCRIPTION

FusionInventory uses OCS Inventory XML format for the data transmition. This
module is the abstraction layer. It's mostly used in the backend module where
it called $inventory in general.

=cut

use XML::Simple;
use Digest::MD5 qw(md5_base64);
use Config;
use FusionInventory::Agent::XML::Query;

use FusionInventory::Agent::Task::Inventory;

our @ISA = ('FusionInventory::Agent::XML::Query');

=over 4

=item new()

The usual constructor.

=cut
sub new {
  my ($class, $params) = @_;

  my $self = $class->SUPER::new($params);
  bless ($self, $class);

  $self->{backend} = $params->{backend};
  my $logger = $self->{logger};
  my $target = $self->{target};
  my $config = $self->{config};

  if (!($target->{deviceid})) {
    $logger->fault ('deviceid unititalised!');
  }

  $self->{h}{QUERY} = ['INVENTORY'];
  $self->{h}{CONTENT}{ACCESSLOG} = {};
  $self->{h}{CONTENT}{BIOS} = {};
  $self->{h}{CONTENT}{CONTROLLERS} = [];
  $self->{h}{CONTENT}{CPUS} = [];
  $self->{h}{CONTENT}{DRIVES} = [];
  $self->{h}{CONTENT}{HARDWARE} = {
    # TODO move that in a backend module
    ARCHNAME => [$Config{archname}]
  };
  $self->{h}{CONTENT}{MONITORS} = [];
  $self->{h}{CONTENT}{PORTS} = [];
  $self->{h}{CONTENT}{SLOTS} = [];
  $self->{h}{CONTENT}{STORAGES} = [];
  $self->{h}{CONTENT}{SOFTWARES} = [];
  $self->{h}{CONTENT}{USERS} = [];
  $self->{h}{CONTENT}{VIDEOS} = [];
  $self->{h}{CONTENT}{VIRTUALMACHINES} = [];
  $self->{h}{CONTENT}{SOUNDS} = [];
  $self->{h}{CONTENT}{MODEMS} = [];
  $self->{h}{CONTENT}{ENVS} = [];
  $self->{h}{CONTENT}{UPDATES} = [];
  $self->{h}{CONTENT}{USBDEVICES} = [];
  $self->{h}{CONTENT}{VERSIONCLIENT} = ['FusionInventory-Agent_v'.$config->{VERSION}];

  # Is the XML centent initialised?
  $self->{isInitialised} = undef;

  return $self;
}

=item initialise()

Runs the backend modules to initilise the data.

=cut
sub initialise {
  my ($self) = @_;

  return if $self->{isInitialised};

  $self->{backend}->feedInventory ({inventory => $self});

}

=item addController()

Add a controller in the inventory.

=cut
sub addController {
  my ($self, $args) = @_;

  my $driver = $args->{DRIVER};
  my $name = $args->{NAME};
  my $manufacturer = $args->{MANUFACTURER};
  my $pciclass = $args->{PCICLASS};
  my $pciid = $args->{PCIID};
  my $pcislot = $args->{PCISLOT};
  my $type = $args->{TYPE};

  push @{$self->{h}{CONTENT}{CONTROLLERS}},
  {
    DRIVER => [$driver?$driver:''],
    NAME => [$name],
    MANUFACTURER => [$manufacturer],
# The PCI Class in hexa. e.g: 0c03
    PCICLASS => [$pciclass?$pciclass:''],
# E.g: 8086:2a40
    PCIID => [$pciid?$pciid:''],
# E.g: 00:00.0
    PCISLOT => [$pcislot?$pcislot:''],
    TYPE => [$type],

  };
}

=item addModem()

Add a modem in the inventory.

=cut
sub addModem {
  my ($self, $args) = @_;

  my $description = $args->{DESCRIPTION};
  my $name = $args->{NAME};

  push @{$self->{h}{CONTENT}{MODEMS}},
  {

    DESCRIPTION => [$description],
    NAME => [$name],

  };
}
# For compatibiliy
sub addModems {
   my $self = shift;
   my $logger = $self->{logger};

   $logger->debug("please rename addModems to addModem()");
   $self->addModem(@_);
}

=item addDrive()

Add a partition in the inventory.

=cut
sub addDrive {
  my ($self, $args) = @_;

  my $createdate = $args->{CREATEDATE};
  my $description = $args->{DESCRIPTION};
  my $free = $args->{FREE};
  my $filesystem = $args->{FILESYSTEM};
  my $label = $args->{LABEL};
  my $letter = $args->{LETTER};
  my $serial = $args->{SERIAL};
  my $systemdrive = $args->{SYSTEMDRIVE};
  my $total = $args->{TOTAL};
  my $type = $args->{TYPE};
  my $volumn = $args->{VOLUMN};

  push @{$self->{h}{CONTENT}{DRIVES}},
  {
    CREATEDATE => [$createdate?$createdate:''],
# Windows only, e.g: Network drive
    DESCRIPTION => [$description?$description:''],
    FREE => [$free?$free:''],
    FILESYSTEM => [$filesystem?$filesystem:''],
# On windows the LABEL is also in VOLUMN
    LABEL => [$label?$label:''],
    LETTER => [$letter?$letter:''],
    SERIAL => [$serial?$serial:''],
# Is it the system partition
    SYSTEMDRIVE => [$systemdrive?$systemdrive:''],
    TOTAL => [$total?$total:''],
# type is Mount point on Linux/UNIX/MacOSX
    TYPE => [$type?$type:''],
# UNIX: /dev/XXXX, on Windows, the LABEL...
    VOLUMN => [$volumn?$volumn:'']
  };
}
# For compatibiliy
sub addDrives {
   my $self = shift;
   my $logger = $self->{logger};

   $logger->debug("please rename addDrives to addDrive()");
   $self->addDrive(@_);
}

=item addStorage()

Add a storage system (hard drive, USB key, SAN volume, etc) in the inventory.

=cut
sub addStorage {
  my ($self, $args) = @_;

  my $logger = $self->{logger};

  my $description = $args->{DESCRIPTION};
  my $disksize = $args->{DISKSIZE};
  my $interface = $args->{INTERFACE};
  my $manufacturer = $args->{MANUFACTURER};
  my $model = $args->{MODEL};
  my $name = $args->{NAME};
  my $type = $args->{TYPE};
  my $serial = $args->{SERIAL};
  my $serialnumber = $args->{SERIALNUMBER};
  my $firmware = $args->{FIRMWARE};
  my $scsi_coid = $args->{SCSI_COID};
  my $scsi_chid = $args->{SCSI_CHID};
  my $scsi_unid = $args->{SCSI_UNID};
  my $scsi_lun = $args->{SCSI_LUN};

  $serialnumber = $serialnumber?$serialnumber:$serial;

  push @{$self->{h}{CONTENT}{STORAGES}},
  {

    DESCRIPTION => [$description?$description:''],
    DISKSIZE => [$disksize?$disksize:''],
    MANUFACTURER => [$manufacturer?$manufacturer:''],
    MODEL => [$model?$model:''],
    NAME => [$name?$name:''],
    TYPE => [$type?$type:''],
# INTERFACE can be SCSI/HDC/IDE/USB/1394
# (See: Win32_DiskDrive / InterfaceType)
    INTERFACE => [$interface?$interface:''],
    SERIAL => [$serialnumber?$serialnumber:''],
    SERIALNUMBER => [$serialnumber?$serialnumber:''],
    FIRMWARE => [$firmware?$firmware:''],
    SCSI_COID => [$scsi_coid?$scsi_coid:''],
    SCSI_CHID => [$scsi_chid?$scsi_chid:''],
    SCSI_UNID => [$scsi_unid?$scsi_unid:''],
    SCSI_LUN => [$scsi_lun?$scsi_lun:''],

  };
}
# For compatibiliy
sub addStorages {
   my $self = shift;
   my $logger = $self->{logger};

   $logger->debug("please rename addStorages to addStorage()");
   $self->addStorage(@_);
}


=item addMemory()

Add a memory module in the inventory.

=cut
sub addMemory {
  my ($self, $args) = @_;

# In MB, e.g 2048
  my $capacity = $args->{CAPACITY};
# Physical Memory
  my $caption = $args->{CAPTION};
  my $formfactor = $args->{FORMFACTOR};
  my $removable =  $args->{REMOVABLE};
# E.g: System Memory
  my $purpose =  $args->{PURPOSE};
# In Mhz, e.g: 800
  my $speed =  $args->{SPEED};
  my $type = $args->{TYPE};
  my $description = $args->{DESCRIPTION};
# Eg. 2, start at 1, not 0
  my $numslots = $args->{NUMSLOTS};

  my $serialnumber = $args->{SERIALNUMBER};

  push @{$self->{h}{CONTENT}{MEMORIES}},
  {

    CAPACITY => [$capacity?$capacity:''],
    CAPTION => [$caption?$caption:''],
    DESCRIPTION => [$description?$description:''],
    FORMFACTOR => [$formfactor?$formfactor:''],
    REMOVABLE => [$removable?$removable:''],
    PURPOSE => [$purpose?$purpose:''],
    SPEED => [$speed?$speed:''],
    TYPE => [$type?$type:''],
    NUMSLOTS => [$numslots?$numslots:0],
    SERIALNUMBER => [$serialnumber?$serialnumber:'']

  };
}
# For compatibiliy
sub addMemories {
   my $self = shift;
   my $logger = $self->{logger};

   $logger->debug("please rename addMemories to addMemory()");
   $self->addMemory(@_);
}

=item addPort()

Add a port module in the inventory.

=cut
sub addPorts{
  my ($self, $args) = @_;

  my $caption = $args->{CAPTION};
  my $description = $args->{DESCRIPTION};
  my $name = $args->{NAME};
  my $type = $args->{TYPE};


  push @{$self->{h}{CONTENT}{PORTS}},
  {

    CAPTION => [$caption?$caption:''],
    DESCRIPTION => [$description?$description:''],
    NAME => [$name?$name:''],
# e.g: Parallel, Serial, SATA, 
    TYPE => [$type?$type:''],

  };
}
# For compatibiliy
sub addPort {
   my $self = shift;
   my $logger = $self->{logger};

   $logger->debug("please rename addPorts to addPort()");
   $self->addPort(@_);
}

=item addSlot()

Add a slot in the inventory. 

=cut
sub addSlot {
  my ($self, $args) = @_;

  my $description = $args->{DESCRIPTION};
  my $designation = $args->{DESIGNATION};
  my $name = $args->{NAME};
  my $status = $args->{STATUS};


  push @{$self->{h}{CONTENT}{SLOTS}},
  {

    DESCRIPTION => [$description?$description:''],
    DESIGNATION => [$designation?$designation:''],
    NAME => [$name?$name:''],
    STATUS => [$status?$status:''],

  };
}
# For compatibiliy
sub addSlots {
   my $self = shift;
   my $logger = $self->{logger};

   $logger->debug("please rename addSlots to addSlot()");
   $self->addSlot(@_);
}

=item addSoftware()

Register a software in the inventory.

=cut
sub addSoftware {
  my ($self, $args) = @_;

  my $comments = $args->{COMMENTS};
  my $filesize = $args->{FILESIZE};
  my $folder = $args->{FOLDER};
  my $from = $args->{FROM};
  my $helpLink = $args->{HELPLINK};
  my $installDate = $args->{INSTALLDATE};
  my $name = $args->{NAME};
  my $noRemove = $args->{NO_REMOVE};
  my $releaseType = $args->{RELEASE_TYPE};
  my $publisher = $args->{PUBLISHER};
  my $uninstallString = $args->{UNINSTALL_STRING};
  my $urlInfoAbout = $args->{URL_INFO_ABOUT};
  my $version = $args->{VERSION};
  my $versionMinor = $args->{VERSION_MINOR};
  my $versionMajor = $args->{VERSION_MAJOR};
  my $is64bit = $args->{IS64BIT};


  push @{$self->{h}{CONTENT}{SOFTWARES}},
  {

    COMMENTS => [$comments?$comments:''],
    FILESIZE => [$filesize?$filesize:''],
    FOLDER => [$folder?$folder:''],
    FROM => [$from?$from:''],
    HELPLINK => [$helpLink?$helpLink:''],
    INSTALLDATE => [$installDate?$installDate:''],
    NAME => [$name?$name:''],
    NOREMOVE => [$noRemove?$noRemove:''],
    RELEASETYPE => [$releaseType?$releaseType:''],
    PUBLISHER => [$publisher?$publisher:''],
    UNINSTALL_STRING => [$uninstallString],
    URL_INFO_ABOUT => [$urlInfoAbout],
    VERSION => [$version],
    VERSION_MINOR => [$versionMinor?$versionMinor:''],
    VERSION_MAJOR => [$versionMajor?$versionMajor:''],
    IS64BIT => [$is64bit],

  };
}
# For compatibiliy
sub addSoftwares {
   my $self = shift;
   my $logger = $self->{logger};

   $logger->debug("please rename addSoftwares to addSoftware()");
   $self->addSoftware(@_);
}

=item addMonitor()

Add a monitor (screen) in the inventory.

=cut
sub addMonitor {
  my ($self, $args) = @_;

  my $base64 = $args->{BASE64};
  my $caption = $args->{CAPTION};
  my $description = $args->{DESCRIPTION};
  my $manufacturer = $args->{MANUFACTURER};
  my $serial = $args->{SERIAL};
  my $uuencode = $args->{UUENCODE};


  push @{$self->{h}{CONTENT}{MONITORS}},
  {

    BASE64 => [$base64?$base64:''],
    CAPTION => [$caption?$caption:''],
    DESCRIPTION => [$description?$description:''],
    MANUFACTURER => [$manufacturer?$manufacturer:''],
    SERIAL => [$serial?$serial:''],
    UUENCODE => [$uuencode?$uuencode:''],

  };
}
# For compatibiliy
sub addMonitors {
   my $self = shift;
   my $logger = $self->{logger};

   $logger->debug("please rename addMonitors to addMonitor()");
   $self->addMonitor(@_);
}

=item addVideo()

Add a video card in the inventory.

=cut
sub addVideo {
  my ($self, $args) = @_;

  my $chipset = $args->{CHIPSET};
  my $memory = $args->{MEMORY};
  my $name = $args->{NAME};
  my $resolution = $args->{RESOLUTION};

  push @{$self->{h}{CONTENT}{VIDEOS}},
  {

    CHIPSET => [$chipset?$chipset:''],
    MEMORY => [$memory?$memory:''],
    NAME => [$name?$name:''],
    RESOLUTION => [$resolution?$resolution:''],

  };
}
# For compatibiliy
sub addVideos {
   my $self = shift;
   my $logger = $self->{logger};

   $logger->debug("please rename addVideos to addVideo()");
   $self->addVideo(@_);
}

=item addSound()

Add a sound card in the inventory.

=cut
sub addSound {
  my ($self, $args) = @_;

  my $description = $args->{DESCRIPTION};
  my $manufacturer = $args->{MANUFACTURER};
  my $name = $args->{NAME};

  push @{$self->{h}{CONTENT}{SOUNDS}},
  {

    DESCRIPTION => [$description?$description:''],
    MANUFACTURER => [$manufacturer?$manufacturer:''],
    NAME => [$name?$name:''],

  };
}
# For compatibiliy
sub addSounds {
   my $self = shift;
   my $logger = $self->{logger};

   $logger->debug("please rename addSounds to addSound()");
   $self->addSound(@_);
}


=item addNetwork()

Register a network interface in the inventory.

=cut
sub addNetwork {
my ($self, $args) = @_;

    my %tmpXml = ();

    foreach my $item (qw/DESCRIPTION DRIVER IPADDRESS
        IPADDRESS6 IPDHCP IPGATEWAY IPMASK IPSUBNET
        MACADDR MTU PCISLOT STATUS
        TYPE VIRTUALDEV SLAVES/) {
        $tmpXml{$item} = [$args->{$item} ? $args->{$item} : ''];
    }
    push (@{$self->{h}{CONTENT}{NETWORKS}},\%tmpXml);

}

# For compatibiliy
sub addNetworks {
   my $self = shift;
   my $logger = $self->{logger};

   $logger->debug("please rename addNetworks to addNetwork()");
   $self->addNetwork(@_);
}


=item setHardware()

Save global information regarding the machine.

The use of setHardware() to update USERID and PROCESSOR* informations is
deprecated, please, use addUser() and addCPU() instead.

=cut
sub setHardware {
  my ($self, $args, $nonDeprecated) = @_;

  my $logger = $self->{logger};

  foreach my $key (qw/USERID OSVERSION PROCESSORN OSCOMMENTS CHECKSUM
    PROCESSORT NAME PROCESSORS SWAP ETIME TYPE OSNAME IPADDR WORKGROUP
    DESCRIPTION MEMORY UUID DNS LASTLOGGEDUSER USERDOMAIN
    DATELASTLOGGEDUSER DEFAULTGATEWAY VMSYSTEM WINOWNER WINPRODID
    WINPRODKEY WINCOMPANY WINLANG/) {
# WINLANG: Windows Language, see MSDN Win32_OperatingSystem documentation
    if (exists $args->{$key}) {
      if ($key eq 'PROCESSORS' && !$nonDeprecated) {
          $logger->debug("PROCESSORN, PROCESSORS and PROCESSORT shouldn't be set directly anymore. Please use addCPU() method instead.");
      }
      if ($key eq 'USERID' && !$nonDeprecated) {
          $logger->debug("USERID shouldn't be set directly anymore. Please use addCPU() method instead.");
      }

      $self->{h}{'CONTENT'}{'HARDWARE'}{$key}[0] = $args->{$key};
    }
  }
}

=item setBios()

Set BIOS informations.

=cut
sub setBios {
  my ($self, $args) = @_;

  foreach my $key (qw/SMODEL SMANUFACTURER SSN BDATE BVERSION BMANUFACTURER
MMANUFACTURER MSN MMODEL ASSETTAG ENCLOSURESERIAL BASEBOARDSERIAL BIOSSERIAL/) {

    if (exists $args->{$key}) {
      $self->{h}{'CONTENT'}{'BIOS'}{$key}[0] = $args->{$key};
    }
  }
}

=item addCPU()

Add a CPU in the inventory.

=cut
sub addCPU {
  my ($self, $args) = @_;

  # The CPU FLAG
  my $cache = $args->{CACHE};
  my $core = $args->{CORE};
  my $description = $args->{DESCRIPTION},
  my $manufacturer = $args->{MANUFACTURER};
  my $name = $args->{NAME};
  my $thread = $args->{THREAD};
  my $serial = $args->{SERIAL};
  my $speed = $args->{SPEED};

  push @{$self->{h}{CONTENT}{CPUS}},
  {

    CACHESIZE => [$cache],
    CORE => [$core],
    DESCRIPTION => [$description?$description:''],
    MANUFACTURER => [$manufacturer],
    NAME => [$name],
    THREAD => [$thread],
    SERIAL => [$serial],
    SPEED => [$speed],

  };

  # For the compatibility with HARDWARE/PROCESSOR*
  my $processorn = int @{$self->{h}{CONTENT}{CPUS}};
  my $processors = $self->{h}{CONTENT}{CPUS}[0]{SPEED}[0];
  my $processort = $self->{h}{CONTENT}{CPUS}[0]{NAME}[0];

  $self->setHardware ({
    PROCESSORN => $processorn,
    PROCESSORS => $processors,
    PROCESSORT => $processort,
  }, 1);

}

=item addUser()

Add an user in the list of logged user.

=cut
sub addUser {
  my ($self, $args) = @_;

#  my $name  = $args->{NAME};
#  my $gid   = $args->{GID};
  my $login = $args->{LOGIN};
  my $domain = $args->{DOMAIN}; # Windows only
#  my $uid   = $args->{UID};

  return unless $login;
  $domain = "" unless $domain;

  # Is the login, already in the XML ?
  foreach my $user (@{$self->{h}{CONTENT}{USERS}}) {
      return if $user->{LOGIN}[0] eq $login;
  }

  push @{$self->{h}{CONTENT}{USERS}},
  {

#      NAME => [$name],
#      UID => [$uid],
#      GID => [$gid],
      LOGIN => [$login],
      DOMAIN => [$domain]

  };

  my $userString = $self->{h}{CONTENT}{HARDWARE}{USERID}[0] || "";
  my $domainString = $self->{h}{CONTENT}{HARDWARE}{USERDOMAIN}[0] || "";

  $userString .= '/' if $userString;
  $domainString .= '/' if $domainString;

  if ($login =~ /(.*\\|)(\S+)/) {
      $domainString .= $domain;
      $userString .= $2;


      $self->setHardware ({
          USERID => $userString,
          USERDOMAIN => $domainString,
      }, 1);
  }


}

=item addPrinter()

Add a printer in the inventory.

=cut
sub addPrinter {
  my ($self, $args) = @_;

  my $comment = $args->{COMMENT};
  my $description = $args->{DESCRIPTION};
  my $driver = $args->{DRIVER};
  my $name = $args->{NAME};
  my $network = $args->{NETWORK};
  my $port = $args->{PORT};
  my $resolution = $args->{RESOLUTION};
  my $shared = $args->{SHARED};
  my $status = $args->{STATUS};
  my $errStatus = $args->{ERRSTATUS};
  my $serverName = $args->{SERVERNAME};
  my $shareName = $args->{SHARENAME};
  my $printProcessor = $args->{PRINTPROCESSOR};

  push @{$self->{h}{CONTENT}{PRINTERS}},
  {

# Comment: See win32_Printer.Comment
    COMMENT => [$comment?$comment:''],
    DESCRIPTION => [$description?$description:''],
    DRIVER => [$driver?$driver:''],
    NAME => [$name?$name:''],
# Network: True if it's a network printer
    NETWORK => [$network?$network:''],
    PORT => [$port?$port:''],
# Resolution: eg. 600x600
    RESOLUTION => [$resolution?$resolution:''],
# Shared: True if the printer is shared (Win32)
    SHARED => [$shared?$shared:''],
# Status: See Win32_Printer.PrinterStatus
    STATUS => [$status?$status:''],
# ErrStatus: See Win32_Printer.ExtendedDetectedErrorState
    ERRSTATUS => [$errStatus?$errStatus:''],
    SERVERNAME => [$serverName?$serverName:''],
    SHARENAME => [$shareName?$shareName:''],
    PRINTPROCESSOR => [$printProcessor?$printProcessor:''],


  };
}
# For compatibiliy
sub addPrinters {
   my $self = shift;
   my $logger = $self->{logger};

   $logger->debug("please rename addPrinters to addPrinter()");
   $self->addPrinter(@_);
}

=item addVirtualMachine()

Add a Virtual Machine in the inventory.

=cut
sub addVirtualMachine {
  my ($self, $args) = @_;

  my $logger = $self->{logger};

  # The CPU FLAG
  my $memory = $args->{MEMORY};
  my $name = $args->{NAME};
  my $uuid = $args->{UUID};
  my $status = $args->{STATUS};
  my $subsystem = $args->{SUBSYSTEM};
  my $vmtype = $args->{VMTYPE};
  my $vcpu = $args->{VCPU};
  my $vmid = $args->{VMID};

  if (!$status) {
      $logger->error("status not set by ".caller(0));
  } elsif (!$status =~ /(running|idle|paused|shutdown|crashed|dying|off)/) {
    $logger->error("Unknown status '$status' from ".caller(0));
  }

  push @{$self->{h}{CONTENT}{VIRTUALMACHINES}},
  {

      MEMORY =>  [$memory],
      NAME => [$name],
      UUID => [$uuid],
# running, idle, paused, shutdown, crashed, dying, off
      STATUS => [$status],
      # VmWare ESX
      SUBSYSTEM => [$subsystem],
      # VmWare
      VMTYPE => [$vmtype],
      VCPU => [$vcpu],
      VMID => [$vmid],

  };

}

=item addProcess()

Record a running process in the inventory.

=cut
sub addProcess {
  my ($self, $args) = @_;

  my $user = $args->{USER};
  my $pid = $args->{PID};
  my $cpu = $args->{CPUUSAGE};
  my $mem = $args->{MEM};
  my $vsz = $args->{VIRTUALMEMORY};
  my $tty = $args->{TTY};
  my $started = $args->{STARTED};
  my $cmd = $args->{CMD};

  push @{$self->{h}{CONTENT}{PROCESSES}},
  {
    USER => [$user?$user:''],
    PID => [$pid?$pid:''],
    CPUUSAGE => [$cpu?$cpu:''],
    MEM => [$mem?$mem:''],
    VIRTUALMEMORY => [$vsz?$vsz:0],
    TTY => [$tty?$tty:''],
    STARTED => [$started?$started:''],
    CMD => [$cmd?$cmd:''],
  };
}

=item addInput()

Add an input device (mouce/keyboard) in the inventory.

=cut
sub addInput {
  my ($self, $args) = @_;

  my $caption = $args->{CAPTION};
  my $description = $args->{DESCRIPTION};
  my $interface = $args->{INTERFACE};
  my $layout = $args->{LAYOUT};
  my $pointtype = $args->{POINTTYPE};
  my $type = $args->{TYPE};

  push @{$self->{h}{CONTENT}{INPUTS}},
  {

    CAPTION=> [$caption?$caption:''],
    DESCRIPTION => [$description?$description:''],
    INTERFACE => [$interface?$interface:''],
# Free-form string indicating the layout of the keyboard
    LAYOUT => [$layout?$layout:''],
    POINTTYPE => [$pointtype?$pointtype:''],
    TYPE => [$type?$type:''],

  };
}

=item addEnv()

Register an environement variable.

=cut
sub addEnv {
  my ($self, $args) = @_;

  my $key = $args->{KEY};
  my $val = $args->{VAL};

  push @{$self->{h}{CONTENT}{ENVS}},
  {

    KEY => [$key?$key:''],
    VAL => [$val?$val:''],

  };
}

=item addUpdate()

Windows Update

=cut
sub addUpdate {
  my ($self, $args) = @_;

  my $id = $args->{ID};
  my $kb = $args->{KB};

  push @{$self->{h}{CONTENT}{UPDATES}},
  {

    ID => [$id?$id:''],
    KB => [$kb?$kb:''],

  };
}

=item addUSBDevice()

USB device

=cut
sub addUSBDevice {
  my ($self, $args) = @_;

  my $vendorId = $args->{VENDORID};
  my $productId = $args->{PRODUCTID};
  my $serial = $args->{SERIAL};

  push @{$self->{h}{CONTENT}{USBDEVICES}},
  {

    VENDORID => [$vendorId?$vendorId:''],
    PRODUCTID => [$productId?$productId:''],
    SERIAL => [$serial?$serial:''],

  };
}




=item setAccessLog()

What is that for? :)

=cut
sub setAccessLog {
  my ($self, $args) = @_;

  foreach my $key (qw/USERID LOGDATE/) {

    if (exists $args->{$key}) {
      $self->{h}{'CONTENT'}{'ACCESSLOG'}{$key}[0] = $args->{$key};
    }
  }
}

=item addIpDiscoverEntry()

IpDiscover is used to identify network interface on the local network. This
is done on the ARP level.

This function adds a network interface in the inventory.

=cut
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

=item addSoftwareDeploymentPackage()

This function is for software deployment.

Order sent to the agent are recorded on the client side and then send back
to the server in the inventory.

=cut
sub addSoftwareDeploymentPackage {
  my ($self, $args) = @_;

  my $orderId = $args->{ORDERID};

  # For software deployment
  if (!$self->{h}{CONTENT}{DOWNLOAD}{HISTORY}) {
      $self->{h}{CONTENT}{DOWNLOAD}{HISTORY} = [];
  }

  push (@{$self->{h}{CONTENT}{DOWNLOAD}{HISTORY}->[0]{PACKAGE}}, { ID =>
          $orderId });
}

=item getContent()

Return the inventory as a XML string.

=cut
sub getContent {
  my ($self, $args) = @_;

  my $logger = $self->{logger};

  $self->initialise();

  $self->processChecksum();

  #  checks for MAC, NAME and SSN presence
  my $macaddr = $self->{h}->{CONTENT}->{NETWORKS}->[0]->{MACADDR}->[0];
  my $ssn = $self->{h}->{CONTENT}->{BIOS}->{SSN}->[0];
  my $name = $self->{h}->{CONTENT}->{HARDWARE}->{NAME}->[0];

  my $missing;

  $missing .= "MAC-address " unless $macaddr;
  $missing .= "SSN " unless $ssn;
  $missing .= "HOSTNAME " unless $name;

  if ($missing) {
    $logger->debug('Missing value(s): '.$missing.'. I will send this inventory to the server BUT important value(s) to identify the computer are missing');
  }

  my $content = XMLout( $self->{h}, RootName => 'REQUEST', XMLDecl => '<?xml version="1.0" encoding="UTF-8"?>', SuppressEmpty => undef );

  my $clean_content;

  # To avoid strange breakage I remove the unprintable caractere in the XML
  foreach (split "\n", $content) {
#      s/[[:cntrl:]]//g;
    s/\0//g;
    if (! m/\A(
      [\x09\x0A\x0D\x20-\x7E]            # ASCII
      | [\xC2-\xDF][\x80-\xBF]             # non-overlong 2-byte
      |  \xE0[\xA0-\xBF][\x80-\xBF]        # excluding overlongs
      | [\xE1-\xEC\xEE\xEF][\x80-\xBF]{2}  # straight 3-byte
      |  \xED[\x80-\x9F][\x80-\xBF]        # excluding surrogates
      |  \xF0[\x90-\xBF][\x80-\xBF]{2}     # planes 1-3
      | [\xF1-\xF3][\x80-\xBF]{3}          # planes 4-15
      |  \xF4[\x80-\x8F][\x80-\xBF]{2}     # plane 16
      )*\z/x) {
      s/[[:cntrl:]]//g;
      $logger->debug("non utf-8 '".$_."'");
    }

      s/\r|\n//g;

      # Is that a good idea. Intent to drop some nasty char
      # s/[A-z0-9_\-<>\/:\.,#\ \?="'\(\)]//g;
      $clean_content .= $_."\n";
  }

  return $clean_content;
}

=item printXML()

Only for debugging purpose. Print the inventory on STDOUT.

=cut
sub printXML {
  my ($self, $args) = @_;

  $self->initialise();
  print $self->getContent();
}

=item writeXML()

Save the generated inventory as an XML file. The 'local' key of the config
is used to know where the file as to be saved.

=cut
sub writeXML {
  my ($self, $args) = @_;

  my $logger = $self->{logger};
  my $config = $self->{config};
  my $target = $self->{target};

  if ($target->{path} =~ /^$/) {
    $logger->fault ('local path unititalised!');
  }

  $self->initialise();

  my $localfile = $config->{local}."/".$target->{deviceid}.'.ocs';
  $localfile =~ s!(//){1,}!/!;

  # Convert perl data structure into xml strings

  if (open OUT, ">$localfile") {
    print OUT $self->getContent();
    close OUT or warn;
    $logger->info("Inventory saved in $localfile");
  } else {
    warn "Can't open `$localfile': $!"
  }
}

=item processChecksum()

Compute the <CHECKSUM/> field. This information is used by the server to
know which parts of the XML have changed since the last inventory.

The is done thank to the last_file file. It has MD5 prints of the previous
inventory. 

=cut
sub processChecksum {
  my $self = shift;

  my $logger = $self->{logger};
  my $target  = $self->{target};

  # Not needed in local mode
  return unless $target->{type} eq 'server';

#To apply to $checksum with an OR
  my %mask = (
    'HARDWARE'      => 1,
    'BIOS'          => 2,
    'MEMORIES'      => 4,
    'SLOTS'         => 8,
    'REGISTRY'      => 16,
    'CONTROLLERS'   => 32,
    'MONITORS'      => 64,
    'PORTS'         => 128,
    'STORAGES'      => 256,
    'DRIVES'        => 512,
    'INPUT'         => 1024,
    'MODEMS'        => 2048,
    'NETWORKS'      => 4096,
    'PRINTERS'      => 8192,
    'SOUNDS'        => 16384,
    'VIDEOS'        => 32768,
    'SOFTWARES'     => 65536,
    'VIRTUALMACHINES' => 131072,
  );
  # TODO CPUS is not in the list

  if (!$self->{target}->{vardir}) {
    $logger->fault ("vardir uninitialised!");
  }

  my $checksum = 0;

  if ($target->{last_statefile}) {
    if (-f $target->{last_statefile}) {
      # TODO: avoid a violant death in case of problem with XML
      $self->{last_state_content} = XML::Simple::XMLin(

        $target->{last_statefile},
        SuppressEmpty => undef,
        ForceArray => 1

      );
    } else {
      $logger->debug ('last_state file: `'.
      $target->{last_statefile}.
        "' doesn't exist (yet).");
    }
  }

  foreach my $section (keys %mask) {
    #If the checksum has changed...
    my $hash =
        md5_base64(XML::Simple::XMLout($self->{h}{'CONTENT'}{$section}));
    if (!$self->{last_state_content}->{$section}[0] || $self->{last_state_content}->{$section}[0] ne $hash ) {
      $logger->debug ("Section $section has changed since last inventory");
      #We make OR on $checksum with the mask of the current section
      $checksum |= $mask{$section};
    }
    # Finally I store the new value.
    $self->{last_state_content}->{$section}[0] = $hash;
  }


  $self->setHardware({CHECKSUM => $checksum});
}

=item saveLastState()

At the end of the process IF the inventory was saved
correctly, the last_state is saved.

=cut
sub saveLastState {
  my ($self, $args) = @_;

  my $logger = $self->{logger};
  my $target  = $self->{target};

  # Not needed in local mode
  return unless $target->{type} eq 'server';

  if (!defined($self->{last_state_content})) {
	  $self->processChecksum();
  }

  if (!defined ($target->{last_statefile})) {
    $logger->debug ("Can't save the last_state file. File path is not initialised.");
    return;
  }

  if (open LAST_STATE, ">".$target->{last_statefile}) {
    print LAST_STATE my $string = XML::Simple::XMLout( $self->{last_state_content}, RootName => 'LAST_STATE' );;
    close LAST_STATE or warn;
  } else {
    $logger->debug ("Cannot save the checksum values in ".$target->{last_statefile}."
	(will be synchronized by GLPI!!): $!");
  }
}

=item addSection()

A generic way to save a section in the inventory. Please avoid this
solution.

=cut
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

=item feedSection()

Add information in inventory.

=back
=cut
# Q: is that really useful()? Can't we merge with addSection()?
sub feedSection{
  my ($self, $args) = @_;
  my $tagname = $args->{tagname};
  my $values = $args->{data};
  my $logger = $self->{logger};

  my $found=0;
  for( keys %{$self->{h}{CONTENT}} ){
    $found = 1 if $tagname eq $_;
  }

  if(!$found){
    $logger->debug("Tag name `$tagname` doesn't exist - Cannot feed it");
    return 0;
  }

  if( $self->{h}{CONTENT}{$tagname} =~ /ARRAY/ ){
    push @{$self->{h}{CONTENT}{$tagname}}, $args->{data};
  }
  else{
    $self->{h}{CONTENT}{$tagname} = $values;
  }

  return 1;
}

1;
=head1 XML STRUCTURE

This section presents the XML structure used by FusionInventory. The schema
is based on OCS Inventory XML with various additions.

=head2 BIOS

=over 4

=item SMODEL

=item SMANUFACTURER

=item SSN

=item BDATE

=item BVERSION

The BIOS revision

=item BMANUFACTURER

=item MMANUFACTURER

=item MSN

=item MMODEL

=item ASSETTAG

=item ENCLOSURESERIAL

=item BASEBOARDSERIAL

=item BIOSSERIAL

The optional asset tag for this machine.

=back

=head2 CONTROLLERS

=over 4

=item DRIVER

=item NAME

=item MANUFACTURER

=item PCICLASS

=item PCIID

The PCI ID, e.g: 8086:2a40 (only for PCI device)

=item PCISLOT

The PCI slot, e.g: 00:02.1 (only for PCI device)

=item TYPE

The controller revision, e.g: rev 02. This field may be renamed
in the future.

=back

=head2 CPUS

=over 4

=item CACHESIZE

The total CPU cache size in KB. e.g: 3072

=item CORE

Number of core.

=item DESCRIPTION

=item MANUFACTURER

=item NAME

The name of the CPU, e.g: Intel(R) Core(TM)2 Duo CPU     P8600  @ 2.40GHz

=item THREAD

Number of thread.

=item SERIAL

CPU Id/Serial

=item SPEED

Frequency in MHz

=back

=head2 DRIVES

=over 4

=item CREATEDATE

=item DESCRIPTION

=item FREE

=item FILESYSTEM

=item LABEL

=item LETTER

Windows driver letter. Windows only

=item SERIAL

Partition serial number

=item SYSTEMDRIVE

Boolean. Is the system partition?

=item TOTAL

Total space avalaible.

=item TYPE

=item VOLUMN

=back

=head2 HARDWARE

=over 4

=item USERID

The current user list, '/' is the delemiter. This field is deprecated, you
should use the USERS section instead.

=item OSVERSION

=item PROCESSORN

=item OSCOMMENTS

=item CHECKSUM

=item PROCESSORT

=item NAME

=item PROCESSORS

=item SWAP

=item ETIME

=item TYPE

=item OSNAME

=item IPADDR

=item WORKGROUP

=item DESCRIPTION

=item MEMORY

=item UUID

=item DNS

=item LASTLOGGEDUSER

=item USERDOMAIN

This field is deprecated, you should use the USERS section instead.

=item DATELASTLOGGEDUSER

=item DEFAULTGATEWAY

=item VMSYSTEM

The virtualization technologie the machine is a virtual machine.

Can by: Xen, VirtualBox, Virtual Machine, VMware, QEMU, SolarisZone

=item WINOWNER

=item WINPRODID

=item WINPRODKEY

=item WINCOMPANY

=item WINLANG

=back

=head2 MONITORS

=over 4

=item BASE64

=item CAPTION

=item DESCRIPTION

=item MANUFACTURER

=item SERIAL

=item UUENCODE

=back

=head2 PORTS

=over 4

=item CAPTION

=item DESCRIPTION

=item NAME

=item TYPE

=back

=head2 SLOTS

=over 4

=item CAPACITY

=item CAPTION

=item FORMFACTOR

=item REMOVABLE

=item PURPOSE

=item SPEED

=item TYPE

=item DESCRIPTION

=back

=head2 STORAGES

=over 4


=item DESCRIPTION

=item DISKSIZE

=item INTERFACE

=item MANUFACTURER

=item MODEL

=item NAME

=item TYPE

=item SERIAL

=item SERIALNUMBER

=item FIRMWARE

=item SCSI_COID

=item SCSI_CHID

=item SCSI_UNID

=item SCSI_LUN

=back

=head2 SOFTWARES

=over 4

=item COMMENTS

=item FILESIZE

=item FOLDER

=item FROM

=item HELPLINK

=item INSTALLDATE

Installation day in DD/MM/YYYY format. Windows only.

=item NAME

=item NO_REMOVE

=item RELEASE_TYPE

=item PUBLISHER

=item UNINSTALL_STRING

=item URL_INFO_ABOUT

=item VERSION

=item VERSION_MINOR

=item VERSION_MAJOR

=item IS64BIT

=back

=head2 USERS

=over 4

=item LOGIN

=back

=head2 VIDEOS

=over 4

=item CHIPSET

=item MEMORY

=item NAME

=item RESOLUTION

=back

=head2 VIRTUALMACHINES

=over 4

=item MEMORY

=item NAME

=item UUID

=item STATUS

=item SUBSYSTEM

=item VMTYPE

=item VCPU

=item VMID

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

Environement variables

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

=back
