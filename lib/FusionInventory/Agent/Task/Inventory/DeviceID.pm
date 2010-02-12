package FusionInventory::Agent::Task::Inventory::DeviceID;

# Initialise the DeviceID. In fact this value is a bit specific since
# it generates in the main script.
sub doInventory {
  my $params = shift;
  my $inventory = $params->{inventory};
  my $config = $params->{config};

  my $UsersLoggedIn = join "/", keys %user;

  if ($config->{old_deviceid}) {
    $inventory->setHardware({ OLD_DEVICEID => $config->{old_deviceid} });
  }
  $inventory->setHardware({ DEVICEID => $config->{deviceid} });

}

1;
