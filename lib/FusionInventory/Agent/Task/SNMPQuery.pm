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
use Net::SNMP;
use XML::Simple;

use FusionInventory::Agent::SNMP;
use FusionInventory::Agent::XML::Query;

use FusionInventory::Agent::Task::SNMPQuery::Cisco;
use FusionInventory::Agent::Task::SNMPQuery::Procurve;
use FusionInventory::Agent::Task::SNMPQuery::ThreeCom;
use FusionInventory::Agent::Task::SNMPQuery::Nortel;

our $VERSION = '1.3';
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
    my $storage = $self->{target}->getStorage();

    my @threads : shared;
    my @devices : shared;

    @devices = @{$options->{DEVICE}};

    # Models SNMP
    my $models = _modelParser($self->{SNMPQUERY});

    # retrieve SNMP authentication credentials
    my $credentials = $options->{AUTHENTICATION};

    # no need for more threads than devices to scan
    my $nb_threads = $params->{THREADS_QUERY};
    if ($nb_threads > @devices) {
        $nb_threads = @devices;
    }


    #===================================
    # Create all Threads
    #===================================
    for(my $j = 0; $j < $nb_threads; $j++) {
        $threads[$j] = ALIVE;

        threads->create(
            'handleDevices',
            $self,
            $j,
            \@devices,
            $models,
            $credentials,
            $params->{PID},
            \@threads
        )->detach();
        sleep 1;
    }

    # send initial message to the server
    $self->_sendMessage({
        data => {
            AGENT => {
                START        => 1,
                AGENTVERSION => $FusionInventory::Agent::VERSION
            },
            MODULEVERSION => $VERSION,
            PROCESSNUMBER => $params->{PID}
        }
    });

    while (1) {
        last if all { $_ == DEAD } @threads;
        sleep 1;
    }

    # send results to the server
    foreach my $idx (1..$maxIdx) {
        my $data = $storage->restore({
            idx => $idx
        });
        $self->_sendMessage({
            data => $data
        });
        $storage->remove(
            idx => $idx
        );
        sleep 1;
    }

    # send final message to the server
    $self->_sendMessage({
        data => {
            AGENT => {
                END => 1,
            },
            MODULEVERSION => $VERSION,
            PROCESSNUMBER => $params->{PID}
        }
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

sub _handleDevices {
    my ($self, $t, $devicelist, $modelslist, $credentials, $pid, $threads) = @_;

    my $device_id;

    my $xml_thread = {};                                                   
    my $count = 0;
    my $loopthread = 0;

    $self->{logger}->debug("Thread $t created");

    while ($loopthread != 1) {
        # Lance la procÃ©dure et rÃ©cupÃ¨re le rÃ©sultat
        my $device;
        {
            lock $devicelist;
            $device = pop @{$devicelist};
        }
        $loopthread = 1 if !$device;

        if ($loopthread != 1) {
            my $datadevice = $self->_queryDeviceThreaded({
                device              => $device,
                modellist           => $modelslist->{$device->{MODELSNMP_ID}},
                credentials         => $credentials->{$device->{AUTHSNMP_ID}}
            });
            $xml_thread->{DEVICE}->[$count] = $datadevice;
            $xml_thread->{MODULEVERSION} = $VERSION;
            $xml_thread->{PROCESSNUMBER} = $pid;
            $count++;
            if (($count == 1) || (($loopthread == 1) && ($count > 0))) {
                $maxIdx++;
                $self->{storage}->save({
                    idx =>
                    $maxIdx,
                    data => $xml_thread
                });
                 
                $count = 0;
            }
        }
        sleep 1;
    }

    $threads->[$t] = DEAD;
    $self->{logger}->debug("Thread $t deleted");
}

sub _modelParser {
   my $dataModel = shift;

   my $modelslist = {};
   my $lists;
   my $list;
   if (ref($dataModel->{MODEL}) eq "HASH"){
      foreach $lists (@{$dataModel->{MODEL}->{GET}}) {
         $modelslist->{$dataModel->{MODEL}->{ID}}->{GET}->{$lists->{OBJECT}} = {
                     OBJECT   => $lists->{OBJECT},
                     OID      => $lists->{OID},
                     VLAN     => $lists->{VLAN}
                  };
      }
      undef $lists;
      foreach $lists (@{$dataModel->{MODEL}->{WALK}}) {
         $modelslist->{$dataModel->{MODEL}->{ID}}->{WALK}->{$lists->{OBJECT}} = {
                     OBJECT   => $lists->{OBJECT},
                     OID      => $lists->{OID},
                     VLAN     => $lists->{VLAN}
                  };
      }
      undef $lists;
   } else {
      foreach my $num (@{$dataModel->{MODEL}}) {
         foreach $list ($num->{GET}) {
            if (ref($list) eq "HASH") {

            } else {
               foreach $lists (@{$list}) {
                  $modelslist->{ $num->{ID} }->{GET}->{$lists->{OBJECT}} = {
                        OBJECT   => $lists->{OBJECT},
                        OID      => $lists->{OID},
                        VLAN     => $lists->{VLAN}
                     };
               }
            }
            undef $lists;
         }
         foreach $list ($num->{WALK}) {
            if (ref($list) eq "HASH") {

            } else {
               foreach $lists (@{$list}) {
                  $modelslist->{ $num->{ID} }->{WALK}->{$lists->{OBJECT}} = {
                          OBJECT   => $lists->{OBJECT},
                          OID      => $lists->{OID},
                          VLAN     => $lists->{VLAN}
                        };
               }
            }
            undef $lists;
         }         
      }
   }
   return $modelslist;
}



sub _queryDeviceThreaded {
   my ($self, $params) = @_;

   my $ArraySNMPwalk = {};
   my $HashDataSNMP = {};
   my $datadevice = {};
   my $key;

	#threads->yield;
	############### SNMP Queries ###############
   my $session = FusionInventory::Agent::SNMP->new({

               version      => $params->{credentials}->{VERSION},
               hostname     => $params->{device}->{IP},
               community    => $params->{credentials}->{COMMUNITY},
               username     => $params->{credentials}->{USERNAME},
               authpassword => $params->{credentials}->{AUTHPASSWORD},
               authprotocol => $params->{credentials}->{AUTHPROTOCOL},
               privpassword => $params->{credentials}->{PRIVPASSWORD},
               privprotocol => $params->{credentials}->{PRIVPROTOCOL},
               translate    => 1,

            });
	if (!defined($session->{SNMPSession}->{session})) {
		return $datadevice;
	}
   my $session2 = FusionInventory::Agent::SNMP->new({

               version      => $params->{credentials}->{VERSION},
               hostname     => $params->{device}->{IP},
               community    => $params->{credentials}->{COMMUNITY},
               username     => $params->{credentials}->{USERNAME},
               authpassword => $params->{credentials}->{AUTHPASSWORD},
               authprotocol => $params->{credentials}->{AUTHPROTOCOL},
               privpassword => $params->{credentials}->{PRIVPASSWORD},
               privprotocol => $params->{credentials}->{PRIVPROTOCOL},
               translate    => 0,

            });


	my $error = '';
	# Query for timeout #
	my $description = $session->snmpGet({
                     oid => '.1.3.6.1.2.1.1.1.0',
                     up  => 1,
                  });
	my $insertXML = '';
	if ($description =~ m/No response from remote host/) {
		$error = "No response from remote host";
      $datadevice->{ERROR}->{ID} = $params->{device}->{ID};
      $datadevice->{ERROR}->{TYPE} = $params->{device}->{TYPE};
      $datadevice->{ERROR}->{MESSAGE} = $error;
		return $datadevice;
	} else {
		# Query SNMP get #
      if ($params->{device}->{TYPE} eq "PRINTER") {
         $params = cartridgesupport($params);
      }
      for $key ( keys %{$params->{modellist}->{GET}} ) {
         if ($params->{modellist}->{GET}->{$key}->{VLAN} == 0) {
            my $oid_result = $session->snmpGet({
                     oid => $params->{modellist}->{GET}->{$key}->{OID},
                     up  => 1,
                  });
            if (defined $oid_result
               && $oid_result ne ""
               && $oid_result ne "noSuchObject") {
               $HashDataSNMP->{$key} = $oid_result;
            }
         }
      }
      $datadevice->{INFO}->{ID} = $params->{device}->{ID};
      $datadevice->{INFO}->{TYPE} = $params->{device}->{TYPE};
      # Conversion
      ($datadevice, $HashDataSNMP) = _constructDataDeviceSimple($HashDataSNMP,$datadevice);


      # Query SNMP walk #
      my $vlan_query = 0;
      for $key ( keys %{$params->{modellist}->{WALK}} ) {
         $ArraySNMPwalk = $session->snmpWalk({
                        oid_start => $params->{modellist}->{WALK}->{$key}->{OID}
                     });
         $HashDataSNMP->{$key} = $ArraySNMPwalk;
         if (exists($params->{modellist}->{WALK}->{$key}->{VLAN})) {
            if ($params->{modellist}->{WALK}->{$key}->{VLAN} == 1) {
               $vlan_query = 1;
            }
         }
      }
      # Conversion

      ($datadevice, $HashDataSNMP) = _constructDataDeviceMultiple($HashDataSNMP,$datadevice, $self, $params->{modellist}->{WALK}->{vtpVlanName}->{OID}, $params->{modellist}->{WALK});

      if ($datadevice->{INFO}->{TYPE} eq "NETWORKING") {
         # Scan for each vlan (for specific switch manufacturer && model)
         # Implique de recrÃ©er une session spÃ©cialement pour chaque vlan : communautÃ©@vlanID
         if ($vlan_query == 1) {
            while ( (my $vlan_id,my $vlan_name) = each (%{$HashDataSNMP->{'vtpVlanName'}}) ) {
               my $vlan_id_short = $vlan_id;
               $vlan_id_short =~ s/$params->{modellist}->{WALK}->{vtpVlanName}->{OID}//;
               $vlan_id_short =~ s/^.//;
                #Initiate SNMP connection on this VLAN
               my $session = FusionInventory::Agent::SNMP->({

                              version      => $params->{credentials}->{VERSION},
                              hostname     => $params->{device}->{IP},
                              community    => $params->{credentials}->{COMMUNITY}."@".$vlan_id_short,
                              username     => $params->{credentials}->{USERNAME},
                              authpassword => $params->{credentials}->{AUTHPASSWORD},
                              authprotocol => $params->{credentials}->{AUTHPROTOCOL},
                              privpassword => $params->{credentials}->{PRIVPASSWORD},
                              privprotocol => $params->{credentials}->{PRIVPROTOCOL},
                              translate    => 1,

                           });
                  my $session2 = FusionInventory::Agent::SNMP->new({

                              version      => $params->{credentials}->{VERSION},
                              hostname     => $params->{device}->{IP},
                              community    => $params->{credentials}->{COMMUNITY}."@".$vlan_id_short,
                              username     => $params->{credentials}->{USERNAME},
                              authpassword => $params->{credentials}->{AUTHPASSWORD},
                              authprotocol => $params->{credentials}->{AUTHPROTOCOL},
                              privpassword => $params->{credentials}->{PRIVPASSWORD},
                              privprotocol => $params->{credentials}->{PRIVPROTOCOL},
                              translate    => 0,

                           });

               $ArraySNMPwalk = {};
               #$HashDataSNMP  = {};
               for my $link ( keys %{$params->{modellist}->{WALK}} ) {
                  if ($params->{modellist}->{WALK}->{$link}->{VLAN} == 1) {
                     $ArraySNMPwalk = $session->snmpWalk({
                                        oid_start => $params->{modellist}->{WALK}->{$link}->{OID}
                     });
                     $HashDataSNMP->{VLAN}->{$vlan_id}->{$link} = $ArraySNMPwalk;
                  }
               }
               # Detect mac adress on each port
               if ($datadevice->{INFO}->{COMMENTS} =~ /Cisco/) {
                  ($datadevice, $HashDataSNMP) = FusionInventory::Agent::Task::SNMPQuery::Cisco::GetMAC($HashDataSNMP,$datadevice,$vlan_id,$self, $params->{modellist}->{WALK});
               }
               delete $HashDataSNMP->{VLAN}->{$vlan_id};
            }
         } else {
            if (defined ($datadevice->{INFO}->{COMMENTS})) {
               if ($datadevice->{INFO}->{COMMENTS} =~ /3Com IntelliJack/) {
                  $datadevice = FusionInventory::Agent::Task::SNMPQuery::ThreeCom::RewritePortOf225($datadevice, $self);
               } elsif ($datadevice->{INFO}->{COMMENTS} =~ /3Com/) {
                  ($datadevice, $HashDataSNMP) = FusionInventory::Agent::Task::SNMPQuery::ThreeCom::GetMAC($HashDataSNMP,$datadevice,$self,$params->{modellist}->{WALK});
               } elsif ($datadevice->{INFO}->{COMMENTS} =~ /ProCurve/) {
                  ($datadevice, $HashDataSNMP) = FusionInventory::Agent::Task::SNMPQuery::Procurve::GetMAC($HashDataSNMP,$datadevice,$self, $params->{modellist}->{WALK});
               } elsif ($datadevice->{INFO}->{COMMENTS} =~ /Nortel/) {
                  ($datadevice, $HashDataSNMP) = FusionInventory::Agent::Task::SNMPQuery::Nortel::GetMAC($HashDataSNMP,$datadevice,$self, $params->{modellist}->{WALK});
               }
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
   ($datadevice, $HashDataSNMP) = _putSimpleOid($HashDataSNMP,$datadevice,'cpu','INFO','CPU');
   ($datadevice, $HashDataSNMP) = _putSimpleOid($HashDataSNMP,$datadevice,'location','INFO','LOCATION');
   ($datadevice, $HashDataSNMP) = _putSimpleOid($HashDataSNMP,$datadevice,'firmware','INFO','FIRMWARE');
   ($datadevice, $HashDataSNMP) = _putSimpleOid($HashDataSNMP,$datadevice,'firmware1','INFO','FIRMWARE');
   ($datadevice, $HashDataSNMP) = _putSimpleOid($HashDataSNMP,$datadevice,'contact','INFO','CONTACT');
   ($datadevice, $HashDataSNMP) = _putSimpleOid($HashDataSNMP,$datadevice,'comments','INFO','COMMENTS');
   ($datadevice, $HashDataSNMP) = _putSimpleOid($HashDataSNMP,$datadevice,'uptime','INFO','UPTIME');
   ($datadevice, $HashDataSNMP) = _putSimpleOid($HashDataSNMP,$datadevice,'serial','INFO','SERIAL');
   ($datadevice, $HashDataSNMP) = _putSimpleOid($HashDataSNMP,$datadevice,'name','INFO','NAME');
   ($datadevice, $HashDataSNMP) = _putSimpleOid($HashDataSNMP,$datadevice,'model','INFO','MODEL');
   ($datadevice, $HashDataSNMP) = _putSimpleOid($HashDataSNMP,$datadevice,'entPhysicalModelName','INFO','MODEL');
   ($datadevice, $HashDataSNMP) = _putSimpleOid($HashDataSNMP,$datadevice,'enterprise','INFO','MANUFACTURER');
   ($datadevice, $HashDataSNMP) = _putSimpleOid($HashDataSNMP,$datadevice,'otherserial','INFO','OTHERSERIAL');
   ($datadevice, $HashDataSNMP) = _putSimpleOid($HashDataSNMP,$datadevice,'memory','INFO','MEMORY');
   ($datadevice, $HashDataSNMP) = _putSimpleOid($HashDataSNMP,$datadevice,'ram','INFO','RAM');

   if ($datadevice->{INFO}->{TYPE} eq "PRINTER") {
      ($datadevice, $HashDataSNMP) = _putSimpleOid($HashDataSNMP,$datadevice,'tonerblack','CARTRIDGES','TONERBLACK');
      ($datadevice, $HashDataSNMP) = _putSimpleOid($HashDataSNMP,$datadevice,'tonerblack2','CARTRIDGES','TONERBLACK2');
      ($datadevice, $HashDataSNMP) = _putSimpleOid($HashDataSNMP,$datadevice,'tonercyan','CARTRIDGES','TONERCYAN');
      ($datadevice, $HashDataSNMP) = _putSimpleOid($HashDataSNMP,$datadevice,'tonermagenta','CARTRIDGES','TONERMAGENTA');
      ($datadevice, $HashDataSNMP) = _putSimpleOid($HashDataSNMP,$datadevice,'toneryellow','CARTRIDGES','TONERYELLOW');
      ($datadevice, $HashDataSNMP) = _putSimpleOid($HashDataSNMP,$datadevice,'wastetoner','CARTRIDGES','WASTETONER');
      ($datadevice, $HashDataSNMP) = _putSimpleOid($HashDataSNMP,$datadevice,'cartridgeblack','CARTRIDGES','CARTRIDGEBLACK');
      ($datadevice, $HashDataSNMP) = _putSimpleOid($HashDataSNMP,$datadevice,'cartridgeblackphoto','CARTRIDGES','CARTRIDGEBLACKPHOTO');
      ($datadevice, $HashDataSNMP) = _putSimpleOid($HashDataSNMP,$datadevice,'cartridgecyan','CARTRIDGES','CARTRIDGECYAN');
      ($datadevice, $HashDataSNMP) = _putSimpleOid($HashDataSNMP,$datadevice,'cartridgecyanlight','CARTRIDGES','CARTRIDGECYANLIGHT');
      ($datadevice, $HashDataSNMP) = _putSimpleOid($HashDataSNMP,$datadevice,'cartridgemagenta','CARTRIDGES','CARTRIDGEMAGENTA');
      ($datadevice, $HashDataSNMP) = _putSimpleOid($HashDataSNMP,$datadevice,'cartridgemagentalight','CARTRIDGES','CARTRIDGEMAGENTALIGHT');
      ($datadevice, $HashDataSNMP) = _putSimpleOid($HashDataSNMP,$datadevice,'cartridgeyellow','CARTRIDGES','CARTRIDGEYELLOW');
      ($datadevice, $HashDataSNMP) = _putSimpleOid($HashDataSNMP,$datadevice,'maintenancekit','CARTRIDGES','MAINTENANCEKIT');
      ($datadevice, $HashDataSNMP) = _putSimpleOid($HashDataSNMP,$datadevice,'drumblack','CARTRIDGES','DRUMBLACK');
      ($datadevice, $HashDataSNMP) = _putSimpleOid($HashDataSNMP,$datadevice,'drumcyan','CARTRIDGES','DRUMCYAN');
      ($datadevice, $HashDataSNMP) = _putSimpleOid($HashDataSNMP,$datadevice,'drummagenta','CARTRIDGES','DRUMMAGENTA');
      ($datadevice, $HashDataSNMP) = _putSimpleOid($HashDataSNMP,$datadevice,'drumyellow','CARTRIDGES','DRUMYELLOW');

      ($datadevice, $HashDataSNMP) = _putSimpleOid($HashDataSNMP,$datadevice,'pagecountertotalpages','PAGECOUNTERS','TOTAL');
      ($datadevice, $HashDataSNMP) = _putSimpleOid($HashDataSNMP,$datadevice,'pagecounterblackpages','PAGECOUNTERS','BLACK');
      ($datadevice, $HashDataSNMP) = _putSimpleOid($HashDataSNMP,$datadevice,'pagecountercolorpages','PAGECOUNTERS','COLOR');
      ($datadevice, $HashDataSNMP) = _putSimpleOid($HashDataSNMP,$datadevice,'pagecounterrectoversopages','PAGECOUNTERS','RECTOVERSO');
      ($datadevice, $HashDataSNMP) = _putSimpleOid($HashDataSNMP,$datadevice,'pagecounterscannedpages','PAGECOUNTERS','SCANNED');
      ($datadevice, $HashDataSNMP) = _putSimpleOid($HashDataSNMP,$datadevice,'pagecountertotalpages_print','PAGECOUNTERS','PRINTTOTAL');
      ($datadevice, $HashDataSNMP) = _putSimpleOid($HashDataSNMP,$datadevice,'pagecounterblackpages_print','PAGECOUNTERS','PRINTBLACK');
      ($datadevice, $HashDataSNMP) = _putSimpleOid($HashDataSNMP,$datadevice,'pagecountercolorpages_print','PAGECOUNTERS','PRINTCOLOR');
      ($datadevice, $HashDataSNMP) = _putSimpleOid($HashDataSNMP,$datadevice,'pagecountertotalpages_copy','PAGECOUNTERS','COPYTOTAL');
      ($datadevice, $HashDataSNMP) = _putSimpleOid($HashDataSNMP,$datadevice,'pagecounterblackpages_copy','PAGECOUNTERS','COPYBLACK');
      ($datadevice, $HashDataSNMP) = _putSimpleOid($HashDataSNMP,$datadevice,'pagecountercolorpages_copy','PAGECOUNTERS','COPYCOLOR');
      ($datadevice, $HashDataSNMP) = _putSimpleOid($HashDataSNMP,$datadevice,'pagecountertotalpages_fax','PAGECOUNTERS','FAXTOTAL');

      ($datadevice, $HashDataSNMP) = _putPourcentageOid($HashDataSNMP,$datadevice,'cartridgesblackMAX','cartridgesblackREMAIN',
                                                         'CARTRIDGE','BLACK');
      ($datadevice, $HashDataSNMP) = _putPourcentageOid($HashDataSNMP,$datadevice,'cartridgescyanMAX','cartridgescyanREMAIN',
                                                         'CARTRIDGE','CYAN');
      ($datadevice, $HashDataSNMP) = _putPourcentageOid($HashDataSNMP,$datadevice,'cartridgesyellowMAX','cartridgesyellowREMAIN',
                                                         'CARTRIDGE','YELLOW');
      ($datadevice, $HashDataSNMP) = _putPourcentageOid($HashDataSNMP,$datadevice,'cartridgesmagentaMAX','cartridgesmagentaREMAIN',
                                                         'CARTRIDGE','MAGENTA');
      ($datadevice, $HashDataSNMP) = _putPourcentageOid($HashDataSNMP,$datadevice,'cartridgescyanlightMAX','cartridgescyanlightREMAIN',
                                                         'CARTRIDGE','CYANLIGHT');
      ($datadevice, $HashDataSNMP) = _putPourcentageOid($HashDataSNMP,$datadevice,'cartridgesmagentalightMAX','cartridgesmagentalightREMAIN',
                                                         'CARTRIDGE','MAGENTALIGHT');
      ($datadevice, $HashDataSNMP) = _putPourcentageOid($HashDataSNMP,$datadevice,'cartridgesphotoconductorMAX','cartridgesphotoconductorREMAIN',
                                                         'CARTRIDGE','PHOTOCONDUCTOR');
      ($datadevice, $HashDataSNMP) = _putPourcentageOid($HashDataSNMP,$datadevice,'cartridgesphotoconductorblackMAX','cartridgesphotoconductorblackREMAIN',
                                                         'CARTRIDGE','PHOTOCONDUCTORBLACK');
      ($datadevice, $HashDataSNMP) = _putPourcentageOid($HashDataSNMP,$datadevice,'cartridgesphotoconductorcolorMAX','cartridgesphotoconductorcolorREMAIN',
                                                         'CARTRIDGE','PHOTOCONDUCTORCOLOR');
      ($datadevice, $HashDataSNMP) = _putPourcentageOid($HashDataSNMP,$datadevice,'cartridgesphotoconductorcyanMAX','cartridgesphotoconductorcyanREMAIN',
                                                         'CARTRIDGE','PHOTOCONDUCTORCYAN');
      ($datadevice, $HashDataSNMP) = _putPourcentageOid($HashDataSNMP,$datadevice,'cartridgesphotoconductoryellowMAX','cartridgesphotoconductoryellowREMAIN',
                                                         'CARTRIDGE','PHOTOCONDUCTORYELLOW');
      ($datadevice, $HashDataSNMP) = _putPourcentageOid($HashDataSNMP,$datadevice,'cartridgesphotoconductormagentaMAX','cartridgesphotoconductormagentaREMAIN',
                                                         'CARTRIDGE','PHOTOCONDUCTORMAGENTA');
      ($datadevice, $HashDataSNMP) = _putPourcentageOid($HashDataSNMP,$datadevice,'cartridgesunittransfertblackMAX','cartridgesunittransfertblackREMAIN',
                                                         'CARTRIDGE','UNITTRANSFERBLACK');
      ($datadevice, $HashDataSNMP) = _putPourcentageOid($HashDataSNMP,$datadevice,'cartridgesunittransfertcyanMAX','cartridgesunittransfertcyanREMAIN',
                                                         'CARTRIDGE','UNITTRANSFERCYAN');
      ($datadevice, $HashDataSNMP) = _putPourcentageOid($HashDataSNMP,$datadevice,'cartridgesunittransfertyellowMAX','cartridgesunittransfertyellowREMAIN',
                                                         'CARTRIDGE','UNITTRANSFERYELLOW');
      ($datadevice, $HashDataSNMP) = _putPourcentageOid($HashDataSNMP,$datadevice,'cartridgesunittransfertmagentaMAX','cartridgesunittransfertmagentaREMAIN',
                                                         'CARTRIDGE','UNITTRANSFERMAGENTA');
      ($datadevice, $HashDataSNMP) = _putPourcentageOid($HashDataSNMP,$datadevice,'cartridgeswasteMAX','cartridgeswasteREMAIN',
                                                         'CARTRIDGE','WASTE');
      ($datadevice, $HashDataSNMP) = _putPourcentageOid($HashDataSNMP,$datadevice,'cartridgesfuserMAX','cartridgesfuserREMAIN',
                                                         'CARTRIDGE','FUSER');
      ($datadevice, $HashDataSNMP) = _putPourcentageOid($HashDataSNMP,$datadevice,'cartridgesbeltcleanerMAX','cartridgesbeltcleanerREMAIN',
                                                         'CARTRIDGE','BELTCLEANER');
      ($datadevice, $HashDataSNMP) = _putPourcentageOid($HashDataSNMP,$datadevice,'cartridgesmaintenancekitMAX','cartridgesmaintenancekitREMAIN',
                                                         'CARTRIDGE','MAINTENANCEKIT');
   }
   return $datadevice, $HashDataSNMP;
}


sub _constructDataDeviceMultiple {
   my $HashDataSNMP = shift;
   my $datadevice = shift;
   my $self = shift;
   my $vtpVlanName_oid = shift;
   my $walkoid = shift;
   
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
             $shortobject =~ s/$walkoid->{ifaddr}->{OID}//;
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
         ($datadevice, $HashDataSNMP) = FusionInventory::Agent::Task::SNMPQuery::Cisco::CDPPorts($HashDataSNMP,$datadevice, $walkoid, $self);
      } elsif ($datadevice->{INFO}->{COMMENTS} =~ /ProCurve/) {
         ($datadevice, $HashDataSNMP) = FusionInventory::Agent::Task::SNMPQuery::Cisco::TrunkPorts($HashDataSNMP,$datadevice, $self);
         ($datadevice, $HashDataSNMP) = FusionInventory::Agent::Task::SNMPQuery::Procurve::CDPLLDPPorts($HashDataSNMP,$datadevice, $walkoid, $self);
      } elsif ($datadevice->{INFO}->{COMMENTS} =~ /Nortel/) {
         ($datadevice, $HashDataSNMP) = FusionInventory::Agent::Task::SNMPQuery::Nortel::VlanTrunkPorts($HashDataSNMP,$datadevice, $self);
         ($datadevice, $HashDataSNMP) = FusionInventory::Agent::Task::SNMPQuery::Nortel::LLDPPorts($HashDataSNMP,$datadevice, $walkoid, $self);
      }
   }

   # Detect VLAN
   if (exists $HashDataSNMP->{vmvlan}) {
      while ( ($object,$data) = each (%{$HashDataSNMP->{vmvlan}}) ) {
         $datadevice->{PORTS}->{PORT}->[$self->{portsindex}->{lastSplitObject($object)}]->{VLANS}->{VLAN}->{NUMBER} = $data;
         $datadevice->{PORTS}->{PORT}->[$self->{portsindex}->{lastSplitObject($object)}]->{VLANS}->{VLAN}->{NAME} = $HashDataSNMP->{vtpVlanName}->{$vtpVlanName_oid.".".$data};
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
            ($datadevice, $HashDataSNMP) = _putPourcentageOid($HashDataSNMP,$datadevice,$element."-capacitytype",$element."-level", $xmlelement1, $xmlelement2);
         }
      } else {
         $datadevice->{$xmlelement1}->{$xmlelement2} = $HashDataSNMP->{$element};
      }
      delete $HashDataSNMP->{$element};
      
   }
   return $datadevice, $HashDataSNMP;
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
   return $datadevice, $HashDataSNMP;
}



sub _lastSplitObject {
   my $var = shift;

   my @array = split(/\./, $var);
   return $array[-1];
}


sub _cartridgesupport {
   my $params = shift;

   for my $key ( keys %{$params->{modellist}->{GET}} ) {
      if (($key =~ /^toner/) || ($key eq "wastetoner") || ($key =~ /^cartridge/) || ($key eq "maintenancekit") || ($key =~ /^drum/)) {
         $params->{modellist}->{GET}->{$key."-capacitytype"}->{OID} = $params->{modellist}->{GET}->{$key}->{OID};
         $params->{modellist}->{GET}->{$key."-capacitytype"}->{OID} =~ s/43.11.1.1.6/43.11.1.1.8/;
         $params->{modellist}->{GET}->{$key."-capacitytype"}->{VLAN} = 0;

         $params->{modellist}->{GET}->{$key."-level"}->{OID} = $params->{modellist}->{GET}->{$key}->{OID};
         $params->{modellist}->{GET}->{$key."-level"}->{OID} =~ s/43.11.1.1.6/43.11.1.1.9/;
         $params->{modellist}->{GET}->{$key."-level"}->{VLAN} = 0;
      }
   }
   return $params;
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
