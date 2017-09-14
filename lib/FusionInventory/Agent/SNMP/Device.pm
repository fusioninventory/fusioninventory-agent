package FusionInventory::Agent::SNMP::Device;
 
use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::SNMP::MibSupport;

# Supported infos are specified here:
# http://fusioninventory.org/documentation/dev/spec/protocol/netdiscovery.html
use constant discovery => [ qw(
        DESCRIPTION FIRMWARE ID IPS LOCATION MAC MEMORY MODEL SNMPHOSTNAME TYPE
        SERIAL UPTIME MANUFACTURER CONTACT AUTHSNMP
    )];
# http://fusioninventory.org/documentation/dev/spec/protocol/netinventory.html
use constant inventory => [ qw(
        INFO PORTS MODEMS FIRMWARES SIMCARDS PAGECOUNTERS CARTRIDGES
    )];

sub new {
    my ($class, %params) = @_;

    my $snmp   = $params{snmp};
    my $logger = $params{logger};

    return unless $snmp;

    my $self = {
        snmp   => $snmp,
        logger => $logger
    };

    bless $self, $class;

    return $self;
}

sub loadMibSupport {
    my ($self) = @_;

    # list supported mibs regarding sysORID list as this list permits to
    # identify device supported MIBs
    $self->{MIBSUPPORT} = FusionInventory::Agent::SNMP::MibSupport->new(
        sysorid_list => $self->{snmp}->walk('.1.3.6.1.2.1.1.9.1.2'),
        logger       => $self->{logger}
    );
}

sub runMibSupport {
    my ($self) = @_;

    return unless $self->{MIBSUPPORT};

    foreach my $mibsupport ($self->{MIBSUPPORT}->get()) {
        runFunction(
            module   => $mibsupport->{module},
            function => "run",
            logger   => $self->{logger},
            params   => {
                device => $self
            }
        );
    }
}

sub getDiscoveryInfo {
    my ($self) = @_;

    my $info = {};

    # Filter out to only keep discovery infos
    my $infos = discovery;
    foreach my $infokey (@{$infos}) {
        $info->{$infokey} = $self->{$infokey}
            if exists($self->{$infokey});
    }

    return $info;
}

sub getInventory {
    my ($self) = @_;

    my $inventory = {};

    # Filter out to only keep inventory infos
    my $infos = inventory;
    foreach my $infokey (@{$infos}) {
        $inventory->{$infokey} = $self->{$infokey}
            if exists($self->{$infokey});
    }

    return $inventory;
}

sub addModem {
    my ($self, $modem) = @_;

    return unless $modem;

    push @{$self->{MODEMS}}, $modem;
}

sub addFirmware {
    my ($self, $firmware) = @_;

    return unless $firmware;

    push @{$self->{FIRMWARES}}, $firmware;
}

sub addSimcard {
    my ($self, $simcard) = @_;

    return unless $simcard;

    push @{$self->{SIMCARDS}}, $simcard;
}

1;

__END__

=head1 NAME

FusionInventory::Agent::SNMP::Device - FusionInventory agent SNMP device

=head1 DESCRIPTION

Class to help handle general method to apply on snmp device discovery/inventory

=head1 METHODS

=head2 new(%params)

The constructor. The following parameters are allowed, as keys of the %params
hash:

=over

=item logger

=item snmp (mandatory)  SNMP session object

=back
