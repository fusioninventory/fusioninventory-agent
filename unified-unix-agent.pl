#!/usr/bin/perl
# TODO Create ETIME (execution time) correcly
use strict;
use warnings;
#use diagnostics;
use English;
use Data::Dumper; #XXX DEBUG

use Getopt::Long;
use ExtUtils::Installed;

use Ocsinventory::XML::Inventory;
use Ocsinventory::Agent::Network;
my $h = {};
my %module;
my $inventory;
# default settings;
my %params = (
  'debug'     =>  1,
  'force'     =>  0,
  'help'      =>  0,
  'info'      =>  1,
  'local'     =>  '',
  'password'  =>  '',
  'realm'     =>  '',
  'tag'       =>  'DEBUG',
  'server'    =>  'ocsinventory-ng',
  'user'      =>  '',
#  'xml'       =>  0,
);


my %options = (
  "d|debug"         =>   \$params{debug},
  "f|force"         =>   \$params{force},
  "h|help"          =>   \$params{help},
  "i|info"          =>   \$params{info},
  "l|local=s"         =>   \$params{local},
  "p|password=s"    =>   \$params{password},
  "r|realm=s"       =>   \$params{realm},
  "t|tag=s"         =>   \$params{tag},
  "s|server=s"      =>   \$params{server},
  "u|user"          =>   \$params{user},
#  "x|xml"           =>   \$params{xml},
#"nosoft"
);

##########################################
##########################################
##########################################
##########################################
#### Func to move somewhere else :)
sub initModList {
  my ($inst) = ExtUtils::Installed->new();
  my @installed_mod =
  $inst->files("Ocsinventory");

# Find installed modules
  foreach (@installed_mod) {
    my @runAfter;
    my $enable;

    next unless s!.*?(Ocsinventory/Agent/Backend/)(.*?)\.pm$!$1$2!;
    my $m = join('::', split /\//);

    eval ("require $m"); # TODO deal with error

    # Import of module's functions and values
    local *main::runAfter = $m."::runAfter"; 
    local *main::check = $m."::check";
    local *main::run = $m."::run";

    foreach (@{$main::runAfter}) {
      push @runAfter, \%{$module{$_}};
    }

    if (!${*main::check}) {
      # no check function. Enabled by default
      $enable = 1;
    } else {
      $enable = check()?1:0;
    }

    $module{$m}->{name} = $m;
    $module{$m}->{done} = 0;
    $module{$m}->{inUse} = 0;
    $module{$m}->{enable} = $enable;
    $module{$m}->{runAfter} = \@runAfter;
    $module{$m}->{runFunc} = \&run;
  }

  foreach my $m (sort keys %module) {# TODO remove the sort
    print "o>".$m."\n" unless $m;

# find modules to disable and their submodules
    if(!$module{$m}->{enable}) {
      print "$m 's check function failed\n";
      foreach (keys %module) {
	print "A>$_\n";
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

  if ($params{debug}) {
    foreach my $m (sort keys %module) {
      print Dumper($module{$m});
    }

  }
}

sub runMod {
  my $m = shift;
  die ">$m\n" unless $m; # XXX DEBUG
  return if (!$module{$m}->{enable});
  return if ($module{$m}->{done});

  $module{$m}->{inUse} = 1;
  # first I run its "runAfter"

  foreach (@{$module{$m}->{runAfter}}) {
    if (!$_->{name}) {
      # The name is defined during module initialisation so if I 
      # can't read it, I can suppose it had not been initialised.
      die "Module $m need to be runAfter a module not found.".
      "Please fix its runAfter entry or add the module.\n";
    }
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

sub createInventory {
  initModList();
  $inventory = new
  Ocsinventory::XML::Inventory({
      last_state => "/etc/ocsinventory-client/last_state"
    });

  foreach my $m (sort keys %module) {
    die ">$m" unless $m;# XXX Debug
    runMod ($m);
  }
  $inventory->processChecksum();
  # TODO: generate ETIME

  return $inventory;
}

sub help {
  print STDERR "Usage:\n";
  print STDERR "\t-d --debug          debug mode ($params{debug})\n";
  print STDERR "\t-f --force          always send data to server (Don't ask before) ($params{force})\n";
  print STDERR "\t-i --info           verbose mode ($params{info})\n";
  print STDERR "\t-l --local=DIR      do not contact server but write
  inventory in DIR directory in XML ($params{local})\n";
  print STDERR "\t-p --password=PWD   password for server auth\n";
  print STDERR "\t-r --realm=REALM    realm for server auth\n";
  print STDERR "\t-s --server=SERVER  use the specific server SERVER ($params{server})\n";
  print STDERR "\t-t --tag=TAG        use TAG as tag ($params{tag})\n";
  print STDERR "\t-u --user=USER      user for server auth\n";
#  print STDERR "\t-x --xml            write output in a xml file ($params{xml})\n";
#  print STDERR "\t--nosoft           do not return installed software list\n";

  exit 1;
}


#####################################
################ MAIN ###############
#####################################

GetOptions(%options);
&help if $params{help}; 

print "<PARAMS>".Dumper(\%params);



my $inventory;

if ($params{local}) {
  $inventory = createInventory();
  # TODO write XML inventory 
} else { #
  my $cnx = new Ocsinventory::Agent::Network(%params);
  if ($cnx->needInventory()) {
    $inventory = createInventory();
    $cnx->sendInventory($inventory);    
  }
}


$inventory->dump();
