package FusionInventory::Agent::Task::Inventory::OS::HPUX::Drives;

use POSIX;
use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled  {
    return
        can_run('fstyp') &&
        can_run('grep') &&
        can_run('bdf');
}

sub doInventory {
    my $params = shift;

    my $inventory = $params->{inventory};
    my $logger = $params->{logger};


    my $filesystem;
    my $type;
    my $lv;
    my $total;
    my $free;
    my $handle = getFileHandle(
        command => 'fstyp -l',
        logger  => $logger
    );

    return unless $handle;

    while (my $filesystem = <$handle>) {
        next if $filesystem =~ /^\s*$/;
        chomp $filesystem;
        foreach (`bdf -t $filesystem`) {
            next if ( /Filesystem/ );
            my $createdate = '0000/00/00 00:00:00';
            if ( /^(\S+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+%)\s+(\S+)/ ) {
                $lv=$1;
                $total=$2;
                $free=$3;
                $type=$6;
                if ( $filesystem =~ /vxfs/i ) {
                    $createdate = _getVxFSctime($lv, $logger);
                }

                $inventory->addDrive({
                    FREE => $free,
                    FILESYSTEM => $filesystem,
                    TOTAL => $total,
                    TYPE => $type,
                    VOLUMN => $lv,
                    CREATEDATE => $createdate,
                })
            } elsif ( /^(\S+)\s/) {
                $lv=$1;
                if ( $filesystem =~ /vxfs/i ) {
                    $createdate = _getVxFSctime($lv, $logger);
                }
            } elsif ( /(\d+)\s+(\d+)\s+(\d+)\s+(\d+%)\s+(\S+)/) {
                $total=$1;
                $free=$3;
                $type=$5;
                # print "filesystem $filesystem lv $lv total $total free $free type $type\n";
                $inventory->addEntry({
                    FREE       => $free,
                    FILESYSTEM => $filesystem,
                    TOTAL      => $total,
                    TYPE       => $type,
                    VOLUMN     => $lv,
                    CREATEDATE => $createdate,
                })
            }
        } # for bdf -t $filesystem
    }
    close $handle;
}

sub _getVxFSctime {
    my $devfilename = shift;
    my $logger = shift; #$params->{logger}
    my $fsver = 0;
    # Output of 'fstyp' should be something like the following:
    # $ fstyp -v /dev/vg00/lvol3
    #   vxfs
    #   version: 5
    #   .
    #   .
    foreach(`fstyp -v $devfilename`) {
      # Personally, I know only the offset of creation time date
      #  in version 5 and 6 of VxFS
      if ( /^version:\s+([56])$/ ) {
        $fsver = $1;
        last;
      }
    }
    if ( $fsver < 5 or $fsver > 6 ) {
      $logger->debug("fstyp -v $devfilename did not return the version or VxFS version not supported!");
      return;
    }

    my $devfile;
    my $tmpVar;
    # Going to open the device file for RAW Binary Readonly access
    open($devfile, "<:raw:bytes", $devfilename) or return;
    # Offset of creation timestamp of VxFS file system
    #  for version 5 is 8200 and for verion 6 is 8208
    seek($devfile, $fsver==5?8200:8208, 0) or return;
    # Creation time of VxFS file system is a 4 byte integer
    read($devfile, $tmpVar, 4) or return;
    close($devfile);
    # Convert the 4-byte raw data to long integer and
    #  return a string representation of this time stamp
    return POSIX::strftime("%Y/%m/%d %T", localtime( unpack( 'L', $tmpVar ) ));
}

1;
