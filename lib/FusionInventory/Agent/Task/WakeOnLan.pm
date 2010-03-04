package FusionInventory::Agent::Task::WakeOnLan;

use strict;
no strict 'refs';
use warnings;

use constant ETH_P_ALL => 0x0003;
use constant PF_PACKET => 17;
use constant SOCK_PACKET => 10;

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
    my $target = $self->{target} = $data->{'target'};
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

   if ($macaddress !~ /^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$/) {
      $self->{logger}->debug("Invalid MacAddress. Exiting...");
      exit(0);
   }
   $macaddress =~ s/://g;

   ###  for LINUX ONLY ###
   if ( eval { socket(SOCKET, PF_PACKET, SOCK_PACKET, 0); }) {

      setsockopt(SOCKET, SOL_SOCKET, SO_BROADCAST, 1) or warn "Can't do setsockopt: $!\n";

      my $rec = `/sbin/ifconfig -a | grep "HWaddr"`;
      my @netcards = split(/\n/, $rec);
      foreach (@netcards) {
         my ($netName, $field2, $field3, $field4, $netMac) = split(/\s+/, $_);

         $netMac =~ s/://g;

         my $magic_packet = (pack('H12', $macaddress)) . (pack('H12', $netMac)) . (pack('H4', "0842"));
         $magic_packet .= chr(0xFF) x 6 . (pack('H12', $macaddress) x 16);
         my $destination = pack("Sa14", 0, $netName);
         send(SOCKET, $magic_packet, 0, $destination) or warn "Couldn't send packet: $!";
      }
# TODO : For FreeBSD, send to /dev/bpf ....
   } else { # degraded wol by UDP
      if ( eval { socket(SOCKET, PF_INET, SOCK_DGRAM, getprotobyname('udp')) }) {
         my $magic_packet = chr(0xFF) x 6 . (pack('H12', $macaddress) x 16);
         my $sinbroadcast = sockaddr_in("9", inet_aton("255.255.255.255"));
         send(SOCKET, $magic_packet, 0, $sinbroadcast);
      } else {
         $self->{logger}->debug("Impossible to send magic packet...");
      }
   }


# For Windows, I don't know, just test
# See http://msdn.microsoft.com/en-us/library/ms740548(VS.85).aspx

}


1;