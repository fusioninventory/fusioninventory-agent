package FusionInventory::Agent::SNMP::MibSupport::Stormshield;

use strict;
use warnings;

use parent 'FusionInventory::Agent::SNMP::MibSupportTemplate';

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::SNMP;

# https://documentation.stormshield.eu/SNS/v3/fr/Content/User_Configuration_Manual_SNS_v3/SNMP_Agent/MIBS_and_traps_SNMP.htm
use constant    freebsd     => '.1.3.6.1.4.1.8072.3.2.8';
use constant    stormshield => '.1.3.6.1.4.1.11256' ;
use constant    model       => stormshield  .'.1.0.1.0' ;
use constant    fw_pri      => stormshield . '.1.0.2.0' ;
use constant    serial      => stormshield  .'.1.0.3.0' ;
use constant    name        => stormshield  .'.1.0.4.0' ;

our $mibSupport = [
    {
        name        => "stormshield-freebsd",
        sysobjectid => getRegexpOidMatch(freebsd)
    }
];

sub getSerial {
    my ($self) = @_;

    return $self->get(serial);
}


sub getFirmware {
    my ($self) = @_;

    return $self->get(fw_pri);
}

sub getType {
    my ($self) = @_;

    return 'NETWORKING' if($self->getModel());
}

sub getModel {
    my ($self) = @_;
    
    return $self->get(model);
}

sub getManufacturer {
    my ($self) = @_;

    return 'StormShield' if($self->getModel());
}

sub run {
    my ($self) = @_;

    if($self->getModel()){
        my $device = $self->device or return;

        my $name = $self->get(name);
        $device->{INFO}->{NAME} = $name if $name;
    }
}

1;

__END__

=head1 NAME

FusionInventory::Agent::SNMP::MibSupport::Stormshield - Inventory module for Stormshield

=head1 DESCRIPTION

The module enhances Stormshield Rooter devices support.
