package FusionInventory::Agent::Task::NetDiscovery::Manufacturer::Wyse;


sub discovery {
   my $empty       = shift;
   my $description = shift;
   my $session     = shift;

   if ($description =~ m/Linux/) {

      my $description_new = $session->snmpGet({
                        oid => '.1.3.6.1.4.1.714.1.2.5.6.1.2.1.6.1',
                        up  => 1,
                     });
      if (($description_new ne "null") && ($description_new ne "noSuchObject")) {

         $description_new =~ s/^"//;
         $description_new =~ s/"$//;
         $description = "Wyse ".$description_new;
      }
   }

   # OR ($description{'.1.3.6.1.2.1.1.1.0'} =~ m/Windows/))
   # In other oid for Windows

   return $description;
}

1;
