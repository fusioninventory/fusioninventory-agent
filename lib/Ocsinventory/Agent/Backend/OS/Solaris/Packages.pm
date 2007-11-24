package Ocsinventory::Agent::Backend::OS::Solaris::Packages;

use strict;
use warnings;

sub check {
  my $params = shift;

  # Do not run an package inventory if there is the --nosoft parameter
  return if ($params->{params}->{nosoft});

  `which pkginfo 2>&1`;
  return if ($? >> 8)!=0;
  1;
}

sub run {
  my $params = shift;
  my $inventory = $params->{inventory};

  my $name;
  my $version;
  my $comments;
  foreach (`pkginfo -l`) {
    if (/^\s*$/) {
      $inventory->addSoftwares({
          'NAME'          => $name,
          'VERSION'       => $version,
          'COMMENTS'      => $comments,
          });

      $name = '';
      $version = '';
      $comments = '';

    } elsif (/PKGINST:\s+(.+)/) {
      $name = $1;
    } elsif (/VERSION:\s+(.+)/) {
      $version = $1;
    } elsif (/DESC:\s+(.+)/) {
      $comments = $1;
    }
  }
}

1;
