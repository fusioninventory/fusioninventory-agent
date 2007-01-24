use ExtUtils::MakeMaker;

WriteMakefile(
  'NAME' => 'Ocsinventory-Agent',
  'DISTNAME' => 'Ocsinventory-Agent',
  'EXE_FILES' => ["ocs-agent"],
  'VERSION_FROM' => 'ocs-agent',
  'dist'    => {COMPRESS=> 'gzip -9f', SUFFIX=>'gz', 
 	          POSTOP => 'mv $(NAME)-$(VERSION).tar.gz ../'
  },

  (
    $ENV{SKIP_FOR_CORE}
    ? (MAN3PODS    => {})
    : (PREREQ_PM   => { 
      'Compress::Zlib'            => 0,
      'Digest::MD5'               => 0, 
      'XML::Simple'               => 0, 
      'Net::IP'                   => 0, 
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

