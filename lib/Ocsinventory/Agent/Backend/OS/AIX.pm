package Ocsinventory::Agent::Backend::OS::AIX;

use strict;
use vars qw($runAfter);
$runAfter = ["Ocsinventory::Agent::Backend::OS::Generic"];

sub check {
	my $r;
	$r = 1 if $^O =~ /^aix$/;
	$r;
}

sub run {
  my $params = shift;
  my $inventory = $params->{inventory};
  
  my @tabOS;
  my $OSName;
  my $OSComment;
  my $OSVersion;
  my $OSLevel;
  #Operating system informations
  chomp($OSName=`uname -s`);
  # AIX OSVersion = oslevel, OSComment=oslevel -r affiche niveau de maintenance
  chomp($OSVersion=`oslevel`);
  chomp($OSLevel=`oslevel -r`);
  @tabOS=split(/-/,$OSLevel);
  $OSComment="Maintenance Level :".@tabOS[1];

  $OSVersion =~ s/(.0)*$//;
  $inventory->setHardware({
      OSNAME => "$OSName $OSVersion",
      OSCOMMENTS => $OSComment,
      OSVERSION => $OSLevel,
    });
}
1;
