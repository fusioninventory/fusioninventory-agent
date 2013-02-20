package FusionInventory::Agent::Threads;

use strict;
use warnings;
use threads;
use threads::shared;
use base 'Exporter';

no warnings 'redefine';

use Scalar::Util qw(refaddr reftype);

our @EXPORT = qw(shared_clone);

# version 1.21, appearing with perl 5.10.1
sub shared_clone {
    my ($item, $cloned) = @_;

    # Just return the item if:
    # 1. Not a ref;
    # 2. Already shared; or
    # 3. Not running 'threads'.
    return $item
        if (! ref($item) || threads::shared::_id($item) || ! $threads::threads);

    # initialize clone checking hash if needed
    $cloned = {} unless $cloned;

    # Check for previously cloned references
    #   (this takes care of circular refs as well)
    my $addr = refaddr($item);
    if (exists($cloned->{$addr})) {
        # Return the already existing clone
        return $cloned->{$addr};
    }

    # Make copies of array, hash and scalar refs
    my $copy;
    my $ref_type = reftype($item);

    # Copy an array ref
    if ($ref_type eq 'ARRAY') {
        # Make empty shared array ref
        $copy = &share([]);
        # Add to clone checking hash
        $cloned->{$addr} = $copy;
        # Recursively copy and add contents
        push(@$copy, map { shared_clone($_, $cloned) } @$item);
    }

    # Copy a hash ref
    elsif ($ref_type eq 'HASH') {
        # Make empty shared hash ref
        $copy = &share({});
        # Add to clone checking hash
        $cloned->{$addr} = $copy;
        # Recursively copy and add contents
        foreach my $key (keys(%{$item})) {
            $copy->{$key} = shared_clone($item->{$key}, $cloned);
        }
    }

    # Copy a scalar ref
    elsif ($ref_type eq 'SCALAR') {
        $copy = \do{ my $scalar = $$item; };
        share($copy);
        # Add to clone checking hash
        $cloned->{$addr} = $copy;
    }

    return $copy;
}

1;

__END__

=head1 NAME

FusionInventory::Agent::Threads - Backported threads::shared functions

=head1 DESCRIPTION

This module contains backported threads::shared functions for perl 5.8
compatibility.

=head1 FUNCTIONS

=head2 shared_clone($variable)

"shared_clone" takes a reference, and returns a shared version of its argument,
performing a deep copy on any non-shared elements. Any shared elements in the
argument are used as is (i.e., they are not cloned).
