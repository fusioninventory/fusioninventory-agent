use ExtUtils::MakeMaker;

WriteMakefile(
  'NAME' => 'Ocsinventory-Agent',
  'DISTNAME' => 'Ocsinventory-Agent',
  'EXE_FILES' => ["ocsinventory-agent"],
  'VERSION_FROM' => 'ocsinventory-agent',
  'dist'    => {COMPRESS=> 'gzip -9f', SUFFIX=>'gz', 
 	          POSTOP => 'mv $(NAME)-$(VERSION).tar.gz ../'
  },

  (
    $ENV{SKIP_FOR_CORE}
    ? (MAN3PODS    => {})
    : (PREREQ_PM   => { 
      'Digest::MD5'               => 0, 
      'XML::Simple'               => 0, 
      'Net::IP'                   => 0, 
      'Proc::Daemon'              => 0, 
      'LWP'			  => 0,
      'File::Temp'		  => 0,
      'Net::IP'			  => 0,
    }
  )
),

(
  $] >= 5.005
  ? (
    AUTHOR       => 'Gonéri Le Bouder <goneri@rulezlan.org>')
  : ()
), 


);

# Check for compress backend
my @tmpgzip = `gzip -V 2>/dev/null`; 
eval { require Compress::Zlib };
if (!$@) {
    print "Compress::Zlib is avalaible. I will use it for the compress backend\n";
} elsif (!@tmpgzip) {
    print "Warning: Can't find Compress::Zlib or the gzip command to compress inventory\n";
} else {
    print "gzip is avalaible. I will use it for the compress backend. OCS Server ";
    print "1.01 and prior do not support this feature and so needs Compress::Zlib\n";
}

eval { require Crypt::SSLeay };
if ($@) {
    print "Crypt::SSLeay is not installed. You'll not able to do client ";
    print "authentification with SSL\n".
}
