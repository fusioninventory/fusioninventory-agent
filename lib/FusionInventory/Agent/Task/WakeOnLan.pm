package FusionInventory::Agent::Task::WakeOnLan;

use strict;
use warnings;
use base 'FusionInventory::Agent::Task';

use constant ETH_P_ALL => 0x0003;
use constant PF_PACKET => 17;
use constant SOCK_PACKET => 10;

use English qw(-no_match_vars);
use List::Util qw(first);
use Socket;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Network;

our $VERSION = '1.0';

sub isEnabled {
    my ($self, $response) = @_;

    return unless
        $self->{target}->isa('FusionInventory::Agent::Target::Server');

    my $options = $self->getOptionsFromServer(
        $response, 'WAKEONLAN', 'WakeOnLan'
    );
    return unless $options;

    my $target = $options->{PARAM}->[0]->{MAC};
    if (!$target) {
        $self->{logger}->debug("No mac address defined in the prolog response");
        return;
    }

    if (!$target !~ /^$mac_address_pattern$/) {
        $self->{logger}->debug("invalid MAC address $target");
        return;
    }

    $self->{options} = $options;
    return 1;
}

sub run {
    my ($self, %params) = @_;

    $self->{logger}->debug("FusionInventory WakeOnLan task $VERSION");

    my $options = $self->{options};
    my $target  = $options->{PARAM}->[0]->{MAC};
    $target =~ s/://g;

    my @methods = $params{methods} ? @{$params{methods}} : qw/ethernet udp/;

    foreach my $method (@methods) {
        eval {
            my $function = '_send_magic_packet_' . $method;
            $self->$function($target);
        };
        return unless $EVAL_ERROR;
        $self->{logger}->error(
            "Impossible to use $method magic packet: $EVAL_ERROR"
        );
    }

    # For Windows, I don't know, just test
    # See http://msdn.microsoft.com/en-us/library/ms740548(VS.85).aspx
}

sub _send_magic_packet_ethernet {
    my ($self,  $target) = @_;

    socket(SOCKET, PF_PACKET, SOCK_PACKET, 0)
        or die "can't open socket: $ERRNO\n";
    setsockopt(SOCKET, SOL_SOCKET, SO_BROADCAST, 1)
        or die "can't do setsockopt: $ERRNO\n";

    SWITCH: {
        if ($OSNAME eq 'linux') {
            FusionInventory::Agent::Tools::Linux->use();
            last;
        }
        if ($OSNAME =~ /freebsd|openbsd|netbsd|gnukfreebsd|gnuknetbsd|dragonfly/) {
            FusionInventory::Agent::Tools::BSD->use();
            last;
        }
    }
    my $interface =
        first { $_->{MACADDR} }
        getInterfacesFromIfconfig(logger => $self->{logger});
    my $source = $interface->{MACADDR};
    $source =~ s/://g;

    my $magic_packet =
        (pack('H12', $target)) .
        (pack('H12', $source)) .
        (pack('H4', "0842"));
    $magic_packet .= chr(0xFF) x 6 . (pack('H12', $target) x 16);
    my $destination = pack("Sa14", 0, $interface->{DESCRIPTION});

    $self->{logger}->debug(
        "Sending magic packet to $target as ethernet frame"
    );
    send(SOCKET, $magic_packet, 0, $destination)
        or die "can't send packet: $ERRNO\n";
    close(SOCKET);
}

sub _send_magic_packet_udp {
    my ($self,  $target) = @_;

    socket(SOCKET, PF_INET, SOCK_DGRAM, getprotobyname('udp'))
        or die "can't open socket: $ERRNO\n";
    setsockopt(SOCKET, SOL_SOCKET, SO_BROADCAST, 1)
        or die "can't do setsockopt: $ERRNO\n";

    my $magic_packet = 
        chr(0xFF) x 6 .
        (pack('H12', $target) x 16);
    my $destination = sockaddr_in("9", inet_aton("255.255.255.255"));

    $self->{logger}->debug(
        "Sending magic packet to $target as UDP packet"
    );
    send(SOCKET, $magic_packet, 0, $destination)
        or die "can't send packet: $ERRNO\n";
    close(SOCKET);
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Task::WakeOnLan - Wake-on-lan task for FusionInventory 

=head1 DESCRIPTION

This task send a wake-on-lan packet to another host on the same network as the
agent host.
