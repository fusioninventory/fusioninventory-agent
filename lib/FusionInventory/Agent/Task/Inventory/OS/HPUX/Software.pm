package FusionInventory::Agent::Task::Inventory::OS::HPUX::Software;

sub isInventoryEnabled  { 
   my $params = shift;

   # Do not run an package inventory if there is the --nosoft parameter
   return if ($params->{params}->{nosoft});

   $^O =~ /hpux/ 
}

sub doInventory {
   my $params = shift;
   my $inventory = $params->{inventory};

   my @softList;
   my $software;

   

   @softList = `swlist | grep -v '^  PH' | grep -v '^#' |tr -s "\t" " "|tr -s " "` ;
   foreach $software (@softList) {
      chomp( $software );
      if ( $software =~ /^ (\S+)\s(\S+)\s(.+)/ ) {
         $inventory->addSoftwares({
                        'NAME'          => $1  ,
                        'VERSION'       => $2 ,
                        'COMMENTS'      => $3 ,
                        'PUBLISHER'     => "HP" ,
				  });
       }
    }

 }

1;
