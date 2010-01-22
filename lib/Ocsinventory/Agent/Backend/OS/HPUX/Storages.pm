package Ocsinventory::Agent::Backend::OS::HPUX::Storages;

sub check  { $^O =~ /hpux/ }

sub run {
   my $params = shift;
   my $inventory = $params->{inventory};

   my @all_type = ("tape","disk") ;
   my $type;

   my $description;
   my $path;
   my $vendor;
   my $ref;
   my $size;

   my $devdsk;
   my $devrdsk;
   my $revlvl;
   my $alternate;

   for ( @all_type ) {
     $type = "$_";
     for ( `ioscan -kFnC $type | cut -d ':' -f 1,11,18` ) {
        if ( /^(\S+)\:(\S+)\:(\S+)\s+(\S+)/ ) {
           $description = $1;
           $path = $2;
	   $vendor = $3;
           $ref = $4;
	 };
        $alternate = 0 ;
	if (  $type eq "disk" ) {
           if ( /^\s+(\S+)\s+(\S+)/ ) {
              #print "1 $1 2 $2 \n";
              $devdsk=$1;
              $devrdsk=$2;
              # On va regarder si on est sur un alternate link
	      for ( `pvdisplay $devdsk 2> /dev/null` ) {
		 if ( /$devdsk\.+lternate/ ) {
                    $alternate=1;
	         };
              };
              # On est pas sur un alternate link
              if ( $alternate eq 0 ) {
                 #$size = `diskinfo -b $devrdsk`;
	         
		 for ( `diskinfo -v $devrdsk`) {
		   if ( /^\s+size:\s+(\S+)/ ) {
		     $size=$1;
                     $size = int ( $size/1024 ) if $size;
                   };
		   if ( /^\s+rev level:\s+(\S+)/ ) {
		     $revlvl=$1;
		   };
                 };
                 #print "vendor $vendor ref $ref type $type description $description path $path size $size\n";
                 $inventory->addStorages({
                    MANUFACTURER => $vendor,
                    MODEL => $ref,
                    NAME => $devdsk,
                    DESCRIPTION => $description,
                    TYPE => $type,
                    DISKSIZE => $size,
                    FIRMWARE => $revlvl,
				});
	       };
	    };
         } else {
           # On traite les tapes 
	   if ( /^\s+(\/dev\/rmt\/\Sm)\s+/ ) {
	      $devdsk=$1;
	   $inventory->addStorages({
                 MANUFACTURER => $vendor,
                 MODEL => $ref,
                 NAME => $devdsk,
                 DESCRIPTION => $description,
                 TYPE => $type,
                 DISKSIZE => ''
				   });
	    };
         };
      };
   };
}

1;
