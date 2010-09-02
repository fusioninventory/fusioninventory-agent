package FusionInventory::Agent::Job::Target;

use strict;
use warnings;

use POE::Component::IKC::ClientLite;
my $poe;

sub new {
    my $self = {};

    my $name   = "Target$$";
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
   
#    warn "Code me\n";
    my $tmp = {
        key => $key,
        targetId => 0
    };
    $poe->post_respond('targetsList/get', $tmp);
}
sub TIEHASH  {
    my $storage = bless {}, shift;
    warn "New ReportHash created, stored in $storage.\n";
    $storage
}

sub DESTROY { }

1;
