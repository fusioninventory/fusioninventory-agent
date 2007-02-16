package Ocsinventory::Agent::Backend;

use strict;
use warnings;

use ExtUtils::Installed;
#use Data::Dumper; # XXX Debug

sub new {
  my (undef,$params) = @_;

  my $self = {};

  $self->{accountinfo} = $params->{accountinfo};
  $self->{config} = $params->{config};
  $self->{inventory} = $params->{inventory};
  my $logger = $self->{logger} = $params->{logger};
  $self->{params} = $params->{params};

  $self->{modules} = {};

  bless $self;

}
sub initModList {
  my $self = shift;

  my $logger = $self->{logger};

  my ($inst) = ExtUtils::Installed->new();
  my @installed_mod;

  eval {@installed_mod =
    $inst->files('Ocsinventory')};

# ExtUtils::Installed is nice it needs properly installed package with
# .packlist
# This is a workaround for invalide installations...
  if (!@installed_mod) {
    require File::Find;
    # here I need to use $d to avoid a bug with AIX 5.2's perl 5.8.0. It
    # changes the @INC content if i use $_ directly
    foreach my $d (@INC) {
      next unless -d $d;
      File::Find::find( sub {
	  push @installed_mod, $File::Find::name if $File::Find::name =~ /^\/.*\/Ocsinventory\/Agent\/Backend\/.*\.pm$/;
	  }
	  , $d);
    }
  }


# Find installed modules
  foreach (@installed_mod) {
    my @runAfter;
    my $enable = 1;

    next unless s!.*?(Ocsinventory/Agent/Backend/)(.*?)\.pm$!$1$2!;
    my $m = join ('::', split /\//);

    eval {"require $m"};
    if ($@) {
      $logger->debug ("Failed to load $m: $@");
      $enable = 0;
    }

# Import of module's functions and values
    local *Ocsinventory::Agent::Backend::runAfter = $m."::runAfter"; 
    local *Ocsinventory::Agent::Backend::check = $m."::check";
    local *Ocsinventory::Agent::Backend::run = $m."::run";

    foreach (@{$Ocsinventory::Agent::Backend::runAfter}) {
      push @runAfter, \%{$self->{modules}->{$_}};
    }
# TODO, 
# no strict 'refs';
# print Dumper(\@{"Ocsinventory::Agent::Option::Download::EXPORT"});
# to see avalaible func

    $self->{modules}->{$m}->{name} = $m;
    $self->{modules}->{$m}->{done} = 0;
    $self->{modules}->{$m}->{inUse} = 0;
    $self->{modules}->{$m}->{enable} = 1;
    $self->{modules}->{$m}->{checkFunc} = \&check;
    $self->{modules}->{$m}->{runAfter} = \@runAfter;
    $self->{modules}->{$m}->{runFunc} = \&run;
  }

  foreach my $m (sort keys %{$self->{modules}}) {# the sort is useless
# find modules to disable and their submodules
    if($self->{modules}->{$m}->{enable} && !&{$self->{modules}->{$m}->{checkFunc}}) {
      $logger->debug ($m." check function failed");
      foreach (keys %{$self->{modules}}) {
	$self->{modules}->{$_}->{enable} = 0 if /^$m($|::)/;
      }
    }

# add submodule in the runAfter array
    my $t;
    foreach (split /::/,$m) {
      $t .= "::" if $t;
      $t .= $_;
      if (exists $self->{modules}->{$t} && $m ne $t) {
	push @{$self->{modules}->{$m}->{runAfter}}, \%{$self->{modules}->{$t}}
      }
    }
  }
}

sub runMod {
  my ($self, $params) = @_;

  my $logger = $self->{logger};

  my $m = $params->{modname};
  my $inventory = $params->{inventory};

  die ">$m\n" unless $m; # Should NEVER append :) 
    return if (!$self->{modules}->{$m}->{enable});
  return if ($self->{modules}->{$m}->{done});

  $self->{modules}->{$m}->{inUse} = 1; # lock the module
# first I run its "runAfter"

    foreach (@{$self->{modules}->{$m}->{runAfter}}) {
      if (!$_->{name}) {
# The name is defined during module initialisation so if I 
# can't read it, I can suppose it had not been initialised.
	$logger->fault ("Module `$m' need to be runAfter a module not found.".
	    "Please fix its runAfter entry or add the module.");
      }

      if ($_->{inUse}) {
# In use 'lock' is taken during the mod execution. If a module
# need a module also in use, we have provable an issue :).
	$logger->fault ("Circular dependency hell with $m and $_->{name}");
      }
      $self->runMod({
	  inventory => $inventory,
	  logger => $logger,
	  modname => $_->{name},
	  });
    }

  $logger->debug ("Running $m"); 

  &{$self->{modules}->{$m}->{runFunc}}({
      accountinfo => $self->{accountinfo},
      config => $self->{config},
      params => $self->{params},
      inventory => $inventory,
      });
  $self->{modules}->{$m}->{done} = 1;
  $self->{modules}->{$m}->{inUse} = 0; # unlock the module
}

sub feedInventory {
  my ($self, $params) = @_;

  my $inventory;
  if ($params->{inventory}) {
    $inventory = $params->{inventory};
  } else {
    $inventory = $self->{params}->{inventory};
  }

  if (!keys %{$self->{modules}}) {
    $self->initModList();
  }

  my $begin = time();
  foreach my $m (sort keys %{$self->{modules}}) {
    die ">$m" unless $m;# Houston!!!
      $self->runMod ({
	  inventory => $inventory,
	  modname => $m,
	  });
  }
  $inventory->processChecksum();

# Execution time
  $inventory->setHardware({ETIME => time() - $begin});
}


1;
