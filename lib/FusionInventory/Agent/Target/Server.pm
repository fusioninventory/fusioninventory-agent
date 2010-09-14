package FusionInventory::Agent::Target::Server;

use strict;
use warnings;
use base 'FusionInventory::Agent::Target';

use English qw(-no_match_vars);

sub new {
    my ($class, $params) = @_;

    my $dir = $params->{path};
    $dir =~ s/\//_/g;
    # On Windows, we can't have ':' in directory path
    $dir =~ s/:/../g if $OSNAME eq 'MSWin32';

    my $self = $class->SUPER::new(
        {
            %$params,
            dir => $dir
        }
    );

    my $logger = $self->{logger};
    my $config = $self->{config};


    my $storage = $self->{storage};
    $self->{myData} = $storage->restore();

    if ($self->{myData}{nextRunDate}) {
        $logger->debug (
            "[$self->{path}] Next server contact planned for ".
            localtime($self->{myData}{nextRunDate})
        );
        ${$self->{nextRunDate}} = $self->{myData}{nextRunDate};
    }

    $self->{accountinfo} = $self->{myData}->{accountinfo};

    return $self;

}

sub getAccountInfo {
    my ($self) = @_;

    return $self->{accountinfo};
}

sub setAccountInfo {
    my ($self, $accountinfo) = @_;

    return $self->{accountinfo} = $accountinfo;
}

1;
