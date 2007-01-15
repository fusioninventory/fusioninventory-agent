package Ocsinventory::Agent::Config;
use strict;
use warnings;

use Data::Dumper; # XXX Debug

sub new {
  my (undef,$params) = @_;

  my $self = {};

  $self->{params} = $params->{params};
  my $logger = $self->{logger} = $params->{logger};

  # Configuration reading
  $self->{xml} = {};

  if (! -f $self->{params}->{conffile}) {
      $logger->log ({

	  level => 'info',
	  message => 'conffile file: `'. $self->{params}->{conffile}."' doesn't exist."

	});
  } else {
    $self->{xml} = XML::Simple::XMLin(
      $self->{params}->{conffile},
      SuppressEmpty => undef
    );
  }

  bless $self;
}

sub get {
  my ($self, $name) = @_;

  my $logger = $self->{logger};

  return $self->{xml}->{$name} if $name;
  return $self->{xml};
}

sub set {
  my ($self, $name, $value) = @_;

  my $logger = $self->{logger};

  $self->{xml}->{$name} = $value;
  $self->write(); # save the change
}


sub write {
  my ($self, $args) = @_;

  my $logger = $self->{logger};

  my $xml = XML::Simple::XMLout( $self->{xml} , RootName => 'CONF',
    NoAttr => 1 );

  my $fault;
  if (!open CONF, ">".$self->{params}->{conffile}) {

    $fault = 1;

  } else {

    print CONF $xml;
    $fault = 1 if (!close CONF);

  }

  if (!$fault) {

    $logger->log ({

	level => 'debug',
	message => "ocsinv.conf updated successfully"

      });

  } else {

    $logger->log ({

	level => 'error',
	message => "Can't save setting change in `$self->{params}->{conffile}'"

      });
  }
}

1;
