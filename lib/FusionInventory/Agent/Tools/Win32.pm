package FusionInventory::Agent::Tools::Win32;

use strict;
use warnings;
use base 'Exporter';

use English qw(-no_match_vars);
use File::stat;
use Memoize;
use Time::Local;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Task::Inventory::OS::Win32; # getWmiProperties

our @EXPORT = qw(
    is64bit
);

sub is64bit {
    my $ret;
    foreach my $Properties (getWmiProperties('Win32_Processor', qw/
        AddressWidth
    /)) {
        if ($Properties->{AddressWidth} eq 64) {
            $ret = 1;
        }
    }

    return $ret; 
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Tools::Win32 - Windows generic functions

=head1 DESCRIPTION

This module provides some Windows-specific generic functions.

=head1 FUNCTIONS

=head2 is64bit()

Returns true if the OS is 64bit or false.

=back
