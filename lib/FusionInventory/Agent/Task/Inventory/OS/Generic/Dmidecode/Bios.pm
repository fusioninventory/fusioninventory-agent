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

    s/^\s+// for (@$dmidecode);

    # get the BIOS values
    my $flag=0;
    for(@$dmidecode) {
        $flag=1 if /dmi type 0,/i;
        last if($flag && (/dmi type (\d+),/i) && ($1!=0));
        if((/^vendor:\s*(.+?)(\s*)$/i) && ($flag)) {
            $result{BiosManufacturer} = $1;
            if ($result{BiosManufacturer} =~ /QEMU/i) {
                $result{vmsystem} = 'QEMU';
            } elsif ($result{BiosManufacturer} =~ /VirtualBox/i) {
                $result{vmsystem} = 'VirtualBox';
            } elsif ($result{BiosManufacturer} =~ /^Xen/i) {
                $result{vmsystem} = 'Xen';
            }

        }
        if((/^release\ date:\s*(.+?)(\s*)$/i) && ($flag)) {
            $result{BiosDate} = $1
        }
        if((/^version:\s*(.+?)(\s*)$/i) && ($flag)) {
            $result{BiosVersion} = $1
        }
    }
     
    # Try to query the machine itself 
    $flag=0;
    for(@$dmidecode) {
        if(/dmi type 1,/i){$flag=1;}
        last if($flag && (/dmi type (\d+),/i) && ($1!=1));
        if((/^serial number:\s*(.+?)(\s*)$/i) && ($flag)) {
            $result{SystemSerial} = $1
        }
        if((/^(product name|product):\s*(.+?)(\s*)$/i) && ($flag)) {
            $result{SystemModel} = $2;
            if ($result{SystemModel} =~ /VMware/i) {
                $result{vmsystem} = 'VMware';
            } elsif ($result{SystemModel} =~ /Virtual Machine/i) {
                $result{vmsystem} = 'Virtual Machine';
            }
        }
        if((/^(manufacturer|vendor):\s*(.+?)(\s*)$/i) && ($flag)) {
            $result{SystemManufacturer} = $2
        }
    }

    # Failback on the motherbord
    $flag=0;
    for(@$dmidecode){
        if(/dmi type 2,/i){$flag=1;}
        last if($flag && (/dmi type (\d+),/i) && ($1!=2));
        if((/^serial number:\s*(.+?)(\s*)/i) && ($flag) && (!$result{SystemSerial})) {
            $result{SystemSerial} = $1
        }
        if((/^product name:\s*(.+?)(\s*)/i) && ($flag) && (!$result{SystemModel})) {
            $result{SystemModel} = $1
        }
        if((/^manufacturer:\s*(.+?)(\s*)/i) && ($flag) && (!$result{SystemManufacturer})) {
            $result{SystemManufacturer} = $1
        }
    }

    $flag=0;
    for(@$dmidecode) {
        if ($flag) {
            if (/^Asset Tag:\s*(.+\S)/i) {
                $result{AssetTag} = $1;
                $result{AssetTag} = '' if $result{AssetTag} eq 'Not Specified';
                last;
            } elsif (/dmi type \d+,/i) {  # End of the section
                last;
            }
        }
        if (/dmi type 3,/i) {
            $flag=1;
        }
    }

    # Some bioses don't provide a serial number so I check for CPU ID (e.g: server from dedibox.fr)
    if (!$result{SystemSerial} ||$result{SystemSerial} =~ /^0+$/) {
        $flag=0;
        for(@$dmidecode) {
            if(/dmi type 4,/i){$flag=1;}
            elsif(/^processor information:/i){$flag=2;}
            elsif((/^ID:\s*(.*)/i) && ($flag)) {
                $result{SystemSerial} = $1;
                $result{SystemSerial} =~ s/\ /-/g;
                last
            }
        }
    }

  return %result;

}

1;
