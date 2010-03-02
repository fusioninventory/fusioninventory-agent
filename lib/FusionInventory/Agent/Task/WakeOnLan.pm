package FusionInventory::Agent::Task::WakeOnLan;

use strict;
no strict 'refs';
use warnings;

use Socket;
use ExtUtils::Installed;
use FusionInventory::Agent::Config;
use FusionInventory::Logger;
use FusionInventory::Agent::Storage;
use FusionInventory::Agent::XML::Query::SimpleMessage;
use FusionInventory::Agent::XML::Response::Prolog;
use FusionInventory::Agent::Network;

use FusionInventory::Agent::AccountInfo;

sub main {
    my ( undef ) = @_;

   my $self = {};
    bless $self;

    my $storage = new FusionInventory::Agent::Storage({
            target => {
                vardir => $ARGV[0],
            }
        });

    my $data = $storage->restore("FusionInventory::Agent");
    $self->{data} = $data;
    my $myData = $self->{myData} = $storage->restore(__PACKAGE__);

    my $config = $self->{config} = $data->{config};
    my $target = $self->{'target'} = $data->{'target'};
    my $logger = $self->{logger} = new FusionInventory::Logger ({
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

    my $network = $self->{network} = new FusionInventory::Agent::Network ({

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

# for LINUX ONLY:
   socket(SOCKET, PF_PACKET, SOCK_PACKET, 0) or die "Couldn't create raw socket: $!";

   setsockopt(SOCKET, SOL_SOCKET, SO_BROADCAST, 1) or warn "Can't do setsockopt: $!\n";

   # TODO : get mac adress of eth0
   my $macaddresseth0 = "";

   $macaddress =~ s/://g;
   $macaddresseth0 =~ s/://g;

   my $magic_packet = (pack('H12', $macaddress)) . (pack('H12', $macaddresseth0)) . (pack('H4', "0842"));
   $magic_packet .= chr(0xFF) x 6 . (pack('H12', $macaddress) x 16);
   my $destination = pack("Sa14", 0, "eth0");
   send(SOCKET, $magic_packet, 0, $destination) or die "Couldn't send packet: $!";


# For FreeBSD, send to /dev/bpf ....


# For Windows, I don't know, just test
# See http://msdn.microsoft.com/en-us/library/ms740548(VS.85).aspx

}


1;
