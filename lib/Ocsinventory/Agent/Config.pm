package Ocsinventory::Agent::Config;

sub get {
  my $file = shift;
  my $config;

  if (!$file || !-f $file) {
    $file = $ENV{HOME}.'/.ocsinventory/ocsinventory-agent.cfg';
    if (!-f $file) {
      $file = '/etc/ocsinventory/ocsinventory-agent.cfg';
      return {} if (! -f $file);
    }
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
