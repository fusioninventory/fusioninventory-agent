package FusionInventory::Agent::Task::NetDiscovery::Manufacturer::Samsung;


sub discovery {
   my $empty       = shift;
   my $description = shift;
   my $session     = shift;

   if($description =~ m/SAMSUNG NETWORK PRINTER,ROM/) {
      my $description_new = $session->snmpGet({
                        oid => '.1.3.6.1.4.1.236.11.5.1.1.1.1.0',
                        up  => 1,
                     });
      if ($description_new ne "null") {
         $description = $description_new;
      }
   }
   return $description;
}

1;