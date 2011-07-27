package FusionInventory::Agent::Task::WakeOnLan;

use strict;
use warnings;
use base 'FusionInventory::Agent::Task';

use constant ETH_P_ALL => 0x0003;
use constant PF_PACKET => 17;
use constant SOCK_PACKET => 10;

use English qw(-no_match_vars);
use Socket;

use FusionInventory::Agent::Tools::Regexp;

our $VERSION = '1.0';

sub run {
    my ($self) = @_;

    if (!$self->{target}->isa('FusionInventory::Agent::Target::Server')) {
        $self->{logger}->debug("No server. Exiting...");
        return;
    }

    my $response = $self->{prologresp};
    if (!$response) {
        $self->{logger}->debug("No server response. Exiting...");
        return;
    }

    my $options = $response->getOptionsInfoByName('WAKEONLAN');
    if (!$options) {
        $self->{logger}->debug(
            "No wake on lan requested in the prolog, exiting"
        );
        return;
    }

    my $macaddress = $self->{WAKEONLAN}->{PARAM}->[0]->{MAC};

    return unless defined $macaddress;

    if ($macaddress !~ /^$mac_address_pattern$/) {
        die "invalid MAC address $macaddress, exiting";
    }
    $macaddress =~ s/://g;

    # Linux only
    eval {
        socket(SOCKET, PF_PACKET, SOCK_PACKET, 0);

        setsockopt(SOCKET, SOL_SOCKET, SO_BROADCAST, 1)
            or warn "Can't do setsockopt: $ERRNO\n";

        open my $handle, '-|', '/sbin/ifconfig -a'
            or die "Can't run /sbin/ifconfig: $ERRNO";
        while (my $line = <$handle>) {
            next unless $line =~ /(\S+) \s+ Link \s \S+ \s+ HWaddr \s (\S+)/x;
            my $netName = $1;
            my $netMac = $2;
            $self->{logger}->debug(
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
    };

    return unless $EVAL_ERROR;

    # degraded WOL by UDP
    eval {
        socket(SOCKET, PF_INET, SOCK_DGRAM, getprotobyname('udp'));
        my $magic_packet = 
            chr(0xFF) x 6 .
            (pack('H12', $macaddress) x 16);
        my $sinbroadcast = sockaddr_in("9", inet_aton("255.255.255.255"));
        $self->{logger}->debug(
            "Send magic packet to $macaddress in UDP mode (degraded wol)"
        );
        send(SOCKET, $magic_packet, 0, $sinbroadcast);
    };

    return unless $EVAL_ERROR;

    $self->{logger}->debug("Impossible to send magic packet...");

    # For Windows, I don't know, just test
    # See http://msdn.microsoft.com/en-us/library/ms740548(VS.85).aspx
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Task::WakeOnLan - Wake-on-lan task for FusionInventory 

=head1 DESCRIPTION

This task send a wake-on-lan packet to another host on the same network as the
agent host.
