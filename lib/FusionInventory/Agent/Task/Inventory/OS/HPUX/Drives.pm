package FusionInventory::Agent::Task::Inventory::OS::HPUX::Drives;

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
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $filesystem;
    my $type;
    my $lv;
    my $total;
    my $free;
    my $createdate;

    my $handle = getFileHandle(
        command => 'fstyp -l',
        logger  => $logger
    );

    return unless $handle;

    while (my $line = <$handle>) {
        next if /^\s*$/;
        next if $line =~ /nfs/;
        chomp $line;
        foreach (`bdf -t $line`) {
            next if ( /Filesystem/ );
            my $createdate = '0000/00/00 00:00:00';
            if ( /^(\S+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+%)\s+(\S+)/ ) {
                $lv=$1;
                $total=$2;
                $free=$3;
                $type=$6;
# Disabled for the moment, see http://forge.fusioninventory.org/issues/778
#                if ( $filesystem =~ /vxfs/i and can_run('fsdb') ) {
#                    my $tmp = `echo '8192B.p S' | fsdb -F vxfs $lv 2>/dev/null | fgrep -i ctime`;
#                    if ($tmp =~ /ctime\s+(\d+)\s+\d+\s+.*$/i) {
#                        $createdate = POSIX::strftime("%Y/%m/%d %T", localtime($1));
#                    }
#                    #my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($1);
#                    #$createdate = sprintf ('%04d/%02d/%02d %02d:%02d:%02d', ($year+1900), ($mon+1), $mday, $hour, $min, $sec);
#                }

                $inventory->addEntry({
                    section => 'DRIVES',
                    entry   => {
                        FREE => $free,
                        FILESYSTEM => $filesystem,
                        TOTAL => $total,
                        TYPE => $type,
                        VOLUMN => $lv,
                        CREATEDATE => $createdate,
                    }
                })
            } elsif ( /^(\S+)\s/) {
                $lv=$1;
# Disabled for the moment, see http://forge.fusioninventory.org/issues/778
#                if ( $filesystem =~ /vxfs/i and can_run('fsdb') ) {
#                    my $tmp = `echo '8192B.p S' | fsdb -F vxfs $lv 2>/dev/null | fgrep -i ctime`;
#                    if ($tmp =~ /ctime\s+(\d+)\s+\d+\s+.*$/i) {
#                        $createdate = POSIX::strftime("%Y/%m/%d %T", localtime($1));
#                    }
#                    #my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($1);
#                    #$createdate = sprintf ('%04d/%02d/%02d %02d:%02d:%02d', ($year+1900), ($mon+1), $mday, $hour, $min, $sec);
#                }
            } elsif ( /(\d+)\s+(\d+)\s+(\d+)\s+(\d+%)\s+(\S+)/) {
                $total=$1;
                $free=$3;
                $type=$5;
                # print "filesystem $filesystem lv $lv total $total free $free type $type\n";
                $inventory->addEntry({
                    section => 'DRIVES',
                    entry   => {
                        FREE       => $free,
                        FILESYSTEM => $filesystem,
                        TOTAL      => $total,
                        TYPE       => $type,
                        VOLUMN     => $lv,
                        CREATEDATE => $createdate,
                    }
                })
            }
        } # for bdf -t $filesystem
    }
    close $handle;
}

1;
