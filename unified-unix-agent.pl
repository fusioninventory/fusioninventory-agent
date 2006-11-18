#!/usr/bin/perl

use strict;
use warnings;
#use diagnostics;
use English;
use Data::Dumper;
use Hash::Merge; # TODO: create a built in function
# to deal correctly with overwrite (at last debug message)

use ExtUtils::Installed;
my $h = {};
my %module;


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
    print "$m\n";
    
    # Import of module's functions and values
    local *main::runAfter = $m."::runAfter"; 
    local *main::check = $m."::check";
    local *main::run = $m."::run";

    my @runAfter;
    foreach (@{$main::runAfter}) {
      push @runAfter, \%{$module{$_}};
    }

    $module{$m} = {
      name => $m,
      done => 0,
      inUse => 0,
      enable => check(),
      runAfter => \@runAfter,
      runFunc => \&run
    };

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
      print ">>".$t."\n";
      if (exists $module{$t} && $m ne $t) {
	push @{$module{$m}->{runAfter}}, \%{$module{$t}}
      }
    }
  }
}


sub runMod {
  my $m = shift;
  
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
  &{$module{$m}->{runFunc}}($h);
  $module{$m}->{done} = 1;
  $module{$m}->{inUse} = 0;
}

initModList();

foreach my $m (sort keys %module) {
  runMod ($m);
}

print Dumper($h);
