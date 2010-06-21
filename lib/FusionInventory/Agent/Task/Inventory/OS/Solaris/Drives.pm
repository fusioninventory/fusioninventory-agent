package FusionInventory::Agent::Task::Inventory::OS::Solaris::Drives;

#Filesystem            kbytes    used   avail capacity  Mounted on
#/dev/vx/dsk/bootdg/rootvol 16525754 5423501 10936996    34%    /
#/devices                   0       0       0     0%    /devices
#ctfs                       0       0       0     0%    /system/contract
#proc                       0       0       0     0%    /proc
#mnttab                     0       0       0     0%    /etc/mnttab

use strict;
use warnings;

sub isInventoryEnabled {
    return can_run ("df");
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $free;
    my $filesystem;
    my $total;
    my $type;
    my $volumn;  

#Looking for mount points and disk space 
    for(`df -k`){
        if (/^Filesystem\s*/){next};
        # on Solaris 10 /devices is an extra mount which we like to exclude
        if (/^\/devices/){next};
        # on Solaris 10 /platform/.../libc_psr_hwcap1.so.1 is an extra mount which we like to exclude
        if (/^\/platform/){next};
        # exclude cdrom mount point
        if (/^\/.*\/cdrom/){next};

        if (!(/^\/.*/) && !(/^swap.*/)){next};

        if(/^(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\n/){	
            $filesystem = $1;
            $total = sprintf("%i",($2/1024));	
            $free = sprintf("%i",($4/1024));
            $volumn = $6;

            if($filesystem =~ /^\/dev\/\S*/){	 
                chomp($type=`fstyp $filesystem`);
                $type = '' if $type =~ /cannot stat/;
            } else {$type="";}	 
#print "FILESYS ".$filesystem." FILETYP ".$type." TOTAL ".$total." FREE ".$free." VOLUMN ".$volumn."\n";
            $inventory->addDrive({
                FREE => $free,
                FILESYSTEM => $filesystem,
                TOTAL => $total,
                TYPE => $type,
                VOLUMN => $volumn
            })
        }
    }
}

1;
