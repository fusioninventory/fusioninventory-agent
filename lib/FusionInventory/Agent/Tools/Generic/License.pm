package FusionInventory::Agent::Tools::Generic::License;

use strict;
use warnings;
use base 'Exporter';

use English qw(-no_match_vars);
use Memoize;

use FusionInventory::Agent::Tools;

our @EXPORT = qw(
    getAdobeLicenses
    decodeWinKey
);

sub getAdobeLicenses {
    my (%params) = (@_);

    my $handle = getFileHandle(%params);


    my @licenses;

    my %data;

    while (my $line = <$handle>) {
        chomp($line);

        my @f = split(/ <> /, $line);
 
        $f[1] =~ s/\{\|\}.*//;
        $f[2] =~ s/\{\|\}.*//;
        $f[3] =~ s/\{\|\}.*//;

        if ($f[2] eq 'FLMap') {
            push @{$data{$f[3]}{with}}, $f[1];
        } elsif ($f[3] ne "unlicensed") {
            $data{$f[1]}{$f[2]} = $f[3];
        }
    }

    foreach my $key (keys %data) {
        next unless $data{$key}{SN} || $data{$key}{with};

        push @licenses, {
            NAME => $key,
            FULLNAME => $data{$key}{ALM_LicInfo_EpicAppName},
            KEY => $data{$key}{SN},
            COMPONENTS => join('/', @{$data{$key}{with}})
        }
    }

    return @licenses;

}

# http://www.perlmonks.org/?node_id=497616
# Thanks William Gannon && Charles Clarkson
sub decodeWinKey {
    my ($key) = @_;
    return unless $key;

    my @encoded = ( unpack 'C*', $key )[ reverse 52 .. 66 ];

    # Get indices
    my @indices;
    foreach ( 0 .. 24 ) {
        my $index = 0;

        # Shift off remainder
        ( $index, $_ ) = _quotient( $index, $_ ) foreach @encoded;

        # Store index.
        unshift @indices, $index;
    }

    # translate base 24 "digits" to characters
    my $cd_key =
        join '',
        qw( B C D F G H J K M P Q R T V W X Y 2 3 4 6 7 8 9 )[ @indices ];

    # Add seperators
    $cd_key =
        join '-',
        $cd_key =~ /(.{5})/g;

    return if $cd_key =~ /^[B-]*$/;
    return $cd_key;
}

sub _quotient {
    my($index, $encoded) = @_;

    # Same as $index * 256 + $product_key ???
    my $dividend = $index * 256 ^ $encoded; ## no critic (ProhibitBitwise)

    # return modulus and integer quotient
    return(
        $dividend % 24,
        $dividend / 24,
    );
}




1;
__END__

=head1 NAME

FusionInventory::Agent::Tools::Generic::License - OS-independant license functions

=head1 DESCRIPTION

This module provides some OS-independant generic functions to access license
informations.

=head1 FUNCTIONS

=head2 getAdobeLicense

Returns a structured view of Adobe license.

=back

=head2 decodeWinKey($string)

Decode Office and Windows encoded serial number string. This function is in
Agent::Tools because it is required for Microsoft Office for MacOSX too.

=back
