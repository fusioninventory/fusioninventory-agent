package FusionInventory::Agent::Tools::Win32;

use strict;
use warnings;
use base 'Exporter';
use utf8;

use threads;
use threads 'exit' => 'threads_only';
use threads::shared;

use sigtrap qw(handler errorHandler untrapped);

use UNIVERSAL::require();
use UNIVERSAL;

use constant KEY_WOW64_64 => 0x100;
use constant KEY_WOW64_32 => 0x200;
use constant HKEY_LOCAL_MACHINE => 0x80000002;
use constant HKEY_USERS => 0x80000003;

use Cwd;
use Encode;
use English qw(-no_match_vars);
use File::Temp qw(:seekable tempfile);
use File::Basename qw(basename);
use Win32::Job;
use Win32::TieRegistry (
    Delimiter   => '/',
    ArrayValues => 0,
    qw/KEY_READ REG_SZ REG_EXPAND_SZ REG_DWORD REG_BINARY REG_MULTI_SZ/
);

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Network;
use FusionInventory::Agent::Version;

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
    FileTimeToSystemTime
    getUsersFromRegistry
    isDefinedRemoteRegistryKey
    getRegistryKeyFromWMI
    getRegistryValuesFromWMI
    retrieveValuesNameAndType
    retrieveKeyValuesFromRemote
    getAgentMemorySize
    FreeAgentMem
    getWMIService
    getRemoteLocaleFromWMI
    getFormatedWMIDateTime
);

my $_is64bits = undef;

sub errorHandler {}

sub is64bit {
    # Cache is64bit() result in a private module variable to avoid a lot of wmi
    # calls and as this value won't change during the service/task lifetime
    return $_is64bits if $_is64bits;
    return $_is64bits =
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
    my $win32_ole_dependent_api = {
        array => 1,
        funct => '_getWMIObjects',
        args  => \@_
    };

    return _call_win32_ole_dependent_api($win32_ole_dependent_api);
}

sub _getWMIObjects {
    my (%params) = (
        moniker => 'winmgmts:{impersonationLevel=impersonate,(security)}!//./',
        @_
    );

    my $WMIService;
    if (_remoteWmi()) {
        $WMIService = getWMIService(
            root => $params{root} || "root\\cimv2",
            @_
        );
        # Support alternate moniker if provided and main failed to open
        if (!defined($WMIService) && $params{altmoniker}) {
            $WMIService = getWMIService( moniker => $params{altmoniker} );
        }
    } else {
        $WMIService = Win32::OLE->GetObject($params{moniker});
        # Support alternate moniker if provided and main failed to open
        if (!defined($WMIService) && $params{altmoniker}) {
            $WMIService = Win32::OLE->GetObject($params{altmoniker});
        }
    }

    return unless (defined($WMIService));

    Win32::OLE->use('in');

    my @objects;
    foreach my $instance (in(
        $params{query} ?
        $WMIService->ExecQuery(@{$params{query}})
        :
        $WMIService->InstancesOf($params{class})
    )) {
        my $object;
        # Handle Win32::OLE object method, see _getLoggedUsers() method in
        # FusionInventory::Agent::Task::Inventory::Win32::Users as example to
        # use or enhance this feature
        if ($params{method}) {
            my @invokes = ( $params{method} );
            my %results = ();

            # Prepare Invoke params for known requested types
            foreach my $name (@{$params{params}}) {
                my ($type, $default) = @{$params{$name}}
                    or next;
                my $variant;
                if ($type eq 'string') {
                    Win32::OLE::Variant->use(qw/VT_BYREF VT_BSTR/);
                    eval {
                        $variant = VT_BYREF()|VT_BSTR();
                    };
                }
                eval {
                    $results{$name} = Win32::OLE::Variant::Variant($variant, $default);
                };
                push @invokes, $results{$name};
            }

            # Invoke the method saving the result so we can also bind it
            eval {
                $results{$params{method}} = $instance->Invoke(@invokes);
            };

            # Bind results to object to return
            foreach my $name (keys(%{$params{binds}})) {
                next unless (defined($results{$name}));
                my $bind = $params{binds}->{$name};
                eval {
                    $object->{$bind} = $results{$name}->Get();
                };
                if (defined $object->{$bind} && !ref($object->{$bind})) {
                    utf8::upgrade($object->{$bind});
                }
            }
        }
        foreach my $property (@{$params{properties}}) {
            if (defined $instance->{$property} && !ref($instance->{$property})) {
                # string value
                $object->{$property} = $instance->{$property};
                # despite CP_UTF8 usage, Win32::OLE downgrades string to native
                # encoding, if possible, ie all characters have code <= 0x00FF:
                # http://code.activestate.com/lists/perl-win32-users/Win32::OLE::CP_UTF8/
                utf8::upgrade($object->{$property});
            } elsif (defined $instance->{$property}) {
                # list value
                $object->{$property} = $instance->{$property};
            } else {
                $object->{$property} = undef;
            }
        }
        push @objects, $object;
    }

    return @objects;
}

sub getRegistryValue {
    my (%params) = @_;

    if (!$params{path}) {
        $params{logger}->error(
            "No registry value path provided"
        ) if $params{logger};
        return;
    }

    # Shortcut call in remote wmi case
    if (_remoteWmi()) {
        my $win32_ole_dependent_api = {
            funct => '_getRegistryValueFromWMI',
            args  => \@_
        };

        return _call_win32_ole_dependent_api($win32_ole_dependent_api);
    }

    my ($root, $keyName, $valueName);
    if ($params{path} =~ m{^(HKEY_\w+.*)/([^/]+)/([^/]+)} ) {
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

    return unless (defined($key));

    if ($valueName eq '*') {
        my %ret;
        foreach (keys %$key) {
            s{^/}{};
            $ret{$_} = $params{withtype} ? [$key->GetValue($_)] : $key->{"/$_"} ;
        }
        return \%ret;
    } else {
        return $params{withtype} ? [$key->GetValue($valueName)] : $key->{"/$valueName"} ;
    }
}

sub getRegistryValuesFromWMI {
    my $win32_ole_dependent_api = {
        funct => '_getRegistryValuesFromWMI',
        args  => \@_
    };

    return _call_win32_ole_dependent_api($win32_ole_dependent_api);
}

sub _getRegistryValuesFromWMI {
    my (%params) = @_;

    return unless ref($params{path}) eq 'ARRAY' || ref($params{path}) eq 'HASH';

    my $WMIService = getWMIService(%params);
    return unless $WMIService;
    my $objReg = $WMIService->Get("StdRegProv");
    return unless $objReg;

    if (ref($params{path}) eq 'ARRAY') {
        my %hash = ();
        %hash = map { $_ => 1 } @{$params{path}};
        $params{path} = \%hash;
    }

    my $values = {};
    for my $path (keys %{$params{path}}) {
        next unless $path =~ m{^(HKEY_\S+)/(.+)/([ ^ /]+)};
        my $root = $1;
        my $keyName = $2;
        my $valueName = $3;
        $values->{$path} = _retrieveRemoteRegistryValueByType(
            %params,
            root => $root,
            keyName => $keyName,
            valueName => $valueName,
            objReg => $objReg,
            valueType => $params{path}->{$path}
        );
    }
    return $values;
}

sub _getRegistryValueFromWMI {
    my (%params) = @_;

    if ($params{path} =~ m{^(HKEY_\S+)/(.+)/([^/]+)} ) {
        $params{root}      = $1;
        $params{keyName}   = $2;
        $params{valueName} = $3;
    } else {
        return;
    }

    my $WMIService = getWMIService(%params)
        or return;
    my $objReg = $WMIService->Get("StdRegProv")
        or return;

    my $value;
    $params{valueType} = REG_SZ() unless $params{valueType};
    eval {
        $value = _retrieveRemoteRegistryValueByType(
            %params,
            objReg => $objReg
        );
    };

    return $value;
}

sub isDefinedRemoteRegistryKey {
    my (%params) = @_;

    my $defined = 0;
    # has subKeys ?
    $defined = defined getRegistryKeyFromWMI(@_);
    return $defined if $defined;

    # has values ?
    $defined = defined retrieveValuesNameAndType(@_);
    return $defined if $defined;

    # is a value ?
    # we have to look at value type, so we use the value's parent path
    return $defined unless ($params{path} =~ /(HKEY.*)\/([^\/]+)/);
    my $parentPath = $1;
    my $valueName = $2;
    my $values = retrieveValuesNameAndType(
        %params,
        path => $parentPath
    );
    $defined = defined $values && defined $values->{$valueName};

    return $defined;
}

sub getRegistryKey {
    my (%params) = @_;

    if (!$params{path}) {
        $params{logger}->error(
            "No registry key path provided"
        ) if $params{logger};
        return;
    }

    my ($root, $keyName);
    if ($params{path} =~ m{^(HKEY_\w+.*)/([^/]+)} ) {
        $root      = $1;
        $keyName   = $2;
    } else {
        $params{logger}->error(
            "Failed to parse '$params{path}'. Does it start with HKEY_?"
        ) if $params{logger};
        return;
    }

    return _remoteWmi() ?
    getRegistryKeyFromWMI(
            %params,
            root => $root,
            keyName => $keyName
        )
    :
    _getRegistryKey(
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

sub getRegistryKeyFromWMI {
    my (%params) = @_;

    my $win32_ole_dependent_api = {
        funct => '_getRegistryKeyFromWMI',
        args  => \@_
    };

    my $keyNames = _call_win32_ole_dependent_api($win32_ole_dependent_api);

    if ($params{retrieveValuesForAllKeys}) {
        my %hash = map { $_ => 1 } @$keyNames;
        $keyNames = \%hash;
        for my $wantedKey (keys %$keyNames) {
            next if ($params{keysToKeep} && !($params{keysToKeep}->{$wantedKey}));
            my $wantedKeyPath = $params{path} . '/' . $wantedKey;
            eval {
                $keyNames->{$wantedKey} = retrieveValuesNameAndType(
                    @_,
                    # overwrite 'root' to force use of 'path'
                    root => 0,
                    path => $wantedKeyPath
                );
            };
            eval {
                if ($params{retrieveSubKeysForAllKeys}) {
                    my $subKeys = getRegistryKeyFromWMI(
                        @_,
                        # overwrite 'root' to force use of 'path'
                        root => 0,
                        path                     => $wantedKeyPath,
                        retrieveValuesForAllKeys => 1,
                    );
                    @{$keyNames->{$wantedKey}}{ keys %$subKeys } = values %$subKeys;
                }
            };
        }
    }
    return $keyNames;
}

sub _getRegistryKeyFromWMI{
    my (%params) = @_;

    return unless $params{WMIService};

    my $WMIService = getWMIService(%params);
    if (!$WMIService) {
        return;
    }
    my $objReg = $WMIService->Get("StdRegProv");
    if (!$objReg) {
        return;
    }

    if ($params{path} eq 'HKEY_USERS') {
        $params{root}      = $params{path};
        $params{keyName}   = "";
    } elsif ($params{path} =~ m{^(HKEY_\S+)/(.+)} ) {
        $params{root}      = $1;
        $params{keyName}   = $2;
    } else {
        return;
    }

    return _retrieveSubKeyList(
        %params,
        objReg => $objReg
    );
}

sub _retrieveSubKeyList {
    my (%params) = @_;

    Win32::OLE->use('in');

    my $hkey;
    if ($params{root} =~ /^HKEY_LOCAL_MACHINE(?:\\|\/)(.*)$/) {
        $hkey = $Win32::Registry::HKEY_LOCAL_MACHINE;
        my $keyName = $1 . '/' . $params{keyName};
        $keyName =~ tr#/#\\#;
        $params{keyName} = $keyName;
    } elsif ($params{root} =~ /^HKEY_USERS(?:\\|\/)(.*)$/) {
        $hkey = HKEY_USERS;
        my $keyName = $1 . '/' . $params{keyName};
        $keyName =~ tr#/#\\#;
        $params{keyName} = $keyName;
    } elsif ($params{root} eq 'HKEY_USERS') {
        $hkey = HKEY_USERS;
    } else {
        return;
    }

    my $arr = Win32::OLE::Variant->new( Win32::OLE::Variant::VT_ARRAY() | Win32::OLE::Variant::VT_VARIANT() | Win32::OLE::Variant::VT_BYREF()  , [1,1] );
    # Do not use Die for this method

    my $return = $params{objReg}->EnumKey($hkey, $params{keyName}, $arr);
    my $subKeys;
    if (defined $return && $return == 0 && $arr->Value) {
        $subKeys = [ ];
        foreach my $item (in( $arr->Value )) {
            push @$subKeys, $item;
        }
    }

    return $subKeys;
}

sub retrieveValuesNameAndType {
    my $win32_ole_dependent_api = {
        funct => '_retrieveValuesNameAndType',
        args  => \@_
    };

    return _call_win32_ole_dependent_api($win32_ole_dependent_api);
}

sub _retrieveValuesNameAndType {
    my (%params) = @_;

    unless ($params{root}) {
        if ($params{path} && $params{path} =~ m{^(HKEY_\S+)/(.+)}) {
            $params{root} = $1;
            $params{keyName} = $2;
        } elsif (!($params{keyName})) {
            return;
        }
    }

    my $hkey;
    if ($params{root} && $params{root} =~ /^HKEY_LOCAL_MACHINE(?:\\|\/)(.*)$/) {
        $hkey = $Win32::Registry::HKEY_LOCAL_MACHINE;
        my $keyName = $1 . '/' . $params{keyName};
        $keyName =~ tr#/#\\#;
        $params{keyName} = $keyName;
    } elsif ($params{root} && $params{root} =~ /^HKEY_USERS(?:\\|\/)(.*)$/) {
        $hkey = HKEY_USERS;
        my $keyName = $1 . '/' . $params{keyName};
        $keyName =~ tr#/#\\#;
        $params{keyName} = $keyName;
    } elsif ($params{hkey} && $params{hkey} eq 'HKEY_LOCAL_MACHINE') {
        $hkey = $Win32::Registry::HKEY_LOCAL_MACHINE;
    } elsif ($params{hkey} && $params{hkey} eq 'HKEY_USERS') {
        $hkey = HKEY_USERS;
    } else {
        $params{logger}->error(
            "Failed to parse '$params{path}'. Does it start with HKEY_?"
        ) if $params{logger};
        return;
    }

    unless ($params{objReg}) {
        return unless $params{WMIService};
        my $WMIService = getWMIService(%params);
        if (!$WMIService) {
            return;
        }
        my $objReg = $WMIService->Get("StdRegProv");
        if (!$objReg) {
            return;
        }
        $params{objReg} = $objReg;
    }

    my $values;
    my $types;
    my $arrValueTypes = Win32::OLE::Variant->new( Win32::OLE::Variant::VT_ARRAY() | Win32::OLE::Variant::VT_VARIANT() | Win32::OLE::Variant::VT_BYREF() , [1,1] );
    my $arrValueNames = Win32::OLE::Variant->new( Win32::OLE::Variant::VT_ARRAY() | Win32::OLE::Variant::VT_VARIANT() | Win32::OLE::Variant::VT_BYREF() , [1,1] );
    my $return = $params{objReg}->EnumValues($hkey, $params{keyName}, $arrValueNames, $arrValueTypes);

    if (defined $return && $return == 0) {
        $types = [ ];
        foreach my $item (in( $arrValueTypes->Value )) {
            next unless $item;
            push @$types, sprintf $item;
        }
        if (scalar (@$types) > 0) {
                my $i = 0;
            $values = { };
            foreach my $item (in( $arrValueNames->Value )) {
                next unless $item;
                my $valueName = sprintf $item;
                if ($params{fields} && !$params{fields}->{$valueName}) {

                } else {
                    $values->{$valueName} = eval {
                        _retrieveRemoteRegistryValueByType(
                            valueType => $types->[$i],
                            keyName   => $params{keyName},
                            valueName => $valueName,
                            objReg    => $params{objReg},
                            hkey      => $hkey,
                        );
                    };
                }
                $i++;
            }
        }
    }

    return $values;
}

sub _retrieveRemoteRegistryValueByType {
    my (%params) = @_;

    return unless $params{valueType} && $params{objReg} && $params{keyName};

    if ($params{root} && $params{root} =~ /^HKEY_LOCAL_MACHINE(?:\\|\/)(.*)$/) {
        $params{hkey} = $Win32::Registry::HKEY_LOCAL_MACHINE;
        my $keyName = $1 . '/' . $params{keyName};
        $keyName =~ tr#/#\\#;
        $params{keyName} = $keyName;
    } elsif ($params{root} && $params{root} =~ /^HKEY_USERS(?:\\|\/)(.*)$/) {
        $params{hkey} = HKEY_USERS;
        my $keyName = $1 . '/' . $params{keyName};
        $keyName =~ tr#/#\\#;
        $params{keyName} = $keyName;
    } elsif ($params{hkey} && $params{hkey} eq 'HKEY_LOCAL_MACHINE') {
        $params{hkey} = $Win32::Registry::HKEY_LOCAL_MACHINE;
    } elsif ($params{hkey} && $params{hkey} eq 'HKEY_USERS') {
        $params{hkey} = HKEY_USERS;
    }

    my $func1 = sub {
        die "thread is dying now (SEGV cached)\n";
    };
    my $value;
    {
        $SIG{SEGV} = \&$func1;

        my $result = Win32::OLE::Variant->new(Win32::OLE::Variant::VT_BYREF() | Win32::OLE::Variant::VT_BSTR(), 0);
        if ($params{valueType} == REG_BINARY()) {
            $params{objReg}->GetBinaryValue($params{hkey}, $params{keyName}, $params{valueName}, $result);
            $value = sprintf($result) if (defined $result);
        }
        elsif ($params{valueType} == REG_DWORD()) {
            $result = Win32::OLE::Variant->new(Win32::OLE::Variant::VT_BYREF() | Win32::OLE::Variant::VT_VARIANT(), '');
            $params{objReg}->GetDWORDValue($params{hkey}, $params{keyName}, $params{valueName}, $result);
            $value = sprintf($result) || $result->Value() if (defined $result);
        }
        elsif ($params{valueType} == REG_EXPAND_SZ()) {
            $params{objReg}->GetExpandedStringValue($params{hkey}, $params{keyName}, $params{valueName}, $result);
            $value = sprintf($result) if (defined $result);
        }
        elsif ($params{valueType} == REG_MULTI_SZ()) {
            $params{objReg}->GetMultiStringValue($params{hkey}, $params{keyName}, $params{valueName}, $result);
            $value = sprintf($result) if (defined $result);
        }
        elsif ($params{valueType} == REG_SZ()) {
            $value = $params{objReg}->GetStringValue($params{hkey}, $params{keyName}, $params{valueName}, $result);
            $value = $result->Value() || sprintf($result) if (defined $result);
        }
        else {
            $params{logger}->error('_retrieveRemoteRegistryValueByType() : wrong valueType !') if $params{logger};
        }
    }

    return $value || '';
}

sub getValueFromRemoteRegistryViaVbScript {
    my (%params) = @_;

    my @values = (
        'cscript',
        $params{WMIService}->{toolsdir} . '/' . 'getValueRemote.vbs',
        '"' . $params{WMIService}->{hostname} . '"',
        '"' . $params{WMIService}->{user} . '"',
        '"' . $params{WMIService}->{pass} . '"',
        '"' . $params{keyName} . '"',
        '"' . $params{valueName} . '"'
    );
    my $command .= join(' ', @values);
    my @lines = getAllLines(
        command => $command
    );

    my $value = '';
    $value = $lines[3] if scalar @lines >= 3;
    $value = '' if !(defined $value);

    return $value;
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

    my $provider = lc($FusionInventory::Agent::Version::PROVIDER);
    my $template = $ENV{TEMP}."\\".$provider."XXXXXXXXXXX";
    my ($fh, $filename) = File::Temp::tempfile( $template, SUFFIX => '.bat');
    print $fh "cd \"".$winCwd."\"\r\n";
    print $fh $params{command}."\r\n";
    print $fh "exit %ERRORLEVEL%\r\n";
    close $fh;

    my $args = {
        stdout    => $buff,
        stderr    => $buff,
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

sub getInterfaces {
    my (%params) = @_;

    my @properties = qw/Index Description IPEnabled DHCPServer MACAddress
                           MTU DefaultIPGateway DNSServerSearchOrder IPAddress
                           IPSubnet/;
    if ($params{additionalProperties}
        && $params{additionalProperties}->{NetWorkAdapterConfiguration}) {
        if (ref($params{additionalProperties}->{NetWorkAdapterConfiguration}) eq 'ARRAY') {
            push @properties, @{$params{additionalProperties}->{NetWorkAdapterConfiguration}};
        } else {
            delete $params{additionalProperties}->{NetWorkAdapterConfiguration};
        }
    }
    
    my @configurations;
    my @wmiResult =
            $params{list}
                && $params{list}->{Win32_NetworkAdapterConfiguration}
                && ref($params{list}->{Win32_NetworkAdapterConfiguration}) eq 'ARRAY' ?
        @{$params{list}->{Win32_NetworkAdapterConfiguration}} :
        getWMIObjects(
            class      => 'Win32_NetworkAdapterConfiguration',
            properties => \@properties
        );
    foreach my $object (@wmiResult) {

        my $configuration = {
            DESCRIPTION => $object->{Description},
            STATUS      => $object->{IPEnabled} ? "Up" : "Down",
            IPDHCP      => $object->{DHCPServer},
            MACADDR     => $object->{MACAddress},
            MTU         => $object->{MTU}
        };

        if ($params{additionalProperties}
            && $params{additionalProperties}->{NetWorkAdapterConfiguration}) {
            for my $prop (@{$params{additionalProperties}->{NetWorkAdapterConfiguration}}) {
                if (defined $object->{$prop}) {
                    $configuration->{$prop} = $object->{$prop};
                }
            }
        }

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

    @properties = qw/Index PNPDeviceID Speed PhysicalAdapter AdapterTypeId/;
    if ($params{additionalProperties}
        && $params{additionalProperties}->{NetWorkAdapter}) {
        if (ref($params{additionalProperties}->{NetWorkAdapter}) eq 'ARRAY') {
            push @properties, @{$params{additionalProperties}->{NetWorkAdapter}};
        } else {
            delete $params{additionalProperties}->{NetWorkAdapter};
        }
    }
    @wmiResult =
            $params{list} && $params{list}->{Win32_NetworkAdapter} ?
        @{$params{list}->{Win32_NetworkAdapter}} :
        getWMIObjects(
            class      => 'Win32_NetworkAdapter',
            properties => \@properties
        );
    foreach my $object (@wmiResult) {
        # http://comments.gmane.org/gmane.comp.monitoring.fusion-inventory.devel/34
        next unless $object->{PNPDeviceID};

        my $pciid;
        if ($object->{PNPDeviceID} =~ /PCI\\VEN_(\w{4})&DEV_(\w{4})&SUBSYS_(\w{4})(\w{4})/) {
            $pciid = join(':', $1 , $2 , $3 , $4);
        }

        my $configuration = $configurations[$object->{Index}];

        if ($configuration->{addresses}) {
            foreach my $address (@{$configuration->{addresses}}) {

                my $interface = {
                    PNPDEVICEID => $object->{PNPDeviceID},
                    PCIID       => $pciid,
                    MACADDR     => $configuration->{MACADDR},
                    DESCRIPTION => $configuration->{DESCRIPTION},
                    STATUS      => $configuration->{STATUS},
                    MTU         => $configuration->{MTU},
                    dns         => $configuration->{dns},
                };

                if ($params{additionalProperties}
                    && $params{additionalProperties}->{NetWorkAdapterConfiguration}) {
                    for my $prop (@{$params{additionalProperties}->{NetWorkAdapterConfiguration}}) {
                        if ($configuration->{$prop}) {
                            $interface->{$prop} = $configuration->{$prop};
                        }
                    }
                }
                if ($params{additionalProperties}
                    && $params{additionalProperties}->{NetWorkAdapter}) {
                    for my $prop (@{$params{additionalProperties}->{NetWorkAdapter}}) {
                        if ($object->{$prop}) {
                            $interface->{$prop} = $object->{$prop};
                        }
                    }
                }

                if ($address->[0] =~ /$ip_address_pattern/) {
                    $interface->{IPADDRESS} = $address->[0];
                    $interface->{IPMASK}    = $address->[1];
                    $interface->{IPSUBNET}  = getSubnetAddress(
                        $interface->{IPADDRESS},
                        $interface->{IPMASK}
                    );
                    $interface->{IPDHCP}    = $configuration->{IPDHCP};
                    $interface->{IPGATEWAY} = $configuration->{IPGATEWAY};
                } else {
                    $interface->{IPADDRESS6} = $address->[0];
                    $interface->{IPMASK6}    = getNetworkMaskIPv6($address->[1]);
                    $interface->{IPSUBNET6}  = getSubnetAddressIPv6(
                        $interface->{IPADDRESS6},
                        $interface->{IPMASK6}
                    );
                }

                $interface->{SPEED}      = $object->{Speed} / 1_000_000
                    if $object->{Speed};
                $interface->{VIRTUALDEV} = _isVirtual($object, $configuration);

                push @interfaces, $interface;
            }
        } else {
            next unless $configuration->{MACADDR};

            my $interface = {
                PNPDEVICEID => $object->{PNPDeviceID},
                PCIID       => $pciid,
                MACADDR     => $configuration->{MACADDR},
                DESCRIPTION => $configuration->{DESCRIPTION},
                STATUS      => $configuration->{STATUS},
                MTU         => $configuration->{MTU},
                dns         => $configuration->{dns}
            };

            $interface->{SPEED}      = $object->{Speed} / 1_000_000
                if $object->{Speed};
            $interface->{VIRTUALDEV} = _isVirtual($object, $configuration);

            if ($params{additionalProperties}
                && $params{additionalProperties}->{NetWorkAdapterConfiguration}) {
                for my $prop (@{$params{additionalProperties}->{NetWorkAdapterConfiguration}}) {
                    if ($configuration->{$prop}) {
                        $interface->{$prop} = $configuration->{$prop};
                    }
                }
            }
            if ($params{additionalProperties}
                && $params{additionalProperties}->{NetWorkAdapter}) {
                for my $prop (@{$params{additionalProperties}->{NetWorkAdapter}}) {
                    if ($configuration->{$prop}) {
                        $interface->{$prop} = $configuration->{$prop};
                    }
                }
            }

            push @interfaces, $interface;
        }

    }

    return @interfaces;

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

sub FileTimeToSystemTime {
    # Inspired by Win32::FileTime module
    my $time = shift;

    return unless defined($time);

    my $SystemTime = pack( 'SSSSSSSS', 0, 0, 0, 0, 0, 0, 0, 0 );

    # Load Win32::API as late as possible
    Win32::API->require() or return;

    my @times;
    eval {
        my $FileTimeToSystemTime = Win32::API->new(
            'kernel32',
            'FileTimeToSystemTime',
            [ 'P', 'P' ],
            'I'
        );

        $FileTimeToSystemTime->Call( $time, $SystemTime );
        @times = unpack( 'SSSSSSSS', $SystemTime );
    };

    return @times;
}

sub getAgentMemorySize {

    # Load Win32::API as late as possible
    Win32::API->require() or return;

    # Get current thread handle
    my $thread;
    eval {
        my $apiGetCurrentThread = Win32::API->new(
            'kernel32',
            'GetCurrentThread',
            [],
            'I'
        );
        $thread = $apiGetCurrentThread->Call();
    };
    return -1 unless (defined($thread));

    # Get system ProcessId for current thread
    my $thread_pid;
    eval {
        my $apiGetProcessIdOfThread = Win32::API->new(
            'kernel32',
            'GetProcessIdOfThread',
            [ 'I' ],
            'I'
        );
        $thread_pid = $apiGetProcessIdOfThread->Call($thread);
    };
    return -1 unless (defined($thread_pid));

    # Get Process Handle
    my $ph;
    eval {
        my $apiOpenProcess = Win32::API->new(
            'kernel32',
            'OpenProcess',
            [ 'I', 'I', 'I' ],
            'I'
        );
        $ph = $apiOpenProcess->Call(0x400, 0, $thread_pid);
    };
    return -1 unless (defined($ph));

    my $size = -1;
    eval {
        # memory usage is bundled up in ProcessMemoryCounters structure
        # populated by GetProcessMemoryInfo() win32 call
        Win32::API::Struct->typedef('PROCESS_MEMORY_COUNTERS', qw(
            DWORD  cb;
            DWORD  PageFaultCount;
            SIZE_T PeakWorkingSetSize;
            SIZE_T WorkingSetSize;
            SIZE_T QuotaPeakPagedPoolUsage;
            SIZE_T QuotaPagedPoolUsage;
            SIZE_T QuotaPeakNonPagedPoolUsage;
            SIZE_T QuotaNonPagedPoolUsage;
            SIZE_T PagefileUsage;
            SIZE_T PeakPagefileUsage;
        ));

        # initialize PROCESS_MEMORY_COUNTERS structure
        my $mem_counters = Win32::API::Struct->new( 'PROCESS_MEMORY_COUNTERS' );
        foreach my $key (qw/cb PageFaultCount PeakWorkingSetSize WorkingSetSize
            QuotaPeakPagedPoolUsage QuotaPagedPoolUsage QuotaPeakNonPagedPoolUsage
            QuotaNonPagedPoolUsage PagefileUsage PeakPagefileUsage/) {
                 $mem_counters->{$key} = 0;
        }
        my $cb = $mem_counters->sizeof();

        # Request GetProcessMemoryInfo API and call it to find current process memory
        my $apiGetProcessMemoryInfo = Win32::API->new(
            'psapi',
            'BOOL GetProcessMemoryInfo(
                HANDLE hProc,
                LPPROCESS_MEMORY_COUNTERS ppsmemCounters, DWORD cb
            )'
        );
        if ($apiGetProcessMemoryInfo->Call($ph, $mem_counters, $cb)) {
            # Uses WorkingSetSize as process memory size
            $size = $mem_counters->{WorkingSetSize};
        }
    };

    return $size;
}

sub FreeAgentMem {

    # Load Win32::API as late as possible
    Win32::API->require() or return;

    eval {
        # Get current process handle
        my $apiGetCurrentProcess = Win32::API->new(
            'kernel32',
            'HANDLE GetCurrentProcess()'
        );
        my $proc = $apiGetCurrentProcess->Call();

        # Call SetProcessWorkingSetSize with magic parameters for freeing our memory
        my $apiSetProcessWorkingSetSize = Win32::API->new(
            'kernel32',
            'SetProcessWorkingSetSize',
            [ 'I', 'I', 'I' ],
            'I'
        );
        $apiSetProcessWorkingSetSize->Call( $proc, -1, -1 );
    };
}

my $worker ;
my $worker_semaphore;
my $wmiService;
my $wmiLocator;
my $wmiParams = {};

my @win32_ole_calls : shared;

sub start_Win32_OLE_Worker {

    unless (defined($worker)) {
        # Request a semaphore on which worker blocks immediatly
        Thread::Semaphore->require();
        $worker_semaphore = Thread::Semaphore->new(0);

        # Start a worker thread
        $worker = threads->create( \&_win32_ole_worker );
    }
}

sub _win32_ole_worker {
    # Load Win32::OLE as late as possible in a dedicated worker
    Win32::OLE->require() or return;
    Win32::OLE::Variant->require() or return;
    Win32::OLE->Option(CP => Win32::OLE::CP_UTF8());
    Win32::OLE->use('in');

    local $SIG{SEGV} = 'DEFAULT';

    while (1) {
        # Always block until semaphore is made available by main thread
        $worker_semaphore->down();

        my ($call, $result);
        {
            lock(@win32_ole_calls);
            $call = shift @win32_ole_calls
                if (@win32_ole_calls);
        }

        if (defined($call)) {
            lock($call);

            # Found requested private function and call it as expected
            my $funct;
            eval {
                no strict 'refs'; ## no critic (ProhibitNoStrict)
                $funct = \&{$call->{'funct'}};
            };
            eval {
                if (exists($call->{'array'}) && $call->{'array'}) {
                    my @results = &{$funct}(@{$call->{'args'}});
                    $result = \@results;
                } else {
                    $result = &{$funct}(@{$call->{'args'}});
                }
            };

            # Share back the result
            $call->{'result'} = shared_clone($result);

            # Signal main thread result is available
            cond_signal($call);
        }
    }
}

sub _call_win32_ole_dependent_api {
    my ($call) = @_
        or return;

    if (defined($worker)) {
        # Share the expect call
        my $call = shared_clone($call);
        my $result;

        if (defined($call)) {
            # Be sure the worker block
            $worker_semaphore->down_nb();

            # Lock list calls before releasing semaphore so worker waits
            # on it until we start cond_timedwait for signal on $call
            lock(@win32_ole_calls);
            push @win32_ole_calls, $call;

            # Release semaphore so the worker can continue its job
            $worker_semaphore->up();

            # Now, wait for worker result with one minute timeout
            my $timeout = time + 60;
            while (!exists($call->{'result'})) {
                last if (!cond_timedwait($call, $timeout, @win32_ole_calls));
            }

            # Be sure to always block worker on semaphore from now
            $worker_semaphore->down_nb();

            if (exists($call->{'result'})) {
                $result = $call->{'result'};
            } else {
                # Worker is failing: get back to mono-thread and pray
                $worker->detach();
                $worker = undef;
                return _call_win32_ole_dependent_api(@_);
            }
        }

        return (exists($call->{'array'}) && $call->{'array'}) ?
            @{$result || []} : $result ;
    } else {
        # Load Win32::OLE as late as possible
        Win32::OLE->require() or return;
        Win32::OLE::Variant->require() or return;
        Win32::OLE->Option(CP => Win32::OLE::CP_UTF8());

        # We come here from worker or if we failed to start worker
        my $funct;
        eval {
            no strict 'refs'; ## no critic (ProhibitNoStrict)
            $funct = \&{$call->{'funct'}};
        };
        return &{$funct}(@{$call->{'args'}});
    }
}

sub getUsersFromRegistry {
    my (%params) = @_;

    my $logger = $params{logger};

    my $profileListKey = 'SOFTWARE/Microsoft/Windows NT/CurrentVersion/ProfileList';
    my $profileList;

    if (remoteWmi()) {
        $profileList = getRegistryKeyFromWMI(
            %params,
            path => 'HKEY_LOCAL_MACHINE/' . $profileListKey,
            retrieveValuesForAllKeys => 1
        );
    } else {
        # ensure native registry access, not the 32 bit view
        my $flags = is64bit() ? KEY_READ | KEY_WOW64_64 : KEY_READ;
        my $machKey = $Registry->Open('LMachine', {
                Access => $flags
            }) or $logger->error("Can't open HKEY_LOCAL_MACHINE key: $EXTENDED_OS_ERROR");
        if (!$machKey) {
            $logger->error("getUsersFromRegistry() : Can't open HKEY_LOCAL_MACHINE key: $EXTENDED_OS_ERROR");
            return;
        }
        $logger->debug2('getUsersFromRegistry() : opened LMachine registry key');
        my $profileList = $machKey->{$profileListKey};
    }
    next unless $profileList;

    my $userList;
    foreach my $profileName (keys %$profileList) {
        $params{logger}->debug2('profileName : ' . $profileName);
        next unless $profileName =~ m{/$};
        next unless length($profileName) > 10;
        my $profilePath = $profileList->{$profileName}{'/ProfileImagePath'};
        my $sid = $profileList->{$profileName}{'/Sid'};
        next unless $sid;
        next unless $profilePath;
        my $user = basename($profilePath);
        $userList->{$profileName} = $user;
    }

    if ($params{logger}) {
        $params{logger}->debug2('getUsersFromRegistry() : retrieved ' . scalar(keys %$userList) . ' users');
    }
    return $userList;
}

sub _remoteWmi {
    return $wmiParams->{host} ? 1 : 0;
}

sub _connectToService {
    my (%params) = @_;

    # Be sure to reset known access params in threaded version so
    # getWMIService won't reset when called from right thread
    foreach my $param (qw( host user pass root locale)) {
        $wmiParams->{$param} = $params{$param};
    }

    Win32::OLE->require() or return;

    $wmiLocator = Win32::OLE->CreateObject('WbemScripting.SWbemLocator')
        or return;

    $wmiService = $wmiLocator->ConnectServer(
        $params{host}, $params{root},
        $params{user}, $params{pass},
        $params{locale}
    );

    return defined $wmiService;
}

sub getWMIService {
    my (%params) = @_;

    my $host   = $params{host} || $wmiParams->{host} || '127.0.0.1';
    my $user   = $params{user} || $wmiParams->{user} || '';
    my $pass   = $params{pass} || $wmiParams->{pass} || '';
    my $root   = $params{root} || $wmiParams->{root} || 'root\\cimv2';
    my $locale = $params{locale} || $wmiParams->{locale} || '';

    # Reset root if found in moniker params
    if ($params{moniker} && $params{moniker} =~ /root\\(.*)$/i) {
        $root = "root\\" . lc($1);
    }

    # check if the connection is right otherwise reset it
    if (!$wmiService || $wmiParams
                && $wmiParams->{host} eq $host
                && $wmiParams->{user} eq $user
                && $wmiParams->{pass} eq $pass
                && $wmiParams->{root} eq $root
                && $wmiParams->{locale} eq $locale) {

        $wmiParams = {
            host    => $host,
            user    => $user,
            pass    => $pass,
            root    => $root,
            locale  => $locale
        };

        my $win32_ole_dependent_api = {
            funct => '_connectToService',
            args  => [ %{$wmiParams} ]
        };

        my $connected = _call_win32_ole_dependent_api($win32_ole_dependent_api);

        # Only set $wmiService as connected status in main thread if worker is active
        $wmiService = $connected if (defined($worker));
    }

    return $wmiService;
}

sub getRemoteLocaleFromWMI {
    my ($obj) = getWMIObjects(
        class      => "Win32_OperatingSystem",
        properties => [ qw/ Locale / ]
    );
    return $obj->{Locale};
}

sub getFormatedWMIDateTime {
    my ($datetime) = @_;

    return unless $datetime &&
        $datetime =~ /^(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})\.\d{6}.(\d{3})$/;

    # Timezone in $7 is ignored

    return getFormatedDate($1, $2, $3, $4, $5, $6);
}

END {
    # Just detach worker
    $worker->detach() if (defined($worker) && !$worker->is_detached());
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

Returns the list of objects from given WMI class or from a query, with given
properties, properly encoded.

=over

=item moniker a WMI moniker (default: winmgmts:{impersonationLevel=impersonate,(security)}!//./)

=item altmoniker another WMI moniker to use if first failed (none by default)

=item class a WMI class, not used if query parameter is also given

=item properties a list of WMI properties

=item query a WMI request to execute, if specified, class parameter is not used

=item method an object method to call, in that case, you will also need the
following parameters:

=item params a list ref to the parameters to use fro the method. This list contains
string as key to other parameters defining the call. The key names should not
match any exiting parameter definition. Each parameter definition must be a list
of the type and default value.

=item binds a hash ref to the properties to bind to the returned object

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

=head2 getInterfaces()

Returns the list of network interfaces.

=head2 FileTimeToSystemTime()

Returns an array of a converted FILETIME datetime value with following order:
    ( year, month, wday, day, hour, minute, second, msecond )

=head2 start_Win32_OLE_Worker()

Under win32, just start a worker thread handling Win32::OLE dependent
APIs like is64bit() & getWMIObjects(). This is sometime needed to avoid
perl crashes.
