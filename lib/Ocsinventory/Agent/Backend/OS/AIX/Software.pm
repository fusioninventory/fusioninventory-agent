package Ocsinventory::Agent::Backend::OS::AIX::Software;

use strict;
use warnings;

sub check {
  `lslpp -l 2>&1`;
  return if ($? >> 8)!=0;
  1;
}

sub run {
  my $params = shift;
  my $inventory = $params->{inventory};

  my @list;
  my $buff;
  foreach (`lslpp -c -l`) {
    my @entry = split /:/,$_;
    next unless (@entry);
    next unless ($entry[1]);
    next if $entry[1] =~ /^device/;

    $inventory->addSoftwares({
	'NAME'          => $entry[1],
	'VERSION'       => $entry[2],
	'COMMENTS'      => $entry[6],
	});
  }
}

1;
