package FusionInventory::Agent::Task::NetInventory::Engine;

use strict;
use warnings;

use English qw(-no_match_vars);
use UNIVERSAL::require;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Hardware;

sub new {
    my ($class, %params) = @_;

    my $self = {
        models      => $params{models},
        credentials => $params{credentials},
        logger      => $params{logger},
        timeout     => $params{timeout} || 15,
        datadir     => $params{datadir},
    };
    bless $self, $class;

    return $self;
}

sub _queryDevice {
    my ($self, $device) = @_;

    my $logger = $self->{logger};
    $logger->debug("scanning $device->{ID}");

    my $snmp;
    if ($device->{FILE}) {
        FusionInventory::Agent::SNMP::Mock->require();
        eval {
            $snmp = FusionInventory::Agent::SNMP::Mock->new(
                file => $device->{FILE}
            );
        };
        if ($EVAL_ERROR) {
            $logger->error("Unable to create SNMP session for $device->{FILE}: $EVAL_ERROR");
            return;
        }
    } else {
        my $credentials = $self->{credentials}->{$device->{AUTHSNMP_ID}};
        eval {
            FusionInventory::Agent::SNMP::Live->require();
            $snmp = FusionInventory::Agent::SNMP::Live->new(
                hostname     => $device->{IP},
                timeout      => $self->{timeout},
                %$credentials
            );
        };
        if ($EVAL_ERROR) {
            $logger->error("Unable to create SNMP session for $device->{IP}: $EVAL_ERROR");
            return;
        }
    }

    my $result = getDeviceFullInfo(
         id      => $device->{ID},
         type    => $device->{TYPE},
         snmp    => $snmp,
         model   => $self->{models}->{$device->{MODELSNMP_ID}},
         logger  => $self->{logger},
         datadir => $self->{datadir},
    );

    return $result;
}

1;

__END__

=head1 NAME

FusionInventory::Agent::Task::NetInventory::Engine - Network inventory engine
