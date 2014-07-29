package FusionInventory::Agent::Tools::Win32;

use strict;
use warnings;
use base 'Exporter';
use utf8;

use constant KEY_WOW64_64 => 0x100;
use constant KEY_WOW64_32 => 0x200;

use Cwd;
use Encode;
use English qw(-no_match_vars);
use File::Temp qw(:seekable tempfile);
use Win32::Job;
use Win32::OLE qw(in);
use Win32::OLE::Const;
use Win32::TieRegistry (
    Delimiter   => '/',
    ArrayValues => 0,
    qw/KEY_READ/
);

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Network;

Win32::OLE->Option(CP => Win32::OLE::CP_UTF8);

my $localCodepage;

our @EXPORT = qw(
    is64bit
    encodeFromRegistry
    KEY_WOW64_64
    KEY_WOW64_32
    getInterfaces
    getRegistryValue
    getRegistryKey
    getWMIObjects
    getLocalCodepage
    runCommand
    parseProductKey
);

sub is64bit {
    return
        any { $_->{AddressWidth} eq 64 }
        getWMIObjects(
            class => 'Win32_Processor', properties => [ qw/AddressWidth/ ]
        );
}

sub getLocalCodepage {
    if (!$localCodepage) {
        $localCodepage =
            "cp" .
            getRegistryValue(
                path => 'HKEY_LOCAL_MACHINE/SYSTEM/CurrentControlSet/Control/Nls/CodePage/ACP'
            );
    }

    return $localCodepage;
}

sub encodeFromRegistry {
    my ($string) = @_;

    ## no critic (ExplicitReturnUndef)
    return undef unless $string;

    return $string if Encode::is_utf8($string);

    return decode(getLocalCodepage(), $string);
}

sub getWMIObjects {
    my (%params) = (
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
            if (!ref($instance->{$property}) && $instance->{$property}) {
                # cast the Win32::OLE object in string
                $object->{$property} = sprintf("%s", $instance->{$property});

                # because of the Win32::OLE->Option(CP => Win32::OLE::CP_UTF8);
                # we know it's UTF8, let's flag the string according because
                # Win32::OLE don't do it
                utf8::upgrade($object->{$property});
            } else {
                $object->{$property} = $instance->{$property};
            }
        }
        push @objects, $object;
    }

    return @objects;
}

sub getRegistryValue {
    my (%params) = @_;

    my ($root, $keyName, $valueName);
    if ($params{path} =~ m{^(HKEY_\S+)/(.+)/([^/]+)} ) {
        $root      = $1;
        $keyName   = $2;
        $valueName = $3;
    } else {
        $params{logger}->error(
            "Failed to parse '$params{path}'. Does it start with HKEY_?"
        ) if $params{logger};
        return;
    }

    my $key = _getRegistryKey(
        logger  => $params{logger},
        root    => $root,
        keyName => $keyName
    );

    if ($valueName eq '*') {
        my %ret;
        foreach (keys %$key) {
            s{^/}{};
            $ret{$_}=$key->{"/$_"};
        }
        return \%ret;
    } else {
        return $key->{"/$valueName"};
    }
}

sub getRegistryKey {
    my (%params) = @_;

    my ($root, $keyName);
    if ($params{path} =~ m{^(HKEY_\S+)/(.+)} ) {
        $root      = $1;
        $keyName   = $2;
    } else {
        $params{logger}->error(
            "Failed to parse '$params{path}'. Does it start with HKEY_?"
        ) if $params{logger};
        return;
    }

    return _getRegistryKey(
        logger  => $params{logger},
        root    => $root,
        keyName => $keyName
    );
}

sub _getRegistryKey {
    my (%params) = @_;

    ## no critic (ProhibitBitwise)
    my $rootKey = is64bit() ?
        $Registry->Open($params{root}, { Access=> KEY_READ | KEY_WOW64_64 } ) :
        $Registry->Open($params{root}, { Access=> KEY_READ } )                ;

    if (!$rootKey) {
        $params{logger}->error(
            "Can't open $params{root} key: $EXTENDED_OS_ERROR"
        ) if $params{logger};
        return;
    }
    my $key = $rootKey->Open($params{keyName});

    return $key;
}

sub runCommand {
    my (%params) = (
        timeout => 3600 * 2,
        @_
    );

    my $job = Win32::Job->new();

    my $buff = File::Temp->new();

    my $winCwd = Cwd::getcwd();
    $winCwd =~ s{/}{\\}g;

    my ($fh, $filename) = File::Temp::tempfile( "$ENV{TEMP}\\fusinvXXXXXXXXXXX", SUFFIX => '.bat');
    print $fh "cd \"".$winCwd."\"\r\n";
    print $fh $params{command}."\r\n";
    print $fh "exit %ERRORLEVEL%\r\n";
    close $fh;

    my $args = {
        stdout    => $buff,
        no_window => 1
    };

    $job->spawn(
        "$ENV{SYSTEMROOT}\\system32\\cmd.exe",
        "start /wait cmd /c $filename",
        $args
    );

    $job->run($params{timeout});
    unlink($filename);

    $buff->seek(0, SEEK_SET);

    my $exitcode;

    my ($status) = $job->status();
    foreach my $pid (%$status) {
        $exitcode = $status->{$pid}{exitcode};
        last;
    }

    return ($exitcode, $buff);
}

# inspired by http://poshcode.org/4363
sub parseProductKey {
    my ($key_string) = @_;

    ## no critic (ProhibitBitwise)

    return unless $key_string;

    my @key_bytes = unpack 'C*', $key_string;

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

sub getInterfaces {

    my @configurations;

    foreach my $object (getWMIObjects(
        class      => 'Win32_NetworkAdapterConfiguration',
        properties => [ qw/Index Description IPEnabled DHCPServer MACAddress
                           MTU DefaultIPGateway DNSServerSearchOrder IPAddress
                           IPSubnet/  ]
    )) {

        my $configuration = {
            DESCRIPTION => $object->{Description},
            STATUS      => $object->{IPEnabled} ? "Up" : "Down",
            IPDHCP      => $object->{DHCPServer},
            MACADDR     => $object->{MACAddress},
            MTU         => $object->{MTU}
        };

        if ($object->{DefaultIPGateway}) {
            $configuration->{IPGATEWAY} = $object->{DefaultIPGateway}->[0];
        }

        if ($object->{DNSServerSearchOrder}) {
            $configuration->{dns} = $object->{DNSServerSearchOrder}->[0];
        }

        if ($object->{IPAddress}) {
            foreach my $address (@{$object->{IPAddress}}) {
                my $prefix = shift @{$object->{IPSubnet}};
                push @{$configuration->{addresses}}, [ $address, $prefix ];
            }
        }

        $configurations[$object->{Index}] = $configuration;
    }

    my @interfaces;

    foreach my $object (getWMIObjects(
        class      => 'Win32_NetworkAdapter',
        properties => [ qw/Index PNPDeviceID Speed PhysicalAdapter
                           AdapterTypeId/  ]
    )) {
        # http://comments.gmane.org/gmane.comp.monitoring.fusion-inventory.devel/34
        next unless $object->{PNPDeviceID};

        my $configuration = $configurations[$object->{Index}];

        if ($configuration->{addresses}) {
            foreach my $address (@{$configuration->{addresses}}) {

                my $interface = {
                    SPEED       => $object->{Speed},
                    PNPDEVICEID => $object->{PNPDeviceID},
                    MACADDR     => $configuration->{MACADDR},
                    DESCRIPTION => $configuration->{DESCRIPTION},
                    STATUS      => $configuration->{STATUS},
                    IPDHCP      => $configuration->{IPDHCP},
                    MTU         => $configuration->{MTU},
                    IPGATEWAY   => $configuration->{IPGATEWAY},
                    dns         => $configuration->{dns},
                };

                if ($address->[0] =~ /$ip_address_pattern/) {
                    $interface->{IPADDRESS} = $address->[0];
                    $interface->{IPMASK}    = $address->[1];
                    $interface->{IPSUBNET}  = getSubnetAddress(
                        $interface->{IPADDRESS},
                        $interface->{IPMASK}
                    );
                } else {
                    $interface->{IPADDRESS6} = $address->[0];
                    $interface->{IPMASK6}    = getNetworkMaskIPv6($address->[1]);
                    $interface->{IPSUBNET6}  = getSubnetAddressIPv6(
                        $interface->{IPADDRESS6},
                        $interface->{IPMASK6}
                    );
                }

                $interface->{VIRTUALDEV} = _isVirtual($object, $configuration);
                $interface->{TYPE}       = _getType($object);

                push @interfaces, $interface;
            }
        } else {
            next unless $configuration->{MACADDR};

            my $interface = {
                SPEED       => $object->{Speed},
                PNPDEVICEID => $object->{PNPDeviceID},
                MACADDR     => $configuration->{MACADDR},
                DESCRIPTION => $configuration->{DESCRIPTION},
                STATUS      => $configuration->{STATUS},
                IPDHCP      => $configuration->{IPDHCP},
                MTU         => $configuration->{MTU},
                IPGATEWAY   => $configuration->{IPGATEWAY},
                dns         => $configuration->{dns},
            };

            $interface->{VIRTUALDEV} = _isVirtual($object, $configuration);
            $interface->{TYPE}       = _getType($object);

            push @interfaces, $interface;
        }

    }

    return
        @interfaces;

}

sub _isVirtual {
    my ($object, $configuration) = @_;

    # PhysicalAdapter only work on OS > XP
    if (defined $object->{PhysicalAdapter}) {
        return $object->{PhysicalAdapter} ? 0 : 1;
    }

    # http://forge.fusioninventory.org/issues/1166
    if ($configuration->{DESCRIPTION} &&
        $configuration->{DESCRIPTION} =~ /RAS/ &&
        $configuration->{DESCRIPTION} =~ /Adapter/i
    ) {
          return 1;
    }

    return $object->{PNPDeviceID} =~ /^ROOT/ ? 1 : 0;
}

sub _getType {
    my ($object) = @_;

    return unless defined $object->{AdapterTypeId};

    # available adapter types:
    # http://msdn.microsoft.com/en-us/library/windows/desktop/aa394216%28v=vs.85%29.aspx
    # don't bother discriminating between wired and wireless ethernet adapters
    # for sake of simplicity
    return
        $object->{AdapterTypeId} == 0 ? 'ethernet' :
        $object->{AdapterTypeId} == 9 ? 'wifi'     :
                                        undef      ;
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

=head2 getLocalCodepage()

Returns the local codepage.

=head2 getWMIObjects(%params)

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

=head2 getRegistryKey(%params)

Returns a key from the registry. If key name is '*', all the keys of the path are returned as a hash reference.

=over

=item path a string in hive/key format

E.g: HKEY_LOCAL_MACHINE/SOFTWARE/Microsoft/Windows NT/CurrentVersion

=item logger

=back

=head2 runCommand(%params)

Returns a command in a Win32 Process

=over

=item command the command to run

=item timeout a time in second, default is 3600*2

=back

Return an array

=over

=item exitcode the error code, 293 means a timeout occurred

=item fd a file descriptor on the output

=back

=head2 parseProductKey($string)

Return a Parsed binary product key (XP, office, etc)

=head2 getInterfaces()

Returns the list of network interfaces.
