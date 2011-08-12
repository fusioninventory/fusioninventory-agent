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
    encodeFromRegistry
    KEY_WOW64_64
    KEY_WOW64_32
    getRegistryValue
    getWmiObjects
);

sub is64bit {

    return
        any { $_->{AddressWidth} eq 64 } 
        getWmiObjects(
            class => 'Win32_Processor', properties => [ qw/AddressWidth/ ]
        );
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
        or return; #die "WMI connection failed: " . Win32::OLE->LastError();

    my @objects;
    foreach my $instance (in(
        $WMIService->InstancesOf($params{class})
    )) {
        my $object;
        foreach my $property (@{$params{properties}}) {
            $object->{$property} = $instance->{$property};
        }
        push @objects, $object;
    }

    return @objects;
}

sub getRegistryValue {
    my %params = @_;

    my ($root, $keyName, $valueName);
    if ($params{path} =~ /^(HKEY\S+?)\/(.*)\/([^\/.]*)/ ) {
        $root      = $1;
        $keyName   = $2;
        $valueName = $3;
    } elsif($params{logger}) {
        $params{logger}->error("Failed to parse '$params{path}'. Does it start with HKEY_?");
        return;
    }

    my $machKey = is64bit() ?
        $Registry->Open($root, { Access=> KEY_READ | KEY_WOW64_64 } ) : ## no critic (ProhibitBitwise)
	$Registry->Open($root, { Access=> KEY_READ } )                ;

    if (!$machKey) {
        $params{logger}->error("Can't open 'root': $EXTENDED_OS_ERROR") if $params{logger};
        return;
    }
    my $key = $machKey->Open($keyName);
    my $value = $key->{$valueName};

    return if ref $value;
    return $value;
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

=head2 encodeFromRegistry($string)

Ensure given registry content is properly encoded to utf-8.

=head2 getRegistryValue(%params)

Returns a value from the registry.

=over

=item path a string in hive/key/value format

E.g: HKEY_LOCAL_MACHINE/SOFTWARE/Microsoft/Windows NT/CurrentVersion/ProductName

=item logger

=back
