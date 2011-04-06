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

Win32::OLE->Option(CP => 'CP_UTF8');

use FusionInventory::Agent::Tools;

my $localCodepage;

our @EXPORT = qw(
    is64bit
    getWmiProperties
    encodeFromWmi
    encodeFromRegistry
    KEY_WOW64_64
    KEY_WOW64_32
);

sub is64bit {

    return
        any { $_->{AddressWidth} eq 64 } 
        getWmiProperties('Win32_Processor', qw/AddressWidth/);
}

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

sub getWmiObjects {
    my %params = (
        moniker => 'winmgmts:{impersonationLevel=impersonate,(security)}!//./',
        @_
    );

    my $WMIService = Win32::OLE->GetObject($params{moniker})
        or die "WMI connection failed: " . Win32::OLE->LastError();

    my @objects;
    foreach my $instance (in(
        $WMIServices->InstancesOf($params{class})
    )) {
        my $object;
        foreach my $property (@{$params{properties}}) {
            $object->{$property} = encodeFromWmi($instance->{$property});
        }
        push @objects, $object;
    }

    return @objects;
}

sub getRawRegistryKey {
    my ($name) = @_;

    my $key = $Registry->Open('LMachine', {
        Access => KEY_READ | KEY_WOW64_64KEY
    }) or die "Can't open HKEY_LOCAL_MACHINE key: $EXTENDED_OS_ERROR";

    return $key->{$name};
}

sub getRegistryKey {
    my $rawkey = getRawRegistryKey(@_);

    my $key;

    foreach my $rawentry (%$rawkey) {
        next unless $rawentry =~ /^\/(.*)/;
        my $entry = $1;
        $key->{$entry} = $rawkey->{$rawentry};
    }

    return $key;
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

=head2 getWmiObjects(%params)

Returns the list of objects from given WMI class, with given properties, properly encoded.

=over

=item moniker a WMI moniker (default: winmgmts:{impersonationLevel=impersonate,(security)}!//./)

=item class a WMI class

=item properties a list of WMI properties

=back

=head2 encodeFromWmi($string)

Ensure given WMI content is properly encoded to utf-8.

=head2 encodeFromRegistry($string)

Ensure given registry content is properly encoded to utf-8.

=head2 getRawRegistryKey($name)

Return a registry key directly.

=head2 getRegistryKey($name)

Return a registry key after filtering its content.
