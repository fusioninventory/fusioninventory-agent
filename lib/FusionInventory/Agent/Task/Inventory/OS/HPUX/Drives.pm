package FusionInventory::Agent::Task::Inventory::OS::AIX::Drives;

sub doInventory  { $^O =~ /hpux/ }

sub run {
   my $params = shift;
   my $inventory = $params->{inventory};

   my $type;
   my $fs;
   my $lv;
   my $total;
   my $free;
   

   for ( `fstyp -l | grep -v nfs` ) {
      $type=$_;
      for ( `bdf -t $type `) {
        if ( /Filesystem/ ) { ;  } ;
        if ( /^(\S+)\s(\d+)\s+(\d+)\s+(\d+)\s+(\d+%)\s+(\S+)/ ) {
	   $lv=$1;
           $total=$2;
           $free=$3;
           $fs=$6;
	   $inventory->addDrives({
               FREE => $free,
               FILESYSTEM => $fs,
               TOTAL => $total,
               TYPE => $type,
               VOLUMN => $lv,
				 });

	};
	if ( /^(\S+)\s/) {
	   $lv=$1;
	};
        if ( /(\d+)\s+(\d+)\s+(\d+)\s+(\d+%)\s+(\S+)/) {
	   $total=$1;
	   $free=$3;
	   $fs=$5;
	# print "fs $fs lv $lv total $total free $free type $type\n";
        $inventory->addDrives({
           FREE => $free,
           FILESYSTEM => $fs,
           TOTAL => $total,
           TYPE => $type,
           VOLUMN => $lv,
			     });
        };
      };

   };
}

1;
