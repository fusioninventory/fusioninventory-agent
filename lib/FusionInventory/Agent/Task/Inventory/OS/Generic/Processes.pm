package FusionInventory::Agent::Task::Inventory::OS::Generic::Processes;

use strict;
use warnings;

use English qw(-no_match_vars);

sub isInventoryEnabled {
    return can_run("ps");
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $line;   
    my $begin;   
    my %month = (
        'Jan' => '01',
        'Feb' => '02',
        'Mar' => '03',
        'Apr' => '04',
        'May' => '05',
        'Jun' => '06',
        'Jul' => '07',
        'Aug' => '08',
        'Sep' => '09',
        'Oct' => '10',
        'Nov' => '11',
        'Dec' => '12',
    );
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    my $the_year=$year+1900;
    my $the_mon=$mon+1;

    my $command = $OSNAME eq 'solaris' ?
        'ps -A -o user,pid,pcpu,pmem,vsz,rss,tty,s,stime,time,comm' : 'ps aux';

    my $handle;
    if (!open $handle, '-|', $command) {
        warn "Can't run $command: $ERRNO";
        return;
    }

    while ($line = <$handle>) {
        next if ($. ==1);
        if ($line =~
            /^(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(.*?)\s*$/){
            my $user = $1;
            my $pid= $2;
            my $cpu= $3;
            my $mem= $4;
            my $vsz= $5;
            my $tty= $7;
            my $started= $9;
            my $time= $10;
            my $cmd= $11;

            if ($started =~ /^(\w+)_(\d{1,2})/) { # Solaris
                $begin=$the_year."-".$month{$1}."-".$2." ".$time;
            } elsif ($started =~ /^([A-z]{3})(\d{1,2})$/)  {
                $begin=$the_year."-".$month{$1}."-".$2." ".$time;
            }  elsif ($started =~ /^(\d{2}):(\d{2})$/) {
                $begin=$the_year."-".$the_mon."-".$mday." ".$started;
            } elsif (my @stat = stat('/proc/'.$pid)) {
                my (undef,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($stat[10]);
                my $the_year=$year+1900;
                my $the_mon=$mon+1;
                $begin=$the_year."-".$the_mon."-".$mday." ".$hour.':'.$min;
            }

            $inventory->addProcess({
                    'USER' => $user,
                    'PID' => $pid,
                    'CPUUSAGE' => $cpu,
                    'MEM' => $mem,
                    'VIRTUALMEMORY' => $vsz,
                    'TTY' => $tty,
                    'STARTED' => $begin,
                    'CMD' => $cmd
                });
        }
    }
    close $handle; 
}

1;
