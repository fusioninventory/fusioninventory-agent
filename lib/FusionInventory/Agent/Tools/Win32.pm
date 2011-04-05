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

sub getWmiProperties {
    my $wmiClass = shift;
    my @keys = @_;

    my $WMIService = Win32::OLE->GetObject(
        "winmgmts:{impersonationLevel=impersonate,(security)}!//./"
    ) or die "WMI connection failed: " . Win32::OLE->LastError();

    my @properties;
    foreach my $value (in(
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

1;
__END__

=head1 NAME

FusionInventory::Agent::Tools::Win32 - Windows generic functions

=head1 DESCRIPTION

This module provides some Windows-specific generic functions.

=head1 FUNCTIONS

=head2 is64bit()

Returns true if the OS is 64bit or false.

=head2 getWmiProperties($class, @properties)

Returns the list of given properties from given WMI class, properly encoded.

=head2 encodeFromWmi($string)

Ensure given WMI content is properly encoded to utf-8.

=head2 encodeFromRegistry($string)

Ensure given registry content is properly encoded to utf-8.
