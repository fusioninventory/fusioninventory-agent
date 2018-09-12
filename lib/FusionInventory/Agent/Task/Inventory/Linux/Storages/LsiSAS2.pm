package FusionInventory::Agent::Task::Inventory::Linux::Storages::LsiSAS2;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isEnabled {
    return canRun('sas2ircu');
}

# The module gets a disk data from `sas2ircu LIST` and `sas2irsu NMBR DISPLAY`.
# `LIST` provides informations about number of controllers
# `DISPLAY` provides s/n and model in a single 'Device is a Hard disk' string.

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    # Get list of controllers
    my $command = "sas2ircu LIST";

    my $handle = getFileHandle(
        command => $command,
        %params
    );
    return unless $handle;

    my (%ctrList, %drvList);

    while (my $line = <$handle>) {
        chomp $line;

        if ( $line =~ /^\s+(\d+)\s+([^ ]+)\s+(.+)\s*$/ ) {
            my $ctrl_id = $1;
            my $ctrl_type =$2;
            $ctrList{$ctrl_id}{type} = $ctrl_type;
        }
    }

    while (my ($ctrl_id, $ctrl) =  each %ctrList) {
        $drvList{$ctrl_id}  = _getDisplay( ctrl_id => $ctrl_id );
        while (my ($drv_id, $drv) = each %{$drvList{$ctrl_id}}) {
              my ($size, $manufacturer, $model, $firmware, $serial, $storage);

              if ( $drv->{'Size (in MB)/(in sectors)'} =~/^(\d+)\//) {
                  $size = $1;
              }

              $firmware = $drv->{'Firmware Revision'};
              $model = $drv->{'Model Number'};
              $serial = $drv->{'Serial No'};
              $manufacturer = getCanonicalManufacturer($model);

              $storage = {
                  TYPE         => 'disk',
                  FIRMWARE     => $firmware,
                  DESCRIPTION  => $drv->{'Protocol'},
                  DISKSIZE     => $size,
                  SERIALNUMBER => $serial,
                  NAME         => $model,
                  MODEL        => $model,
                  MANUFACTURER => $manufacturer,
              };

              $inventory->addEntry(
                  section => 'STORAGES',
                  entry   => $storage,
              );

        }
    }

}

sub _getDisplay {
    my (%params) = @_;

    my $command = exists $params{ctrl_id} ? "sas2ircu $params{ctrl_id} DISPLAY" : undef;

    my $handle = getFileHandle(
        command => $command,
        %params
    );
    return unless $handle;

    # fast forward to relevant section
    while (my $line = <$handle>) {
        last if $line =~ /^Physical device information/;
    }

    my %drive;
    my $n = -1;

    while (my $line = <$handle>) {
        # end of relevant section
        last if $line =~ /^Enclosure information/;
        chomp $line;
        next unless $line =~ /^([^:]+)\s*:\s*(.*\S)/;
        my $key = $1;
        my $val = $2;
        $key =~ s/^\s+//;    # Delete leading spaces
        $key =~ s/\s+$//;    # Delete tailing spaces
        $n++ if $key =~ /Enclosure #/;
        $drive{$n}->{$key} = $val;
    }
    close $handle;

    return \%drive;
}


1;
