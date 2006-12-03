#!/usr/bin/perl

use strict;
use warnings;
#use diagnostics;
use English;
use Data::Dumper;

use Getopt::Long;
use Ocsinventory::XML::Inventory;
use ExtUtils::Installed;
my $h = {};
my %module;
my $inventory;
# default settings;
my %params = (
'debug'   => 0,
'force' => 0,
'help'  => 0,
'info'  => 1,
'local' => 1,
'tag'   => 'DEBUG',
'server' => 'localhost',
'xml'   => 1,
);


my %options = (
  "d|debug"    =>   \$params{debug},
  "f|force"    =>   \$params{force},
  "h|help"     =>   \$params{help},
  "i|info"     =>   \$params{info},
  "l|local"    =>   \$params{local},
  "t|tag=s"    =>   \$params{tag},
  "s|server=s" =>   \$params{server},
  "x|xml"      =>   \$params{xml},
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

  if ($params{debug}) {
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

sub createInventenory {
  initModList();
  $inventory = new
  Ocsinventory::XML::Inventory({
      last_state => "/etc/ocsinventory-client/last_state"
    });

  foreach my $m (sort keys %module) {
    die unless $m;# XXX Debug
    runMod ($m);
  }
  $inventory->processChecksum();
}

sub help {
  print STDERR "Usage:\n";
  print STDERR "\t-d --debug          debug mode ($params{debug})\n";
  print STDERR "\t-f --force          always send data to server (Don't ask before) ($params{force})\n";
  print STDERR "\t-i --info           verbose mode ($params{info})\n";
  print STDERR "\t-l --local          do not send data to server ($params{local})\n";
  print STDERR "\t-s --server=SERVER  use the specific server SERVER ($params{server})\n";
  print STDERR "\t-t --tag=TAG        use TAG as tag ($params{tag})\n";
  print STDERR "\t-x --xml            write output in a xml file ($params{xml})\n";
#  print STDERR "\t--nosoft           do not return installed software list\n";

  exit 1;
}

#####################################
################ MAIN ###############
#####################################

GetOptions(%options);
&help if $params{help}; 

# Proceed...
if(($params{server} =~ /^localhost$/i) or $params{xml}){
  &_inventory();
}else{
  # Connect to server
  $ua = LWP::UserAgent->new(keep_alive => 1);
  $ua->agent('OCS-NG_linux_client_v'.VERSION);

  # Call modules start sub
  #&_call_start_handlers(); XXX

  # Prolog phase
  if(&_prolog()){
    # Send inventory if needed
    &_inventory();
  }

  # Call modules end sub
  #&_call_end_handlers; XXX
}



createInventenory();
$inventory->dump();
