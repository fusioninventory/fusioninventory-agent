package FusionInventory::Agent::Task::Inventory::Win32::CPU;

use strict;
use warnings;

use English qw(-no_match_vars);
use Win32;
use Storable 'dclone';

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Win32;
use FusionInventory::Agent::Tools::Generic;

sub isEnabled {
    my (%params) = @_;
    return 0 if $params{no_category}->{cpu};
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};
    my $wmiParams = {};
    $wmiParams->{WMIService} = dclone ($params{inventory}->{WMIService}) if $params{inventory}->{WMIService};
    my @cpus = _getCPUs(logger => $logger, %$wmiParams);

    foreach my $cpu (@cpus) {
        $inventory->addEntry(
            section => 'CPUS',
            entry   => $cpu
        );
    }

    if (any { $_->{NAME} =~ /QEMU/i } @cpus) {
        $inventory->setHardware ({
            VMSYSTEM => 'QEMU'
        });
    }
}

sub _getCPUs {
    my (%params) = @_;

    my @dmidecodeInfos;
    my $registryInfos;
    my $path = "HKEY_LOCAL_MACHINE/Hardware/Description/System/CentralProcessor";
    if (!$params{WMIService}) {
        @dmidecodeInfos = Win32::GetOSName() eq 'Win2003' ?
            ()                                            : getCpusFromDmidecode();

        # the CPU description in WMI is false, we use the registry instead
        $registryInfos = getRegistryKey(
            path => $path,
            %params
        );
    }

    my $cpuId = 0;
    my @cpus;

    foreach my $object (getWMIObjects(
        %params,
        class      => 'Win32_Processor',
        properties => [ qw/NumberOfCores NumberOfLogicalProcessors ProcessorId MaxClockSpeed/ ]
    )) {

        my $cpu;
        if ($params{WMIService}) {
            $cpu = _retrieveCpuIdFromRemoteRegistry(
                %params,
                cpuId => $cpuId,
                path => $path,
                object => $object
            );
        } else {
            my $dmidecodeInfo = $dmidecodeInfos[$cpuId];
            my $registryInfo = $registryInfos->{"$cpuId/"};

            # Compute WMI threads for this CPU if not available in dmidecode, this is the case on win2003r2 with 932370 hotfix applied (see #2894)
            my $wmi_threads = !$dmidecodeInfo->{THREAD} && $object->{NumberOfCores} ? $object->{NumberOfLogicalProcessors} / $object->{NumberOfCores} : undef;

            # Split CPUID from its value inside registry
            my @splitted_identifier = split(/ |\n/, $registryInfo->{'/Identifier'});

            $cpu = {
                CORE         => $dmidecodeInfo->{CORE} || $object->{NumberOfCores},
                THREAD       => $dmidecodeInfo->{THREAD} || $wmi_threads,
                DESCRIPTION  => $registryInfo->{'/Identifier'},
                NAME         => trimWhitespace($registryInfo->{'/ProcessorNameString'}),
                MANUFACTURER => getCanonicalManufacturer($registryInfo->{'/VendorIdentifier'}),
                SERIAL       => $dmidecodeInfo->{SERIAL},
                SPEED        => $dmidecodeInfo->{SPEED} || $object->{MaxClockSpeed},
                FAMILYNUMBER => $splitted_identifier[2],
                MODEL        => $splitted_identifier[4],
                STEPPING     => $splitted_identifier[6],
                ID           => $dmidecodeInfo->{ID} || $object->{ProcessorId}
            };

            # Support CORECOUNT total available cores
            $cpu->{CORECOUNT} = $dmidecodeInfo->{CORECOUNT}
                if ($dmidecodeInfo->{CORECOUNT});
        }

        # Some information are missing on Win2000
        if (!$cpu->{NAME}) {
            $cpu->{NAME} = $ENV{PROCESSOR_IDENTIFIER};
            if ($cpu->{NAME} =~ s/,\s(\S+)$//) {
                $cpu->{MANUFACTURER} = $1;
            }
        }

        if ($cpu->{SERIAL}) {
            $cpu->{SERIAL} =~ s/\s//g;
        }

        if ($cpu->{NAME} =~ /([\d\.]+)s*(GHZ)/i) {
            $cpu->{SPEED} = {
                ghz => 1000,
                mhz => 1,
            }->{lc($2)} * $1;
        }

        push @cpus, $cpu;

        $cpuId++;
    }

    return @cpus;
}

sub _retrieveCpuIdFromRemoteRegistry {
    my (%params) = @_;

    my $path = $params{path};
    my $cpuId = $params{cpuId};
    my $object = $params{object};

    return unless $params{WMIService};

    my $cpuIdPath = $path . '/' . "$cpuId";
    my $wantedKeys = {
        Identifier => undef,
        ProcessorNameString => undef,
        VendorIdentifier => undef
    };
    my %filteredFields = map { $_ => 1 } keys %$wantedKeys;
    my $values = retrieveValuesNameAndType(
        %params,
        path => $cpuIdPath,
        fields => \%filteredFields
    );
    return unless $values;
    my %values = %$values;
    my %wantedKeys = %$wantedKeys;
    my @filtered_keys = grep { exists $values{$_} } keys %wantedKeys;
    @wantedKeys{@filtered_keys} = @values{@filtered_keys};

    $wantedKeys = \%wantedKeys;

    my $wmi_threads;
    if ($object->{NumberOfCores}) {
        $wmi_threads = $object->{NumberOfLogicalProcessors} / $object->{NumberOfCores};
    }

    # Split CPUID from its value inside registry
    my @splitted_identifier;
    if ($wantedKeys->{Identifier}) {
        @splitted_identifier = split(/ |\n/, $wantedKeys->{Identifier});
    }

    my $cpu = {
        CORE         => $object->{NumberOfCores},
        THREAD       => $wmi_threads,
        DESCRIPTION  => encodeFromRegistry($wantedKeys->{Identifier}),
        NAME         => trimWhitespace($wantedKeys->{ProcessorNameString}),
        MANUFACTURER => getCanonicalManufacturer($wantedKeys->{VendorIdentifier}),
        SERIAL       => '',
        SPEED        => $object->{MaxClockSpeed},
        FAMILYNUMBER => $splitted_identifier[2],
        MODEL        => $splitted_identifier[4],
        STEPPING     => $splitted_identifier[6],
        ID           => $object->{ProcessorId}
    };

    return $cpu;
}

1;
