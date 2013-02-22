package FusionInventory::Agent::Tools::Generic::License;

use strict;
use warnings;
use base 'Exporter';

use English qw(-no_match_vars);
use Memoize;

use FusionInventory::Agent::Tools;

our @EXPORT = qw(
    getAdobeLicenses
);

sub _parseAdobeSerial {
    my ($raw) = @_;

# Thanks to Brandon Mulcahy
# http://www.a1vbcode.com/snippet-4796.asp
# http://blog.eka808.com/?p=251
    my @subCipherKey = qw/
        0000000001 5038647192 1456053789 2604371895
        4753896210 8145962073 0319728564 7901235846
        7901235846 0319728564 8145962073 4753896210
        2604371895 1426053789 5038647192 3267408951
        5038647192 2604371895 8145962073 7901235846
        3267408951 1426053789 4753896210 0319728564/;

    my $i = 0;
    my $ret = "";
    while ($raw =~ s/^(\d)//) {
        $subCipherKey[$i++]=~ /^.{$1}(.)/;
        $ret .= $1;
    }

    $ret =~ s/(\d{4})(\d{4})(\d{4})(\d{4})(\d{4})(\d{4})/$1-$2-$3-$4-$5/;

    return $ret;
}

sub getAdobeLicenses {
    my (%params) = (@_);

    my $handle = getFileHandle(%params);


    my @licenses;

    my %data;

    while (my $line = <$handle>) {
        chomp($line);

        my @f = split(/ <> /, $line);

        next unless $f[3];

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
            KEY => _parseAdobeSerial($data{$key}{SN}),
            COMPONENTS => join('/', @{$data{$key}{with}})
        }
    }

    return @licenses;

}


1;
__END__

=head1 NAME

FusionInventory::Agent::Tools::Generic::License - OS-independant license functions

=head1 DESCRIPTION

This module provides some OS-independant generic functions to access license
informations.

=head1 FUNCTIONS

=head2 getAdobeLicenses

Returns a structured view of Adobe license.
