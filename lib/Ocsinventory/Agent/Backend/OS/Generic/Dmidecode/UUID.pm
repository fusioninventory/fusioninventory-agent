package Ocsinventory::Agent::Backend::OS::Generic::Dmidecode::UUID;

use strict;

sub check { return can_run('dmidecode') }

sub run {
  my $params = shift;
  my $inventory = $params->{inventory};

  my $dmidecode = `dmidecode`; # TODO retrieve error
  # some versions of dmidecode do not separate items with new lines
  # so add a new line before each handle
  $dmidecode =~ s/\nHandle/\n\nHandle/g;
  my @dmidecode = split (/\n/, $dmidecode);
  # add a new line at the end
  push @dmidecode, "\n";
  # delete all space at the beginning of each line
  s/^\s+// for (@dmidecode);

  my $flag;
  my $uuid;

  foreach (@dmidecode) {
     if (/dmi type 1,/i) {
         $flag = 1;
         next;
     }

     if ($flag) {
        if (/^UUID:\s+(\S+)/) {
            $uuid = $1;
            last;
        } elsif (/^$/) { # End of the TYPE 1 section
            last;
        }
      }
   }

   $inventory->setHardware({
      UUID => $uuid,
   });

}

1;
