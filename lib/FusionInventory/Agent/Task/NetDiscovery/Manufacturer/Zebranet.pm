package FusionInventory::Agent::Task::NetDiscovery::Manufacturer::Zebranet;


sub discovery {
   my $empty       = shift;
   my $description = shift;
   my $session     = shift;

   if($description =~ m/ZebraNet PrintServer/) {
      my $description_new = $session->snmpGet({
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
   return $description;
}

1;