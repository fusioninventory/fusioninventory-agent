package FusionInventory::Agent::Task::Inventory::OS::HPUX::Drives;

use strict;
use warnings;

use English qw(-no_match_vars);
use POSIX qw(strftime);

use FusionInventory::Agent::Tools;

sub isInventoryEnabled  {
    return
        can_run('fstyp') &&
        can_run('grep') &&
        can_run('bdf');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

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

# get filesystem creation time by reading binary value directly on the device
sub _getVxFSctime {
    my ($device, $logger) = @_;

    # compute version-dependant read offset

    # Output of 'fstyp' should be something like the following:
    # $ fstyp -v /dev/vg00/lvol3
    #   vxfs
    #   version: 5
    #   .
    #   .
    my $version = getFirstMach(
        command => "fstyp -v $device",
        logger  => $logger,
        pattern => /^version:\s+(\d+)$/
    );

    my $offset =
        $version == 5 ? 8200 :
        $version == 6 ? 8208 :
                        undef;

    if (!$offset) {
      $logger->error("unable to compute offset from fstyp output");
      return;
    }

    # read value
    open (my $handle, "<:raw:bytes", $device)
        or die "Can't open $device in raw mode: $ERRNO";
    seek($handle, $offset, 0) 
        or die "Can't seek offset $offset on device $device: $ERRNO";
    my $raw;
    read($handle, $raw, 4)
        or die "Can't read 4 bytes on device $device: $ERRNO";
    close($handle);

    # Convert the 4-byte raw data to long integer and
    # return a string representation of this time stamp
    return strftime("%Y/%m/%d %T", localtime(unpack('L', $raw)));
}

1;
