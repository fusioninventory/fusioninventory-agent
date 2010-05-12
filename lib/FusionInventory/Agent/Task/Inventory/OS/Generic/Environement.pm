package FusionInventory::Agent::Task::Inventory::OS::Generic::Environement;

sub isInventoryEnabled {1}

sub doInventory {
  my $params = shift;
  my $inventory = $params->{inventory};

  foreach my $key (keys %ENV) {
    $inventory->addEnv({
        KEY => $key,
        VAL => $ENV{$key}
        });
  }
}

1;
