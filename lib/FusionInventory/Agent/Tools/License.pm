package FusionInventory::Agent::Tools::License;

use strict;
use warnings;
use base 'Exporter';

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;

our @EXPORT = qw(
    getAdobeLicenses
    decodeMicrosoftKey
);

# Thanks to Brandon Mulcahy
# http://www.a1vbcode.com/snippet-4796.asp
# http://blog.eka808.com/?p=251
sub _decodeAdobeKey {
    my ($raw) = @_;

    my @subCipherKey = qw/
        0000000001 5038647192 1456053789 2604371895
        4753896210 8145962073 0319728564 7901235846
        7901235846 0319728564 8145962073 4753896210
        2604371895 1426053789 5038647192 3267408951
        5038647192 2604371895 8145962073 7901235846
        3267408951 1426053789 4753896210 0319728564/;

    my $i = 0;
    my @chars;
    while ($raw =~ s/^(\d)//) {
        $subCipherKey[$i++]=~ /^.{$1}(.)/;
        push @chars, $1;
    }

    return sprintf
        '%s%s%s%s-%s%s%s%s-%s%s%s%s-%s%s%s%s-%s%s%s%s', @chars;
}

sub getAdobeLicenses {
    my (%params) = @_;

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
            KEY => _decodeAdobeKey($data{$key}{SN}),
            COMPONENTS => join('/', @{$data{$key}{with}})
        }
    }

    return @licenses;
}

# inspired by http://poshcode.org/4363
sub decodeMicrosoftKey {
    my ($raw) = @_;

    ## no critic (ProhibitBitwise)

    return unless $raw;

    my @key_bytes = unpack 'C*', $raw;

    # check for Windows 8/Office 2013 style key (can contains the letter "N")
    my $containsN  = ($key_bytes[66] >> 3) & 1;
    $key_bytes[66] = ($key_bytes[66] & 0xF7);

    # length of product key, in chars
    my $chars_length = 25;

    # length of product key, in bytes
    my $bytes_length = 15;

    # product key available characters
    my @letters = qw(B C D F G H J K M P Q R T V W X Y 2 3 4 6 7 8 9);

    # extract bytes 52 to 66
    my @bytes = @key_bytes[52 .. 66];

    # return immediatly for null keys
    return if all { $_ == 00 } @bytes;

    # decoded product key
    my @chars;

    for (my $i = $chars_length - 1; $i >= 0; $i--) {
        my $index = 0;
        for (my $j = $bytes_length - 1; $j >= 0; $j--) {
            my $value = ($index << 8) | $bytes[$j];
            $bytes[$j] = $value / scalar @letters;
            $index = $value % (scalar @letters);
        }
        $chars[$i] = $letters[$index];
    }

    if ($containsN != 0) {
        my $first_char = shift @chars;
        my $first_char_index = 0;
        for (my $index = 0; $index < scalar @letters; $index++) {
            next if $first_char ne $letters[$index];
            $first_char_index = $index;
            last;
        }

        splice @chars, $first_char_index, 0, 'N';
    }

    return sprintf
        '%s%s%s%s%s-%s%s%s%s%s-%s%s%s%s%s-%s%s%s%s%s-%s%s%s%s%s', @chars;
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Tools::License - License-related functions

=head1 DESCRIPTION

This module provides some functions to access license information.

=head1 FUNCTIONS

=head2 getAdobeLicenses

Returns a structured view of Adobe license.

=head2 decodeMicrosoftKey($string)

Return a decoded string from a binary binary microsoft product key (XP, office,
etc)
