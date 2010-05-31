package FusionInventory::Agent::Task::NetDiscovery::Manufacturer::Axis;


sub discovery {
   my $empty       = shift;
   my $description = shift;
   my $session     = shift;

   if ($description =~ m/AXIS OfficeBasic Network Print Server/) {
      my $description_new = $session->snmpGet({
                     oid => '.1.3.6.1.4.1.2699.1.2.1.2.1.1.3.1',
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
   return $description;
}

1;