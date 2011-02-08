package FusionInventory::Agent::Tools;

use strict;
use warnings;
use base 'Exporter';

use English qw(-no_match_vars);
use File::stat;
use Memoize;
use Sys::Hostname;
use File::Spec;
use File::Basename;

our @EXPORT = qw(
    getCanonicalManufacturer
    getVersionFromTaskModuleFile
    getFusionInventoryLibdir
    getFusionInventoryTaskList
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

    return $version;
}

sub getFusionInventoryLibdir {
    my ($config) = @_;

    die unless $config;

    my @dirToScan;

    if ($config->{devlib}) {
# devlib enable, I only search for backend module in ./lib
        return './lib';
    } else {
        foreach (@INC) {
# perldoc lib
# For each directory in LIST (called $dir here) the lib module also checks to see
# if a directory called $dir/$archname/auto exists. If so the $dir/$archname
# directory is assumed to be a corresponding architecture specific directory and
# is added to @INC in front of $dir. lib.pm also checks if directories called
# $dir/$version and $dir/$version/$archname exist and adds these directories to @INC.
            my $autoDir = $_.'/'.$Config::Config{archname}.'/auto/FusionInventory/Agent/Task/Inventory';

            next if ! -d || (-l && -d readlink) || /^(\.|lib)$/;
            next if ! -d $_.'/FusionInventory/Agent/Task/Inventory';
            return $_ if -d $_.'/FusionInventory/Agent';
            return $autoDir if -d $autoDir.'/FusionInventory/Agent';
        }
    }

    return;

}

sub getFusionInventoryTaskList {
    my ($config) = @_;

    my $libdir = getFusionInventoryLibdir($config);

    my @tasks = glob($libdir.'/FusionInventory/Agent/Task/*.pm');

    my @ret;
    foreach (@tasks) {
        next unless basename($_) =~ /(.*)\.pm/;
        my $module = $1;

        next if $module eq 'Base';

        push @ret, {
            path => $_,
            version => getVersionFromTaskModuleFile($_),
            module => $module,
        }
    }

    return \@ret;
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

=head2 getFusionInventoryLibdir()

Return the location of the FusionInventory/Agent library directory
on the system.
