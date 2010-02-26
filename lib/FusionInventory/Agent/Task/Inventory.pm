package FusionInventory::Agent::Task::Inventory;

use strict;
no strict 'refs';
use warnings;

use threads;

use ExtUtils::Installed;

use Data::Dumper;

use FusionInventory::Logger;
use FusionInventory::Agent::Config;
use FusionInventory::Agent::XML::Query::Inventory;
use FusionInventory::Agent::Network;

use FusionInventory::Agent::AccountInfo;

use FusionInventory::Agent::XML::Response::Prolog;

use FusionInventory::Agent::Storage;

sub main {
  my (undef, $params) = @_;

  my $self = {};
  bless $self;

  my $storage = new FusionInventory::Agent::Storage({
      target => {
          vardir => $ARGV[0],
      }
  });
  my $data = $storage->restore("FusionInventory::Agent");
  $self->{storage} = $storage;

  my $config = $self->{config} = $data->{config};
  my $prologresp = $self->{prologresp} = $data->{prologresp};
  my $target = $self->{target} = $data->{target};
  
  
  my $logger = $self->{logger} = new FusionInventory::Logger ({
          config => $self->{config}
      });

  if ($target->{type} eq 'server' &&
      (!exists($prologresp->{parsedcontent}->{RESPONSE})
          ||
          $prologresp->{parsedcontent}->{RESPONSE} !~ /^SEND$/)) {
    $logger->debug('<RESPONSE>SEND</RESPONSE> no found in PROLOG, do not '.
        'send an inventory.');
    exit(0);
  }


  $self->{modules} = {};

  if (!$target) {
    $logger->fault("target is undef");
  }

  $self->{inventory} = new FusionInventory::Agent::XML::Query::Inventory ({

          # TODO, check if the accoun{info,config} are needed in localmode
#          accountinfo => $accountinfo,
#          accountconfig => $accountinfo,
          target => $self->{target},
          config => $self->{config},
          logger => $logger,

      });
  my $inventory = $self->{inventory};

  if (!$config->{'stdout'} && !$config->{'local'}) {
      $logger->fault("No prologresp!") unless $prologresp;
    
      if ($config->{'force'}) {
        $logger->debug("Force enable, ignore prolog and run inventory.");
      } elsif (!$prologresp->isInventoryAsked()) {
        $logger->debug("No inventory requested in the prolog...");
        exit(0);
      }
  }

  $self->feedInventory();


  if ($target->{type} eq 'stdout') {
      $self->{inventory}->printXML();
  } elsif ($target->{'type'} eq 'local') {
      $self->{inventory}->writeXML();
  } elsif ($target->{'type'} eq 'server') {

      my $accountinfo = $target->{accountinfo};

      # Put ACCOUNTINFO values in the inventory
      $accountinfo->setAccountInfo($self->{inventory});

      my $network = new FusionInventory::Agent::Network ({

              logger => $logger,
              config => $config,
              target => $target,

          });

      my $response = $network->send({message => $inventory});

      return unless $response;
      $inventory->saveLastState();

      my $parsedContent = $response->getParsedContent();
      if ($parsedContent
          &&
          exists ($parsedContent->{RESPONSE})
          &&
          $parsedContent->{RESPONSE} =~ /^ACCOUNT_UPDATE$/
      ) {
          $accountinfo->reSetAll($parsedContent->{ACCOUNTINFO});
      }

  }

  exit(0);

}

sub initModList {
  my $self = shift;

  my $logger = $self->{logger};
  my $config = $self->{config};
  my $storage = $self->{storage};

  my @dirToScan;
  my @installed_mods;
  my @installed_files;


  # Hackish. The function we want to export
  # in the module
  my $backendSharedFuncs = {

    # TODO replace that by the standard can_run()
    can_run => sub {
      my $binary = shift;

      my $calling_namespace = caller(0);
      chomp(my $binpath=`which $binary 2>/dev/null`);
      return unless -x $binpath;
      $self->{logger}->debug(" - $binary found");
      1
    },
    can_load => sub {
      my $module = shift;

      my $calling_namespace = caller(0);
      eval "package $calling_namespace; use $module;";
#      print STDERR "$module not loaded in $calling_namespace! $!: $@\n" if $@;
      return if $@;
      $self->{logger}->debug(" - $module loaded");
#      print STDERR "$module loaded in $calling_namespace!\n";
      1;
    },
    can_read => sub {
      my $file = shift;
      return unless -r $file;
      $self->{logger}->debug(" - $file can be read");
      1;
    },
    runcmd => sub {
      my $cmd = shift;
      return unless $cmd;

      # $self->{logger}->debug(" - run $cmd");

      return `$cmd`;
    }
  };





  # This is a workaround for PAR::Packer. Since it resets @INC
  # I can't find the backend modules to load dynamically. So
  # I prepare a list and include it.
  eval "use FusionInventory::Agent::Task::Inventory::ModuleToLoad;";
  if (!$@) {
    $logger->debug("use FusionInventory::Agent::Task::Inventory::ModuleToLoad to get the modules ".
      "to load. This should not append unless you use the standalone agent built with ".
      "PAR::Packer (pp)");
    push @installed_mods, @FusionInventory::Agent::Task::Inventory::ModuleToLoad::list;
  }

  if ($config->{devlib}) {
  # devlib enable, I only search for backend module in ./lib
    push (@dirToScan, './lib');
  } else {
    my ($inst) = ExtUtils::Installed->new();

    eval {@installed_files =
      $inst->files('FusionInventory')};

# ExtUtils::Installed is nice but it needs properly installed package with
# .packlist
# This is a workaround for 'invalide' installations...
    foreach (@INC) {
      next if ! -d || (-l && -d readlink) || /^(\.|lib)$/;
      push @dirToScan, $_;
    }
  }
  if (@dirToScan) {
    eval {require File::Find};
    if ($@) {
      $logger->debug("Failed to load File::Find");
    } else {
# here I need to use $d to avoid a bug with AIX 5.2's perl 5.8.0. It
# changes the @INC content if i use $_ directly
# thanks to @rgs on irc.perl.org
      File::Find::find(
        {
          wanted => sub {
            push @installed_files, $File::Find::name if $File::Find::name =~
            /FusionInventory\/Agent\/Task\/Inventory\/.*\.pm$/;
          },
          follow => 1,
          follow_skip => 2
        }
        , @dirToScan);
    }
  }

  foreach my $file (@installed_files) {
    my $t = $file;
    next unless $t =~ s!.*?(FusionInventory/Agent/Task/Inventory/)(.*?)\.pm$!$1$2!;
    my $m = join ('::', split /\//, $t);
    push @installed_mods, $m;
  }

  if (!@installed_mods) {
    $logger->info("ZERO backend module found! Is FusionInventory-Agent ".
    "correctly installed? Use the --devlib flag if you want to run the agent ".
    "directly from the source directory.")
  }

  foreach my $m (@installed_mods) {
    my @runAfter;
    my @runMeIfTheseChecksFailed;
    my $enable = 1;

    if (exists ($self->{modules}->{$m}->{name})) {
      $logger->debug($m." already loaded.");
      next;
    }

    eval "use $m;";
    if ($@) {
      $logger->debug ("Failed to load $m: $@");
      $enable = 0;
    }

    my $package = $m."::";
    # Load in the module the backendSharedFuncs
    foreach my $func (keys %{$backendSharedFuncs}) {
      $package->{$func} = $backendSharedFuncs->{$func};
    }

    if ($package->{'check'}) {
        $logger->error("$m: check() function is deprecated, please rename it to ".
            "isInventoryEnabled()");
    }
    if ($package->{'run'}) {
        $logger->error("$m: run() function is deprecated, please rename it to ".
            "doInventory()");
    }
    if ($package->{'longRun'}) {
        $logger->error("$m: longRun() function is deprecated, please rename it to ".
            "postInventory()");
    }

    $self->{modules}->{$m}->{name} = $m;
    $self->{modules}->{$m}->{done} = 0;
    $self->{modules}->{$m}->{inUse} = 0;
    $self->{modules}->{$m}->{inventoryFuncEnable} = $enable;

    # TODO add a isPostInventoryEnabled() function to know if we need to run
    # the postInventory() function.
    # Is that really needed?
    $self->{modules}->{$m}->{postInventoryFuncEnable} = 1;#$enable;

    $self->{modules}->{$m}->{isInventoryEnabledFunc} = $package->{'isInventoryEnabled'};
    $self->{modules}->{$m}->{runAfter} = $package->{'runAfter'};
    $self->{modules}->{$m}->{runMeIfTheseChecksFailed} = $package->{'runMeIfTheseChecksFailed'};
    $self->{modules}->{$m}->{doInventoryFunc} = $package->{'doInventory'};
    $self->{modules}->{$m}->{doPostInventoryFunc} = $package->{'doPostInventory'};
    $self->{modules}->{$m}->{mem} = {}; # Deprecated
    $self->{modules}->{$m}->{rpcCfg} = $package->{'rpcCfg'};
# Load the Storable object is existing or return undef
    $self->{modules}->{$m}->{storage} = $storage;

    if (exists($package->{'new'})) {
        $self->{modules}->{$m}->{instance} = $m->new({

            accountconfig => $self->{accountconfig},
            accountinfo => $self->{accountinfo},
            config => $self->{config},
            inventory => $self->{inventory},
            logger => $self->{logger},
            network => $self->{network},
            prologresp => $self->{prologresp},
#            mem => $self->{modules}->{$m}->{mem},# Deprecated
#            storage => $self->{modules}->{$m}->{storage},           
            
            }); 
    }

  }

# the sort is just for the presentation
  foreach my $m (sort keys %{$self->{modules}}) {
      next unless $self->{modules}->{$m}->{isInventoryEnabledFunc};
# find modules to disable and their submodules

      next unless $self->{modules}->{$m}->{inventoryFuncEnable};

      my $enable = $self->runWithTimeout($m, "isInventoryEnabled");


    if (!$enable) {
      $logger->debug ($m." ignored");
      foreach (keys %{$self->{modules}}) {
          $self->{modules}->{$_}->{inventoryFuncEnable} = 0 if /^$m($|::)/;
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
    next unless	$self->{modules}->{$m}->{inventoryFuncEnable};
    next unless	$self->{modules}->{$m}->{runMeIfTheseChecksFailed};
    foreach my $condmod (@{${$self->{modules}->{$m}->{runMeIfTheseChecksFailed}}}) {
       if ($self->{modules}->{$condmod}->{inventoryFuncEnable}) {
         foreach (keys %{$self->{modules}}) {
           next unless /^$m($|::)/ && $self->{modules}->{$_}->{inventoryFuncEnable};
           $self->{modules}->{$_}->{inventoryFuncEnable} = 0;
           $logger->debug ("$_ disabled because of a 'runMeIfTheseChecksFailed' in '$m'\n");
         }
      }
    }
  }
}

sub runMod {
  my ($self, $params) = @_;

  my $logger = $self->{logger};

  my $m = $params->{modname};

  return if (!$self->{modules}->{$m}->{inventoryFuncEnable});
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
        modname => $_->{name},
      });
  }

  $logger->debug ("Running $m");

  if ($self->{modules}->{$m}->{doInventoryFunc}) {
      $self->runWithTimeout($m, "doInventory");
  } else {
      $logger->debug("$m has no doInventory() function -> ignored");
  }
  $self->{modules}->{$m}->{done} = 1;
  $self->{modules}->{$m}->{inUse} = 0; # unlock the module
}

sub feedInventory {
  my ($self, $params) = @_;

  my $logger = $self->{logger};

  if (!$self->{inventory}) {
      $logger->fault('Missing inventory parameter.');
  }

  my $inventory = $self->{inventory};

  if (!keys %{$self->{modules}}) {
    $self->initModList();
  }

  my $begin = time();
  foreach my $m (sort keys %{$self->{modules}}) {
    $logger->fault(">$m Houston!!!") unless $m;
      $self->runMod ({
	  modname => $m,
	  });
  }

# Execution time
  $inventory->setHardware({ETIME => time() - $begin});

  $inventory->{isInitialised} = 1;

}

=item runWithTimeout()

Run a function with a timeout.

=cut
sub runWithTimeout {
    my ($self, $m, $funcName, $timeout) = @_;

    my $logger = $self->{logger};
    my $storage = $self->{storage};

    my $ret;
    
    if (!$timeout) {
        $timeout = $self->{config}{backendCollectTimeout};
    }

    eval {
        local $SIG{ALRM} = sub { die "alarm\n" }; # NB: \n require
        alarm $timeout;



        my $instance = $self->{modules}->{$m}->{instance};
        if ($instance) {

            $instance->{storage} = $storage;
            $instance->$funcName();

        } else {

            my $func = $self->{modules}->{$m}->{$funcName."Func"};

            $ret = &{$func}({
                    accountconfig => $self->{accountconfig},
                    accountinfo => $self->{accountinfo},
                    config => $self->{config},
                    inventory => $self->{inventory},
                    logger => $self->{logger},
                    network => $self->{network},
                    # Compatibiliy with agent 0.0.10 <=
                    # We continue to pass params->{params}
                    params => $self->{params},
                    prologresp => $self->{prologresp},
                    storage => $storage
                });
        }
    };
    alarm 0;
    my $evalRet = $@;

    if ($evalRet) {
        if ($@ ne "alarm\n") {
            $logger->debug("runWithTimeout(): unexpected error: $@");
        } else {
            $logger->debug("$m killed by a timeout.");
            return;
        }
    } else {
        return $ret;
    }
}


1;
