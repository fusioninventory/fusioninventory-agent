package FusionInventory::Agent::Task::WakeOnLan;

use strict;
use warnings;
use base 'FusionInventory::Agent::Task::Base';

use constant ETH_P_ALL => 0x0003;
use constant PF_PACKET => 17;
use constant SOCK_PACKET => 10;

use English qw(-no_match_vars);
use Socket;

use FusionInventory::Agent::AccountInfo;
use FusionInventory::Agent::Config;
use FusionInventory::Agent::Network;
use FusionInventory::Agent::Storage;
use FusionInventory::Agent::XML::Query::SimpleMessage;
use FusionInventory::Agent::XML::Response::Prolog;
use FusionInventory::Logger;

sub main {
    my $self = FusionInventory::Agent::Task::WakeOnLan->new();

    my $continue = 0;
    foreach my $num (@{$self->{prologresp}->{parsedcontent}->{OPTION}}) {
        if (defined($num)) {
            if ($num->{NAME} eq "WAKEONLAN") {
                $continue = 1;
                $self->{WAKEONLAN} = $num;
            }
        }
    }
    if ($continue == 0) {
        $self->{logger}->debug("No WAKEONLAN. Exiting...");
        exit(0);
    }

    if ($self->{target}->{type} ne 'server') {
        $self->{logger}->debug("No server. Exiting...");
        exit(0);
    }

    $self->{network} = FusionInventory::Agent::Network->new({
        logger => $self->{logger},
        config => $self->{config},
        target => $self->{target},
    });

    $self->StartMachine();

    exit(0);
}


sub StartMachine {
    my ($self, $params) = @_;

    my $macaddress = $self->{WAKEONLAN}->{PARAM}->[0]->{MAC};
    my $ip         = $self->{WAKEONLAN}->{PARAM}->[0]->{IP};

    my $logger = $self->{logger};

    return unless defined $macaddress;

    my $byte = '[0-9A-F]{2}';
    if ($macaddress !~ /^$byte:$byte:$byte:$byte:$byte:$byte$/i) {
        $self->{logger}->debug("Invalid MacAddress $macaddress . Exiting...");
        exit(0);
    }
    $macaddress =~ s/://g;

    ###  for LINUX ONLY ###
    if ( eval { socket(SOCKET, PF_PACKET, SOCK_PACKET, 0); }) {

        setsockopt(SOCKET, SOL_SOCKET, SO_BROADCAST, 1)
            or warn "Can't do setsockopt: $ERRNO\n";

        open my $handle, '-|', '/sbin/ifconfig -a'
            or $logger->fault("Can't run /sbin/ifconfig: $ERRNO");
        while (my $line = <$handle>) {
            next unless $line =~ /(\S+) \s+ Link \s \S+ \s+ HWaddr \s (\S+)/x;
            my $netName = $1;
            my $netMac = $2;
            $logger->debug(
                "Send magic packet to $macaddress directly on card driver"
            );
            $netMac =~ s/://g;

            my $magic_packet =
                (pack('H12', $macaddress)) .
                (pack('H12', $netMac)) .
                (pack('H4', "0842"));
            $magic_packet .= chr(0xFF) x 6 . (pack('H12', $macaddress) x 16);
            my $destination = pack("Sa14", 0, $netName);
            send(SOCKET, $magic_packet, 0, $destination)
                or warn "Couldn't send packet: $ERRNO";
        }
        close $handle;
        # TODO : For FreeBSD, send to /dev/bpf ....
    } else { # degraded wol by UDP
        if ( eval { socket(SOCKET, PF_INET, SOCK_DGRAM, getprotobyname('udp')) }) {
            my $magic_packet = 
                chr(0xFF) x 6 .
                (pack('H12', $macaddress) x 16);
            my $sinbroadcast = sockaddr_in("9", inet_aton("255.255.255.255"));
            $logger->debug(
                "Send magic packet to $macaddress in UDP mode (degraded wol)"
            );
            send(SOCKET, $magic_packet, 0, $sinbroadcast);
        } else {
            $logger->debug("Impossible to send magic packet...");
        }
    }

    # For Windows, I don't know, just test
    # See http://msdn.microsoft.com/en-us/library/ms740548(VS.85).aspx
}

1;
