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

our $VERSION = '2.0';
my $maxIdx : shared = 0;

my @infos = (
    [ qw/macaddr MAC/ ],
    [ qw/cpu CPU/ ],
    [ qw/location LOCATION/ ],
    [ qw/firmware FIRMWARE/ ],
    [ qw/firmware1 FIRMWARE/ ],
    [ qw/contant CONTACT/ ],
    [ qw/comments COMMENTS/ ],
    [ qw/uptime UPTIME/ ],
    [ qw/serial SERIAL/ ],
    [ qw/name NAME/ ],
    [ qw/model MODEL/ ],
    [ qw/entPhysicalModelName MODEL/ ],
    [ qw/enterprise MANUFACTURER/ ],
    [ qw/otherserial OTHERSERIAL/ ],
    [ qw/memory MEMORY/ ],
    [ qw/ram RAM/ ],
);

my @printer_cartridges_simple_infos = (
    [ qw/tonerblack TONERBLACK/ ],
    [ qw/tonerblack2 TONERBLACK2/ ],
    [ qw/tonercyan TONERCYAN/ ],
    [ qw/tonermagenta TONERMAGENTA/ ],
    [ qw/toneryellow TONERYELLOW/ ],
    [ qw/wastetoner WASTETONER/ ],
    [ qw/cartridgeblack CARTRIDGEBLACK/ ],
    [ qw/cartridgeblackphoto CARTRIDGEBLACKPHOTO/ ],
    [ qw/cartridgecyan CARTRIDGECYAN/ ],
    [ qw/cartridgecyanlight CARTRIDGECYANLIGHT/ ],
    [ qw/cartridgemagenta CARTRIDGEMAGENTA/ ],
    [ qw/cartridgemagentalight CARTRIDGEMAGENTALIGHT/ ],
    [ qw/cartridgeyellow CARTRIDGEYELLOW/ ],
    [ qw/maintenancekit MAINTENANCEKIT/ ],
    [ qw/drumblack DRUMBLACK/ ],
    [ qw/drumcyan DRUMCYAN/ ],
    [ qw/drummagenta DRUMMAGENTA/ ],
    [ qw/drumyellow DRUMYELLOW/ ],
);

my @printer_pagecounters_simple_infos = (
    [ qw/pagecountertotalpages TOTAL/ ],
    [ qw/pagecounterblackpages BLACK/ ],
    [ qw/pagecountercolorpages COLOR/ ],
    [ qw/pagecounterrectoversopages RECTOVERSO/ ],
    [ qw/pagecounterscannedpages SCANNED/ ],
    [ qw/pagecountertotalpages_print PRINTTOTAL/ ],
    [ qw/pagecounterblackpages_print PRINTBLACK/ ],
    [ qw/pagecountercolorpages_print PRINTCOLOR/ ],
    [ qw/pagecountertotalpages_copy COPYTOTAL/ ],
    [ qw/pagecounterblackpages_copy COPYBLACK/ ],
    [ qw/pagecountercolorpages_copy COPYCOLOR/ ],
    [ qw/pagecountertotalpages_fax FAXTOTAL/ ],
);

my @printer_cartridges_percent_infos = (
    [ qw/cartridgesblackMAX cartridgesblackREMAIN BLACK/ ],
    [ qw/cartridgescyanMAX cartridgescyanREMAIN CYAN/ ],
    [ qw/cartridgesyellowMAX cartridgesyellowREMAIN YELLOW/ ],
    [ qw/cartridgesmagentaMAX cartridgesmagentaREMAIN MAGENTA/ ],
    [ qw/cartridgescyanlightMAX cartridgescyanlightREMAIN CYANLIGHT/ ],
    [ qw/cartridgesmagentalightMAX cartridgesmagentalightREMAIN MAGENTALIGHT/ ],
    [ qw/cartridgesphotoconductorMAX cartridgesphotoconductorREMAIN PHOTOCONDUCTOR/ ],
    [ qw/cartridgesphotoconductorblackMAX cartridgesphotoconductorblackREMAIN PHOTOCONDUCTORBLACK/ ],
    [ qw/cartridgesphotoconductorcolorMAX cartridgesphotoconductorcolorREMAIN PHOTOCONDUCTORCOLOR/ ],
    [ qw/cartridgesphotoconductorcyanMAX cartridgesphotoconductorcyanREMAIN PHOTOCONDUCTORCYAN/ ],
    [ qw/cartridgesphotoconductoryellowMAX cartridgesphotoconductoryellowREMAIN PHOTOCONDUCTORYELLOW/ ],
    [ qw/cartridgesphotoconductormagentaMAX cartridgesphotoconductormagentaREMAIN PHOTOCONDUCTORMAGENTA/ ],
    [ qw/cartridgesunittransfertblackMAX cartridgesunittransfertblackREMAIN UNITTRANSFERBLACK/ ],
    [ qw/cartridgesunittransfertcyanMAX cartridgesunittransfertcyanREMAIN UNITTRANSFERCYAN/ ],
    [ qw/cartridgesunittransfertyellowMAX cartridgesunittransfertyellowREMAIN UNITTRANSFERYELLOW/ ],
    [ qw/cartridgesunittransfertmagentaMAX cartridgesunittransfertmagentaREMAIN CARTRIDGE UNITTRANSFERMAGENTA/ ],
    [ qw/cartridgeswasteMAX cartridgeswasteREMAIN WASTE/ ],
    [ qw/cartridgesfuserMAX cartridgesfuserREMAIN FUSER/ ],
    [ qw/cartridgesbeltcleanerMAX cartridgesbeltcleanerREMAIN BELTCLEANER/ ],
    [ qw/cartridgesmaintenancekitMAX cartridgesmaintenancekitREMAIN MAINTENANCEKIT/ ],
);

my @ports_dispatch_table = (
    {
        match => qr/Cisco/,
        trunk => 'FusionInventory::Agent::Task::SNMPQuery::Cisco',
        cdp   => 'FusionInventory::Agent::Task::SNMPQuery::Cisco',
    },
    {
        match => qr/ProCurve/,
        trunk => 'FusionInventory::Agent::Task::SNMPQuery::Cisco',
        cdp   => 'FusionInventory::Agent::Task::SNMPQuery::ProCurve',
    },
    {
        match => qr/Nortel/,
        trunk => 'FusionInventory::Agent::Task::SNMPQuery::Nortel',
        cdp   => 'FusionInventory::Agent::Task::SNMPQuery::Nortel',
    },
);

my @mac_dispatch_table = (
    {
        match    => qr/3Com IntelliJack/,
        module   => 'FusionInventory::Agent::Task::SNMPQuery::ThreeCom',
        function => 'RewritePortOf225',
    },
    {
        match    => qr/3Com/,
        module   => 'FusionInventory::Agent::Task::SNMPQuery::ThreeCom',
        function => 'GetMAC',
    },
    {
        match    => qr/ProCurve/,
        module   => 'FusionInventory::Agent::Task::SNMPQuery::ProCurve',
        function => 'GetMAC'
    },
    {
        match    => qr/Nortel/,
        module   => 'FusionInventory::Agent::Task::SNMPQuery::Nortel',
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

    my @threads : shared;
    my @devices : shared;

    @devices = @{$options->{DEVICE}};

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
    my ($self, $thread, $devices, $models, $credentials) = @_;

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
        foreach my $key (keys %{$model->{GET}}) {
            if (
                $key eq "wastetoner"     ||
                $key eq "maintenancekit" ||
                $key =~ /^toner/         ||
                $key =~ /^cartridge/     ||
                $key =~ /^drum/
            ) {
                my $type_oid = $model->{GET}->{$key}->{OID};
                $type_oid =~ s/43.11.1.1.6/43.11.1.1.8/;
                my $level_oid = $model->{GET}->{$key}->{OID};
                $level_oid =~ s/43.11.1.1.6/43.11.1.1.9/;

                $model->{GET}->{$key."-capacitytype"} = {
                    OID  => $type_oid,
                    VLAN => 0
                };
                $model->{GET}->{$key."-level"} = {
                    OID  => $level_oid,
                    VLAN => 0
                };
            }
        }
    }

    my $datadevice = {
        INFO => {
            ID   => $device->{ID},
            TYPE => $device->{TYPE}
        }
    };
    my $results;
    my $ports;

    # first, query single values
    foreach my $key (keys %{$model->{GET}}) {
        next unless $model->{GET}->{$key}->{VLAN} == 0;
        $results->{$key} = $snmp->get(
            $model->{GET}->{$key}->{OID}
        );
    }
    $self->_constructDataDeviceSimple($results,$datadevice);

    # second, query multiple values
    foreach my $key (keys %{$model->{WALK}}) {
        $results->{$key} = $snmp->walk(
            $model->{WALK}->{$key}->{OID}
        );
    }
    $self->_constructDataDeviceMultiple($results,$datadevice, $ports, $model->{WALK});

    # additional queries for network devices
    if ($datadevice->{INFO}->{TYPE} eq "NETWORKING") {
        # check if vlan-specific queries are is needed
        my $vlan_query =
            any { $_->{VLAN} == 1 }
            values %{$model->{WALK}};

        if ($vlan_query) {
            while (my ($id, $name) = each (%{$results->{vtpVlanName}}) ) {
                my $short_id = $id;
                $short_id =~ s/$model->{WALK}->{vtpVlanName}->{OID}//;
                $short_id =~ s/^.//;
                # initiate a new SNMP connection on this VLAN
                eval {
                    $snmp = FusionInventory::Agent::SNMP->new(
                        version      => $credentials->{VERSION},
                        hostname     => $device->{IP},
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
                    $self->{logger}->error("Unable to create SNMP session for $device->{IP}, VLAN $id: $EVAL_ERROR");
                    return;
                }

                foreach my $link (keys %{$model->{WALK}}) {
                    next unless $model->{WALK}->{$link}->{VLAN} == 1;
                    my $result = $snmp->walk(
                        $model->{WALK}->{$link}->{OID}
                    );
                    $results->{VLAN}->{$id}->{$link} = $result;
                }
                # Detect mac adress on each port
                if ($datadevice->{INFO}->{COMMENTS} =~ /Cisco/) {
                    $self->_runFunction(
                        module   => 'FusionInventory::Agent::Task::SNMPQuery::Cisco',
                        function => 'GetMAC',
                        params   => [ $results, $datadevice, $id, $ports, $model->{WALK} ]
                    );
                }
            }
        } else {
            my $comments = $datadevice->{INFO}->{COMMENTS};
            if (defined $comments) {
                foreach my $entry (@mac_dispatch_table) {
                    next unless $comments =~ $entry->{match};

                    $self->_runFunction(
                        module   => $entry->{module},
                        function => $entry->{function},
                        params   => [ $results, $datadevice, $ports, $model->{WALK} ]
                    );

                    last;
                }
            }
        }
    }

    return $datadevice;
}



sub _constructDataDeviceSimple {
    my ($self, $results, $datadevice) = @_;

    if (exists $results->{cpuuser}) {
        $datadevice->{INFO}->{CPU} = $results->{'cpuuser'} + $results->{'cpusystem'};
    }

    foreach my $info (@infos) {
        my $raw_value = $results->{$info->[0]};
        my $value =
            $info->[0] eq 'name'        ? _hex2String($raw_value)       :
            $info->[0] eq 'otherserial' ? _hex2String($raw_value)       :
            $info->[0] eq 'serial'      ? _sanitizedSerial($raw_value)  :
            $info->[0] eq 'ram'         ? int($raw_value / 1024 / 1024) :
            $info->[0] eq 'memory'      ? int($raw_value / 1024 / 1024) :
            $info->[0] eq 'firmware1'   ? $raw_value . " " . $results->{"firmware2"} :
                                          $raw_value                    ;
        $datadevice->{INFO}->{$info->[1]} = $value;
    }

    if ($datadevice->{INFO}->{TYPE} eq "PRINTER") {
        # consumable levels
        foreach my $info (@printer_cartridges_simple_infos) {
            $datadevice->{CARTRIDGES}->{$info->[1]} =
                $results->{"$info->[0]-level"} == -3 ?
                    100 :
                    _getPercentValue(
                        $results->{"$info->[0]-capacitytype"},
                        $results->{"$info->[0]-level"},
                    );
        }
        foreach my $info (@printer_cartridges_percent_infos) {
            $datadevice->{CARTRIDGES}->{$info->[2]} = _getPercentValue(
                $results->{$info->[0]},
                $results->{$info->[1]},
            );
        }

        # page counters
        foreach my $info (@printer_pagecounters_simple_infos) {
            $datadevice->{PAGECOUNTERS}->{$info->[1]} =
                $results->{$info->[0]};
        }
    }
}


sub _constructDataDeviceMultiple {
    my ($self, $results, $datadevice, $ports, $walks) = @_;

    if (exists $results->{ipAdEntAddr}) {
        my $i = 0;
        while (my ($object,$data) = each (%{$results->{ipAdEntAddr}}) ) {
            $datadevice->{INFO}->{IPS}->{IP}->[$i] = $data;
            $i++;
        }
    }

    if (exists $results->{ifIndex}) {
        my $num = 0;
        while (my ($object,$data) = each (%{$results->{ifIndex}}) ) {
            $ports->{lastSplitObject($object)} = $num;
            $datadevice->{PORTS}->{PORT}->[$num]->{IFNUMBER} = $data;
            $num++;
        }
    }

    if (exists $results->{ifdescr}) {
        while (my ($object,$data) = each (%{$results->{ifdescr}}) ) {
            $datadevice->{PORTS}->{PORT}->[$ports->{lastSplitObject($object)}]->{IFDESCR} = $data;
        }
    }

    if (exists $results->{ifName}) {
        while (my ($object,$data) = each (%{$results->{ifName}}) ) {
            $datadevice->{PORTS}->{PORT}->[$ports->{lastSplitObject($object)}]->{IFNAME} = $data;
        }
    }

    if (exists $results->{ifType}) {
        while (my ($object,$data) = each (%{$results->{ifType}}) ) {
            $datadevice->{PORTS}->{PORT}->[$ports->{lastSplitObject($object)}]->{IFTYPE} = $data;
        }
    }

    if (exists $results->{ifmtu}) {
        while (my ($object,$data) = each (%{$results->{ifmtu}}) ) {
            $datadevice->{PORTS}->{PORT}->[$ports->{lastSplitObject($object)}]->{IFMTU} = $data;
        }
    }

    if (exists $results->{ifspeed}) {
        while (my ($object,$data) = each (%{$results->{ifspeed}}) ) {
            $datadevice->{PORTS}->{PORT}->[$ports->{lastSplitObject($object)}]->{IFSPEED} = $data;
        }
    }

    if (exists $results->{ifstatus}) {
        while (my ($object,$data) = each (%{$results->{ifstatus}}) ) {
            $datadevice->{PORTS}->{PORT}->[$ports->{lastSplitObject($object)}]->{IFSTATUS} = $data;
        }
    }

    if (exists $results->{ifinternalstatus}) {
        while (my ($object,$data) = each (%{$results->{ifinternalstatus}}) ) {
            $datadevice->{PORTS}->{PORT}->[$ports->{lastSplitObject($object)}]->{IFINTERNALSTATUS} = $data;
        }
    }

    if (exists $results->{iflastchange}) {
        while (my ($object,$data) = each (%{$results->{iflastchange}}) ) {
            $datadevice->{PORTS}->{PORT}->[$ports->{lastSplitObject($object)}]->{IFLASTCHANGE} = $data;
        }
    }

    if (exists $results->{ifinoctets}) {
        while (my ($object,$data) = each (%{$results->{ifinoctets}}) ) {
            $datadevice->{PORTS}->{PORT}->[$ports->{lastSplitObject($object)}]->{IFINOCTETS} = $data;
        }
    }

    if (exists $results->{ifoutoctets}) {
        while (my ($object,$data) = each (%{$results->{ifoutoctets}}) ) {
            $datadevice->{PORTS}->{PORT}->[$ports->{lastSplitObject($object)}]->{IFOUTOCTETS} = $data;
        }
    }

    if (exists $results->{ifinerrors}) {
        while (my ($object,$data) = each (%{$results->{ifinerrors}}) ) {
            $datadevice->{PORTS}->{PORT}->[$ports->{lastSplitObject($object)}]->{IFINERRORS} = $data;
        }
    }

    if (exists $results->{ifouterrors}) {
        while (my ($object,$data) = each (%{$results->{ifouterrors}}) ) {
            $datadevice->{PORTS}->{PORT}->[$ports->{lastSplitObject($object)}]->{IFOUTERRORS} = $data;
        }
    }

    if (exists $results->{ifPhysAddress}) {
        while (my ($object,$data) = each (%{$results->{ifPhysAddress}}) ) {
            if ($data ne "") {
                $datadevice->{PORTS}->{PORT}->[$ports->{lastSplitObject($object)}]->{MAC} = $data;
            }
        }
    }

    if (exists $results->{ifaddr}) {
        while (my ($object,$data) = each (%{$results->{ifaddr}}) ) {
            if ($data ne "") {
                my $shortobject = $object;
                $shortobject =~ s/$walks->{ifaddr}->{OID}//;
                $shortobject =~ s/^.//;
                $datadevice->{PORTS}->{PORT}->[$ports->{$data}]->{IP} = $shortobject;
            }
        }
    }

    if (exists $results->{portDuplex}) {
        while (my ($object,$data) = each (%{$results->{portDuplex}}) ) {
            $datadevice->{PORTS}->{PORT}->[$ports->{lastSplitObject($object)}]->{IFPORTDUPLEX} = $data;
        }
    }

    # Detect Trunk & CDP
    my $comments = $datadevice->{INFO}->{COMMENTS};
    if (defined $comments) {
        foreach my $entry (@ports_dispatch_table) {
            next unless $comments =~ $entry->{match};

            $self->_runFunction(
                module   => $entry->{trunk},
                function => 'setTrunkPorts',
                params   => [ $results, $datadevice, $ports ]
            );

            $self->_runFunction(
                module   => $entry->{cdp},
                function => 'setCDPPorts',
                params   => [ $results, $datadevice, $walks, $ports ]
            );

            last;
        }
    }

    # Detect VLAN
    if (exists $results->{vmvlan}) {
        while (my ($object,$data) = each (%{$results->{vmvlan}}) ) {
            $datadevice->{PORTS}->{PORT}->[$ports->{lastSplitObject($object)}]->{VLANS}->{VLAN}->{NUMBER} = $data;
            $datadevice->{PORTS}->{PORT}->[$ports->{lastSplitObject($object)}]->{VLANS}->{VLAN}->{NAME} = $results->{vtpVlanName}->{$walks->{vtpVlanName}->{OID} . ".".$data};
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



sub _lastSplitObject {
    my ($var) = @_;

    my @array = split(/\./, $var);
    return $array[-1];
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

sub _hex2String {
    my ($value) = @_;

    return unless $value =~ /0x/;
    $value =~ s/0x//;
    $value =~ s/(\w{2})/chr(hex($1))/eg;

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
