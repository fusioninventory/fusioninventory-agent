#!/usr/bin/perl

use strict;
use warnings;

use File::Basename;
use File::Path qw(make_path);
use Pod::Markdown;

my $parser = Pod::Markdown->new;

my @files = qw/
  fusioninventory-agent
  fusioninventory-injector
  /;

my @branches = qw/
  2.1.x
  2.2.x
  2.3.x
  /;

my %matrice = (
    '2.2.x:fusioninventory-agent' =>
      'documentation/agent/references/agent/2.2.x/fusioninventory-agent.mdwn',
    '2.3.x:fusioninventory-agent' =>
      'documentation/agent/references/agent/2.3.x/fusioninventory-agent.mdwn',
    'master:fusioninventory-agent' =>
      'documentation/agent/references/agent/3.0.x/fusioninventory-agent.mdwn',
    '2.2.x:fusioninventory-injector' =>
'documentation/agent/references/agent/2.2.x/fusioninventory-injector.mdwn',
    '2.3.x:fusioninventory-injector' =>
'documentation/agent/references/agent/2.3.x/fusioninventory-injector.mdwn',
    'master:fusioninventory-injector' =>
      'documentation/agent/references/agent/3.0.x/fusioninventory-injector.mdwn'
);

foreach my $file (@files) {
    foreach my $branch (@branches) {

        my $mkdwnFile =
          "../wiki/documentation/agent/references/agent/$branch/$file.mdwn";
        print $mkdwnFile. "\n";
        open( FH, "-|", "git show $branch:$file" )
          or die "Can't start git show: $!";

        $parser->parse_from_filehandle( \*FH );
        make_path( dirname($mkdwnFile) );
        open OUT, ">$mkdwnFile" or die "$!";
        print OUT $parser->as_markdown;
        close FH;

    }
}
