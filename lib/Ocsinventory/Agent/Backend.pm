package Ocsinventory::Agent::Backend;

use strict;
use warnings;

use Storable;
use ExtUtils::Installed;

sub new {
  my (undef,$params) = @_;

  my $self = {};

  $self->{accountconfig} = $params->{accountconfig};
  $self->{accountinfo} = $params->{accountinfo};
  $self->{inventory} = $params->{inventory};
  my $logger = $self->{logger} = $params->{logger};
  $self->{params} = $params->{params};
  $self->{prologresp} = $params->{prologresp};

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
  eval {require File::Find};
  if ($@) {
    $logger->debug("Failed to load File::Find");
  } else {
# here I need to use $d to avoid a bug with AIX 5.2's perl 5.8.0. It
# changes the @INC content if i use $_ directly
# thanks to @rgs on irc.perl.org
    foreach my $d (@INC) {
      next unless -d $d;
      File::Find::find( sub {
	  push @installed_mod, $File::Find::name if $File::Find::name =~ /Ocsinventory\/Agent\/Backend\/.*\.pm$/;
	  }
	  , $d);
    }
  }

# Find installed modules
  foreach my $file (@installed_mod) {
    my @runAfter;
    my @runMeIfTheseChecksFailed;
#    my @replace;
    my $enable = 1;

    my $t = $file;
    next unless $t =~ s!.*?(Ocsinventory/Agent/Backend/)(.*?)\.pm$!$1$2!;
    my $m = join ('::', split /\//, $t);

    if (exists ($self->{modules}->{$m}->{name})) {
      $logger->debug($m." already loaded.");
      next;
    }
    
    eval {require $file}; # I do require directly on the file to avoid issues
    # with AIX perl 5.8.0
    if ($@) {
      $logger->debug ("Failed to load $m: $@");
      $enable = 0;
    }

# Import of module's functions and values
    local *Ocsinventory::Agent::Backend::runAfter = $m."::runAfter"; 
    local *Ocsinventory::Agent::Backend::runMeIfTheseChecksFailed = $m."::runMeIfTheseChecksFailed"; 
#    local *Ocsinventory::Agent::Backend::replace = $m."::replace"; 
    local *Ocsinventory::Agent::Backend::check = $m."::check";
    local *Ocsinventory::Agent::Backend::run = $m."::run";

    foreach (@{$Ocsinventory::Agent::Backend::runAfter}) {
      push @runAfter, \%{$self->{modules}->{$_}};
    }
    foreach (@{$Ocsinventory::Agent::Backend::runMeIfTheseChecksFailed}) {
      push @runMeIfTheseChecksFailed, \%{$self->{modules}->{$_}};
    }

# TODO, 
# no strict 'refs';
# print Dumper(\@{"Ocsinventory::Agent::Option::Download::EXPORT"});
# to see avalaible func


    $self->{modules}->{$m}->{name} = $m;
    $self->{modules}->{$m}->{done} = 0;
    $self->{modules}->{$m}->{inUse} = 0;
    $self->{modules}->{$m}->{enable} = $enable;
    $self->{modules}->{$m}->{checkFunc} = \&check;
    $self->{modules}->{$m}->{runAfter} = \@runAfter;
    $self->{modules}->{$m}->{runMeIfTheseChecksFailed} = \@runMeIfTheseChecksFailed;
#    $self->{modules}->{$m}->{replace} = \@replace;
    $self->{modules}->{$m}->{runFunc} = \&run;
    $self->{modules}->{$m}->{mem} = {};
# Load the Storable object is existing or return undef
    $self->{modules}->{$m}->{storage} = $self->retrieveStorage($m);

  }

# the sort is just for the presentation 
  foreach my $m (sort keys %{$self->{modules}}) {
# find modules to disable and their submodules
    if($self->{modules}->{$m}->{enable} &&
    !&{$self->{modules}->{$m}->{checkFunc}}({
            accountconfig => $self->{accountconfig},
            accountinfo => $self->{accountinfo},
            inventory => $self->{inventory},
            logger => $self->{logger},
            params => $self->{params},
	    prologresp => $self->{prologresp},
	    mem => $self->{modules}->{$m}->{mem},
	    storage => $self->{modules}->{$m}->{storage},
	})) {
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


  # Remove the runMeIfTheseChecksFailed if needed
  foreach my $m (sort keys %{$self->{modules}}) {
    next unless	$self->{modules}->{$m}->{enable};
    foreach (@{$self->{modules}->{$m}->{runMeIfTheseChecksFailed}}) {
      $self->{modules}->{$m}->{enable} = 0 if $_->{enable};
    }
  }
}

sub runMod {
  my ($self, $params) = @_;

  my $logger = $self->{logger};

  my $m = $params->{modname};
  my $inventory = $params->{inventory};

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
        modname => $_->{name},
      });
  }

  $logger->debug ("Running $m"); 

  eval {
  &{$self->{modules}->{$m}->{runFunc}}({
      accountconfig => $self->{accountconfig},
      accountinfo => $self->{accountinfo},
      inventory => $inventory,
      logger => $logger,
      params => $self->{params},
      prologresp => $self->{prologresp},
      mem => $self->{modules}->{$m}->{mem},
      storage => $self->{modules}->{$m}->{storage},
      });
  };
  $self->{modules}->{$m}->{done} = 1;
  $self->{modules}->{$m}->{inUse} = 0; # unlock the module
  $self->saveStorage($m, $self->{modules}->{$m}->{storage});
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

# Execution time
  $inventory->setHardware({ETIME => time() - $begin});
}

sub retrieveStorage {
    my ($self, $m) = @_;

    my $storagefile = $self->{params}->{vardir}."/$m.storage";

    return (-f $storagefile)?retrieve($storagefile):{};

}

sub saveStorage {
    my ($self, $m, $data) = @_;

    my $storagefile = $self->{params}->{vardir}."/$m.storage";
    if ($data && keys (%$data)>1) {
	store ($data, $storagefile) or die;
    } elsif (-f $storagefile) {
	unlink $storagefile;
    }

}

1;
