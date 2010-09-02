package FusionInventory::Agent::Job::Config;

use strict;
use warnings;

use POE::Component::IKC::ClientLite;
my $poe;

sub new {
    my $self = {};


    my $name   = "Client$$";
    $poe = create_ikc_client(
        port    => 3030,
        name    => $name,
        timeout => 10,
    );
    die $POE::Component::IKC::ClientLite::error unless $poe;

    tie %$self, __PACKAGE__;

    bless $self;
}

sub FETCH {
    my($self, $key) = @_;

#    warn "key $key requested\n";

    $poe->post_respond('config/get', $key);
#    return $poe->post_respond('config/get', $key) or die $poe->error;

}
sub TIEHASH  {
    my $storage = bless {}, shift;
    warn "New ReportHash created, stored in $storage.\n";
    $storage
}

sub DESTROY { }

1;

