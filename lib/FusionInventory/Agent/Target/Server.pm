package FusionInventory::Agent::Target::Server;

use strict;
use warnings;
use base 'FusionInventory::Agent::Target';

use English qw(-no_match_vars);

use FusionInventory::Agent::AccountInfo;

sub new {
    my ($class, $params) = @_;

    my $self = $class->SUPER::new($params);

    $self->{path} = $params->{path};

    my $subdir = $params->{path};
    $subdir =~ s/\//_/g;
    $subdir =~ s/:/../g if $OSNAME eq 'MSWin32';

    $self->_init({
        vardir => $params->{basevardir} . '/' . $subdir
    });

    my $logger = $self->{logger};

    $self->{accountinfo} = FusionInventory::Agent::AccountInfo->new({
        logger => $logger,
        target => $self,
        file   => $self->{vardir} . "/ocsinv.adm"
    });

    my $accountinfo = $self->{accountinfo};

    if ($params->{tag}) {
        if ($accountinfo->get("TAG")) {
            $logger->debug(
                "A TAG seems to already exist in the server for this ".
                "machine. The -t paramter may be ignored by the server " .
                "unless it has OCS_OPT_ACCEPT_TAG_UPDATE_FROM_CLIENT=1."
            );
        }
        $accountinfo->set("TAG", $params->{tag});
    }

    $self->{accountinfofile} = $self->{vardir} . "/ocsinv.adm";
   
    return $self;
}

sub getDescription {
    my ($self) = @_;

    return "server, $self->{path}";
}

1;
