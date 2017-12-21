package FusionInventory::Agent::Task::WMI;

use strict;
use warnings;

use parent 'FusionInventory::Agent::Task::Inventory';

use UNIVERSAL::require;
use English qw(-no_match_vars);

sub isEnabled {
    my ($self, $response) = @_;

    # Task only supported on MSWin32 at the moment
    return 0 if $OSNAME ne 'MSWin32';

    # Enabled for local target only is still connected
    return defined($self->{service}) unless
        $self->{target}->isa('FusionInventory::Agent::Target::Server');

    my $content = $response->getContent();
    if (!$content || !$content->{RESPONSE} || $content->{RESPONSE} ne 'SEND') {
        if ($self->{config}->{force}) {
            $self->{logger}->debug("WMI inventory task execution not requested, but execution forced");
        } else {
            $self->{logger}->debug("WMI inventory task execution not requested");
            return 0;
        }
    }

    # TODO: This is only a POC as nothing is implemented server-side and we need
    # to safely pass credentials
    my %connection = (
        host => $response->getOptionsInfoByName('REMOTEHOST'),
        user => $response->getOptionsInfoByName('REMOTEUSER'),
        pass => $response->getOptionsInfoByName('REMOTEPASS'),
    );

    $self->{registry} = [ $response->getOptionsInfoByName('REGISTRY') ];

    # Finally enable task only is can connect
    return $self->connect(%connection);
}

sub connect {
    my ( $self, %params ) = @_;

    my $logger = $self->{logger} || $params{logger};
    my $host   = $params{host} || '127.0.0.1';
    my $user   = $params{user} || '';
    my $pass   = $params{pass} || '';

    $logger->debug2("Connecting via wmi to ".($user?"$user@":"").$host) if $logger;

    FusionInventory::Agent::Tools::Win32->use();

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
