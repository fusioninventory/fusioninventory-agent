package Ocsinventory::Agent::Backend::DeviceID;

# Initialise the DeviceID. In fact this value is a bit specific since
# it generates in the main script.
sub run {
  my $params = shift;
  my $inventory = $params->{inventory};
  my $params = $params->{params};

  my $UsersLoggedIn = join "/", keys %user;

  if ($params->{old_deviceid}) {
    $inventory->setHardware({ OLD_DEVICEID => $params->{old_deviceid} });
  }
  $inventory->setHardware({ DEVICEID => $params->{deviceid} });

}

1;
