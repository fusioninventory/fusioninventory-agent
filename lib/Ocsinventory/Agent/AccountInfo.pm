package Ocsinventory::Agent::AccountInfo;

use strict;
use warnings;

use Data::Dumper; # XXX Debug

sub new {
  my (undef,$params) = @_;

  my $self = {};

  $self->{params} = $params->{params};
  $self->{logger} = $params->{logger};

  my $logger = $self->{logger} = $params->{logger};

  $logger->log ({

      level => 'debug',
      message => 'Accountinfo file: '. $self->{params}->{accountinfofile}

    });

  if (! -f $self->{params}->{accountinfofile}) {
      $logger->log ({

	  level => 'info',
	  message => "Accountinfo file doesn't exist. (yet)"

	});
  } else {

    my $xmladm = XML::Simple::XMLin(
      $self->{params}->{accountinfofile},
      ForceArray => [ 'ACCOUNTINFO' ]
    );

    # Store the XML content in a local HASH
    for(@{$xmladm->{ACCOUNTINFO}}){
      if (!$_->{KEYNAME}) {

	$logger->log ({

	  level => 'debug',
	  message => "Incorrect KEYNAME in ACCOUNTINFO"

	});

      }
      $self->{accountinfo}{ $_->{KEYNAME} } = $_->{KEYVALUE};
    }
  }

  bless $self;
}

sub get {
  my ($self, $keyname) = @_;

  return $self->{accountinfo}{$keyname} if $keyname;
}

sub getAll {
  my ($self, $name) = @_;

  return $self->{accountinfo};
}

sub set {
  die;
  my ($self, $name, $value) = @_;

  $self->{accountinfo}->{$name} = $value;
  $self->write();
}

sub reSetAll {
  die;
  my ($self, $hash) = @_;

  foreach (keys %$hash) {
    $self->set($_, $hash->{$_});
    print "$_ => $hash->{$_}\n";
  }
}


sub write {
  my ($self, $args) = @_;
  
  my $logger = $self->{logger};

  my $tmp;
  $tmp->{ACCOUNTINFO} = [];

  foreach (keys %{$self->{accountinfo}}) {
    push @{$tmp->{ACCOUNTINFO}}, {KEYNAME => [$_], KEYVALUE =>
      [$self->{accountinfo}{$_}]}; 
  }

  my $xml=XML::Simple::XMLout( $tmp, RootName => 'ADM',
    NoSort => 1 );


  my $fault;
  if (!open ADM, ">".$self->{params}->{accountinfofile}) {

    $fault = 1;

  } else {

    print ADM $xml;
    $fault = 1 unless close ADM;

  }

  if (!$fault) {

    $logger->log ({

	level => 'debug',
	message => "Account info updated successfully"

      });

  } else {

    $logger->log ({

	level => 'error',
	message => "Can't save account info in `$self->{params}->{accountinfofile}'"

      });
  }
}

1;
