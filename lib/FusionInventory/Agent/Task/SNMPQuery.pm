package FusionInventory::Agent::Task::SNMPQuery;

use strict;
use warnings;
use threads;
use threads::shared;
if ($threads::VERSION > 1.32){
   threads->set_stack_size(20*8192);
}
use base 'FusionInventory::Agent::Task';

use constant START => 0;
use constant RUN   => 1;
use constant STOP  => 2;
use constant EXIT  => 3;

use Encode qw(encode);
use English qw(-no_match_vars);

use FusionInventory::Agent::SNMP;
use FusionInventory::Agent::XML::Query;
use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Network;

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
        function => 'setConnectedDevicesMacAddress',
    },
    {
        match    => qr/ProCurve/,
        module   => __PACKAGE__ . '::Manufacturer::ProCurve',
        function => 'setConnectedDevicesMacAddress'
    },
    {
        match    => qr/Nortel/,
        module   => __PACKAGE__ . '::Manufacturer::Nortel',
        function => 'setConnectedDevicesMacAddress'
    },
    {
        match    => qr/Allied Telesis/,
        module   => __PACKAGE__ . '::Manufacturer::AlliedTelesis',
        function => 'setConnectedDevicesMacAddress'
    }
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
    my @devices :shared = map { shared_clone($_) } @{$options->{DEVICE}};
    my @results :shared;
    my @states  :shared;

    # no need for more threads than devices to scan
    my $nb_threads = $params->{THREADS_QUERY};
    if ($nb_threads > @devices) {
        $nb_threads = @devices;
    }

    #===================================
    # Create all Threads
    #===================================
    for (my $i = 0; $i < $nb_threads; $i++) {
        $states[$i] = START;

        threads->create(
            '_queryDevices',
            $self,
            \$states[$i],
            \@devices,
            \@results,
            $models,
            $credentials,
        )->detach();
    }

    # set all threads in RUN state
    $_ = RUN foreach @states;

    # wait for all threads to reach STOP state
    while (any { $_ != EXIT } @states) {
        sleep 1;
    }

    # send results to the server
    foreach my $result (@results) {
        my $data = {
            DEVICE        => $result,
            MODULEVERSION => $VERSION,
            PROCESSNUMBER => $params->{PID}
        };
        $self->_sendMessage($data);
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
    my ($self, $state, $devices, $results, $models, $credentials) = @_;

    my $logger = $self->{logger};
    my $id     = threads->tid();

    $logger->debug("Thread $id created in PAUSE state");

    # start: wait for state to change
    while ($$state == START) {
        sleep 1;
    }

    my $storage = $self->{target}->getStorage();
    # run: process available addresses until exhaustion
    $$state = RUN;
    $logger->debug("Thread $id switched to RUN state");

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

        if ($result) {
            lock $results;
            push @$results, shared_clone($result);
        }
                 
        sleep 1;
    }

    $$state = EXIT;
    $logger->debug("Thread $id switched to EXIT state");
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
        $results->{$variable->{OBJECT}} = $snmp->get($variable->{OID});
    }
    foreach my $variable (values %{$model->{WALK}}) {
        next if $variable->{VLAN};
        $results->{$variable->{OBJECT}} = $snmp->walk($variable->{OID});
    }

    # second, use results to build the object
    my $datadevice = {
        INFO => {
            ID   => $device->{ID},
            TYPE => $device->{TYPE}
        }
    };
    $self->_setGenericProperties($results, $datadevice, $model->{WALK});
    $self->_setPrinterProperties($results, $datadevice)
        if $device->{TYPE} eq 'PRINTER';
    $self->_setNetworkingProperties($results, $datadevice, $model->{WALK}, $device->{IP}, $credentials)
        if $device->{TYPE} eq 'NETWORKING';

    return $datadevice;
}

sub _setGenericProperties {
    my ($self, $results, $datadevice, $walks) = @_;

    if ($results->{cpuuser}) {
        $datadevice->{INFO}->{CPU} =
            $results->{cpuuser} + $results->{cpusystem};
    }

    if ($results->{firmware1}) {
        $datadevice->{INFO}->{FIRMWARE} =
            $results->{firmware1} . ' ' . $results->{firmware2};
    }

    foreach my $key (keys %properties) {
        my $raw_value = $results->{$properties{$key}};
        my $value =
            $key eq 'NAME'        ? hex2char($raw_value)          :
            $key eq 'OTHERSERIAL' ? hex2char($raw_value)          :
            $key eq 'SERIAL'      ? _sanitizedSerial($raw_value)  :
            $key eq 'RAM'         ? int($raw_value / 1024 / 1024) :
            $key eq 'MEMORY'      ? int($raw_value / 1024 / 1024) :
                                    $raw_value                    ;
        $datadevice->{INFO}->{$key} = $value;
    }


    if ($results->{ipAdEntAddr}) {
        my $i = 0;
        while (my ($object, $data) = each %{$results->{ipAdEntAddr}}) {
            $datadevice->{INFO}->{IPS}->{IP}->[$i] = $data;
            $i++;
        }
    }

    my $ports = $datadevice->{PORTS}->{PORT};

    if ($results->{ifIndex}) {
        while (my ($oid, $data) = each %{$results->{ifIndex}}) {
            $ports->[getLastNumber($oid)]->{IFNUMBER} = $data;
        }
    }

    if ($results->{ifdescr}) {
        while (my ($oid, $data) = each %{$results->{ifdescr}}) {
            $ports->[getLastNumber($oid)]->{IFDESCR} = $data;
        }
    }

    if ($results->{ifName}) {
        while (my ($oid, $data) = each %{$results->{ifName}}) {
            $ports->[getLastNumber($oid)]->{IFNAME} = $data;
        }
    }

    if ($results->{ifType}) {
        while (my ($oid, $data) = each %{$results->{ifType}}) {
            $ports->[getLastNumber($oid)]->{IFTYPE} = $data;
        }
    }

    if ($results->{ifmtu}) {
        while (my ($oid, $data) = each %{$results->{ifmtu}}) {
            $ports->[getLastNumber($oid)]->{IFMTU} = $data;
        }
    }

    if ($results->{ifspeed}) {
        while (my ($oid, $data) = each %{$results->{ifspeed}}) {
            $ports->[getLastNumber($oid)]->{IFSPEED} = $data;
        }
    }

    if ($results->{ifstatus}) {
        while (my ($oid, $data) = each %{$results->{ifstatus}}) {
            $ports->[getLastNumber($oid)]->{IFSTATUS} = $data;
        }
    }

    if ($results->{ifinternalstatus}) {
        while (my ($oid, $data) = each %{$results->{ifinternalstatus}}) {
            $ports->[getLastNumber($oid)]->{IFINTERNALSTATUS} = $data;
        }
    }

    if ($results->{iflastchange}) {
        while (my ($oid, $data) = each %{$results->{iflastchange}}) {
            $ports->[getLastNumber($oid)]->{IFLASTCHANGE} = $data;
        }
    }

    if ($results->{ifinoctets}) {
        while (my ($oid, $data) = each %{$results->{ifinoctets}}) {
            $ports->[getLastNumber($oid)]->{IFINOCTETS} = $data;
        }
    }

    if ($results->{ifoutoctets}) {
        while (my ($oid, $data) = each %{$results->{ifoutoctets}}) {
            $ports->[getLastNumber($oid)]->{IFOUTOCTETS} = $data;
        }
    }

    if ($results->{ifinerrors}) {
        while (my ($oid, $data) = each %{$results->{ifinerrors}}) {
            $ports->[getLastNumber($oid)]->{IFINERRORS} = $data;
        }
    }

    if ($results->{ifouterrors}) {
        while (my ($oid, $data) = each %{$results->{ifouterrors}}) {
            $ports->[getLastNumber($oid)]->{IFOUTERRORS} = $data;
        }
    }

    if ($results->{ifPhysAddress}) {
        while (my ($oid, $data) = each %{$results->{ifPhysAddress}}) {
            next unless $data;
            $ports->[getLastNumber($oid)]->{MAC} = $data;
        }
    }

    if ($results->{ifaddr}) {
        while (my ($oid, $data) = each %{$results->{ifaddr}}) {
            next unless $data;
            my $address = $oid;
            $address =~ s/$walks->{ifaddr}->{OID}//;
            $address =~ s/^.//;
            $ports->[$data]->{IP} = $address;
        }
    }

    if ($results->{portDuplex}) {
        while (my ($oid, $data) = each %{$results->{portDuplex}}) {
            $ports->[getLastNumber($oid)]->{IFPORTDUPLEX} = $data;
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
    my ($self, $results, $datadevice, $walks, $host, $credentials) = @_;

    my $comments = $datadevice->{INFO}->{COMMENTS};
    my $ports = $datadevice->{PORTS}->{PORT};

    # trunk & connected devices
    if (defined $comments) {
        foreach my $entry (@ports_dispatch_table) {
            next unless $comments =~ $entry->{match};

            runFunction(
                module   => $entry->{trunk},
                function => 'setTrunkPorts',
                params   => [ $results, $ports ],
                load     => 1
            );

            runFunction(
                module   => $entry->{devices},
                function => 'setConnectedDevices',
                params   => [ $results, $ports, $walks ],
                load     => 1
            );

            last;
        }
    }

    # Detect VLAN
    if ($results->{vmvlan}) {
        while (my ($oid, $data) = each %{$results->{vmvlan}}) {
            my $name = $results->{vtpVlanName}->{$walks->{vtpVlanName}->{OID} . ".".$data};
            $ports->[getLastNumber($oid)]->{VLANS}->{VLAN} = {
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
        while (my ($oid, $name) = each %{$results->{vtpVlanName}}) {
            my $id = $oid;
            $id =~ s/$walks->{vtpVlanName}->{OID}//;
            $id =~ s/^.//;
            # initiate a new SNMP connection on this VLAN
            my $snmp;
            eval {
                $snmp = FusionInventory::Agent::SNMP->new(
                    version      => $credentials->{VERSION},
                    hostname     => $host,
                    community    => $credentials->{COMMUNITY}."@".$id,
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
                my $module = 'FusionInventory::Agent::Task::SNMPQuery::Manufacturer::Cisco';
                runFunction(
                    module   => $module,
                    function => 'setConnectedDevicesMacAddress',
                    params   => [ $results, $ports, $walks, $id ],
                    load     => 1
                );
            }
        }
    } else {
        if (defined $comments) {
            foreach my $entry (@mac_dispatch_table) {
                next unless $comments =~ $entry->{match};

                $self->_runMethod(
                    class  => $entry->{module},
                    method => $entry->{function},
                    params => [ $results, $ports, $walks ]
                );

                last;
            }
        }
    }

    # cleanup ports list to keep only defined ones
    $datadevice->{PORTS}->{PORT} = [
        grep { $_ }
        @{$ports}
    ];

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
