package FusionInventory::Agent::Task::NetDiscovery::Manufacturer::HewlettPackard;

sub discovery {
   my $empty       = shift;
   my $description = shift;
   my $session     = shift;

   if (($description =~ m/HP ETHERNET MULTI-ENVIRONMENT/) || ($description =~ m/A SNMP proxy agent, EEPROM/)){
      my $description_new = $session->snmpGet({
                        oid => '.1.3.6.1.2.1.25.3.2.1.3.1',
                        up  => 1,
                     });
      if (($description_new ne "null") && ($description_new ne "No response from remote host")) {
         $description = $description_new;
      } elsif ($description_new eq "No response from remote host") {
         $description_new = $session->snmpGet({
                        oid => '.1.3.6.1.4.1.11.2.3.9.1.1.7.0',
                        up  => 1,
                     });
         if ($description_new ne "null") {
            my @infos = split(/;/,$description_new);
            foreach (@infos) {
               if ($_ =~ /^MDL:/) {
                  $_ =~ s/MDL://;
                  $description = $_;
                  last;
               } elsif ($_ =~ /^MODEL:/) {
                  $_ =~ s/MODEL://;
                  $description = $_;
                  last;
               }
            }
         }
      }
   }
   return $description;
}

1;