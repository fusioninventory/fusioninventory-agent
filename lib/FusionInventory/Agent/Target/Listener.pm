package FusionInventory::Agent::Target::Listener;

use strict;
use warnings;

use parent 'FusionInventory::Agent::Target';

use FusionInventory::Agent::HTTP::Session;

sub new {
    my ($class, %params) = @_;

    my $self = $class->SUPER::new(%params);

    $self->_init(
        id     => 'listener',
        vardir => $params{basevardir} . '/__LISTENER__',
    );

    return $self;
}

sub getName {
    return 'listener';
}

sub getType {
    return 'listener';
}

# No task planned as the only purpose is to answer HTTP API
sub plannedTasks {
    return ();
}

sub inventory_xml {
    my ($self, $inventory) = @_;

    if ($inventory) {
        $self->{_inventory} = $inventory;
    } else {
        # Don't keep inventory in memory when retrieved
        return delete $self->{_inventory};
    }
}

sub session {
    my ($self, %params) = @_;

    my $sessions = $self->{sessions} || $self->_restore_sessions();

    my $remoteid = $params{remoteid};

    if ($sessions->{$remoteid}) {
        return $sessions->{$remoteid}
            unless $sessions->{$remoteid}->expired();
        delete $sessions->{$remoteid};
    }

    my $session = FusionInventory::Agent::HTTP::Session->new(
        logger  => $self->{logger},
        timeout => $params{timeout},
    );

    $sessions->{$remoteid} = $session;

    $self->_store_sessions();

    return $session;
}

sub clean_session {
    my ($self, $remoteid) = @_;

    my $sessions = $self->{sessions} || $self->_restore_sessions();

    if ($sessions && $sessions->{$remoteid}) {
       delete $sessions->{$remoteid};
       $self->_store_sessions();
    }
}

sub _store_sessions {
    my ($self) = @_;

    my $sessions = $self->{sessions} || $self->_restore_sessions();

    my $datas = {};

    foreach my $remoteid (keys(%{$sessions})) {
        $datas->{$remoteid} = $sessions->{$remoteid}->dump()
            unless $sessions->{$remoteid}->expired();
    };

    my $storage = $self->getStorage();
    $storage->save( name => 'Sessions', data => $datas );
}

sub _restore_sessions {
    my ($self) = @_;

    my $sessions = {};

    my $storage = $self->getStorage();
    my $datas = $storage->restore( name => 'Sessions' );

    $datas = {} unless ref($datas) eq 'HASH';

    foreach my $remoteid (keys(%{$datas})) {
        my $data = $datas->{$remoteid};
        next unless ref($data) eq 'HASH';
        $sessions->{$remoteid} = FusionInventory::Agent::HTTP::Session->new(
            logger => $self->{logger},
            timer  => $data->{timer},
            nonce  => $data->{nonce},
        );
        delete $sessions->{$remoteid}
            if $sessions->{$remoteid}->expired();
    }

    return $self->{sessions} = $sessions;
}

1;

__END__

=head1 NAME

FusionInventory::Agent::Target::Listen - Listen target

=head1 DESCRIPTION

This is a target to serve execution result on a listening port.

=head1 METHODS

=head2 new(%params)

The constructor. The allowed parameters are the ones from the base class
C<FusionInventory::Agent::Target>.

=head2 getName()

Return the target name

=head2 getType()

Return the target type

=head2 plannedTasks([@tasks])

Initializes target tasks with supported ones if a list of tasks is provided

Return an array of planned tasks.

=head2 inventory_xml([$xml])

Set or retrieve an inventory XML to be used by an HTTP plugin

=head2 session(%params)

Create or retrieve a FusionInventory::Agent::HTTP::Session object keeping it
stored in a local storage.

Supported parameters:

=over

=item I<remoteid>

a session id used to index stored sessions

=item I<timeout>

the session timeout to use in seconds (default: 600)

=back

=head2 clean_session($remoteid)

Remove a no more used session from the stored sessions.
