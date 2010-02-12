package FusionInventory::Agent::Task::Inventory::OS::MacOS::Hostname;

sub isInventoryEnabled {
  return 1 if can_load ("Mac::SysProfile");
  0;
}

# Initialise the distro entry
sub doInventory {
  my $params = shift;
  my $inventory = $params->{inventory};

  my $hostname;

  my $prof = Mac::SysProfile->new();
  my $nfo = $prof->gettype('SPSoftwareDataType');
  
  return undef unless(ref($nfo) eq 'HASH');
  
  $hostname = $nfo->{'System Software Overview'}->{'Computer Name'};
  
  $inventory->setHardware ({NAME => $hostname}) if $hostname;
}

1;
