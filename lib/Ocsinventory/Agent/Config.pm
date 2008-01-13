package Ocsinventory::Agent::Config;

use strict;

sub get {
  my $file = shift;
  my $config;

  my @configfile = (
      '/etc/ocsinventory/ocsinventory-agent.cfg',
      '/usr/local/etc/ocsinventory/ocsinventory-agent.cfg',
      $ENV{HOME}.'/.ocsinventory/ocsinventory-agent.cfg'
  );
  if (!$file || !-f $file) {
    foreach (@configfile) {
        if (-f) {
            $file = $_;
            last;
        }
    }
    return {} unless -f $file;
  }

  $config->{configfile} = $file;

  open (CONFIG, "<".$file) or return {};

  foreach (<CONFIG>) {
    s/#.+//;
    if (/(\w+)\s*=\s*([\w\.:\/]+)/) {
      my $key = $1;
      my $val = $2;
      $val =~ s/^"(.*)"$/$1/; # Remove the quote (")
      $config->{$key} = $val;
    }
  }
  close CONFIG;
  return $config;
}

1;
