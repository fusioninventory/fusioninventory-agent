package FusionInventory::Agent::Task::Inventory::OS::Generic::Dmidecode::Bios;

use strict;
use warnings;

use English qw(-no_match_vars);

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my ($bios, $hardware) = parseDmidecode("dmidecode", '-|');

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

            if ($line =~ /^\s+Vendor: (.*\S)/) {
                $bios->{BMANUFACTURER} = $1;
                if ($bios->{BMANUFACTURER} =~ /(QEMU|Bochs)/) {
                    $hardware->{VMSYSTEM} = 'QEMU';
                } elsif ($bios->{BMANUFACTURER} =~ /VirtualBox/) {
                    $hardware->{VMSYSTEM} = 'VirtualBox';
                } elsif ($bios->{BMANUFACTURER} =~ /^Xen/) {
                    $hardware->{VMSYSTEM} = 'Xen';
                }
            } elsif ($line =~ /^\s+Release Date: (.*\S)/) {
                $bios->{BDATE} = $1
            } elsif ($line =~ /^\s+Version: (.*\S)/) {
                $bios->{BVERSION} = $1
            }
            next;
        }

        if ($type == 1) {
            if ($line =~ /^\s+Serial Number: (.*\S)/) {
                $bios->{SSN} = $1
            } elsif ($line =~ /^\s+Product(?: Name)?: (.*\S)/) {
                $bios->{SMODEL} = $1;
                if ($bios->{SMODEL} =~ /(VMware|Virtual Machine)/) {
                    $hardware->{VMSYSTEM} = $1;
                }
            } elsif ($line =~ /^\s+(?:Manufacturer|Vendor): (.*\S)/) {
                $bios->{SMANUFACTURER} = $1
            } elsif ($line =~ /^\s+UUID: (.*\S)/) {
                $hardware->{UUID} = $1;
            }
            next;
        }

        if ($type == 2) {
            # Failback on the motherbord
            if ($line =~ /^\s+Serial Number: (.*\S)/) {
                $bios->{SSN} = $1 if !$bios->{SSN};
            } elsif ($line =~ /^\s+Product Name: (.*\S)/) {
                $bios->{SMODEL} = $1 if !$bios->{SMODEL};
            } elsif ($line =~ /^\s+Manufacturer: (.*\S)/) {
                $bios->{SMANUFACTURER} = $1
                if !$bios->{SMANUFACTURER};
            }
        }

        if ($type == 3) {
            if ($line =~ /^\s+Asset Tag: (.*\S)/) {
                $bios->{ASSETTAG} = $1 eq 'Not Specified'  ? '' : $1;
            }
            next;
        }

        if ($type == 4) {
            # Some bioses don't provide a serial number so I check for CPU ID
            # (e.g: server from dedibox.fr)
            if ($line =~ /^\s+ID: (.*\S)/) {
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
