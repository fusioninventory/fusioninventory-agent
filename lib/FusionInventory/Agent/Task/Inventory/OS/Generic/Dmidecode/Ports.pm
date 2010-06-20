package FusionInventory::Agent::Task::Inventory::OS::Generic::Dmidecode::Ports;

use strict;
use warnings;

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $dmidecode = `dmidecode`; # TODO retrieve error
    # some versions of dmidecode do not separate items with new lines
    # so add a new line before each handle
    $dmidecode =~ s/\nHandle/\n\nHandle/g;
    my @dmidecode = split (/\n/, $dmidecode);
    # add a new line at the end
    push @dmidecode, "\n";

    s/^\s+// for (@dmidecode);

    my $flag;

    my $caption;
    my $description;
    my $name;
    my $type;

    foreach (@dmidecode) {

        if(/dmi type 8,/i) {
            $flag = 1;

        } elsif ($flag && /^$/){ # end of section
            $flag = 0;

            $inventory->addPorts({
                CAPTION => $caption,
                DESCRIPTION => $description,
                NAME => $name,
                TYPE => $type,
            });

            $caption = $description = $name = $type = undef;
        } elsif ($flag) {

            $caption = $1 if /^external connector type\s*:\s*(.+)/i;
            $description = $1 if /^internal connector type\s*:\s*(.+)/i;
            $name = $1 if /^internal reference designator\s*:\s*(.+)/i;
            $type = $1 if /^port type\s*:\s*(.+)/i;

        }
    }
}

1;
