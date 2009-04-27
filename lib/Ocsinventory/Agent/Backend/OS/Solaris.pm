package Ocsinventory::Agent::Backend::OS::Solaris;

use strict;
use vars qw($runAfter);
$runAfter = ["Ocsinventory::Agent::Backend::OS::Generic"];

sub check {$^O =~ /^solaris$/}

sub run {
  my $params = shift;
  my $inventory = $params->{inventory};

  my $OSName;
  my $OSComment;
  my $OSVersion;
  my $OSLevel;
  my $HWDescription;
  my ( $karch, $hostid, $proct, $platform);

  #Operating system informations
  chomp($OSName=`uname -s`);
  chomp($OSLevel=`uname -r`);
  chomp($OSComment=`uname -v`);

   open(FH, "< /etc/release") and do {
       chomp($OSVersion = readline (FH));
       $OSVersion =~ s/^\s+//;
       close FH;
   };

  chomp($OSVersion=`uname -v`) unless $OSVersion;
  chomp($OSVersion);
  $OSVersion=~s/^\s*//;
  $OSVersion=~s/\s*$//;
      
  # Hardware informations
  chomp($karch=`arch -k`);
  chomp($hostid=`hostid`);
  chomp($proct=`uname -p`);
  chomp($platform=`uname -i`);
  $HWDescription = "$platform($karch)/$proct HostID=$hostid";

  $inventory->setHardware({
      OSNAME => "$OSName $OSLevel",
      OSCOMMENTS => $OSComment,
      OSVERSION => $OSVersion,
      DESCRIPTION => $HWDescription
    });
}


1;
