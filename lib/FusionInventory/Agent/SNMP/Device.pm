package FusionInventory::Agent::SNMP::Device;
 
use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::SNMP;
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

sub getSerialByMibSupport {
    my ($self) = @_;

    return unless $self->{MIBSUPPORT};

    my $serial;
    foreach my $mibsupport ($self->{MIBSUPPORT}->get()) {
        $serial = runFunction(
            module   => $mibsupport->{module},
            function => "getSerial",
            logger   => $self->{logger},
            params   => {
                device => $self
            }
        );
        last if defined $serial;
    }

    return $serial;
}

sub getFirmwareByMibSupport {
    my ($self) = @_;

    return unless $self->{MIBSUPPORT};

    my $firmware;
    foreach my $mibsupport ($self->{MIBSUPPORT}->get()) {
        $firmware = runFunction(
            module   => $mibsupport->{module},
            function => "getFirmware",
            logger   => $self->{logger},
            params   => {
                device => $self
            }
        );
        last if defined $firmware;
    }

    return $firmware;
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

sub setSerial {
    my ($self) = @_;

    # Entity-MIB::entPhysicalSerialNum
    my $entPhysicalSerialNum = $self->{snmp}->get_first('.1.3.6.1.2.1.47.1.1.1.1.11');
    return $self->{SERIAL} = getCanonicalSerialNumber($entPhysicalSerialNum)
        if $entPhysicalSerialNum;

    # Printer-MIB::prtGeneralSerialNumber
    my $prtGeneralSerialNumber = $self->{snmp}->get_first('.1.3.6.1.2.1.43.5.1.1.17');
    return $self->{SERIAL} = getCanonicalSerialNumber($prtGeneralSerialNumber)
        if $prtGeneralSerialNumber;

    # Try MIB Support mechanism
    my $otherSerial = $self->getSerialByMibSupport();
    return $self->{SERIAL} = getCanonicalSerialNumber($otherSerial)
        if $otherSerial;

    # vendor specific OIDs
    my @oids = (
        '.1.3.6.1.4.1.2636.3.1.3.0',             # Juniper-MIB
        '.1.3.6.1.4.1.248.14.1.1.9.1.10.1',      # Hirschman MIB
        '.1.3.6.1.4.1.253.8.53.3.2.1.3.1',       # Xerox-MIB
        '.1.3.6.1.4.1.367.3.2.1.2.1.4.0',        # Ricoh-MIB
        '.1.3.6.1.4.1.641.2.1.2.1.6.1',          # Lexmark-MIB
        '.1.3.6.1.4.1.1602.1.2.1.4.0',           # Canon-MIB
        '.1.3.6.1.4.1.2435.2.3.9.4.2.1.5.5.1.0', # Brother-MIB
        '.1.3.6.1.4.1.318.1.1.4.1.5.0',          # MasterSwitch-MIB
        '.1.3.6.1.4.1.6027.3.8.1.1.5.0',         # F10-C-SERIES-CHASSIS-MIB
        '.1.3.6.1.4.1.6027.3.10.1.2.2.1.12.1',   # FORCE10-SMI
    );
    foreach my $oid (@oids) {
        my $value = $self->{snmp}->get($oid);
        next unless $value;
        $self->{SERIAL} = getCanonicalSerialNumber($value);
        last;
    }
}

sub setFirmware {
    my ($self) = @_;

    my $firmware =
        # entPhysicalSoftwareRev
        $self->{snmp}->get_first('.1.3.6.1.2.1.47.1.1.1.1.10') ||
        # entPhysicalFirmwareRev
        $self->{snmp}->get_first('.1.3.6.1.2.1.47.1.1.1.1.9')  ||
        # firmware from supported mib
        $self->getFirmwareByMibSupport();

    if ( not defined $firmware ) {
        # vendor specific OIDs
        my @oids = (
            '.1.3.6.1.4.1.9.9.25.1.1.1.2.5',         # Cisco / IOS
            '.1.3.6.1.4.1.248.14.1.1.2.0',           # Hirschman MIB
            '.1.3.6.1.4.1.2636.3.40.1.4.1.1.1.5.0',  # Juniper-MIB
        );
        foreach my $oid (@oids) {
            $firmware = $self->{snmp}->get($oid);
            last if defined $firmware;
        }
    }

    return unless defined $firmware;

    # Set device firmware
    $self->{FIRMWARE} = getCanonicalString($firmware);

    # Also add firmware as device FIRMWARES
    $self->addFirmware({
        NAME            => $self->{MODEL} || 'device',
        DESCRIPTION     => 'device firmware',
        TYPE            => 'device',
        VERSION         => $self->{FIRMWARE},
        MANUFACTURER    => $self->{MANUFACTURER}
    });
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
