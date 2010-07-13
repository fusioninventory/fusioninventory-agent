package FusionInventory::Agent::Task::Inventory::OS::Generic::Dmidecode::Bios;

use strict;
use warnings;

use English qw(-no_match_vars);

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my ($bios, $hardware) = parseDmidecode("dmidecode", '-|');

    # Writing data
    $inventory->setBios($bios);
    $inventory->setHardware($hardware) if $hardware;

}

sub parseDmidecode {
    my ($file, $mode) = @_;

    my $handle;
    if (!open $handle, $mode, $file) {
        warn "Can't open $file: $ERRNO";
        return;
    }

    my ($bios, $hardware, $type);

    while (my $line = <$handle>) {
        chomp $line;

        if ($line =~ /DMI type (\d+)/) {
            $type = $1;
            next;
        }

        next unless defined $type;

        if ($type == 0) {
            # BIOS values

            if ($line =~ /^\s+Vendor:\s*(.+?)\s*$/) {
                $bios->{BMANUFACTURER} = $1;
                if ($bios->{BMANUFACTURER} =~ /(QEMU|Bochs)/) {
                    $hardware->{VMSYSTEM} = 'QEMU';
                } elsif ($bios->{BMANUFACTURER} =~ /VirtualBox/) {
                    $hardware->{VMSYSTEM} = 'VirtualBox';
                } elsif ($bios->{BMANUFACTURER} =~ /^Xen/) {
                    $hardware->{VMSYSTEM} = 'Xen';
                }
            } elsif ($line =~ /^\s+Release Date:\s*(.+?)\s*$/) {
                $bios->{BDATE} = $1
            } elsif ($line =~ /^\s+Version:\s*(.+?)\s*$/) {
                $bios->{BVERSION} = $1
            }
            next;
        }

        if ($type == 1) {
            if ($line =~ /^\s+Serial Number:\s*(.+?)\s*$/) {
                $bios->{SSN} = $1
            } elsif ($line =~ /^\s+(?:Product Name|Product):\s*(.+?)\s*$/) {
                $bios->{SMODEL} = $1;
                if ($bios->{SMODEL} =~ /(VMware|Virtual Machine)/) {
                    $hardware->{VMSYSTEM} = $1;
                }
            } elsif ($line =~ /^\s+(?:Manufacturer|Vendor):\s*(.+?)\s*$/) {
                $bios->{SMANUFACTURER} = $1
            } elsif ($line =~ /^\s+UUID:\s*(.+?)\s*$/) {
                $hardware->{UUID} = $1;
            }
            next;
        }

        if ($type == 2) {
            # Failback on the motherbord
            if ($line =~ /^\s+Serial Number:\s*(.+?)\s*/) {
                $bios->{SSN} = $1 if !$bios->{SSN};
            } elsif ($line =~ /^\s+Product Name:\s*(.+?)\s*/) {
                $bios->{SMODEL} = $1 if !$bios->{SMODEL};
            } elsif ($line =~ /^\s+Manufacturer:\s*(.+?)\s*/) {
                $bios->{SMANUFACTURER} = $1
                if !$bios->{SMANUFACTURER};
            }
        }

        if ($type == 3) {
            if ($line =~ /^\s+Asset Tag:\s*(.+\S)/) {
                $bios->{ASSETTAG} = $1 eq 'Not Specified'  ? '' : $1;
            }
            next;
        }

        if ($type == 4) {
            # Some bioses don't provide a serial number so I check for CPU ID
            # (e.g: server from dedibox.fr)
            if ($line =~ /^\s+ID:\s*(.*)/) {
                if (!$bios->{SSN}) {
                    $bios->{SSN} = $1;
                    $bios->{SSN} =~ s/\ /-/g;
                }
            }
            next;
        }
    }
    close $handle;

    return $bios, $hardware;
}

1;
