#!/usr/bin/perl

use strict;
use warnings;
#use diagnostics;
use English;
use Data::Dumper;

use Ocsinventory::XML::Inventory;
use ExtUtils::Installed;
my $h = {};
my %module;
my $debug = 1;
my $inventory;

sub initModList {
  my ($inst) = ExtUtils::Installed->new();
  my @installed_mod =
  $inst->files("Ocsinventory");

# Find installed modules
  foreach (@installed_mod) {
    my @modname;
    next unless s!.*?(Ocsinventory/Agent/Backend/)(.*?)\.pm$!$1$2!;
    my $m = join('::', split /\//);

    eval ("require $m"); # TODO deal with error

    # Import of module's functions and values
    local *main::runAfter = $m."::runAfter"; 
    local *main::check = $m."::check";
    local *main::run = $m."::run";

    my @runAfter;
    foreach (@{$main::runAfter}) {
      push @runAfter, \%{$module{$_}};
    }

    $module{$m}->{name} = $m;
    $module{$m}->{done} = 0;
    $module{$m}->{inUse} = 0;
    $module{$m}->{enable} = check()?1:0;
    $module{$m}->{runAfter} = \@runAfter;
    $module{$m}->{runFunc} = \&run;
  }

  foreach my $m (sort keys %module) {# TODO remove the sort
    print $m."\n";

# find modules to disable and their submodules
    if(!$module{$m}->{enable}) {
      print "$m 's check function failed\n";
      foreach (keys %module) {
	$module{$_}->{enable} = 0 if /^$m($|::)/;
      }
    }

# add submodule in the runAfter array
    my $t;
    foreach (split /::/,$m) {
      $t .= "::" if $t;
      $t .= $_;
      if (exists $module{$t} && $m ne $t) {
	push @{$module{$m}->{runAfter}}, \%{$module{$t}}
      }
    }
  }

  if ($debug) {
    foreach my $m (sort keys %module) {
      print Dumper($module{$m});
    }

  }
}


sub runMod {
  my $m = shift;
  print ">$m\n";
  return if (!$module{$m}->{enable});
  return if ($module{$m}->{done});

  $module{$m}->{inUse} = 1;
  # first I run its "runAfter"

  foreach (@{$module{$m}->{runAfter}}) {
    if ($_->{inUse}) {
      die "Circular dependency hell with $m and $_->{name}\n";
    }
    runMod($_->{name});
  }

  print "Running $m\n";
  &{$module{$m}->{runFunc}}($inventory);
  $module{$m}->{done} = 1;
  $module{$m}->{inUse} = 0;
}

initModList();

$inventory = new Ocsinventory::XML::Inventory;
foreach my $m (sort keys %module) {
  die unless $m;# XXX Debug stuff
  runMod ($m);
}

print Dumper($h);
$inventory->addControler({NAME => "toto", MANUFACTURER => "manuf", TYPE =>
    'type' });
$inventory->dump();
