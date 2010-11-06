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

        if ($line =~ /DMI type (\d+)/i) {
            $type = $1;
            next;
        }

        next unless defined $type;

        if ($type == 0) {
            # BIOS values

            if ($line =~ /^\s+vendor:\s*(.+?)\s*$/i) {
                $bios->{BMANUFACTURER} = $1;
                if ($bios->{BMANUFACTURER} =~ /(QEMU|Bochs)/i) {
                    $hardware->{VMSYSTEM} = 'QEMU';
                } elsif ($bios->{BMANUFACTURER} =~ /VirtualBox/i) {
                    $hardware->{VMSYSTEM} = 'VirtualBox';
                } elsif ($bios->{BMANUFACTURER} =~ /innotek/i) {
                    $hardware->{VMSYSTEM} = 'VirtualBox';
                } elsif ($bios->{BMANUFACTURER} =~ /^Xen/i) {
                    $hardware->{VMSYSTEM} = 'Xen';
                }
            } elsif ($line =~ /^\s+release date:\s*(.+?)\s*$/i) {
                $bios->{BDATE} = $1
            } elsif ($line =~ /^\s+version:\s*(.+?)\s*$/i) {
                $bios->{BVERSION} = $1;
                if ($bios->{BVERSION} =~ /VirtualBox/i) {
                    $hardware->{VMSYSTEM} = 'VirtualBox';
                }
            }
            next;
        }

        if ($type == 1) {
            if ($line =~ /^\s+serial number:\s*(.+)/i) {
                $bios->{SSN} = $1;
		$bios->{SSN} =~ s/\s$//;
            } elsif ($line =~ /^\s+(?:product name|product):\s*(.+)/i) {
                $bios->{SMODEL} = $1;
		$bios->{SMODEL} =~ s/\s$//;
                if ($bios->{SMODEL} =~ /(VMware|Virtual Machine)/i) {
                    $hardware->{VMSYSTEM} = $1;
                }
            } elsif ($line =~ /^\s+(?:manufacturer|vendor):\s*(.+)/i) {
                $bios->{SMANUFACTURER} = $1;
		$bios->{SMANUFACTURER} =~ s/\s$//;
            } elsif ($line =~ /SKU Number:\s+(.*)/i) {
		$bios->{SKUNUMBER} = $1;
		$bios->{SKUNUMBER} =~ s/\s$//;
	    }
            next;
        }

        if ($type == 2) {
            # Failback on the motherbord
            if ($line =~ /^\s+serial number:\s*(.+)/i) {
                $bios->{MSN} = $1;
		$bios->{MSN} =~ s/\s+$//
            } elsif ($line =~ /^\s+product name:\s*(.+)/i) {
                $bios->{MMODEL} = $1;
		$bios->{MMODEL} =~ s/\s+$//
            } elsif ($line =~ /^\s+manufacturer:\s*(.+)/i) {
                $bios->{MMANUFACTURER} = $1;
		$bios->{MMANUFACTURER} =~ s/\s+$//
            }
        }

        if ($type == 3) {
            if ($line =~ /^\s+Asset Tag:\s*(.+\S)/i) {
                $bios->{ASSETTAG} = $1 eq 'Not Specified'  ? '' : $1;
            }
            next;
        }

#        if ($type == 4) {
#            # Some bioses don't provide a serial number so I check for CPU ID
#            # (e.g: server from dedibox.fr)
#            if ($line =~ /^\s+ID:\s*(.*)/i) {
#                if (!$bios->{SSN}) {
#                    $bios->{SSN} = $1;
#                    $bios->{SSN} =~ s/\ /-/g;
#                }
#            }
#            next;
#        }
    }
    close $handle;
    return $bios, $hardware;
}

1;
