package Ocsinventory::XML::Inventory;
use strict;
use Data::Dumper;
use XML::Simple;
use Digest::MD5 qw(md5_base64);

sub new {
  my (undef,$params) = @_;

  my $self = {};
  $self->{params} = $params;

  $self->{h}{CONTENT}{ACCESSLOG} = {};
  $self->{h}{CONTENT}{BIOS} = {};
  $self->{h}{CONTENT}{CONTROLLERS} = [];
  $self->{h}{CONTENT}{DRIVES} = [];
  $self->{h}{CONTENT}{HARDWARE} = {};
  $self->{h}{CONTENT}{PORTS} = [];
  $self->{h}{CONTENT}{SLOTS} = [];
  $self->{h}{CONTENT}{STORAGES} = [];

  bless $self;
}

sub dump {
  my $self = shift;
  print Dumper($self->{h});

}

sub addControler {
  my ($self, $args) = @_;

#  die unless ($args->{NAME} && $args->{MANUFACTURER} && $args->{TYPE});

  push @{$self->{h}{CONTENT}{CONTROLLERS}},
  {
    NAME => [$args->{NAME}],
    MANUFACTURER => [$args->{MANUFACTURER}],
    TYPE => [$args->{TYPE}],

  };
}

sub addStorages {
  my ($self, $args) = @_;

#  die unless ($args->{NAME} && $args->{MANUFACTURER} && $args->{TYPE});

  my $description = $args->{DESCRIPTION};
  my $disksize =  $args->{DISKSIZE};
  my $manufacturer = $args->{MANUFACTURER};
  my $model = $args->{MODEL};
  my $type = $args->{TYPE};


  push @{$self->{h}{CONTENT}{STORAGES}},
  {

    DESCRIPTION => [$description?$description:"??"],
    DISKSIZE => [$disksize?$disksize:"??"],
    MANUFACTURER => [$manufacturer?$manufacturer:"??"],
    MODEL => [$model?$model:"??"],
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

sub processChecksum {
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
    'INPUT'        => 1024,
    'MODEM'        => 2048,
    'NETWORKS'      => 4096,
    'PRINTERS'      => 8192,
    'SOUNDS'        => 16384,
    'VIDEOS'        => 32768,
    'SOFTWARES'     => 65536
  );


  my $self = shift;
  my $last_state;
  my $checksum = 0;

  if (-f $self->{params}{"last_state"}) {
    # TODO: avoid a violant death in case of problem with XML
    $last_state = XML::Simple::XMLin($self->{params}{"last_state"},
      SuppressEmpty => undef, ForceArray => [
      'HARDWARE', 'BIOS', 'MEMORIES', 'SLOTS', 'REGISTRY', 'CONTROLLERS',
      'MONITORS', 'PORTS', 'STORAGES', 'DRIVES', 'INPUT', 'MODEM', 'NETWORKS',
      'PRINTERS', 'SOUNDS', 'VIDEOS', 'SOFTWARES' ] );
  }

  foreach my $section (keys %mask) {
    #If the checksum has changed...
    my $hash = md5_base64(XML::Simple::XMLout($self->{h}{'CONTENT'}{$section}));
    if (!$last_state || $last_state->{$section}[0] ne $hash ) {
      print "Section $section has changed since last inventory( New hash--> ".$hash.")\n" if $self->{params}{debug};
      #We made OR on $checksum with the mask of the current section
      $checksum |= $mask{$section};
      # Finally I store the new value.
      $last_state->{$section}[0] = $hash;
    }
  }

  open LAST_STATE, ">".$self->{params}{"last_state"} or warn "Cannot save
  the checksum values in ".$self->{params}{"last_state"}." (will be synchronized by GLPI!!): $!\n";
  print LAST_STATE my $string = XML::Simple::XMLout( $last_state, RootName => 'LAST_STATE' );;
  close LAST_STATE or warn;

  print $checksum."\n";
  $self->setHardware({CHECKSUM => $checksum});
}

1;
