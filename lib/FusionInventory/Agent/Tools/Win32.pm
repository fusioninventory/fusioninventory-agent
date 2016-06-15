package FusionInventory::Agent::Tools::Win32;

use strict;
use warnings;
use base 'Exporter';
use utf8;

use threads;
use threads 'exit' => 'threads_only';
use threads::shared;

use UNIVERSAL::require();

use constant KEY_WOW64_64 => 0x100;
use constant KEY_WOW64_32 => 0x200;

use Cwd;
use Encode;
use English qw(-no_match_vars);
use File::Temp qw(:seekable tempfile);
use Win32::Job;
use Win32::TieRegistry (
    Delimiter   => '/',
    ArrayValues => 0,
    qw/KEY_READ/
);

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Network;

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

    my $WMIService = Win32::OLE->GetObject($params{moniker})
        or return;

    Win32::OLE->use('in');

    my @objects;
    foreach my $instance (in(
        $WMIService->InstancesOf($params{class})
    )) {
        my $object;
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
                dns         => $configuration->{dns},
            };

            $interface->{SPEED}      = $object->{Speed} / 1_000_000
                if $object->{Speed};
            $interface->{VIRTUALDEV} = _isVirtual($object, $configuration);

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

sub FileTimeToSystemTime {
    # Inspired by Win32::FileTime module
    my $time = shift;

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

my $worker ;
my $worker_semaphore;

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
    Win32::OLE->Option(CP => Win32::OLE::CP_UTF8());

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
            if (exists($call->{'array'}) && $call->{'array'}) {
                my @results = &{$funct}(@{$call->{'args'}});
                $result = \@results;
            } else {
                $result = &{$funct}(@{$call->{'args'}});
            }

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

=head2 getInterfaces()

Returns the list of network interfaces.

=head2 FileTimeToSystemTime()

Returns an array of a converted FILETIME datetime value with following order:
    ( year, month, wday, day, hour, minute, second, msecond )

=head2 start_Win32_OLE_Worker()

Under win32, just start a worker thread handling Win32::OLE dependent
APIs like is64bit() & getWMIObjects(). This is sometime needed to avoid
perl crashes.
