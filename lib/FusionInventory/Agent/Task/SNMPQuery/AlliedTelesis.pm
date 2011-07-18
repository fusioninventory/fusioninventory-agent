package FusionInventory::Agent::Task::SNMPQuery::AlliedTelesis;

use strict;
use Data::Dumper;


sub GetMAC {
   my $HashDataSNMP = shift,
   my $datadevice = shift;
   my $self = shift;
   my $oid_walks = shift;

   my $ifIndex;
   my $numberip;
   my $mac;
   my $short_number;
   my $dot1dTpFdbPort;

   my $i = 0;

   while ( my ($number,$ifphysaddress) = each (%{$HashDataSNMP->{dot1dTpFdbAddress}}) ) {
      $short_number = $number;
      $short_number =~ s/$oid_walks->{dot1dTpFdbAddress}->{OID}//;
      $dot1dTpFdbPort = $oid_walks->{dot1dTpFdbPort}->{OID};
      if (exists $HashDataSNMP->{dot1dTpFdbPort}->{$dot1dTpFdbPort.$short_number}) {
         if (exists $HashDataSNMP->{dot1dBasePortIfIndex}->{
                              $oid_walks->{dot1dBasePortIfIndex}->{OID}.".".
                              $HashDataSNMP->{dot1dTpFdbPort}->{$dot1dTpFdbPort.$short_number}
                           }) {

            $ifIndex = $HashDataSNMP->{dot1dBasePortIfIndex}->{
                              $oid_walks->{dot1dBasePortIfIndex}->{OID}.".".
                              $HashDataSNMP->{dot1dTpFdbPort}->{$dot1dTpFdbPort.$short_number}
                           };
            if (not exists $datadevice->{PORTS}->{PORT}->[$self->{portsindex}->{$ifIndex}]->{CONNECTIONS}->{CDP}) {
               my $add = 1;
               if ($ifphysaddress eq "") {
                  $add = 0;
               }
               if ($ifphysaddress eq $datadevice->{PORTS}->{PORT}->[$self->{portsindex}->{$ifIndex}]->{MAC}) {
                  $add = 0;
               }
               if ($add eq "1") {
                  if (exists $datadevice->{PORTS}->{PORT}->[$self->{portsindex}->{$ifIndex}]->{CONNECTIONS}->{CONNECTION}) {
                     $i = @{$datadevice->{PORTS}->{PORT}->[$self->{portsindex}->{$ifIndex}]->{CONNECTIONS}->{CONNECTION}};
                     #$i++;
                  } else {
                     $i = 0;
                  }
                  $datadevice->{PORTS}->{PORT}->[$self->{portsindex}->{$ifIndex}]->{CONNECTIONS}->{CONNECTION}->[$i]->{MAC} = $ifphysaddress;
                  $i++;
               }
            }
         }
      }
      delete $HashDataSNMP->{dot1dTpFdbAddress}->{$number};
      delete $HashDataSNMP->{dot1dTpFdbPort}->{$dot1dTpFdbPort.$short_number};
   }
   return $datadevice, $HashDataSNMP;
}

1;