package Ocsinventory::XML::Inventory;
use strict;
use Data::Dumper;
sub new {

  my $self = {};

  $self->{h}{CONTENT}{CONTROLLERS} = [];
  $self->{h}{CONTENT}{STORAGES} = [];
  $self->{h}{CONTENT}{BIOS} = {};
  $self->{h}{CONTENT}{DRIVES} = [];
  $self->{h}{CONTENT}{HARDWARE} = {};
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
  my $description =  $args->{DESCRIPTION};
  my $name = $args->{NAME};
  my $type = $args->{TYPE};


  push @{$self->{h}{CONTENT}{MEMORIES}},
  {

    CAPTION => [$caption?$caption:"??"],
    DESCRIPTION => [$description?$description:"??"],
    NAME => [$name?$name:"??"],
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
      $self->{h}{'CONTENT'}{'HARDWARE'}{$key}[0] = $args->{$key};
    }
  }
}



1;
