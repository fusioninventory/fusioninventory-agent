package FusionInventory::Agent::Task::NetDiscovery::Manufacturer::Alcatel;


sub discovery {
   my $empty       = shift;
   my $description = shift;
   my $session     = shift;

   # example : 5.1.6.485.R02 Service Release, September 26, 2008.

   if ($description =~ m/^([1-9]{1}).([0-9]{1}).([0-9]{1})(.*) Service Release,(.*)([0-9]{1}).$/ ) {
      my $description_new = $session->snmpGet({
                        oid => '.1.3.6.1.2.1.47.1.1.1.1.13.1',
                        up  => 1,
                     });
      if (($description_new ne "null") && ($description_new ne "No response from remote host")) {
         if ($description_new eq "OS66-P24") {
            $description = "OmniStack 6600-P24";
         } else {
            $description = $description_new;
         }
      }
   }
   return $description;
}

1;