package FusionInventory::Agent::Task::Inventory::OS::HPUX::Drives;

use strict;
use warnings;

sub isInventoryEnabled  {
    return
        can_run('fstyp') &&
        can_run('grep') &&
        can_run('bdf') &&
        can_load('POSIX');
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $filesystem;
    my $type;
    my $lv;
    my $total;
    my $free;
    my $createdate;

    for ( `fstyp -l | grep -v nfs` ) {
        next if /^\s*$/;
        chomp;
        $filesystem=$_;
        for ( `bdf -t $filesystem `) {
            next if ( /Filesystem/ );
            if ( /^(\S+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+%)\s+(\S+)/ ) {
                $lv=$1;
                $total=$2;
                $free=$3;
                $type=$6;
                if ( $filesystem =~ /vxfs/i and can_run('fsdb') ) {
                    $createdate = `echo '8192B.p S' | fsdb -F vxfs $lv 2>/dev/null | fgrep -i ctime`;
                    $createdate =~ /ctime\s+(\d+)\s+\d+\s+.*$/i;
                    $createdate = POSIX::strftime("%Y/%m/%d %T", localtime($1));
                    #my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($1);
                    #$createdate = sprintf ('%04d/%02d/%02d %02d:%02d:%02d', ($year+1900), ($mon+1), $mday, $hour, $min, $sec);
                } else {
                    $createdate = '0000/00/00 00:00:00';
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
                if ( $filesystem =~ /vxfs/i and can_run('fsdb') ) {
                    $createdate = `echo '8192B.p S' | fsdb -F vxfs $lv 2>/dev/null | fgrep -i ctime`;
                    $createdate =~ /ctime\s+(\d+)\s+\d+\s+.*$/i;
                    $createdate = POSIX::strftime("%Y/%m/%d %T", localtime($1));
                    #my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($1);
                    #$createdate = sprintf ('%04d/%02d/%02d %02d:%02d:%02d', ($year+1900), ($mon+1), $mday, $hour, $min, $sec);
                } else {
                    $createdate = '0000/00/00 00:00:00';
                }
            } elsif ( /(\d+)\s+(\d+)\s+(\d+)\s+(\d+%)\s+(\S+)/) {
                $total=$1;
                $free=$3;
                $type=$5;
                # print "filesystem $filesystem lv $lv total $total free $free type $type\n";
                $inventory->addDrive({
                    FREE => $free,
                    FILESYSTEM => $filesystem,
                    TOTAL => $total,
                    TYPE => $type,
                    VOLUMN => $lv,
                    CREATEDATE => $createdate,
                })
            }
        } # for bdf -t $filesystem
    }
}

1;
