package FusionInventory::Agent::Job::Target;

use strict;
use warnings;

sub new {
    my $self = {};

    tie %$self, __PACKAGE__;

    bless $self;
}

sub FETCH {
    my($self, $key) = @_;
   
    warn "Code me\n";

    return "aaa";
}
sub TIEHASH  {
    my $storage = bless {}, shift;
    warn "New ReportHash created, stored in $storage.\n";
    $storage
}

sub DESTROY { }

1;
