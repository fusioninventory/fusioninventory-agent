package FusionInventory::Agent::Task::WakeOnLan;

use strict;
use warnings;
use base 'FusionInventory::Agent::Task';

use English qw(-no_match_vars);
use List::Util qw(first);
use Socket;
use UNIVERSAL::require;

use FusionInventory::Agent;
use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Network;

our $VERSION = $FusionInventory::Agent::VERSION;

sub getConfiguration {
    my ($self, %params) = @_;

    my $options = $params{spec}->{options};

    my @addresses = map {
        $_->{MAC}
    } @{$options->{PARAM}};

    return (
        addresse => \@addresses
    );
}

sub run {
    my ($self, %params) = @_;

    my @addresses = @{$self->{config}->{addresses}}
        or die "no mac addresses provided, aborting";
    my $use_ethernet = $self->{config}->{ethernet} && $self->_canUseEthernet();
    my $use_udp      = $self->{config}->{udp}      && $self->_canUseUDP();

    $self->{logger}->debug(
        "got " . scalar @addresses . " mac address as magic packets recipients"
    );

    foreach my $address (@addresses) {
        if ($address !~ /^$mac_address_pattern$/) {
            $self->{logger}->error(
                "invalid MAC address $address, skipping"
            );
            next;
        }

        $address =~ s/://g;

        if ($use_ethernet) {
            eval {
                $self->_send_magic_packet_ethernet($address);
            };
            next unless $EVAL_ERROR;
            $self->{logger}->error("Error with ethernet method: $EVAL_ERROR");
        }

        if ($use_udp) {
            eval {
                $self->_send_magic_packet_udp($address);
            };
            next unless $EVAL_ERROR;
            $self->{logger}->error("Error with UDP method: $EVAL_ERROR");
        }
    }
}

sub _canUseEthernet {
    my ($self) = @_;

    if (!$UID == 0) {
        $self->{logger}->debug(
            "no root privileges, disabling ethernet method"
        );
        return;
    }

    if (!canLoad('Net::Write::Layer2')) {
        $self->{logger}->debug(
            "unable to load Net::Write, disabling ethernet method"
        );
        return;
    }

    return 1;
}

sub _canUseUDP {
    my ($self) = @_;

    socket(my $socket, PF_INET, SOCK_DGRAM, getprotobyname('udp'));

    if (!$socket) {
        $self->{logger}->debug(
            "unable to open UDP socket ($ERRNO), disabling UDP method"
        );
        return;
    }

    setsockopt($socket, SOL_SOCKET, SO_BROADCAST, 1);

    if (!$socket) {
        $self->{logger}->debug(
            "unable to set broadcast flag ($ERRNO), disabling UDP method"
        );
        return;
    }

    close($socket);

    return 1;
}

sub _send_magic_packet_ethernet {
    my ($self, $target) = @_;

    my $interface = $self->_getInterface();
    my $source = $interface->{MACADDR};
    $source =~ s/://g;

    my $packet =
        pack('H12', $target) .
        pack('H12', $source) .
        pack('H4', "0842")   .
        $self->_getPayload($target);

    $self->{logger}->debug(
        "Sending magic packet to $target as ethernet frame"
    );

    my $writer = Net::Write::Layer2->new(
       dev => $interface->{DESCRIPTION}
    );

    $writer->open();
    $writer->send($packet);
    $writer->close();
}

sub _send_magic_packet_udp {
    my ($self,  $target) = @_;

    socket(my $socket, PF_INET, SOCK_DGRAM, getprotobyname('udp'))
        or die "can't open socket: $ERRNO\n";
    setsockopt($socket, SOL_SOCKET, SO_BROADCAST, 1)
        or die "can't do setsockopt: $ERRNO\n";

    my $packet = $self->_getPayload($target);
    my $destination = sockaddr_in("9", inet_aton("255.255.255.255"));

    $self->{logger}->debug(
        "Sending magic packet to $target as UDP packet"
    );
    send($socket, $packet, 0, $destination)
        or die "can't send packet: $ERRNO\n";
    close($socket);
}

sub _getInterface {
    my ($self) = @_;

    my @interfaces;

    SWITCH: {
        if ($OSNAME eq 'linux') {
            FusionInventory::Agent::Tools::Linux->require();
            @interfaces = FusionInventory::Agent::Tools::Linux::getInterfacesFromIfconfig(
                logger => $self->{logger}
            );
            last;
        }

        if ($OSNAME =~ /freebsd|openbsd|netbsd|gnukfreebsd|gnuknetbsd|dragonfly/) {
            FusionInventory::Agent::Tools::BSD->require();
            @interfaces = FusionInventory::Agent::Tools::BSD::getInterfacesFromIfconfig(
                logger => $self->{logger}
            );
            last;
        }

        if ($OSNAME eq 'MSWin32') {
            FusionInventory::Agent::Tools::Win32->require();
            @interfaces = FusionInventory::Agent::Tools::Win32::getInterfaces(
                logger => $self->{logger}
            );
            last;
        }
    }

    # let's take the first interface with an IP adress, a MAC address
    # different from the loopback
    my $interface =
        first { $_->{DESCRIPTION} ne 'lo' }
        grep { $_->{IPADDRESS} }
        grep { $_->{MACADDR} }
        @interfaces;

    # on Windows, we have to use internal device name instead of litteral name
    $interface->{DESCRIPTION} =
        $self->_getWin32InterfaceId($interface->{PNPDEVICEID})
        if $OSNAME eq 'MSWin32';

    return $interface;
}

sub _getPayload {
    my ($self, $target) = @_;

    return
        pack('H12', 'FF' x 6) .
        pack('H12', $target) x 16;
}

sub _getWin32InterfaceId {
    my ($self, $pnpid) = @_;

    FusionInventory::Agent::Tools::Win32->require();

    my $key = FusionInventory::Agent::Tools::Win32::getRegistryKey(
        path => "HKEY_LOCAL_MACHINE/SYSTEM/CurrentControlSet/Control/Network",
    );

    foreach my $subkey_id (keys %$key) {
        # we're only interested in GUID subkeys
        next unless $subkey_id =~ /^\{\S+\}\/$/;
        my $subkey = $key->{$subkey_id};
        foreach my $subsubkey_id (keys %$subkey) {
            my $subsubkey = $subkey->{$subsubkey_id};
            next unless $subsubkey->{'Connection/'};
            next unless $subsubkey->{'Connection/'}->{'/PnpInstanceID'};
            next unless $subsubkey->{'Connection/'}->{'/PnpInstanceID'} eq $pnpid;
            my $device_id = $subsubkey_id;
            $device_id =~ s{/$}{};

            return '\Device\NPF_' . $device_id;
        }
    }

}

1;
__END__

=head1 NAME

FusionInventory::Agent::Task::WakeOnLan - Wake-on-lan support

=head1 DESCRIPTION

This modules allows the FusionInventory agent to send a wake-on-lan packet to
another host on the same network as its own host.
