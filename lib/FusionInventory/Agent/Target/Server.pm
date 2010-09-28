package FusionInventory::Agent::Target::Server;

use strict;
use warnings;
use base 'FusionInventory::Agent::Target';

use English qw(-no_match_vars);

my $count = 0;

sub new {
    my ($class, $params) = @_;

    die "no url parameter" unless $params->{url};

    my $self = $class->SUPER::new($params);

    # assume an url without protocol part is actually a server name
    if ($params->{url} =~ m{^https?://}) {
        $self->{url} = $params->{url};
    } else {
        $self->{url} = "http://$params->{url}/ocsinventory";
    }

    # compute storage subdirectory from url
    my $subdir = $self->{url};
    $subdir =~ s/\//_/g;
    $subdir =~ s/:/../g if $OSNAME eq 'MSWin32';

    $self->_init({
        id     => 'server' . $count++,
        vardir => $params->{basevardir} . '/' . $subdir
    });

    return $self;
}

sub getUrl {
    my ($self) = @_;

    return $self->{url};
}

sub getAccountInfo {
    my ($self) = @_;

    return $self->{accountInfo};
}

sub setAccountInfo {
    my ($self, $accountInfo) = @_;

    $self->{accountInfo} = $accountInfo;
}

sub _load {
    my ($self) = @_;

    my $data = $self->{storage}->restore();
    $self->{nextRunDate} = $data->{nextRunDate} if $data->{nextRunDate};
    $self->{maxOffset}   = $data->{maxOffset} if $data->{maxOffset};
    $self->{accountInfo} = $data->{accountInfo} if $data->{accountInfo};
}

sub checkpoint {
    my ($self) = @_;

    $self->{storage}->save({
        data => {
            nextRunDate => $self->{nextRunDate},
            maxOffset   => $self->{maxOffset},
            accountInfo => $self->{accountInfo}
        }
    });

}

1;

__END__

=head1 NAME

FusionInventory::Agent::Target::Server - Server target

=head1 DESCRIPTION

This is a target for sending execution result to a server.

=head1 METHODS

=head2 new($params)

The constructor. The following parameters are allowed, in addition to those
from the base class C<FusionInventory::Agent::Target>:

=over

=item url: server URL

=back

=head2 getAccountInfo()

Get account informations for this target.

=head2 setAccountInfo($info)

Set account informations for this target.
