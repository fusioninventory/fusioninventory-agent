package FusionInventory::Agent::Task::SNMPQuery;

use strict;
use warnings;
use threads;
use threads::shared;
if ($threads::VERSION > 1.32){
   threads->set_stack_size(20*8192);
}
use base 'FusionInventory::Agent::Task';

use constant ALIVE => 0;
use constant DEAD  => 1;

use Encode qw(encode);
use English qw(-no_match_vars);

use FusionInventory::Agent::SNMP;
use FusionInventory::Agent::XML::Query;
use FusionInventory::Agent::Task::SNMPQuery::Tools;

our $VERSION = '2.0';

# list of devices properties, indexed by XML element name
# the link to a specific OID is made by the model

# generic properties
my %properties = (
    MAC          => 'macaddr',
    CPU          => 'cpu',
    LOCATION     => 'location',
    FIRMWARE     => 'firmware',
    CONTACT      => 'contant',
    COMMENTS     => 'comments',
    UPTIME       => 'uptime',
    SERIAL       => 'serial',
    NAME         => 'name',
    MODEL        => 'model',
    MODEL        => 'entPhysicalModelName',
    MANUFACTURER => 'enterprise',
    OTHERSERIAL  => 'otherserial',
    MEMORY       => 'memory',
    RAM          => 'ram',
);

# printer catridge simple properties
my %printer_cartridges_simple_properties = (
    TONERBLACK            => 'tonerblack',
    TONERBLACK2           => 'tonerblack2',
    TONERCYAN             => 'tonercyan',
    TONERMAGENTA          => 'tonermagenta',
    TONERYELLOW           => 'toneryellow',
    WASTETONER            => 'wastetoner',
    CARTRIDGEBLACK        => 'cartridgeblack',
    CARTRIDGEBLACKPHOTO   => 'cartridgeblackphoto',
    CARTRIDGECYAN         => 'cartridgecyan',
    CARTRIDGECYANLIGHT    => 'cartridgecyanlight',
    CARTRIDGEMAGENTA      => 'cartridgemagenta',
    CARTRIDGEMAGENTALIGHT => 'cartridgemagentalight',
    CARTRIDGEYELLOW       => 'cartridgeyellow',
    MAINTENANCEKIT        => 'maintenancekit',
    DRUMBLACK             => 'drumblack',
    DRUMCYAN              => 'drumcyan',
    DRUMMAGENTA           => 'drummagenta',
    DRUMYELLOW            => 'drumyellow',
);

# printer cartridge percent properties
my %printer_cartridges_percent_properties = (
    BLACK                 => 'cartridgesblack',
    CYAN                  => 'cartridgescyan',
    YELLOW                => 'cartridgesyellow',
    MAGENTA               => 'cartridgesmagenta',
    CYANLIGHT             => 'cartridgescyanlight',
    MAGENTALIGHT          => 'cartridgesmagentalight',
    PHOTOCONDUCTOR        => 'cartridgesphotoconductor',
    PHOTOCONDUCTORBLACK   => 'cartridgesphotoconductorblack',
    PHOTOCONDUCTORCOLOR   => 'cartridgesphotoconductorcolor',
    PHOTOCONDUCTORCYAN    => 'cartridgesphotoconductorcyan',
    PHOTOCONDUCTORYELLOW  => 'cartridgesphotoconductoryellow',
    PHOTOCONDUCTORMAGENTA => 'cartridgesphotoconductormagenta',
    UNITTRANSFERBLACK     => 'cartridgesunittransfertblack',
    UNITTRANSFERCYAN      => 'cartridgesunittransfertcyan',
    UNITTRANSFERYELLOW    => 'cartridgesunittransfertyellow',
    UNITTRANSFERMAGENTA   => 'cartridgesunittransfertmagenta',
    WASTE                 => 'cartridgeswaste',
    FUSER                 => 'cartridgesfuser',
    BELTCLEANER           => 'cartridgesbeltcleaner',
    MAINTENANCEKIT        => 'cartridgesmaintenancekit',
);

# printer page counter properties
my %printer_pagecounters_properties = (
    TOTAL      => 'pagecountertotalpages',
    BLACK      => 'pagecounterblackpages',
    COLOR      => 'pagecountercolorpages',
    RECTOVERSO => 'pagecounterrectoversopages',
    SCANNED    => 'pagecounterscannedpages',
    PRINTTOTAL => 'pagecountertotalpages_print',
    PRINTBLACK => 'pagecounterblackpages_print',
    PRINTCOLOR => 'pagecountercolorpages_print',
    COPYTOTAL  => 'pagecountertotalpages_copy',
    COPYBLACK  => 'pagecounterblackpages_copy',
    COPYCOLOR  => 'pagecountercolorpages_copy',
    FAXTOTAL   => 'pagecountertotalpages_fax',
);


my @ports_dispatch_table = (
    {
        match   => qr/Cisco/,
        trunk   => __PACKAGE__ . '::Manufacturer::Cisco',
        devices => __PACKAGE__ . '::Manufacturer::Cisco',
    },
    {
        match   => qr/ProCurve/,
        trunk   => __PACKAGE__ . '::Manufacturer::Cisco',
        devices => __PACKAGE__ . '::Manufacturer::ProCurve',
    },
    {
        match   => qr/Nortel/,
        trunk   => __PACKAGE__ . '::Manufacturer::Nortel',
        devices => __PACKAGE__ . '::Manufacturer::Nortel',
    },
);

my @mac_dispatch_table = (
    {
        match    => qr/3Com IntelliJack/,
        module   =>  __PACKAGE__ . '::Manufacturer::3Com',
        function => 'RewritePortOf225',
    },
    {
        match    => qr/3Com/,
        module   => __PACKAGE__ . '::Manufacturer::3Com',
        function => 'setMacAddresses',
    },
    {
        match    => qr/ProCurve/,
        module   => __PACKAGE__ . '::Manufacturer::ProCurve',
        function => 'setMacAddresses'
    },
    {
        match    => qr/Nortel/,
        module   => __PACKAGE__ . '::Manufacturer::Nortel',
        function => 'setMacAddresses'
    },
);

sub run {
    my ($self) = @_;

    if (!$self->{target}->isa('FusionInventory::Agent::Target::Server')) {
        $self->{logger}->debug("No server. Exiting...");
        return;
    }

    my $response = $self->{prologresp};
    if (!$response) {
        $self->{logger}->debug("No server response. Exiting...");
        return;
    }

    my $options = $response->getOptionsInfoByName('SNMPQUERY');
    if (!$options) {
        $self->{logger}->debug(
            "No SNMP query requested in the prolog, exiting"
        );
        return;
    }

    $self->{logger}->debug("FusionInventory SNMPQuery module ".$VERSION);

    my $params  = $options->{PARAM}->[0];

    # SNMP models
    my $models = _getIndexedModels($options->{MODEL});

    # SNMP credentials
    my $credentials = _getIndexedCredentials($options->{AUTHENTICATION});

    # send initial message to the server
    $self->_sendMessage({
        AGENT => {
            START        => 1,
            AGENTVERSION => $FusionInventory::Agent::VERSION
        },
        MODULEVERSION => $VERSION,
        PROCESSNUMBER => $params->{PID}
    });

    # create the required number of threads, sharing variables
    # for synchronisation
    my $maxIdx  : shared = 0;
    my @devices : shared = @{$options->{DEVICE}};
    my @threads : shared;

    # no need for more threads than devices to scan
    my $nb_threads = $params->{THREADS_QUERY};
    if ($nb_threads > @devices) {
        $nb_threads = @devices;
    }

    #===================================
    # Create all Threads
    #===================================
    for (my $j = 0; $j < $nb_threads; $j++) {
        $threads[$j] = {
            id    => $j,
            state => ALIVE
        };

        threads->create(
            '_queryDevices',
            $self,
            $threads[$j],
            \@devices,
            $models,
            $credentials,
            $maxIdx,
            $params->{PID},
        )->detach();
        sleep 1;
    }

    # wait for all threads to reach DEAD state
    while (any { $_->{state} != DEAD } @threads) {
        sleep 1;
    }

    # send results to the server
    my $storage = $self->{target}->getStorage();
    foreach my $idx (1..$maxIdx) {
        my $data = $storage->restore(
            idx => $idx
        );
        $data->{MODULEVERSION} = $VERSION;
        $data->{PROCESSNUMBER} = $params->{PID};
        $self->_sendMessage($data);
        $storage->remove(
            idx => $idx
        );
        sleep 1;
    }

    # send final message to the server
    $self->_sendMessage({
        AGENT => {
            END => 1,
        },
        MODULEVERSION => $VERSION,
        PROCESSNUMBER => $params->{PID}
    });
}

sub _sendMessage {
   my ($self, $content) = @_;

   my $message = FusionInventory::Agent::XML::Query->new(
       deviceid => $self->{deviceid},
       query    => 'SNMPQUERY',
       content  => $content
   );

   $self->{client}->send(
       url     => $self->{target}->getUrl(),
       message => $message
   );
}

sub _queryDevices {
    my ($self, $thread, $devices, $models, $credentials, $maxIdx) = @_;

    $self->{logger}->debug("Thread $thread->{id} created");

    my $storage = $self->{target}->getStorage();

    RUN: while (1) {
        my $device;
        {
            lock $devices;
            $device = pop @{$devices};
        }
        last RUN unless $device;

        my $result = $self->_queryDevice(
            device      => $device,
            model       => $models->{$device->{MODELSNMP_ID}},
            credentials => $credentials->{$device->{AUTHSNMP_ID}}
        );

        $maxIdx++;
        $self->{storage}->save(
            idx  => $maxIdx,
            data => {
                DEVICE => $result,
            }
        );
                 
        sleep 1;
    }

    $thread->{state} = DEAD;
    $self->{logger}->debug("Thread $thread->{id} deleted");
}

sub _getIndexedModels {
    my ($models) = @_;

    foreach my $model (@{$models}) {
        # index GET and WALK properties
        $model->{GET}  = { map { $_->{OBJECT} => $_ } @{$model->{GET}}  };
        $model->{WALK} = { map { $_->{OBJECT} => $_ } @{$model->{WALK}} };
    }

    # index models by their ID
    return { map { $_->{ID} => $_ } @{$models} };
}

sub _getIndexedCredentials {
    my ($credentials) = @_;

    # index credentials by their ID
    return { map { $_->{ID} => $_ } @{$credentials} };
}

sub _queryDevice {
    my ($self, %params) = @_;

    my $credentials = $params{credentials};
    my $model       = $params{model};
    my $device      = $params{device};

    my $snmp;
    eval {
        $snmp = FusionInventory::Agent::SNMP->new(
            version      => $credentials->{VERSION},
            hostname     => $device->{IP},
            community    => $credentials->{COMMUNITY},
            username     => $credentials->{USERNAME},
            authpassword => $credentials->{AUTHPASSWORD},
            authprotocol => $credentials->{AUTHPROTOCOL},
            privpassword => $credentials->{PRIVPASSWORD},
            privprotocol => $credentials->{PRIVPROTOCOL},
            translate    => 1,
        );
    };
    if ($EVAL_ERROR) {
        $self->{logger}->error("Unable to create SNMP session for $device->{IP}: $EVAL_ERROR");
        return;
    }

    my $description = $snmp->get('.1.3.6.1.2.1.1.1.0');
    if (!$description) {
        return {
            ERROR => {
                ID      => $device->{ID},
                TYPE    => $device->{TYPE},
                MESSAGE => "No response from remote host"
            }
        };
    }

    # automatically extend model for cartridge support
    if ($device->{TYPE} eq "PRINTER") {
        foreach my $variable (values %{$model->{GET}}) {
            my $object = $variable->{OBJECT};
            if (
                $object eq "wastetoner"     ||
                $object eq "maintenancekit" ||
                $object =~ /^toner/         ||
                $object =~ /^cartridge/     ||
                $object =~ /^drum/
            ) {
                my $type_oid = $variable->{OID};
                $type_oid =~ s/43.11.1.1.6/43.11.1.1.8/;
                my $level_oid = $variable->{OID};
                $level_oid =~ s/43.11.1.1.6/43.11.1.1.9/;

                $model->{GET}->{"$object-capacitytype"} = {
                    OID  => $type_oid,
                    VLAN => 0
                };
                $model->{GET}->{"$object-level"} = {
                    OID  => $level_oid,
                    VLAN => 0
                };
            }
        }
    }

    # first, fetch values from device
    my $results;
    foreach my $variable (values %{$model->{GET}}) {
        next if $variable->{VLAN};
        $results->{$variable->{OBJECT}} = $snmp->get($variable->{OID});
    }
    foreach my $variable (values %{$model->{WALK}}) {
        $results->{$variable->{OBJECT}} = $snmp->walk($variable->{OID});
    }

    # second, use results to build the object
    my $datadevice = {
        INFO => {
            ID   => $device->{ID},
            TYPE => $device->{TYPE}
        }
    };
    my $index;
    $self->_setGenericProperties($results, $datadevice, $index, $model->{WALK});
    $self->_setPrinterProperties($results, $datadevice)
        if $device->{TYPE} eq 'PRINTER';
    $self->_setNetworkingProperties($results, $datadevice, $index, $model->{WALK}, $device->{IP}, $credentials)
        if $device->{TYPE} eq 'NETWORKING';

    return $datadevice;
}

sub _setGenericProperties {
    my ($self, $results, $datadevice, $index, $walks) = @_;

    if (exists $results->{cpuuser}) {
        $datadevice->{INFO}->{CPU} = $results->{cpuuser} + $results->{cpusystem};
    }

    if (exists $results->{firmware1}) {
        $datadevice->{INFO}->{FIRMWARE} = $results->{firmware1} . ' ' . $results->{firmware2};
    }

    foreach my $key (keys %properties) {
        my $raw_value = $results->{$properties{$key}};
        my $value =
            $key eq 'NAME'        ? hex2string($raw_value)        :
            $key eq 'OTHERSERIAL' ? hex2string($raw_value)        :
            $key eq 'SERIAL'      ? _sanitizedSerial($raw_value)  :
            $key eq 'RAM'         ? int($raw_value / 1024 / 1024) :
            $key eq 'MEMORY'      ? int($raw_value / 1024 / 1024) :
                                    $raw_value                    ;
        $datadevice->{INFO}->{$key} = $value;
    }


    if (exists $results->{ipAdEntAddr}) {
        my $i = 0;
        while (my ($object, $data) = each %{$results->{ipAdEntAddr}}) {
            $datadevice->{INFO}->{IPS}->{IP}->[$i] = $data;
            $i++;
        }
    }

    if (exists $results->{ifIndex}) {
        my $num = 0;
        while (my ($object, $data) = each %{$results->{ifIndex}}) {
            $index->{lastSplitObject($object)} = $num;
            $datadevice->{PORTS}->{PORT}->[$num]->{IFNUMBER} = $data;
            $num++;
        }
    }

    if (exists $results->{ifdescr}) {
        while (my ($object, $data) = each %{$results->{ifdescr}}) {
            $datadevice->{PORTS}->{PORT}->[$index->{lastSplitObject($object)}]->{IFDESCR} = $data;
        }
    }

    if (exists $results->{ifName}) {
        while (my ($object, $data) = each %{$results->{ifName}}) {
            $datadevice->{PORTS}->{PORT}->[$index->{lastSplitObject($object)}]->{IFNAME} = $data;
        }
    }

    if (exists $results->{ifType}) {
        while (my ($object, $data) = each %{$results->{ifType}}) {
            $datadevice->{PORTS}->{PORT}->[$index->{lastSplitObject($object)}]->{IFTYPE} = $data;
        }
    }

    if (exists $results->{ifmtu}) {
        while (my ($object, $data) = each %{$results->{ifmtu}}) {
            $datadevice->{PORTS}->{PORT}->[$index->{lastSplitObject($object)}]->{IFMTU} = $data;
        }
    }

    if (exists $results->{ifspeed}) {
        while (my ($object, $data) = each %{$results->{ifspeed}}) {
            $datadevice->{PORTS}->{PORT}->[$index->{lastSplitObject($object)}]->{IFSPEED} = $data;
        }
    }

    if (exists $results->{ifstatus}) {
        while (my ($object, $data) = each %{$results->{ifstatus}}) {
            $datadevice->{PORTS}->{PORT}->[$index->{lastSplitObject($object)}]->{IFSTATUS} = $data;
        }
    }

    if (exists $results->{ifinternalstatus}) {
        while (my ($object, $data) = each %{$results->{ifinternalstatus}}) {
            $datadevice->{PORTS}->{PORT}->[$index->{lastSplitObject($object)}]->{IFINTERNALSTATUS} = $data;
        }
    }

    if (exists $results->{iflastchange}) {
        while (my ($object, $data) = each %{$results->{iflastchange}}) {
            $datadevice->{PORTS}->{PORT}->[$index->{lastSplitObject($object)}]->{IFLASTCHANGE} = $data;
        }
    }

    if (exists $results->{ifinoctets}) {
        while (my ($object, $data) = each %{$results->{ifinoctets}}) {
            $datadevice->{PORTS}->{PORT}->[$index->{lastSplitObject($object)}]->{IFINOCTETS} = $data;
        }
    }

    if (exists $results->{ifoutoctets}) {
        while (my ($object, $data) = each %{$results->{ifoutoctets}}) {
            $datadevice->{PORTS}->{PORT}->[$index->{lastSplitObject($object)}]->{IFOUTOCTETS} = $data;
        }
    }

    if (exists $results->{ifinerrors}) {
        while (my ($object, $data) = each %{$results->{ifinerrors}}) {
            $datadevice->{PORTS}->{PORT}->[$index->{lastSplitObject($object)}]->{IFINERRORS} = $data;
        }
    }

    if (exists $results->{ifouterrors}) {
        while (my ($object, $data) = each %{$results->{ifouterrors}}) {
            $datadevice->{PORTS}->{PORT}->[$index->{lastSplitObject($object)}]->{IFOUTERRORS} = $data;
        }
    }

    if (exists $results->{ifPhysAddress}) {
        while (my ($object, $data) = each %{$results->{ifPhysAddress}}) {
            next unless $data;
            $datadevice->{PORTS}->{PORT}->[$index->{lastSplitObject($object)}]->{MAC} = $data;
        }
    }

    if (exists $results->{ifaddr}) {
        while (my ($object, $data) = each %{$results->{ifaddr}}) {
            next unless $data;
            my $shortobject = $object;
            $shortobject =~ s/$walks->{ifaddr}->{OID}//;
            $shortobject =~ s/^.//;
            $datadevice->{PORTS}->{PORT}->[$index->{$data}]->{IP} = $shortobject;
        }
    }

    if (exists $results->{portDuplex}) {
        while (my ($object, $data) = each %{$results->{portDuplex}}) {
            $datadevice->{PORTS}->{PORT}->[$index->{lastSplitObject($object)}]->{IFPORTDUPLEX} = $data;
        }
    }
}

sub _setPrinterProperties {
    my ($self, $results, $datadevice) = @_;

    # consumable levels
    foreach my $key (keys %printer_cartridges_simple_properties) {
        my $property = $printer_cartridges_simple_properties{$key};
        $datadevice->{CARTRIDGES}->{$key} =
            $results->{$property . '-level'} == -3 ?
                100 :
                _getPercentValue(
                    $results->{$property . '-capacitytype'},
                    $results->{$property . '-level'},
                );
    }
    foreach my $key (keys %printer_cartridges_percent_properties) {
        my $property = $printer_cartridges_percent_properties{$key};
        $datadevice->{CARTRIDGES}->{$key} = _getPercentValue(
            $results->{$property . 'MAX'},
            $results->{$property . 'REMAIN'},
        );
    }

    # page counters
    foreach my $key (keys %printer_pagecounters_properties) {
        my $property = $printer_pagecounters_properties{$key};
        $datadevice->{PAGECOUNTERS}->{$key} =
            $results->{$property};
    }
}

sub _setNetworkingProperties {
    my ($self, $results, $datadevice, $index, $walks, $host, $credentials) = @_;

    my $comments = $datadevice->{INFO}->{COMMENTS};

    # trunk & connected devices
    if (defined $comments) {
        foreach my $entry (@ports_dispatch_table) {
            next unless $comments =~ $entry->{match};

            $self->_runFunction(
                module   => $entry->{trunk},
                function => 'setTrunkPorts',
                params   => [ $results, $datadevice->{PORTS}->{PORT}, $index ]
            );

            $self->_runFunction(
                module   => $entry->{devices},
                function => 'setConnectedDevices',
                params   => [ $results, $datadevice->{PORTS}->{PORT}, $index, $walks ]
            );

            last;
        }
    }

    # Detect VLAN
    if (exists $results->{vmvlan}) {
        while (my ($object, $data) = each %{$results->{vmvlan}}) {
            my $name = $results->{vtpVlanName}->{$walks->{vtpVlanName}->{OID} . ".".$data};
            $datadevice->{PORTS}->{PORT}->[$index->{lastSplitObject($object)}]->{VLANS}->{VLAN} = {
                NUMBER => $data,
                NAME   => $name
            };
        }
    }

    # check if vlan-specific queries are is needed
    my $vlan_query =
        any { $_->{VLAN} }
        values %{$walks};

    if ($vlan_query) {
        while (my ($id, $name) = each %{$results->{vtpVlanName}}) {
            my $short_id = $id;
            $short_id =~ s/$walks->{vtpVlanName}->{OID}//;
            $short_id =~ s/^.//;
            # initiate a new SNMP connection on this VLAN
            my $snmp;
            eval {
                $snmp = FusionInventory::Agent::SNMP->new(
                    version      => $credentials->{VERSION},
                    hostname     => $host,
                    community    => $credentials->{COMMUNITY}."@".$short_id,
                    username     => $credentials->{USERNAME},
                    authpassword => $credentials->{AUTHPASSWORD},
                    authprotocol => $credentials->{AUTHPROTOCOL},
                    privpassword => $credentials->{PRIVPASSWORD},
                    privprotocol => $credentials->{PRIVPROTOCOL},
                    translate    => 1,
                );
            };
            if ($EVAL_ERROR) {
                $self->{logger}->error("Unable to create SNMP session for $host, VLAN $id: $EVAL_ERROR");
                return;
            }

            foreach my $variable (values %{$walks}) {
                next unless $variable->{VLAN};
                $results->{VLAN}->{$id}->{$variable->{OBJECT}} = $snmp->walk($variable->{OID});
            }
            # Detect mac adress on each port
            if ($comments =~ /Cisco/) {
                $self->_runFunction(
                    module   => 'FusionInventory::Agent::Task::SNMPQuery::Manufacturer::Cisco',
                    function => 'setMacAddresses',
                    params   => [ $results, $datadevice->{PORTS}->{PORT}, $index, $walks, $id ]
                );
            }
        }
    } else {
        if (defined $comments) {
            foreach my $entry (@mac_dispatch_table) {
                next unless $comments =~ $entry->{match};

                $self->_runFunction(
                    module   => $entry->{module},
                    function => $entry->{function},
                    params   => [ $results, $datadevice->{PORTS}->{PORT}, $index, $walks ]
                );

                last;
            }
        }
    }

}

sub _getPercentValue {
    my ($value1, $value2) = @_;

    return unless defined $value1 && _isInteger($value1);
    return unless defined $value2 && _isInteger($value2);
    return if $value1 == 0;

    return int(
        ( 100 * $value2 ) / $value1
    );
}

sub _isInteger {
    $_[0] =~ /^[+-]?\d+$/;
}

sub _sanitizedSerial {
    my ($value) = @_;

    $value =~ s/^\s+//;
    $value =~ s/\s+$//;
    $value =~ s/(\.{2,})*//g;

    return $value;
}

sub _runFunction {
    my ($self, %params) = @_;

    my $module   = $params{module};
    my $function = $params{function};
    my $params   = $params{params};

    $module->require();
    if ($EVAL_ERROR) {
        $self->{logger}->debug("Failed to load $module: $EVAL_ERROR");
    } else {
        no strict 'refs'; ## no critic
        &{$module . '::' . $function}(@$params);
    };
}

1;

__END__

=head1 NAME

FusionInventory::Agent::Task::SNMPQuery - Remote inventory support for FusionInventory Agent

=head1 DESCRIPTION

This task extracts various informations from remote hosts through SNMP
protocol:

=over

=item *

printer cartridges and counters status

=item *

router/switch ports status

=item *

relations between devices and router/switch ports

=back

This task requires a GLPI server with FusionInventory plugin.

=head1 AUTHORS

Copyright (C) 2009 David Durieux
Copyright (C) 2010-2011 FusionInventory Team
