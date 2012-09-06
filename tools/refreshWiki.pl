#!/usr/bin/perl

use strict;
use warnings;

use File::Basename;
use File::Path qw(make_path);
use Pod::Markdown;

my $wikiDir = "../wiki/";
my @files = qw/
  fusioninventory-agent
  fusioninventory-injector
  /;

my @branches = qw/
  2.1.x
  2.2.x
  2.3.x
  /;

my $indexContent =
"# Reference documentation

";

foreach my $file (@files) {
    $indexContent .= "\n##$file\n\n";
    foreach my $branch (@branches) {

        my $mdwnFile =
          "documentation/references/agent/$branch/$file";
        print $mdwnFile. "\n";
        my $mdwnFilePath =
          $wikiDir . $mdwnFile . '.mdwn';

        open(my $in, '-|', "git show $branch:$file" )
          or die "Can't start git show: $!";

        my $parser = Pod::Markdown->new;
        $parser->parse_from_filehandle($in);
        make_path( dirname($mdwnFilePath) );

        open (my $out, '>', $mdwnFilePath) or die "$!";
        print $out $parser->as_markdown;
        close $out;

        close $in;
        $indexContent .= "* [[$branch|$mdwnFile]]\n";
    }
}

open (my $index, '>', $wikiDir . "documentation/references/agent.mdwn") or die;
print $index $indexContent;
close $index;
