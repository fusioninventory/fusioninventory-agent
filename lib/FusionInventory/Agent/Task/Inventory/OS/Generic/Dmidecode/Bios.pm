package FusionInventory::Agent::Task::Inventory::OS::Generic::Dmidecode::Bios;
use strict;

sub doInventory {
  my $params = shift;
  my $inventory = $params->{inventory};

  my @dmidecode = `dmidecode`;

  my %result = parseDmidecode(\@dmidecode);

  # Writing data
  $inventory->setBios ({
      ASSETTAG => $result{AssetTag},
      SMANUFACTURER => $result{SystemManufacturer},
      SMODEL => $result{SystemModel},
      SSN => $result{SystemSerial},
      BMANUFACTURER => $result{BiosManufacturer},
      BVERSION => $result{BiosVersion},
      BDATE => $result{BiosDate},
    });

    if ($result{vmsystem}) {
        $inventory->setHardware ({
            VMSYSTEM => $result{vmsystem},
        });
    }

}

sub parseDmidecode {
    my ($dmidecode) = @_;

    my %result;
    my $type;

    foreach my $line (@$dmidecode) {
        chomp $line;

        if ($line =~ /DMI type (\d+)/i) {
            $type = $1;
            next;
        }

        next unless defined $type;

        if ($type == 0) {
            # BIOS values
            if ($line =~ /^\s+vendor:\s*(.+?)\s*$/i) {
                $result{BiosManufacturer} = $1;
                if ($result{BiosManufacturer} =~ /QEMU/i) {
                    $result{vmsystem} = 'QEMU';
                } elsif ($result{BiosManufacturer} =~ /VirtualBox/i) {
                    $result{vmsystem} = 'VirtualBox';
                } elsif ($result{BiosManufacturer} =~ /^Xen/i) {
                    $result{vmsystem} = 'Xen';
                }
            } elsif ($line =~ /^\s+release\ date:\s*(.+?)\s*$/i) {
                $result{BiosDate} = $1
            } elsif ($line =~ /^\s+version:\s*(.+?)\s*$/i) {
                $result{BiosVersion} = $1
            }
            next;
        }

        if ($type == 1) {
            if ($line =~ /^\s+serial number:\s*(.+?)\s*$/i) {
                $result{SystemSerial} = $1
            } elsif ($line =~ /^\s+(?:product name|product):\s*(.+?)\s*$/i) {
                $result{SystemModel} = $1;
                if ($result{SystemModel} =~ /VMware/i) {
                    $result{vmsystem} = 'VMware';
                } elsif ($result{SystemModel} =~ /Virtual Machine/i) {
                    $result{vmsystem} = 'Virtual Machine';
                }
            } elsif ($line =~ /^\s+(?:manufacturer|vendor):\s*(.+?)\s*$/i) {
                $result{SystemManufacturer} = $1
            }
            next;
        }

        if ($type == 2) {
            # Failback on the motherbord
            if ($line =~ /^\s+serial number:\s*(.+?)\s*/i) {
                $result{SystemSerial} = $1 if !$result{SystemSerial};
            } elsif ($line =~ /^\s+product name:\s*(.+?)\s*/i) {
                $result{SystemModel} = $1 if !$result{SystemModel};
            } elsif ($line =~ /^\s+manufacturer:\s*(.+?)\s*/i) {
                $result{SystemManufacturer} = $1
                    if !$result{SystemManufacturer};
            }
        }

        if ($type == 3) {
            if ($line =~ /^\s+Asset Tag:\s*(.+\S)/i) {
                $result{AssetTag} = $1 eq 'Not Specified'  ? '' : $1;
            }
            next;
        }

        if ($type == 4) {
            # Some bioses don't provide a serial number so I check for CPU ID
            # (e.g: server from dedibox.fr)
            if ($line =~ /^\s+ID:\s*(.*)/i) {
                if (!$result{SystemSerial}) {
                    $result{SystemSerial} = $1;
                    $result{SystemSerial} =~ s/\ /-/g;
                }
            }
            next;
        }
    }

    return %result;

}

1;
