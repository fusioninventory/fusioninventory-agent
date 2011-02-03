package FusionInventory::Agent::Task::Inventory::OS::AIX::Storages;

use strict;
use warnings;

sub isInventoryEnabled {
    `which lsdev 2>&1`;
    return if($? >> 8)!=0;
    `which lsattr 2>&1`;
    ($? >> 8)?0:1}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my(@disques, $n, $i, $flag, @rep, @scsi, @values, @lsattr, $FRU, $status);

    #lsvpd
    my @lsvpd = `lsvpd`;  
    s/^\*// for (@lsvpd);

    #SCSI disks 
    $n=0;
    @scsi=`lsdev -Cc disk -s scsi -F 'name:description'`;
    for(@scsi){
        my $device;
        my $manufacturer;
        my $model;
        my $description;
        my $capacity;

        my $serial;

        chomp $scsi[$n];
        /^(.+):(.+)/;
        $device=$1;
        $description=$2;
        @lsattr=`lsattr -EOl $device -a 'size_in_mb'`;
        for (@lsattr){
            if (! /^#/ ){
                $capacity= $_;
                chomp($capacity);$capacity =~ s/(\s+)$//;
            }
        }
        for (@lsvpd){
            if(/^AX $device/){$flag=1}
            if ((/^MF (.+)/) && $flag){$manufacturer=$1;chomp($manufacturer);$manufacturer =~ s/(\s+)$//;}
            if ((/^TM (.+)/) && $flag){$model=$1;chomp($model);$model =~ s/(\s+)$//;}
            if ((/^FN (.+)/) && $flag){$FRU=$1;chomp($FRU);$FRU =~ s/(\s+)$//;$manufacturer .= ",FRU number :".$FRU}
            if ((/^FC .+/) && $flag) {$flag=0;last}
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
        $n++;
    }
$n=0;
  @scsi=`lsdev -Cc disk -s fcp -F 'name:description'`;
  for(@scsi){
        my $device;
        my $manufacturer;
        my $model;
        my $description;
        my $capacity;

        my $serial;
        chomp $scsi[$n];
        /^(.+):(.+)/;
        $device=$1;
        $description=$2;
            $capacity='';
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
          DISKSIZE => $capacity
    });
        $n++;
  }

$n=0;
  @scsi=`lsdev -Cc disk -s fdar -F 'name:description'`;
  for(@scsi){
        my $device;
        my $manufacturer;
        my $model;
        my $description;
        my $capacity;

        my $serial;
        chomp $scsi[$n];
        /^(.+):(.+)/;
        $device=$1;
        $description=$2;
            $capacity='';
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
          DISKSIZE => $capacity
    });
        $n++;
  }


#Virtual disks
    @scsi= ();
    @lsattr= ();
    $n=0;
    @scsi=`lsdev -Cc disk -s vscsi -F 'name:description'`;
    for(@scsi){
        my $device;
        my $manufacturer;
        my $model;
        my $description;
        my $capacity;

        my $serial;
        chomp $scsi[$n];
        /^(.+):(.+)/;
        $device=$1;
        $description=$2;
        @lsattr=`lspv  $device 2>&1`;
        for (@lsattr){
            if ( ! ( /^0516-320.*/ ) )
            {
                if (/TOTAL PPs:/ ) {

                    ($capacity,$model) = split(/\(/, $_);
                    ($capacity,$model) = split(/ /,$model);
                }
            }
            else
            {
                $capacity=0;
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
        $n++;
    }


    #CDROM
    @scsi= ();
    @lsattr= ();
    @scsi=`lsdev -Cc cdrom -s scsi -F 'name:description:status'`;
    $i=0;
    for(@scsi){
        my $device;
        my $manufacturer;
        my $model;
        my $description;
        my $capacity;

        chomp $scsi[$i];
        /^(.+):(.+):(.+)/;
        $device=$1;
        $status=$3;
        $description=$2;
        $capacity="";
        if (($status =~ /Available/)){
            @lsattr=`lsattr -EOl $device -a 'size_in_mb'`;
            for (@lsattr){
                if (! /^#/ ){
                    $capacity= $_;
                    chomp($capacity);$capacity =~ s/(\s+)$//;
                }
            }
            $description = $scsi[$n];
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
                    TYPE => 'cd',
                    DISKSIZE => $capacity
                });
            $n++;
        }
        $i++;
    }

    #TAPE
    @scsi= ();
    @lsattr= ();
    @scsi=`lsdev -Cc tape -s scsi -F 'name:description:status'`;
    $i=0;
    for(@scsi){
        my $device;
        my $manufacturer;
        my $model;
        my $description;
        my $capacity;

        chomp $scsi[$i];
        /^(.+):(.+):(.+)/;
        $device=$1;
        $status=$3;
        $description=$2;
        $capacity="";
        if (($status =~ /Available/)){
            @lsattr=`lsattr -EOl $device -a 'size_in_mb'`;
            for (@lsattr){
                if (! /^#/ ){
                    $capacity= $_;
                    chomp($capacity);$capacity =~ s/(\s+)$//;
                }
            }
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
                    TYPE => 'tape',
                    DISKSIZE => $capacity
                });
            $n++;
        }
        $i++;
    }

    #Disquette
    @scsi= ();
    @lsattr= ();
    @scsi=`lsdev -Cc diskette -F 'name:description:status'`;
    $i=0;
    for(@scsi){
        my $device;
        my $manufacturer;
        my $model;
        my $description;
        my $capacity;

        chomp $scsi[$i];
        /^(.+):(.+):(.+)/;
        $device=$1;
        $status=$3;
        $description=$2;
        $capacity="";
        if (($status =~ /Available/)){
            @lsattr=`lsattr -EOl $device -a 'fdtype'`;
            for (@lsattr){
                if (! /^#/ ){
                    $capacity= $_;
                    chomp($capacity);$capacity =~ s/(\s+)$//;
                }
            }
            #On le force en retour taille disquette non affichable
            $capacity ="";
            $inventory->addStorage({
                    NAME => $device,
                    MANUFACTURER => 'N/A',
                    MODEL => 'N/A',
                    DESCRIPTION => $description,
                    TYPE => 'floppy',
                    DISKSIZE => ''
                });
            $n++;
        }
        $i++;
    }
}

1;
