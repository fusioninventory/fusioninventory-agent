package FusionInventory::Agent::Task::NetDiscovery::Manufacturer::Epson;


sub discovery {
   my $empty       = shift;
   my $description = shift;
   my $session     = shift;

   if($description =~ m/EPSON Built-in/) {
      my $description_new = $session->snmpGet({
                        oid => '.1.3.6.1.4.1.1248.1.1.3.1.3.8.0',
                        up  => 1,
                     });
      if ($description_new ne "null") {
         $description = $description_new;
      }
   }
   return $description;
}

1;