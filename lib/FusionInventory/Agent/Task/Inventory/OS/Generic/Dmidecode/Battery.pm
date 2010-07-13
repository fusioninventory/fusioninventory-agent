package FusionInventory::Agent::Task::Inventory::OS::Generic::Dmidecode::Battery;
use strict;
use warnings;

use English qw(-no_match_vars);

sub parseDate {
    my $string = shift;

    if ($string =~ /(\d{1,2})([\/-])(\d{1,2})([\/-])(\d{2})/) {
        my $d = $1;
        my $m = $3;
        my $y = ($5>90?"19":"20").$5;

        return "$1/$3/$y";
    } elsif ($string =~ /(\d{4})([\/-])(\d{1,2})([\/-])(\d{1,2})/) {
        my $y = ($5>90?"19":"20").$1;
        my $d = $3;
        my $m = $5;

        return "$d/$m/$y";
    }


}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $battery = parseDmidecode('/usr/sbin/dmidecode', '-|');

    $inventory->addBattery($battery);
}

sub parseDmidecode {
    my ($file, $mode) = @_;

    my $handle;
    if (!open $handle, $mode, $file) {
        warn "Can't open $file: $ERRNO";
        return;
    }

    my ($battery, $type);

    while (my $line = <$handle>) {
        chomp $line;

        if ($line =~ /DMI type (\d+)/) {
            $type = $1;
            next;
        }

        next unless defined $type;

        if ($type == 22) {
            if($line =~ /^\s+Name:\s*(.+?)(\s*)$/) {
                $battery->{NAME} = $1;
            } elsif ($line =~ /^\s+Capacity:\s*(\d+)\s*m(W|A)h/) {
                $battery->{CAPACITY} = $1;
            } elsif ($line =~/^\s+Manufacturer:\s*(.+?)(\s*)$/) {
                $battery->{MANUFACTURER} = $1;
            } elsif ($line =~ /^\s+Serial\s*Number:\s*(.+?)(\s*)$/) {
                $battery->{SERIAL} = $1
            } elsif ($line =~ /^\s+Manufacture\s*Date:\s*(\S*)$/) {
                $battery->{DATE} = parseDate($1);
            } elsif ($line =~ /^\s+Voltage:\s*(\d+)\s*mV/) {
                $battery->{VOLTAGE} = $1;
            } elsif ($line =~ /^\s+Chemistry:\s*(\S+\s*)/) {
                $battery->{CHEMISTRY} = $1;
            }
            next;
        }

    }
    close $handle;

    return $battery;
}

1;
