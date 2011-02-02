package FusionInventory::Agent::Tools;

use strict;
use warnings;
use base 'Exporter';

use English qw(-no_match_vars);
use File::stat;
use Memoize;
use Sys::Hostname;
use File::Spec;

our @EXPORT = qw(
    getCanonicalManufacturer
    getVersionFromTaskModuleFile
);

memoize('getCanonicalManufacturer');

sub getCanonicalManufacturer {
    my ($model) = @_;

    return unless $model;

    my $manufacturer;
    if ($model =~ /(
        maxtor    |
        sony      |
        compaq    |
        ibm       |
        toshiba   |
        fujitsu   |
        lg        |
        samsung   |
        nec       |
        transcend |
        matshita  |
        hitachi   |
        pioneer
    )/xi) {
        $manufacturer = ucfirst(lc($1));
    } elsif ($model =~ /^(hp|HP|hewlett packard)/) {
        $manufacturer = "Hewlett Packard";
    } elsif ($model =~ /^(WDC|[Ww]estern)/) {
        $manufacturer = "Western Digital";
    } elsif ($model =~ /^(ST|[Ss]eagate)/) {
        $manufacturer = "Seagate";
    } elsif ($model =~ /^(HD|IC|HU)/) {
        $manufacturer = "Hitachi";
    }

    return $manufacturer;
}

sub getVersionFromTaskModuleFile {
    my ($file) = @_;

    my $version;
    open my $fh, "<$file" or return;
    foreach (<$fh>) {
        if (/^# VERSION FROM Agent.pm/) {
            if (!$FusionInventory::Agent::VERSION) {
                eval { use FusionInventory::Agent; 1 };
            }
            $version = $FusionInventory::Agent::VERSION;
            last;
        } elsif (/^our\ *\$VERSION\ *=\ *(\S+);/) {
            $version = $1;
            last;
        } elsif (/^use strict;/) {
            last;
        }
    }
    close $fh;

    if ($version) {
        $version =~ s/^'(.*)'$/$1/;
        $version =~ s/^"(.*)"$/$1/;
    }

    print $version."\n";
    return $version;
}


1;
__END__

=head1 NAME

FusionInventory::Agent::Tools - OS-independant generic functions

=head1 DESCRIPTION

This module provides some OS-independant generic functions.

This module is a backported from the master git branch.

=head1 FUNCTIONS

=head2 getCanonicalManufacturer($manufacturer)

Returns a normalized manufacturer value for given one.

=head2 getVersionFromTaskModuleFile($taskModuleFile)

Parse a task module file to get the $VERSION. The VERSION must be
a line between the begining of the file and the 'use strict;' line.
The line must by either:

 our $VERSION = 'XXXX';

In case the .pm file is from the core distribution, the follow line 
must be present instead:

 # VERSION FROM Agent.pm/
