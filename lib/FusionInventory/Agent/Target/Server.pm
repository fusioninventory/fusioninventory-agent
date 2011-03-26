package FusionInventory::Agent::Target::Server;

use strict;
use warnings;
use base 'FusionInventory::Agent::Target';

use English qw(-no_match_vars);
use URI;

use FusionInventory::Agent::AccountInfo;

sub new {
    my ($class, $params) = @_;

    die "no url parameter" unless $params->{url};

    my $self = $class->SUPER::new($params);

    $self->{url} = URI->new($params->{url});

    my $scheme = $self->{url}->scheme();
    if (!$scheme) {
        # this is likely a bare hostname
        # as parsing relies on scheme, host and path have to be set explicitely
        $self->{url}->scheme('http');
        $self->{url}->host($params->{url});
        $self->{url}->path('ocsinventory');
    } else {
        die "invalid protocol for URL: $params->{url}"
            if $scheme ne 'http' && $scheme ne 'https';
        # complete path if needed
        $self->{url}->path('ocsinventory') if !$self->{url}->path();
    }

    # compute storage subdirectory from url
    my $subdir = $params->{url};
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

    return "server, $self->{url}";
}

1;
