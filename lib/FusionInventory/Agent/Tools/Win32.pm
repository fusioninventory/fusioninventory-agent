package FusionInventory::Agent::Tools::Win32;

use strict;
use warnings;
use base 'Exporter';

use English qw(-no_match_vars);
use File::stat;
use Memoize;
use Time::Local;


use constant KEY_WOW64_64 => 0x100;
use constant KEY_WOW64_32 => 0x200;

use Win32::TieRegistry (
        Delimiter   => '/',
        ArrayValues => 0,
        qw/KEY_READ/
        );

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Task::Inventory::OS::Win32; # getWmiProperties

our @EXPORT = qw(
    is64bit
    getValueFromRegistry
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

sub getValueFromRegistry {
    my ($path, $logger) = @_;

    my $root;
    my $subpath;
    my $keyName;
    if ($path =~ /^(HKEY\S+?)\/(.*)\/([^\/.]*)/ ) {
        $root = $1;
        $subpath = $2;
        $keyName = $3;
    }
    my $machKey;
    $Registry->Delimiter("/");
    if (is64bit()) {
        $machKey = $Registry->Open($root, { Access=> KEY_READ()|KEY_WOW64_64KEY() } );
    } else {
	$machKey = $Registry->Open($root, { Access=> KEY_READ() } );
    }
    if (!$machKey) {
        if ($logger) {
            $logger->error("Can't open `$root': $EXTENDED_OS_ERROR");
        } else {
            warn("Can't open `$root': $EXTENDED_OS_ERROR");
        }
        return;
    }
    my $key = $machKey->Open($subpath);
    my $t = $key->{$keyName};
    return if ref($t);
    return $t;
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

=head2 getValueFromRegistry($path, $logger)

Returns a value from the registry. The function returns undef in case of
error.

the $path parameter is a string in this format :
$hive/location/keyname

E.g: HKEY_LOCAL_MACHINE/SOFTWARE/Microsoft/Windows NT/CurrentVersion/ProductName

The delimiter is '/

If the $logger parameter is defined, it will be used.
