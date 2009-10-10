package Ocsinventory::Agent::Backend;

use strict;
no strict 'refs';
use warnings;

use ExtUtils::Installed;

sub new {
  my (undef, $params) = @_;

  my $self = {};

  $self->{accountconfig} = $params->{accountconfig};
  $self->{accountinfo} = $params->{accountinfo};
  $self->{config} = $params->{config};
  $self->{inventory} = $params->{inventory};
  my $logger = $self->{logger} = $params->{logger};
  $self->{network} = $params->{network};
  $self->{prologresp} = $params->{prologresp};

  $self->{modules} = {};

  $self->{backendSharedFuncs} = {

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


  bless $self;

}

sub initModList {
  my $self = shift;

  my $logger = $self->{logger};
  my $config = $self->{config};

  my @dirToScan;
  my @installed_mods;
  my @installed_files;

  # This is a workaround for PAR::Packer. Since it resets @INC
  # I can't find the backend modules to load dynamically. So
  # I prepare a list and include it.
  eval "use Ocsinventory::Agent::Backend::ModuleToLoad;";
  if (!$@) {
    $logger->debug("use Ocsinventory::Agent::Backend::ModuleToLoad to get the modules ".
      "to load. This should not append unless you use the standalone agent built with ".
      "PAR::Packer (pp)");
    push @installed_mods, @Ocsinventory::Agent::Backend::ModuleToLoad::list;
  }

  if ($config->{devlib}) {
  # devlib enable, I only search for backend module in ./lib
    push (@dirToScan, './lib');
  } else {
    my ($inst) = ExtUtils::Installed->new();

    eval {@installed_files =
      $inst->files('Ocsinventory')};

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
            push @installed_files, $File::Find::name if $File::Find::name =~ /Ocsinventory\/Agent\/Backend\/.*\.pm$/;
          },
          follow => 1,
          follow_skip => 2
        }
        , @dirToScan);
    }
  }

  foreach my $file (@installed_files) {
    my $t = $file;
    next unless $t =~ s!.*?(Ocsinventory/Agent/Backend/)(.*?)\.pm$!$1$2!;
    my $m = join ('::', split /\//, $t);
    push @installed_mods, $m;
  }

  if (!@installed_mods) {
    $logger->info("ZERO backend module found! Is Ocsinventory-Agent ".
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
    foreach my $func (keys %{$self->{backendSharedFuncs}}) {
      $package->{$func} = $self->{backendSharedFuncs}->{$func};
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
    $self->{modules}->{$m}->{storage} = $self->retrieveStorage($m);

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
  $self->saveStorage($m, $self->{modules}->{$m}->{storage});
}

sub feedInventory {
  my ($self, $params) = @_;

  my $logger = $self->{logger};

  if (!$params->{inventory}) {
      $logger->fault('Missing inventory parameter.');
  }

  my $inventory = $self->{inventory} = $params->{inventory};

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


=item retrieveStorage()

Load the $ModuleName.storage file from the filesystem. These .storage files
are used to offert persistance storage to modules.

=cut
sub retrieveStorage {
    my ($self, $m) = @_;

    my $logger = $self->{logger};

    my $storagefile = $self->{config}->{vardir}."/$m.storage";

    if (!exists &retrieve) {
        eval "use Storable;";
        if ($@) {
            $logger->debug("Storable.pm is not avalaible, can't load Backend module data");
            return;
        }
    }

    return (-f $storagefile)?retrieve($storagefile):{};

}

=item saveStorage()

Save the $storage hash reference on the harddrive. 

=cut
sub saveStorage {
    my ($self, $m, $data) = @_;

    my $logger = $self->{logger};

# Perl 5.6 doesn't provide Storable.pm
    if (!exists &store) {
        eval "use Storable;";
        if ($@) {
            $logger->debug("Storable.pm is not avalaible, can't save Backend module data");
            return;
        }
    }

    my $storagefile = $self->{config}->{vardir}."/$m.storage";
    if ($data && keys (%$data)>0) {
	store ($data, $storagefile) or die;
    } elsif (-f $storagefile) {
	unlink $storagefile;
    }

}

=item runWithTimeout()

Run a function with a timeout.

=cut
sub runWithTimeout {
    my ($self, $m, $funcName) = @_;

    my $logger = $self->{logger};

    my $ret;

    my $storage = $self->retrieveStorage($m);
    eval {
        local $SIG{ALRM} = sub { die "alarm\n" }; # NB: \n require
        my $timeout = $self->{accountinfo}{config}{backendCollectTimeout};
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
    $self->saveStorage($m, $storage);

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

sub doPostInventorys {
  my ($self) = @_;

  my $logger = $self->{logger};
  my $config = $self->{config};
  my $network = $self->{network};

  foreach my $m (sort keys %{$self->{modules}}) {

      if ($self->{modules}{$m}{doPostInventoryFunc}) {
          $self->runWithTimeout($m, "doPostInventory");
    }
  }
}



sub runRpc {
    my ($self) = @_;

    my $logger = $self->{logger};
    my $config = $self->{config};

    $logger->fault("--allow-rpc missing!") unless $config->{allowRpc};

    eval "use HTTP::Server::Brick;";
    if ($@) {
        $logger->info("HTTP::Server::Brick is not installed, rpc mode disabled");
        return;
    }

    my $server = HTTP::Server::Brick->new( port => 8888 );

    $logger->info("Starting the RPC server");
    foreach my $m (sort keys %{$self->{modules}}) {

        next unless $self->{modules}->{$m}->{rpcCfg};
        $logger->error("rpcCfg $m");
        my $rpcCfg = $self->{modules}->{$m}->{rpcCfg};
        next unless $rpcCfg;

        use Data::Dumper;
        my $cfg = &$rpcCfg;

        return unless $cfg;

        print Dumper($cfg);

        my $server = HTTP::Server::Brick->new( port => 8888 );

        foreach (keys %$cfg) {
            my $mountPoint = '/'.$m.'/'.$_;

            print "$mountPoint\n";
            if (exists ($cfg->{$mountPoint}->{path})) {
                my $path = '/'.$m.$cfg->{$mountPoint}->{path};

                $server->mount($mountPoint => {
                        path => $path
                    });
            } elsif (exists ($cfg->{$mountPoint}->{myHandler})) {
                print "castor";
            }


        }

        $server->start;


    }
}

1;
