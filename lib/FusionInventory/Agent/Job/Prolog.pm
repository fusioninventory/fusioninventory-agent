package FusionInventory::Agent::Job::Prolog;

use strict;
use warnings;

use POE::Component::IKC::ClientLite;
my $poe;

sub new {
    my $self = {};

    my $name   = "Prolog$$";
    $poe = create_ikc_client(
        port    => 3030,
        name    => $name,
        timeout => 10,
    );
    die $POE::Component::IKC::ClientLite::error unless $poe;


    bless $self;
}


sub getOptionsInfoByName {
    my ($self, $name) = @_;

    $poe->post_respond('prolog/getOptionsInfoByName', $name);
}

1;
