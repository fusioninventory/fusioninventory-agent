package FusionInventory::Agent::Task::Inventory::OS::AIX::Storages;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return
        can_run('lsdev') &&
        can_run('lsattr');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{inventory};

    my(@disques, $flag, @rep, @scsi, @values, @lsattr, $FRU, $status);

    #lsvpd
    my @lsvpd = getAllLines(
        command => 'lsvpd', logger => $logger
    );  
    s/^\*// foreach (@lsvpd);

    #SCSI disks 
    @scsi = getAllLines(
        command => 'lsdev -Cc disk -s scsi -F "name:description"',
        logger  => $logger
    );
    foreach (@scsi){
        my $device;
        my $manufacturer;
        my $model;
        my $description;
        my $capacity;

        my $serial;

        chomp;
        /^(.+):(.+)/;
        $device = $1;
        $description = $2;
        $capacity = _getCapacity($device, $logger);
        foreach (@lsvpd) {
            if (/^AX $device/) {
                $flag = 1;
            }
            if (/^MF (.+)/ && $flag) {
                $manufacturer = $1;
                chomp($manufacturer);
                $manufacturer =~ s/(\s+)$//;
            }
            if (/^TM (.+)/ && $flag) {
                $model = $1;
                chomp($model);
                $model =~ s/(\s+)$//;
            }
            if (/^FN (.+)/ && $flag) {
                $FRU = $1;
                chomp($FRU);
                $FRU =~ s/(\s+)$//;
                $manufacturer .= ",FRU number :".$FRU;
            }
            if (/^FC .+/ && $flag) {
                $flag = 0;
                last;
            }
        }

        foreach (`lscfg -p -v -s -l $device` =~ /Serial Number\.*(.*)/) {
            $serial = $1;
        }

        $inventory->addStorage({
                NAME => $device,
                MANUFACTURER => $manufacturer,
                MODEL => $model,
                DESCRIPTION => $description,
                TYPE => 'disk',
                SERIAL=> $serial,
                DISKSIZE => $capacity
            });
    }

  @scsi=`lsdev -Cc disk -s fcp -F 'name:description'`;
  for(@scsi){
        my $device;
        my $manufacturer;
        my $model;
        my $description;

        my $serial;
        chomp;
        /^(.+):(.+)/;
        $device=$1;
        $description=$2;
        for (@lsvpd){
          if(/^AX $device/){$flag=1}
          if ((/^MF (.+)/) && $flag){$manufacturer=$1;chomp($manufacturer);$manufacturer =~ s/(\s+)$//;}
          if ((/^TM (.+)/) && $flag){$model=$1;chomp($model);$model =~ s/(\s+)$//;}
          if ((/^FN (.+)/) && $flag){$FRU=$1;chomp($FRU);$FRU =~ s/(\s+)$//;$manufacturer .= ",FRU number :".$FRU}
          if ((/^FC .+/) && $flag) {$flag=0;last}
        }
        $inventory->addStorage({
          NAME => $device,
          MANUFACTURER => $manufacturer,
          MODEL => $model,
          DESCRIPTION => $description,
          TYPE => 'disk',
    });
  }

  @scsi=`lsdev -Cc disk -s fdar -F 'name:description'`;
  for(@scsi){
        my $device;
        my $manufacturer;
        my $model;
        my $description;

        my $serial;
        chomp;
        /^(.+):(.+)/;
        $device=$1;
        $description=$2;
        for (@lsvpd){
          if(/^AX $device/){$flag=1}
          if ((/^MF (.+)/) && $flag){$manufacturer=$1;chomp($manufacturer);$manufacturer =~ s/(\s+)$//;}
          if ((/^TM (.+)/) && $flag){$model=$1;chomp($model);$model =~ s/(\s+)$//;}
          if ((/^FN (.+)/) && $flag){$FRU=$1;chomp($FRU);$FRU =~ s/(\s+)$//;$manufacturer .= ",FRU number :".$FRU}
          if ((/^FC .+/) && $flag) {$flag=0;last}
        }
        $inventory->addStorage({
          NAME => $device,
          MANUFACTURER => $manufacturer,
          MODEL => $model,
          DESCRIPTION => $description,
          TYPE => 'disk',
    });
  }


#Virtual disks
    @scsi= ();
    @lsattr= ();
    @scsi = getAllLines(
        command => 'lsdev -Cc disk -s vscsi -F "name:description"',
        logger => $logger
    );
    foreach (@scsi){
        my $device;
        my $manufacturer;
        my $model;
        my $description;
        my $capacity;

        my $serial;
        chomp;
        /^(.+):(.+)/;
        $device = $1;
        $description = $2;
        @lsattr = getAllLines(
            command => "lspv $device",
            logger  => $logger
        );
        foreach (@lsattr) {
            if ( ! ( /^0516-320.*/ ) ) {
                if (/TOTAL PPs:/ ) {
                    ($capacity,$model) = split(/\(/, $_);
                    ($capacity,$model) = split(/ /,$model);
                }
            } else {
                $capacity = 0;
            }
        }
        $inventory->addStorage({
                MANUFACTURER => "VIO Disk",
                MODEL => "Virtual Disk",
                DESCRIPTION => $description,
                TYPE => 'disk',
                NAME => $device,
                DISKSIZE => $capacity
            });
    }

    #CDROM
    @scsi= ();
    @lsattr= ();
    @scsi = getAllLines(
        command => 'lsdev -Cc cdrom -s scsi -F "name:description:status"',
        logger  => $logger
    );

    my $n;
    foreach my $line (@scsi){
        chomp $line;
        next unless $line =~ /^(.+):(.+):.+Available.+/;
        my $device = $1;
        my $description = $2;

        my $capacity = _getCapacity($device, $logger);
        $description = $scsi[$n];

        my $manufacturer;
        my $model;
        foreach (@lsvpd){
            if (/^AX $device/) {
                $flag = 1;
            }
            if (/^MF (.+)/ && $flag) {
                $manufacturer = $1;
                chomp($manufacturer);
                $manufacturer =~ s/(\s+)$//;
            }
            if (/^TM (.+)/ && $flag) {
                $model = $1;
                chomp($model);
                $model =~ s/(\s+)$//;
            }
            if (/^FN (.+)/ && $flag) {
                $FRU = $1;
                chomp($FRU);
                $FRU =~ s/(\s+)$//;
                $manufacturer .= ",FRU number :".$FRU;
            }
            if (/^FC .+/ && $flag) {
                $flag = 0;
                last;
            }
        }
        $inventory->addStorage({
            NAME => $device,
            MANUFACTURER => $manufacturer,
            MODEL => $model,
            DESCRIPTION => $description,
            TYPE => 'cd',
            DISKSIZE => $capacity
        });
        $n++;
    }

    #TAPE
    @scsi= ();
    @lsattr= ();
    @scsi = getAllLines(
        command => 'lsdev -Cc tape -s scsi -F "name:description:status"',
        logger  => $logger
    );
    foreach my $line (@scsi) {
        chomp $line;
        next unless $line =~ /^(.+):(.+):.+Available.+/;
        my $device = $1;
        my $description = $2;
        my $manufacturer;
        my $model;

        my $capacity = _getCapacity($device, $logger);
        foreach (@lsvpd){
            if (/^AX $device/) {
                $flag = 1;
            }
            if (/^MF (.+)/ && $flag) {
                $manufacturer = $1;
                chomp($manufacturer);
                $manufacturer =~ s/(\s+)$//;
            }
            if (/^TM (.+)/ && $flag) {
                $model = $1;
                chomp($model);
                $model =~ s/(\s+)$//;
            }
            if (/^FN (.+)/ && $flag) {
                $FRU = $1;
                chomp($FRU);
                $FRU =~ s/(\s+)$//;
                $manufacturer .= ",FRU number :".$FRU;
            }
            if (/^FC .+/ && $flag) {
                $flag = 0;
                last;
            }
        }
        $inventory->addStorage({
            NAME => $device,
            MANUFACTURER => $manufacturer,
            MODEL => $model,
            DESCRIPTION => $description,
            TYPE => 'tape',
            DISKSIZE => $capacity
        });
    }

    #Disquette
    @scsi= ();
    @lsattr= ();
    @scsi = getAllLines(
        command => 'lsdev -Cc diskette -F "name:description:status"',
        logger  => $logger
    );
    foreach my $line (@scsi) {
        chomp $line;
        next unless $line =~ /^(.+):(.+):.+Available.+/;
        my $device = $1;
        my $description = $2;
        $inventory->addStorage({
            NAME => $1,
            MANUFACTURER => 'N/A',
            MODEL => 'N/A',
            DESCRIPTION => $2,
            TYPE => 'floppy',
            DISKSIZE => ''
        });
    }
}

sub _getCapacity {
    my ($device, $logger) = @_;

    my @lsattr = getAllLinaes(
        command => "lsattr -EOl $device -a 'size_in_mb'",
        logger  => $logger
    );

    my $capacity;
    foreach (@lsattr){
        if (! /^#/ ){
            $capacity= $_;
            chomp($capacity);
            $capacity =~ s/(\s+)$//;
        }
    }

    return $capacity;
}

1;
