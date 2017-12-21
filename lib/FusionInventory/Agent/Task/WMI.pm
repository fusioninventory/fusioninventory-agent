package FusionInventory::Agent::Task::WMI;

use strict;
use warnings;

use parent 'FusionInventory::Agent::Task::Inventory';

use UNIVERSAL::require;
use English qw(-no_match_vars);

use FusionInventory::Agent::Tools::Win32;

sub isEnabled {
    my ($self) = @_;

    # TODO Fix to handle requests from server
    return defined $self->{service};
}

sub connect {
    my ( $self, %params ) = @_;

    my $logger = $self->{logger} || $params{logger};
    my $host   = $params{host} || '127.0.0.1';
    my $user   = $params{user} || '';
    my $pass   = $params{pass} || '';

    $logger->debug2("Connecting via wmi to ".($user?"$user@":"").$host) if $logger;

    $self->{service} = getWMIService(
        host    => $host,
        user    => $user,
        pass    => $pass
    );

    if ($self->{service}) {
        $logger->debug2("Connected via wmi to host $host") if $logger;

        # Set now we are remote
        $self->setRemote('wmi');

        return 1
    } else {
        $logger->error("can't connect to host $host with '$user' user") if $logger;
        return 0;
    }
}

1;
