package Ocsinventory::Agent::Task::WakeOnLan;

use strict;
no strict 'refs';
use warnings;


use ExtUtils::Installed;
use Ocsinventory::Agent::Config;
use Ocsinventory::Logger;
use Ocsinventory::Agent::Storage;
use Ocsinventory::Agent::XML::Query::SimpleMessage;
use Ocsinventory::Agent::XML::Response::Prolog;
use Ocsinventory::Agent::Network;
use Ocsinventory::Agent::SNMP;
use Ocsinventory::Agent::Task::NetDiscovery::dico;

use Ocsinventory::Agent::AccountInfo;

sub main {
    my ( undef ) = @_;


    eval "use Net::Wake;";
    exit(1) if $@;

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

   my $macaddress = $self->{WAKEONLAN}->{PARAM}->[0]->{MAC};
   my $ip         = $self->{WAKEONLAN}->{PARAM}->[0]->{IP};

   Net::Wake::by_udp($ip, $macaddress, 9);  
}


1;
