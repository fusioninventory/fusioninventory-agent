package FusionInventory::Agent::POE::Target;

use strict;
use warnings;

use FusionInventory::Agent::Storage;
use POE::Component::IKC::ClientLite;
my $poe;
my $logger;
my $storage;

sub new {
    my (undef, $params) = @_;

    my $self = {};

    $logger => $params->{logger},

    print "  Target::new()\n";

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

sub getStorage {
    my($self) = @_;

    return $storage if $storage;
    $storage = FusionInventory::Agent::Storage->new({
        logger    => $logger,
        directory => $self->{vardir}
    });
    return $storage;
}

sub FETCH {
    my($self, $key) = @_;
   
#    warn "Code me\n";
    my $tmp = {
        key => $key,
        moduleName => $ARGV[0]
    };
    $poe->post_respond('target/get', $tmp);
}
sub TIEHASH  {
    my $storage = bless {}, shift;
    warn "New ReportHash created, stored in $storage.\n";
    $storage
}

sub DESTROY { }

1;
