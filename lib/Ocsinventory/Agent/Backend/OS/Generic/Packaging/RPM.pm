package Ocsinventory::Agent::Backend::OS::Generic::Packaging::RPM;

use strict;
use warnings;

sub check {
  return unless can_run("rpm");

  # Some time rpm is a wrapper or an alias for another
  `rpm --version 2>&1`;
  return if ($? >> 8)!=0;
  1;
}

sub run {
  my $params = shift;
  my $inventory = $params->{inventory};

  my @list;
  my $buff;
  foreach (`rpm -qa --queryformat "%{NAME}.%{ARCH} %{VERSION}-%{RELEASE} --%{INSTALLTIME:date}-- --%{SIZE}-- %{SUMMARY}\n--\n" 2>/dev/null`) {
    if (! /^--/) {
      chomp;
      $buff .= $_;
    } elsif ($buff =~ s/^(\S+)\s+(\S+)\s+--(.*)--\s+--(.*)--\s+--(.*)--\s+(.*)//) {
    $inventory->addSoftware({
        'NAME'          => $1,
        'VERSION'       => $2,
        'INSTALLDATE'   => $3,
        'FILESIZE'      => $4,
        'COMMENTS'      => $5,
        'FROM'          => 'rpm'
		});
    } else {
      warn "Should never go here!";
      $buff = '';
    }
  }
}

1;
