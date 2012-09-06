#!/usr/bin/perl

use strict;
use warnings;


use Data::Dumper;
use LWP::Simple;


use DateTime;
use DateTime::Format::Mail;

use Encode;
use XML::TreePP;

sub getBug {
    my ($id) = @_;

    my $url = "http://forge.fusioninventory.org/issues/$id";
    my $content = encode("UTF-8",(LWP::Simple::get($url)));

    use XML::TreePP;
    my $tpp = XML::TreePP->new();

    my $title;
    if ($content =~ /<title>FusionInventory  Agent - \w+ #\d+: (.*) - FusionInventory<\/title>/) {
        $title = $1;
    }
    $title =~ s/^FusionInventory  Agent - \w+ #\d+: //;
    $title =~ s/ - FusionInventory$//;
    my $thanks = {};
    if ($content =~ /Added by <a href="\/users\/\d+">(.*?)</) {
        $thanks->{$1}=1;
    }
    my $categorie;
    if ($content =~ /tegory:<\/th><td class="category">(.*?)<\/td>/) {
        $categorie = $1;
    }
    my @t = split(/Updated by <a/, $content);
    foreach (@t) {
        next unless  /href="\/users\/\d+">(.*?)<\/a>/;
        $thanks->{$1}=1;
    }

    return {
        id => $id,
           title => $title,
           thanks => $thanks,
           categorie => $categorie,
           commit => []
    }
};


my $version = shift;


my $bugs;
my @commit;

my $current = { bugs => [], thanks => {} };
foreach (`git log $version..HEAD`) {
    if (/^commit/ && keys %$current > 2) {
        push @commit, $current;

        foreach my $bugId (@{$current->{bugs}}) {
            if (!$bugs->{$bugId}) {
                $bugs->{$bugId} = getBug($bugId);
            }
            foreach (keys %{$current->{thanks}}) {
                $bugs->{$bugId}{thanks}{$_}=1;
            }
            push @{$bugs->{$bugId}{commit}}, $current->{commit};
        }
        $current = { bugs => [], thanks => {} };
    }

    if (/^commit (\S{6})/) {
        $current->{commit} = $1;
    } elsif (/^Author: (.*)/) {
        $current->{author} = $1;
    } elsif (/closes: #(\d+)/) {
        push @{$current->{bugs}}, $1;
    } elsif (/thanks ([\w\s]*?)\s*$/) {
        $current->{thanks}{$1}=1;
    } elsif (/Reported.by: (.*?)(\ <.*|\s*)$/) {
        $current->{thanks}{$1}=1;
    }
}

my %categories;
foreach my $id(sort keys %$bugs) {
    my $info = $bugs->{$id};
    next unless keys %$info;

    if (!$categories{$info->{categorie}}) {
        $categories{$info->{categorie}} = [];
    }

    push @{$categories{$info->{categorie}}}, $bugs->{$id};
}

my $dt = DateTime->now;
print $version."  ".DateTime::Format::Mail->format_datetime( $dt )."\n";
foreach my $categorie(sort keys %categories) {
    print "\n".uc($categorie)."\n";
    foreach my $info (@{$categories{$categorie}}) {
        print " ✔ ".$info->{title}."\n";
        print "      ";
        foreach (@{$info->{commit}}) {
        print " commit:$_";
        }
        print "\n";
        print "     http://forge.fusioninventory.org/issues/".$info->{id}."\n";
        my @thanks;
        foreach (keys (%{$info->{thanks}})) {
            next if /le bouder/i;
            push @thanks, $_;
        };
        print "   thanks: ".join (', ', @thanks)."\n" if @thanks;
    }
}
