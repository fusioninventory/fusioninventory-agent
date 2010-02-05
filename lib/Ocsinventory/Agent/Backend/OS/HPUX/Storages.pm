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
        if ( /(\S+)\:(\S+)\:(\S+)\s+(\S+)/ ) {
           $description = $1;
           $path = $2;
	   $vendor = $3;
           $ref = $4;
	 };
        $alternate = 0 ;
	if (  $type eq "disk" ) {
           if ( /\s+(\/dev\/dsk\/\S+)\s+(\/dev\/rdsk\/\S+)/ ) {
              #print "1 $1 2 $2 \n";
              $devdsk=$1;
              $devrdsk=$2;
              # We look if whe are on an alternate link
	      for ( `pvdisplay $devdsk 2> /dev/null` ) {
		 if ( /$devdsk\.+lternate/ ) {
                    $alternate=1;
	         };
              };
              # We are not on an alternate link
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
           # We look for tapes
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
