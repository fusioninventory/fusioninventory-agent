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

use FusionInventory::Agent::Task::SNMPQuery::Cisco;
use FusionInventory::Agent::Task::SNMPQuery::Procurve;
use FusionInventory::Agent::Task::SNMPQuery::ThreeCom;
use FusionInventory::Agent::Task::SNMPQuery::Nortel;

our $VERSION = '2.0';
my $maxIdx : shared = 0;

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

    my $datadevice;
    my $HashDataSNMP;

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

    foreach my $key (keys %{$model->{GET}}) {
        next unless $model->{GET}->{$key}->{VLAN} == 0;
        my $result = $snmp->get(
            $model->{GET}->{$key}->{OID}
        );
        if ($result) {
            $HashDataSNMP->{$key} = $result;
        }
    }
    $datadevice->{INFO}->{ID} = $device->{ID};
    $datadevice->{INFO}->{TYPE} = $device->{TYPE};
    # Conversion
    ($datadevice, $HashDataSNMP) = _constructDataDeviceSimple($HashDataSNMP,$datadevice);

    # Query SNMP walk #
    foreach my $key (keys %{$model->{WALK}}) {
        my $result = $snmp->walk(
            $model->{WALK}->{$key}->{OID}
        );
        $HashDataSNMP->{$key} = $result;
    }

    ($datadevice, $HashDataSNMP) = _constructDataDeviceMultiple($HashDataSNMP,$datadevice, $self, $model->{WALK});

    if ($datadevice->{INFO}->{TYPE} eq "NETWORKING") {
        # check if vlan-specific queries are is needed
        my $vlan_query =
            any { $_->{VLAN} == 1 }
            values %{$model->{WALK}};

        if ($vlan_query) {
            while ( my ($id, $name) = each (%{$HashDataSNMP->{'vtpVlanName'}}) ) {
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
                    $HashDataSNMP->{VLAN}->{$id}->{$link} = $result;
                }
                # Detect mac adress on each port
                if ($datadevice->{INFO}->{COMMENTS} =~ /Cisco/) {
                    FusionInventory::Agent::Task::SNMPQuery::Cisco::GetMAC($HashDataSNMP,$datadevice,$id,$self, $model->{WALK});
                }
                delete $HashDataSNMP->{VLAN}->{$id};
            }
        } else {
            if (defined ($datadevice->{INFO}->{COMMENTS})) {
                if ($datadevice->{INFO}->{COMMENTS} =~ /3Com IntelliJack/) {
                    FusionInventory::Agent::Task::SNMPQuery::ThreeCom::RewritePortOf225($datadevice, $self);
                } elsif ($datadevice->{INFO}->{COMMENTS} =~ /3Com/) {
                    FusionInventory::Agent::Task::SNMPQuery::ThreeCom::GetMAC($HashDataSNMP,$datadevice,$self,$model->{WALK});
                } elsif ($datadevice->{INFO}->{COMMENTS} =~ /ProCurve/) {
                    FusionInventory::Agent::Task::SNMPQuery::Procurve::GetMAC($HashDataSNMP,$datadevice,$self, $model->{WALK});
                } elsif ($datadevice->{INFO}->{COMMENTS} =~ /Nortel/) {
                    FusionInventory::Agent::Task::SNMPQuery::Nortel::GetMAC($HashDataSNMP,$datadevice,$self, $model->{WALK});
                }
            }
        }
    }

    return $datadevice;
}



sub _constructDataDeviceSimple {
   my $HashDataSNMP = shift;
   my $datadevice = shift;
   if (exists $HashDataSNMP->{macaddr}) {
      $datadevice->{INFO}->{MAC} = $HashDataSNMP->{macaddr};
      delete $HashDataSNMP->{macaddr};
   }
   if (exists $HashDataSNMP->{cpuuser}) {
      $datadevice->{INFO}->{CPU} = $HashDataSNMP->{'cpuuser'} + $HashDataSNMP->{'cpusystem'};
      delete $HashDataSNMP->{'cpuuser'};
      delete $HashDataSNMP->{'cpusystem'};
   }
   _putSimpleOid($HashDataSNMP,$datadevice,'cpu','INFO','CPU');
   _putSimpleOid($HashDataSNMP,$datadevice,'location','INFO','LOCATION');
   _putSimpleOid($HashDataSNMP,$datadevice,'firmware','INFO','FIRMWARE');
   _putSimpleOid($HashDataSNMP,$datadevice,'firmware1','INFO','FIRMWARE');
   _putSimpleOid($HashDataSNMP,$datadevice,'contact','INFO','CONTACT');
   _putSimpleOid($HashDataSNMP,$datadevice,'comments','INFO','COMMENTS');
   _putSimpleOid($HashDataSNMP,$datadevice,'uptime','INFO','UPTIME');
   _putSimpleOid($HashDataSNMP,$datadevice,'serial','INFO','SERIAL');
   _putSimpleOid($HashDataSNMP,$datadevice,'name','INFO','NAME');
   _putSimpleOid($HashDataSNMP,$datadevice,'model','INFO','MODEL');
   _putSimpleOid($HashDataSNMP,$datadevice,'entPhysicalModelName','INFO','MODEL');
   _putSimpleOid($HashDataSNMP,$datadevice,'enterprise','INFO','MANUFACTURER');
   _putSimpleOid($HashDataSNMP,$datadevice,'otherserial','INFO','OTHERSERIAL');
   _putSimpleOid($HashDataSNMP,$datadevice,'memory','INFO','MEMORY');
   _putSimpleOid($HashDataSNMP,$datadevice,'ram','INFO','RAM');

   if ($datadevice->{INFO}->{TYPE} eq "PRINTER") {
      _putSimpleOid($HashDataSNMP,$datadevice,'tonerblack','CARTRIDGES','TONERBLACK');
      _putSimpleOid($HashDataSNMP,$datadevice,'tonerblack2','CARTRIDGES','TONERBLACK2');
      _putSimpleOid($HashDataSNMP,$datadevice,'tonercyan','CARTRIDGES','TONERCYAN');
      _putSimpleOid($HashDataSNMP,$datadevice,'tonermagenta','CARTRIDGES','TONERMAGENTA');
      _putSimpleOid($HashDataSNMP,$datadevice,'toneryellow','CARTRIDGES','TONERYELLOW');
      _putSimpleOid($HashDataSNMP,$datadevice,'wastetoner','CARTRIDGES','WASTETONER');
      _putSimpleOid($HashDataSNMP,$datadevice,'cartridgeblack','CARTRIDGES','CARTRIDGEBLACK');
      _putSimpleOid($HashDataSNMP,$datadevice,'cartridgeblackphoto','CARTRIDGES','CARTRIDGEBLACKPHOTO');
      _putSimpleOid($HashDataSNMP,$datadevice,'cartridgecyan','CARTRIDGES','CARTRIDGECYAN');
      _putSimpleOid($HashDataSNMP,$datadevice,'cartridgecyanlight','CARTRIDGES','CARTRIDGECYANLIGHT');
      _putSimpleOid($HashDataSNMP,$datadevice,'cartridgemagenta','CARTRIDGES','CARTRIDGEMAGENTA');
      _putSimpleOid($HashDataSNMP,$datadevice,'cartridgemagentalight','CARTRIDGES','CARTRIDGEMAGENTALIGHT');
      _putSimpleOid($HashDataSNMP,$datadevice,'cartridgeyellow','CARTRIDGES','CARTRIDGEYELLOW');
      _putSimpleOid($HashDataSNMP,$datadevice,'maintenancekit','CARTRIDGES','MAINTENANCEKIT');
      _putSimpleOid($HashDataSNMP,$datadevice,'drumblack','CARTRIDGES','DRUMBLACK');
      _putSimpleOid($HashDataSNMP,$datadevice,'drumcyan','CARTRIDGES','DRUMCYAN');
      _putSimpleOid($HashDataSNMP,$datadevice,'drummagenta','CARTRIDGES','DRUMMAGENTA');
      _putSimpleOid($HashDataSNMP,$datadevice,'drumyellow','CARTRIDGES','DRUMYELLOW');

      _putSimpleOid($HashDataSNMP,$datadevice,'pagecountertotalpages','PAGECOUNTERS','TOTAL');
      _putSimpleOid($HashDataSNMP,$datadevice,'pagecounterblackpages','PAGECOUNTERS','BLACK');
      _putSimpleOid($HashDataSNMP,$datadevice,'pagecountercolorpages','PAGECOUNTERS','COLOR');
      _putSimpleOid($HashDataSNMP,$datadevice,'pagecounterrectoversopages','PAGECOUNTERS','RECTOVERSO');
      _putSimpleOid($HashDataSNMP,$datadevice,'pagecounterscannedpages','PAGECOUNTERS','SCANNED');
      _putSimpleOid($HashDataSNMP,$datadevice,'pagecountertotalpages_print','PAGECOUNTERS','PRINTTOTAL');
      _putSimpleOid($HashDataSNMP,$datadevice,'pagecounterblackpages_print','PAGECOUNTERS','PRINTBLACK');
      _putSimpleOid($HashDataSNMP,$datadevice,'pagecountercolorpages_print','PAGECOUNTERS','PRINTCOLOR');
      _putSimpleOid($HashDataSNMP,$datadevice,'pagecountertotalpages_copy','PAGECOUNTERS','COPYTOTAL');
      _putSimpleOid($HashDataSNMP,$datadevice,'pagecounterblackpages_copy','PAGECOUNTERS','COPYBLACK');
      _putSimpleOid($HashDataSNMP,$datadevice,'pagecountercolorpages_copy','PAGECOUNTERS','COPYCOLOR');
      _putSimpleOid($HashDataSNMP,$datadevice,'pagecountertotalpages_fax','PAGECOUNTERS','FAXTOTAL');

      _putPourcentageOid($HashDataSNMP,$datadevice,'cartridgesblackMAX','cartridgesblackREMAIN',
                                                         'CARTRIDGE','BLACK');
      _putPourcentageOid($HashDataSNMP,$datadevice,'cartridgescyanMAX','cartridgescyanREMAIN',
                                                         'CARTRIDGE','CYAN');
      _putPourcentageOid($HashDataSNMP,$datadevice,'cartridgesyellowMAX','cartridgesyellowREMAIN',
                                                         'CARTRIDGE','YELLOW');
      _putPourcentageOid($HashDataSNMP,$datadevice,'cartridgesmagentaMAX','cartridgesmagentaREMAIN',
                                                         'CARTRIDGE','MAGENTA');
      _putPourcentageOid($HashDataSNMP,$datadevice,'cartridgescyanlightMAX','cartridgescyanlightREMAIN',
                                                         'CARTRIDGE','CYANLIGHT');
      _putPourcentageOid($HashDataSNMP,$datadevice,'cartridgesmagentalightMAX','cartridgesmagentalightREMAIN',
                                                         'CARTRIDGE','MAGENTALIGHT');
      _putPourcentageOid($HashDataSNMP,$datadevice,'cartridgesphotoconductorMAX','cartridgesphotoconductorREMAIN',
                                                         'CARTRIDGE','PHOTOCONDUCTOR');
      _putPourcentageOid($HashDataSNMP,$datadevice,'cartridgesphotoconductorblackMAX','cartridgesphotoconductorblackREMAIN',
                                                         'CARTRIDGE','PHOTOCONDUCTORBLACK');
      _putPourcentageOid($HashDataSNMP,$datadevice,'cartridgesphotoconductorcolorMAX','cartridgesphotoconductorcolorREMAIN',
                                                         'CARTRIDGE','PHOTOCONDUCTORCOLOR');
      _putPourcentageOid($HashDataSNMP,$datadevice,'cartridgesphotoconductorcyanMAX','cartridgesphotoconductorcyanREMAIN',
                                                         'CARTRIDGE','PHOTOCONDUCTORCYAN');
      _putPourcentageOid($HashDataSNMP,$datadevice,'cartridgesphotoconductoryellowMAX','cartridgesphotoconductoryellowREMAIN',
                                                         'CARTRIDGE','PHOTOCONDUCTORYELLOW');
      _putPourcentageOid($HashDataSNMP,$datadevice,'cartridgesphotoconductormagentaMAX','cartridgesphotoconductormagentaREMAIN',
                                                         'CARTRIDGE','PHOTOCONDUCTORMAGENTA');
      _putPourcentageOid($HashDataSNMP,$datadevice,'cartridgesunittransfertblackMAX','cartridgesunittransfertblackREMAIN',
                                                         'CARTRIDGE','UNITTRANSFERBLACK');
      _putPourcentageOid($HashDataSNMP,$datadevice,'cartridgesunittransfertcyanMAX','cartridgesunittransfertcyanREMAIN',
                                                         'CARTRIDGE','UNITTRANSFERCYAN');
      _putPourcentageOid($HashDataSNMP,$datadevice,'cartridgesunittransfertyellowMAX','cartridgesunittransfertyellowREMAIN',
                                                         'CARTRIDGE','UNITTRANSFERYELLOW');
      _putPourcentageOid($HashDataSNMP,$datadevice,'cartridgesunittransfertmagentaMAX','cartridgesunittransfertmagentaREMAIN',
                                                         'CARTRIDGE','UNITTRANSFERMAGENTA');
      _putPourcentageOid($HashDataSNMP,$datadevice,'cartridgeswasteMAX','cartridgeswasteREMAIN',
                                                         'CARTRIDGE','WASTE');
      _putPourcentageOid($HashDataSNMP,$datadevice,'cartridgesfuserMAX','cartridgesfuserREMAIN',
                                                         'CARTRIDGE','FUSER');
      _putPourcentageOid($HashDataSNMP,$datadevice,'cartridgesbeltcleanerMAX','cartridgesbeltcleanerREMAIN',
                                                         'CARTRIDGE','BELTCLEANER');
      _putPourcentageOid($HashDataSNMP,$datadevice,'cartridgesmaintenancekitMAX','cartridgesmaintenancekitREMAIN',
                                                         'CARTRIDGE','MAINTENANCEKIT');
   }
   return $datadevice, $HashDataSNMP;
}


sub _constructDataDeviceMultiple {
   my $HashDataSNMP = shift;
   my $datadevice = shift;
   my $self = shift;
   my $walk = shift;
   
   my $object;
   my $data;

   if (exists $HashDataSNMP->{ipAdEntAddr}) {
      my $i = 0;
      while ( ($object,$data) = each (%{$HashDataSNMP->{ipAdEntAddr}}) ) {
         $datadevice->{INFO}->{IPS}->{IP}->[$i] = $data;
         $i++;
      }
      delete $HashDataSNMP->{ipAdEntAddr};
   }
   if (exists $HashDataSNMP->{ifIndex}) {
      my $num = 0;
      while ( ($object,$data) = each (%{$HashDataSNMP->{ifIndex}}) ) {
         $self->{portsindex}->{lastSplitObject($object)} = $num;
         $datadevice->{PORTS}->{PORT}->[$num]->{IFNUMBER} = $data;
         $num++;
      }
      delete $HashDataSNMP->{ifIndex};
   }
   if (exists $HashDataSNMP->{ifdescr}) {
      while ( ($object,$data) = each (%{$HashDataSNMP->{ifdescr}}) ) {
         $datadevice->{PORTS}->{PORT}->[$self->{portsindex}->{lastSplitObject($object)}]->{IFDESCR} = $data;
      }
      delete $HashDataSNMP->{ifdescr};
   }
   if (exists $HashDataSNMP->{ifName}) {
      while ( ($object,$data) = each (%{$HashDataSNMP->{ifName}}) ) {
         $datadevice->{PORTS}->{PORT}->[$self->{portsindex}->{lastSplitObject($object)}]->{IFNAME} = $data;
      }
      delete $HashDataSNMP->{ifName};
   }
   if (exists $HashDataSNMP->{ifType}) {
      while ( ($object,$data) = each (%{$HashDataSNMP->{ifType}}) ) {
         $datadevice->{PORTS}->{PORT}->[$self->{portsindex}->{lastSplitObject($object)}]->{IFTYPE} = $data;
      }
      delete $HashDataSNMP->{ifType};
   }
   if (exists $HashDataSNMP->{ifmtu}) {
      while ( ($object,$data) = each (%{$HashDataSNMP->{ifmtu}}) ) {
         $datadevice->{PORTS}->{PORT}->[$self->{portsindex}->{lastSplitObject($object)}]->{IFMTU} = $data;
      }
      delete $HashDataSNMP->{ifmtu};
   }
   if (exists $HashDataSNMP->{ifspeed}) {
      while ( ($object,$data) = each (%{$HashDataSNMP->{ifspeed}}) ) {
         $datadevice->{PORTS}->{PORT}->[$self->{portsindex}->{lastSplitObject($object)}]->{IFSPEED} = $data;
      }
      delete $HashDataSNMP->{ifspeed};
   }
   if (exists $HashDataSNMP->{ifstatus}) {
      while ( ($object,$data) = each (%{$HashDataSNMP->{ifstatus}}) ) {
         $datadevice->{PORTS}->{PORT}->[$self->{portsindex}->{lastSplitObject($object)}]->{IFSTATUS} = $data;
      }
      delete $HashDataSNMP->{ifstatus};
   }
   if (exists $HashDataSNMP->{ifinternalstatus}) {
      while ( ($object,$data) = each (%{$HashDataSNMP->{ifinternalstatus}}) ) {
         $datadevice->{PORTS}->{PORT}->[$self->{portsindex}->{lastSplitObject($object)}]->{IFINTERNALSTATUS} = $data;
      }
      delete $HashDataSNMP->{ifinternalstatus};
   }
   if (exists $HashDataSNMP->{iflastchange}) {
      while ( ($object,$data) = each (%{$HashDataSNMP->{iflastchange}}) ) {
         $datadevice->{PORTS}->{PORT}->[$self->{portsindex}->{lastSplitObject($object)}]->{IFLASTCHANGE} = $data;
      }
      delete $HashDataSNMP->{iflastchange};
   }
   if (exists $HashDataSNMP->{ifinoctets}) {
      while ( ($object,$data) = each (%{$HashDataSNMP->{ifinoctets}}) ) {
         $datadevice->{PORTS}->{PORT}->[$self->{portsindex}->{lastSplitObject($object)}]->{IFINOCTETS} = $data;
      }
      delete $HashDataSNMP->{ifinoctets};
   }
   if (exists $HashDataSNMP->{ifoutoctets}) {
      while ( ($object,$data) = each (%{$HashDataSNMP->{ifoutoctets}}) ) {
         $datadevice->{PORTS}->{PORT}->[$self->{portsindex}->{lastSplitObject($object)}]->{IFOUTOCTETS} = $data;
      }
      delete $HashDataSNMP->{ifoutoctets};
   }
   if (exists $HashDataSNMP->{ifinerrors}) {
      while ( ($object,$data) = each (%{$HashDataSNMP->{ifinerrors}}) ) {
         $datadevice->{PORTS}->{PORT}->[$self->{portsindex}->{lastSplitObject($object)}]->{IFINERRORS} = $data;
      }
      delete $HashDataSNMP->{ifinerrors};
   }
   if (exists $HashDataSNMP->{ifouterrors}) {
      while ( ($object,$data) = each (%{$HashDataSNMP->{ifouterrors}}) ) {
         $datadevice->{PORTS}->{PORT}->[$self->{portsindex}->{lastSplitObject($object)}]->{IFOUTERRORS} = $data;
      }
      delete $HashDataSNMP->{ifouterrors};
   }
   if (exists $HashDataSNMP->{ifPhysAddress}) {
      while ( ($object,$data) = each (%{$HashDataSNMP->{ifPhysAddress}}) ) {
         if ($data ne "") {
             $datadevice->{PORTS}->{PORT}->[$self->{portsindex}->{lastSplitObject($object)}]->{MAC} = $data;
         }
      }
      delete $HashDataSNMP->{ifPhysAddress};
   }
   if (exists $HashDataSNMP->{ifaddr}) {
      while ( ($object,$data) = each (%{$HashDataSNMP->{ifaddr}}) ) {
         if ($data ne "") {
             my $shortobject = $object;
             $shortobject =~ s/$walk->{ifaddr}->{OID}//;
             $shortobject =~ s/^.//;
             $datadevice->{PORTS}->{PORT}->[$self->{portsindex}->{$data}]->{IP} = $shortobject;
         }
      }
      delete $HashDataSNMP->{ifaddr};
   }
   if (exists $HashDataSNMP->{portDuplex}) {
      while ( ($object,$data) = each (%{$HashDataSNMP->{portDuplex}}) ) {
         $datadevice->{PORTS}->{PORT}->[$self->{portsindex}->{lastSplitObject($object)}]->{IFPORTDUPLEX} = $data;
      }
      delete $HashDataSNMP->{portDuplex};
   }

   # Detect Trunk & CDP
   if (defined ($datadevice->{INFO}->{COMMENTS})) {
      if ($datadevice->{INFO}->{COMMENTS} =~ /Cisco/) {
         ($datadevice, $HashDataSNMP) = FusionInventory::Agent::Task::SNMPQuery::Cisco::TrunkPorts($HashDataSNMP,$datadevice, $self);
         ($datadevice, $HashDataSNMP) = FusionInventory::Agent::Task::SNMPQuery::Cisco::CDPPorts($HashDataSNMP,$datadevice, $walk, $self);
      } elsif ($datadevice->{INFO}->{COMMENTS} =~ /ProCurve/) {
         ($datadevice, $HashDataSNMP) = FusionInventory::Agent::Task::SNMPQuery::Cisco::TrunkPorts($HashDataSNMP,$datadevice, $self);
         ($datadevice, $HashDataSNMP) = FusionInventory::Agent::Task::SNMPQuery::Procurve::CDPLLDPPorts($HashDataSNMP,$datadevice, $walk, $self);
      } elsif ($datadevice->{INFO}->{COMMENTS} =~ /Nortel/) {
         ($datadevice, $HashDataSNMP) = FusionInventory::Agent::Task::SNMPQuery::Nortel::VlanTrunkPorts($HashDataSNMP,$datadevice, $self);
         ($datadevice, $HashDataSNMP) = FusionInventory::Agent::Task::SNMPQuery::Nortel::LLDPPorts($HashDataSNMP,$datadevice, $walk, $self);
      }
   }

   # Detect VLAN
   if (exists $HashDataSNMP->{vmvlan}) {
      while ( ($object,$data) = each (%{$HashDataSNMP->{vmvlan}}) ) {
         $datadevice->{PORTS}->{PORT}->[$self->{portsindex}->{lastSplitObject($object)}]->{VLANS}->{VLAN}->{NUMBER} = $data;
         $datadevice->{PORTS}->{PORT}->[$self->{portsindex}->{lastSplitObject($object)}]->{VLANS}->{VLAN}->{NAME} = $HashDataSNMP->{vtpVlanName}->{$walk->{vtpVlanName}->{OID} . ".".$data};
      }
      delete $HashDataSNMP->{vmvlan};
   }


   return $datadevice, $HashDataSNMP;
}

sub _putSimpleOid {
   my $HashDataSNMP = shift;
   my $datadevice = shift;
   my $element = shift;
   my $xmlelement1 = shift;
   my $xmlelement2 = shift;

   if (exists $HashDataSNMP->{$element}) {
      # Rewrite hexa to string
      if (($element eq "name") || ($element eq "otherserial")) {
         $HashDataSNMP->{$element} = _hexaToString($HashDataSNMP->{$element});
      }
      # End rewrite hexa to string
      if (($element eq "ram") || ($element eq "memory")) {
         $HashDataSNMP->{$element} = int(( $HashDataSNMP->{$element} / 1024 ) / 1024);
      }
      if ($element eq "serial") {
         $HashDataSNMP->{$element} =~ s/^\s+//;
         $HashDataSNMP->{$element} =~ s/\s+$//;
         $HashDataSNMP->{$element} =~ s/(\.{2,})*//g;
      }
      if ($element eq "firmware1") {
         $datadevice->{$xmlelement1}->{$xmlelement2} = $HashDataSNMP->{"firmware1"}." ".$HashDataSNMP->{"firmware2"};
         delete $HashDataSNMP->{"firmware2"};
      } elsif (($element =~ /^toner/) || ($element eq "wastetoner") || ($element =~ /^cartridge/) || ($element eq "maintenancekit") || ($element =~ /^drum/)) {
         if ($HashDataSNMP->{$element."-level"} == -3) {
            $datadevice->{$xmlelement1}->{$xmlelement2} = 100;
         } else {
            _putPourcentageOid($HashDataSNMP,$datadevice,$element."-capacitytype",$element."-level", $xmlelement1, $xmlelement2);
         }
      } else {
         $datadevice->{$xmlelement1}->{$xmlelement2} = $HashDataSNMP->{$element};
      }
      delete $HashDataSNMP->{$element};
      
   }
}

sub _putPourcentageOid {
   my $HashDataSNMP = shift;
   my $datadevice = shift;
   my $element1 = shift;
   my $element2 = shift;
   my $xmlelement1 = shift;
   my $xmlelement2 = shift;
   if (exists $HashDataSNMP->{$element1}) {
      if ((_isInteger($HashDataSNMP->{$element2})) && (_isInteger($HashDataSNMP->{$element1})) && ($HashDataSNMP->{$element1} != 0)) {
         $datadevice->{$xmlelement1}->{$xmlelement2} = int ( ( 100 * $HashDataSNMP->{$element2} ) / $HashDataSNMP->{$element1} );
         delete $HashDataSNMP->{$element2};
         delete $HashDataSNMP->{$element1};
      }
   }
}



sub _lastSplitObject {
   my $var = shift;

   my @array = split(/\./, $var);
   return $array[-1];
}

sub _isInteger {
   $_[0] =~ /^[+-]?\d+$/;
}

sub _hexaToString {
   my $val = shift;

   if ($val =~ /0x/) {
      $val =~ s/0x//g;
      $val =~ s/([a-fA-F0-9][a-fA-F0-9])/chr(hex($1))/g;
      $val = encode('UTF-8', $val);
      $val =~ s/\0//g;
      $val =~ s/([\x80-\xFF])//g;
      $val =~ s/[\x00-\x1F\x7F]//g;
   }
   return $val;
}

1;
