package FusionInventory::Agent::Task::Inventory::OS::Generic::Dmidecode::Battery;
use strict;

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

    my $capacity;
    my $voltage;
    my $name;
    my $serial;
    my $date;
    my $manufacturer;

    # get the BIOS values
    my $type;
    for(`dmidecode`){
        if (/dmi type (\d+),/i) {

            if ($type == 22) {
                $inventory->addBattery({
                        CAPACITY => $capacity,
                        DATE => $date,
                        NAME => $name,
                        SERIAL => $serial,
                        MANUFACTURER => $manufacturer,
                        VOLTAGE => $voltage
                    });
                $capacity = $date = $name = undef;
                $serial = $manufacturer = $voltage = undef;
            }
            $type = $1;
        }


        if ($type == 22) {

            if(/Name:\s*(.+?)(\s*)$/i) {
                $name = $1;
            } elsif(/Capacity:\s*(\d+)\s*mWh/i) {
                $capacity = $1;
            } elsif(/Manufacturer:\s*(.+?)(\s*)$/i) {
                $manufacturer = $1;
            } elsif(/Serial\s*Number:\s*(.+?)(\s*)$/i) {
                $serial = $1
            } elsif(/Manufacture\s*date:\s*(\S*)$/i) {
                $date = parseDate($1);
            } elsif(/Voltage:\s*(\d+)\s*mV/i) {
                $voltage = $1;
            }
        }

    }
}
1;
