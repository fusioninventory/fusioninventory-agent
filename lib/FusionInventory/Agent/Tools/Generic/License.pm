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
