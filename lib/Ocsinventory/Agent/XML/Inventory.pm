package Ocsinventory::Agent::XML::Inventory;

use strict;
use warnings;

use Data::Dumper; # XXX Debug
use XML::Simple;
use Digest::MD5 qw(md5_base64);

sub new {
  my (undef,$params) = @_;

  my $self = {};
  $self->{accountinfo} = $params->{accountinfo};
  $self->{params} = $params->{params};
  my $logger = $self->{logger} = $params->{logger};

  if (!($self->{params}{deviceid})) {
    $logger->fault ('deviceid unititalised!');
  }

  $self->{h}{QUERY} = ['INVENTORY']; 
  $self->{h}{DEVICEID} = [$self->{params}->{deviceid}]; 
  $self->{h}{CONTENT}{ACCESSLOG} = {};
  $self->{h}{CONTENT}{BIOS} = {};
  $self->{h}{CONTENT}{CONTROLLERS} = [];
  $self->{h}{CONTENT}{DRIVES} = [];
  $self->{h}{CONTENT}{HARDWARE} = {};
  $self->{h}{CONTENT}{MONITORS} = [];
  $self->{h}{CONTENT}{PORTS} = [];
  $self->{h}{CONTENT}{SLOTS} = [];
  $self->{h}{CONTENT}{STORAGES} = [];
  $self->{h}{CONTENT}{SOFTWARES} = [];
  $self->{h}{CONTENT}{VIDEOS} = [];
  $self->{h}{CONTENT}{SOUNDS} = [];
  $self->{h}{CONTENT}{MODEMS} = [];

  bless $self;
}

sub dump {
  my $self = shift;
  require Data::Dumper;
  print Data::Dumper($self->{h});

}

sub addController {
  my ($self, $args) = @_;

  my $name = $args->{NAME};
  my $manufacturer = $args->{MANUFACTURER};
  my $type = $args->{TYPE};

  push @{$self->{h}{CONTENT}{CONTROLLERS}},
  {

    NAME => [$name],
    MANUFACTURER => [$manufacturer],
    TYPE => [$type],

  };
}

sub addModems {
  my ($self, $args) = @_;

  my $description = $args->{DESCRIPTION};
  my $name = $args->{NAME};

  push @{$self->{h}{CONTENT}{MODEMS}},
  {

    DESCRIPTION => [$description],
    NAME => [$name],

  };
}

sub addDrives {
  my ($self, $args) = @_;

  my $free = $args->{FREE};
  my $filesystem = $args->{FILESYSTEM};
  my $total = $args->{TOTAL};
  my $type = $args->{TYPE};
  my $volumn = $args->{VOLUMN};

  push @{$self->{h}{CONTENT}{DRIVES}},
  {
    FREE => [$free?$free:"??"],
    FILESYSTEM => [$filesystem?$filesystem:"??"],
    TOTAL => [$total?$total:"??"],
    TYPE => [$type?$type:"??"],
    VOLUMN => [$volumn?$volumn:"??"]
  };
}

sub addStorages {
  my ($self, $args) = @_;

  my $description = $args->{DESCRIPTION};
  my $disksize =  $args->{DISKSIZE};
  my $manufacturer = $args->{MANUFACTURER};
  my $model = $args->{MODEL};
  my $name = $args->{NAME};
  my $type = $args->{TYPE};


  push @{$self->{h}{CONTENT}{STORAGES}},
  {

    DESCRIPTION => [$description?$description:"??"],
    DISKSIZE => [$disksize?$disksize:"??"],
    MANUFACTURER => [$manufacturer?$manufacturer:"??"],
    MODEL => [$model?$model:"??"],
    NAME => [$name?$name:"??"],
    TYPE => [$type?$type:"??"],

  };
}

sub addMemories {
  my ($self, $args) = @_;

  my $capacity = $args->{CAPACITY};
  my $speed =  $args->{SPEED};
  my $type = $args->{TYPE};
  my $description = $args->{DESCRIPTION};
  my $numslots = $args->{NUMSLOTS};


  push @{$self->{h}{CONTENT}{MEMORIES}},
  {

    CAPACITY => [$capacity?$capacity:"??"],
    DESCRIPTION => [$description?$description:"??"],
    NUMSLOTS => [$numslots?$numslots:"??"],
    SPEED => [$speed?$speed:"??"],
    TYPE => [$type?$type:"??"],

  };
}

sub addPorts {
  my ($self, $args) = @_;

  my $caption = $args->{CAPTION};
  my $description = $args->{DESCRIPTION};
  my $name = $args->{NAME};
  my $type = $args->{TYPE};


  push @{$self->{h}{CONTENT}{PORTS}},
  {

    CAPTION => [$caption?$caption:"??"],
    DESCRIPTION => [$description?$description:"??"],
    NAME => [$name?$name:"??"],
    TYPE => [$type?$type:"??"],

  };
}

sub addSlots {
  my ($self, $args) = @_;

  my $description = $args->{DESCRIPTION};
  my $designation = $args->{DESIGNATION};
  my $name = $args->{NAME};
  my $status = $args->{STATUS};


  push @{$self->{h}{CONTENT}{SLOTS}},
  {

    DESCRIPTION => [$description?$description:"??"],
    DESIGNATION => [$designation?$designation:"??"],
    NAME => [$name?$name:"??"],
    STATUS => [$status?$status:"??"],

  };
}

sub addSoftwares {
  my ($self, $args) = @_;

  my $comments = $args->{COMMENTS};
  my $name = $args->{NAME};
  my $version = $args->{VERSION};


  push @{$self->{h}{CONTENT}{SOFTWARES}},
  {

    COMMENTS => [$comments?$comments:"??"],
    NAME => [$name?$name:"??"],
    VERSION => [$version?$version:"??"],

  };
}

sub addMonitors {
  my ($self, $args) = @_;

  my $caption = $args->{CAPTION};
  my $manufacturer = $args->{MANUFACTURER};
  my $description = $args->{DESCRIPTION};


  push @{$self->{h}{CONTENT}{MONITORS}},
  {

    CAPTION => [$caption?$caption:"??"],
    MANUFACTURER => [$manufacturer?$manufacturer:"??"],
    DESCRIPTION => [$description?$description:"??"],

  };
}

sub addVideos {
  my ($self, $args) = @_;

  my $chipset = $args->{CHIPSET};
  my $name = $args->{NAME};

  push @{$self->{h}{CONTENT}{VIDEOS}},
  {

    CHIPSET => [$chipset?$chipset:"??"],
    NAME => [$name?$name:"??"],

  };
}

sub addSounds {
  my ($self, $args) = @_;

  my $description = $args->{DESCRIPTION};
  my $manufacturer = $args->{MANUFACTURER};
  my $name = $args->{NAME};

  push @{$self->{h}{CONTENT}{SOUNDS}},
  {

    DESCRIPTION => [$description?$description:"??"],
    MANUFACTURER => [$manufacturer?$manufacturer:"??"],
    NAME => [$name?$name:"??"],

  };
}

sub addNetworks {
  # TODO IPSUBNET, IPMASK IPADDRESS seem to be missing.
  my ($self, $args) = @_;

  my $description = $args->{DESCRIPTION};
  my $ipaddress = $args->{IPADDRESS};
  my $ipdhcp = $args->{IPDHCP};
  my $ipgateway = $args->{IPGATEWAY};
  my $ipmask = $args->{IPMASK};
  my $ipsubnet = $args->{IPSUBNET};
  my $macaddr = $args->{MACADDR};
  my $status = $args->{STATUS};
  my $type = $args->{TYPE};

  push @{$self->{h}{CONTENT}{NETWORKS}},
  {

    DESCRIPTION => [$description?$description:"??"],
    IPADDRESS => [$ipaddress?$ipaddress:"??"],
    IPDHCP => [$ipdhcp?$ipdhcp:"??"],
    IPGATEWAY => [$ipgateway?$ipgateway:"??"],
    IPMASK => [$ipmask?$ipmask:"??"],
    IPSUBNET => [$ipsubnet?$ipsubnet:"??"],
    MACADDR => [$macaddr?$macaddr:"??"],
    STATUS => [$status?$status:"??"],
    TYPE => [$type?$type:"??"],

  };
}

sub setHardware {
  my ($self, $args) = @_;

  foreach my $key (qw/USERID OSVERSION PROCESSORN OSCOMMENTS CHECKSUM
    PROCESSORT NAME PROCESSORS SWAP ETIME TYPE OSNAME IPADDR WORKGROUP
    DESCRIPTION MEMORY/) {

    if (exists $args->{$key}) {
      $self->{h}{'CONTENT'}{'HARDWARE'}{$key}[0] = $args->{$key};
    }
  }
}

sub setBios {
  my ($self, $args) = @_;

  foreach my $key (qw/SMODEL SMANUFACTURER BDATE SSN BVERSION BMANUFACTURER/) {

    if (exists $args->{$key}) {
      $self->{h}{'CONTENT'}{'BIOS'}{$key}[0] = $args->{$key};
    }
  }
}

sub setAccessLog {
  my ($self, $args) = @_;

  foreach my $key (qw/USERID LOGDATE/) {

    if (exists $args->{$key}) {
      $self->{h}{'CONTENT'}{'ACCESSLOG'}{$key}[0] = $args->{$key};
    }
  }
}

sub content {
  my ($self, $args) = @_;

  my $logger = $self->{logger};

  #  checks for MAC, NAME and SSN presence
  my $macaddr = $self->{h}->{CONTENT}->{NETWORKS}->[0]->{MACADDR}->[0];
  my $ssn = $self->{h}->{CONTENT}->{BIOS}->{SSN}->[0];
  my $name = $self->{h}->{CONTENT}->{HARDWARE}->{NAME}->[0];

  my $missing;

  $missing .= "MAC-address " unless $macaddr;
  $missing .= "SSN " unless $ssn;
  $missing .= "HOSTNAME " unless $name;

  if ($missing) {
    $logger->fault('Missing value(s): '.$missing.'. I don\' send this inventory to the server since important value(s) to identify the computer are missing');
  }

  $self->{accountinfo}->setAccountInfo($self);
  
  my $content = XMLout( $self->{h}, RootName => 'REQUEST', XMLDecl => '<?xml version="1.0" encoding="ISO-8859-1"?>', SuppressEmpty => undef );

  return $content;
}

sub writeXML {
  my ($self, $args) = @_;

  my $logger = $self->{logger};

  if ($self->{params}{local} =~ /^$/) {
    $logger->fault ('local path unititalised!');
  }

  my $localfile = $self->{params}{local}."/".$self->{params}{deviceid};
  $localfile =~ s!(//){1,}!/!;

  # Convert perl data structure into xml strings

  if (open OUT, ">$localfile") {
    print OUT $self->content();
    close OUT or warn;
    $logger->info("Inventory saved in $localfile");
  } else {
    warn "Can't open `$localfile': $!"
  }
}

sub processChecksum {
  my $self = shift;

  my $logger = $self->{logger};
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
    'SOFTWARES'     => 65536
  );

  if (!$self->{params}->{vardir}) {
    $logger->fault ("vardir uninitialised!");
  }

  my $last_state_content;
  my $checksum = 0;

  if (! -f $self->{params}->{last_statefile}) {
    $logger->info ('laste_state file: `'.
	$self->{params}->{last_statefile}."' doesn't exist.");
  }
  if (-f $self->{params}->{last_statefile}) {
    # TODO: avoid a violant death in case of problem with XML
    $last_state_content = XML::Simple::XMLin(

      $self->{params}->{last_statefile},
      SuppressEmpty => undef,
      ForceArray => 1

    );
  } else {
    $logger->debug ('last_state file: `'.
	$self->{params}->{last_statefile}.
	"' doesn't exist.");
  }

  foreach my $section (keys %mask) {
    #If the checksum has changed...
    my $hash = md5_base64(XML::Simple::XMLout($self->{h}{'CONTENT'}{$section}));
    if (!$last_state_content->{$section}[0] || $last_state_content->{$section}[0] ne $hash ) {
      $logger->debug ("Section $section has changed since last inventory");
      #We made OR on $checksum with the mask of the current section
      $checksum |= $mask{$section};
      # Finally I store the new value.
      $last_state_content->{$section}[0] = $hash; #TODO, I've to store the new HASH
    }
  }

  if (open LAST_STATE, ">".$self->{params}->{last_statefile}) {
    print LAST_STATE my $string = XML::Simple::XMLout( $last_state_content, RootName => 'LAST_STATE' );;
    close LAST_STATE or warn;
  } else {
    $logger->error ("Cannot save the checksum values in ".$self->{params}->{last_statefile}."
	(will be synchronized by GLPI!!): $!"); 
  }

  $self->setHardware({CHECKSUM => $checksum});
}


1;
