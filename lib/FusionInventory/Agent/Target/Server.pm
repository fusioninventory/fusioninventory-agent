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

    $self->{accountinfo} = FusionInventory::Agent::AccountInfo->new({
        logger => $logger,
        config => $config,
        target => $self,
    });

    my $accountinfo = $self->{accountinfo};

    if ($config->{tag}) {
        if ($accountinfo->get("TAG")) {
            $logger->debug(
                "A TAG seems to already exist in the server for this ".
                "machine. The -t paramter may be ignored by the server " .
                "unless it has OCS_OPT_ACCEPT_TAG_UPDATE_FROM_CLIENT=1."
            );
        }
        $accountinfo->set("TAG", $config->{tag});
    }

    my $storage = $self->{storage};
    $self->{myData} = $storage->restore();

    if ($self->{myData}{nextRunDate}) {
        $logger->debug (
            "[$self->{path}] Next server contact planned for ".
            localtime($self->{myData}{nextRunDate})
        );
        ${$self->{nextRunDate}} = $self->{myData}{nextRunDate};
    }

    return $self;

}

1;
