# Write by Simon CLARA 2010-01-25
#
# The complet name of the package
# the path MUST be valid or the package won't be loaded
package FusionInventory::Agent::Backend::OS::Generic::Tarballs;
use strict;
# I need to declare $runAfter because of the strict mode 
use vars qw($runAfter);
# The package must be run after OS::Generic
$runAfter = ["FusionInventory::Agent::Backend::OS::Generic"];

# This is the check function. The agent runs it just once the module is loaded.
# If the function return false, the module and its children are not executed
# eg: OS::Linux and OS::Linux::* won't executed if this run() function return
# false

# Check if we are on a linux server
sub check { $^O =~ /^linux$/ }
# uncomment this if you want check for FreeBSD server
# sub check {can_run("pkg_info")}

# its the main function of the script, it's called during the hardware inventory
sub run {
  my $params = shift;
  # I need to get the inventory object to update it
  my $inventory = $params->{inventory};

# our software are in /usr/local/src/
foreach (`ls /usr/local/src/*.{bz2,tar.gz}`){
    /^(\/.*\/)(\S+)-(\d+\S*)(\.tar.gz|\.bz2)$/i;
    my $name = $2;
    my $version = $3;
    my $comments = "Software in /usr/local/src/ \n".`$2 --version`;
    # and I updated the information collected
      $inventory->addSoftwares({
          COMMENTS => $comments,
          NAME => $name,
          VERSION => $version
        });
  }
}

1;
