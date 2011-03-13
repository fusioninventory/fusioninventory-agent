package FusionInventory::Agent::Tools::Win32;

use strict;
use warnings;
use base 'Exporter';

use constant KEY_WOW64_64 => 0x100;
use constant KEY_WOW64_32 => 0x200;

use Encode;
use English qw(-no_match_vars);
use Win32::OLE qw(in CP_UTF8);
use Win32::OLE::Const;
use Win32::TieRegistry (
    Delimiter   => '/',
    ArrayValues => 0,
    qw/KEY_READ/
);
use FusionInventory::Agent::Task::Inventory::OS::Win32; # getWmiProperties

Win32::OLE->Option(CP => 'CP_UTF8');

our @EXPORT = qw(
    getWmiProperties
    encodeFromWmi
    encodeFromRegistry
    KEY_WOW64_64
    KEY_WOW64_32
    is64bit
    getValueFromRegistry
);

my $localCodepage;

# We don't need to encode to UTF-8 on Win7
sub encodeFromWmi {
    my ($string) = @_;

    return $string;
}

sub encodeFromRegistry {
    my ($string) = @_;

    return unless $string;

    if (!$localCodepage) {
        my $lmachine = $Registry->Open('LMachine', {
            Access => KEY_READ
        }) or die "Can't open HKEY_LOCAL_MACHINE key: $EXTENDED_OS_ERROR";

        my $codepage =
            $lmachine->{"SYSTEM\\CurrentControlSet\\Control\\Nls\\CodePage"}
            or warn;

            $localCodepage = "cp".$codepage->{ACP};
    }

    return encode("UTF-8", decode($localCodepage, $string));
}

sub getWmiProperties {
    my $wmiClass = shift;
    my @keys = @_;

    my $WMIServices = Win32::OLE->GetObject(
        "winmgmts:{impersonationLevel=impersonate,(security)}!//./" );

    if (!$WMIServices) {
        print STDERR Win32::OLE->LastError();
    }

    my @properties;
    foreach my $value (Win32::OLE::in(
        $WMIServices->InstancesOf($wmiClass)
    )) {
    my $property;
        foreach my $key (@keys) {
            $property->{$key} = encodeFromWmi($value->{$key});
        }
        push @properties, $property;
    }

    return @properties;
}

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

FusionInventory::Agent::Tools::Win32 - Win32 generic functions

=head1 DESCRIPTION

This module provides some generic functions for Win32.

=head1 FUNCTIONS

=head2 getWmiProperties($class, @properties)

Returns the list of given properties from given WMI class, properly encoded.

=head2 encodeFromWmi($string)

Ensure given WMI content is properly encoded to utf-8.

=head2 encodeFromRegistry($string)

Ensure given registry content is properly encoded to utf-8.

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
