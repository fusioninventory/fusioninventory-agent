package FusionInventory::Agent::Task::NetDiscovery::Manufacturer::Kyocera;


sub discovery {
   my $empty       = shift;
   my $description = shift;
   my $session     = shift;

   if ($description =~ m/,HP,JETDIRECT,J/) {
      my $description_new = $session->snmpGet({
                        oid => '.1.3.6.1.4.1.1229.2.2.2.1.15.1',
                        up  => 1,
                     });
      if (($description_new ne "null") && ($description_new ne "No response from remote host")) {
         $description = $description_new;
      }
   } elsif (($description eq "KYOCERA MITA Printing System") || ($description eq "KYOCERA Printer I/F") || ($description eq "SB-110")) {
      my $description_new = $session->snmpGet({
                        oid => '.1.3.6.1.4.1.1347.42.5.1.1.2.1',
                        up  => 1,
                     });
      if (($description_new ne "null") && ($description_new ne "No response from remote host")) {
         $description = $description_new;
      } elsif ($description_new eq "No response from remote host") {
          my $description_new = $session->snmpGet({
                            oid => '.1.3.6.1.4.1.1347.43.5.1.1.1.1',
                            up  => 1,
                         });
          if (($description_new ne "null") && ($description_new ne "No response from remote host")) {
             $description = $description_new;
          } elsif ($description_new eq "No response from remote host") {
             my $description_new = $session->snmpGet({
                            oid => '.1.3.6.1.4.1.1347.43.5.1.1.1.1',
                            up  => 1,
                         });
             if (($description_new ne "null") && ($description_new ne "No response from remote host")) {
                $description = $description_new;
             } elsif ($description_new eq "No response from remote host") {
                my $description_new = $session->snmpGet({
                               oid => '.1.3.6.1.4.1.11.2.3.9.1.1.7.0',
                               up  => 1,
                            });
                if (($description_new ne "null") && ($description_new ne "No response from remote host")) {
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
      }
   }
   return $description;
}

1;