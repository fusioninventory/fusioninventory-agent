package Ocsinventory::Agent::Task::WakeOnLan;

use strict;
no strict 'refs';
use warnings;

use Net::Wake;


sub main {
    my ( undef ) = @_;

    my $self = {};
    bless $self;

    my $storage = new Ocsinventory::Agent::Storage({
            target => {
                vardir => $ARGV[0],
            }
        });

    my $data = $storage->restore("Ocsinventory::Agent");
    $self->{data} = $data;
    my $myData = $self->{myData} = $storage->restore(__PACKAGE__);

    my $config = $self->{config} = $data->{config};
    my $target = $self->{'target'} = $data->{'target'};
    my $logger = $self->{logger} = new Ocsinventory::Logger ({
            config => $self->{config}
        });
    $self->{prologresp} = $data->{prologresp};

    my $continue = 0;
    foreach my $num (@{$self->{'prologresp'}->{'parsedcontent'}->{OPTION}}) {
      if (defined($num)) {
        if ($num->{NAME} eq "WAKEONLAN") {
            $continue = 1;
            $self->{WAKEONLAN} = $num;
        }
      }
    }
    if ($continue eq "0") {
        $logger->debug("No WAKEONLAN. Exiting...");
        exit(0);
    }

    if ($target->{'type'} ne 'server') {
        $logger->debug("No server. Exiting...");
        exit(0);
    }

    my $network = $self->{network} = new Ocsinventory::Agent::Network ({

            logger => $logger,
            config => $config,
            target => $target,

        });

   $self->StartMachine();

   exit(0);
}


sub StartMachine {
   my ($self, $params) = @_;

   my $macaddress =  $self->{WAKEONLAN}->{PARAM}->[0]->{MAC};

   my $start = new Net::Wake;
   $start->by_udp(undef,$macaddress);
   
}


1;