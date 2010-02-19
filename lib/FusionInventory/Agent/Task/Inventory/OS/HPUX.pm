package FusionInventory::Agent::Task::Inventory::OS::HPUX;

use strict;
use vars qw($runAfter);
$runAfter = ["FusionInventory::Agent::Backend::OS::Generic"];

sub isInventoryEnabled  { $^O =~ /hpux/ }

sub doInventory {
  my $params = shift;
  my $inventory = $params->{inventory};
  my $OSName;
  my $OSVersion;
  my $OSComment;
  #my $uname_path          = &_get_path('uname');
  
  # Operating systeminformations
  
  chomp($OSName = `uname -s`);
  chomp($OSVersion = `uname -r`);
  chomp($OSComment = `uname -l`);

  $inventory->setHardware({
      OSNAME => $OSName,
      OSCOMMENTS => $OSComment,
      OSVERSION => $OSVersion,
    });

}

1;
