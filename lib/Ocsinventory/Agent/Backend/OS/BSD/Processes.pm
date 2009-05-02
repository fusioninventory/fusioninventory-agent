package Ocsinventory::Agent::Backend::OS::BSD::Processes;
use strict;

sub check {can_run("ps")}

sub run {
  my $params = shift;
  my $inventory = $params->{inventory};

my $line;   
open(PS, "ps aux|");
while ($line = <PS>) {
  next if ($. ==1);
  if ($line =~ /^(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(.*)/){
    my $user = $1;
    my $pid= $2;
    my $cpu= $3;
    my $mem= $4;
    my $vsz= $5;
    my $rss= $6;
    my $tty= $7;
    my $stat= $8;
    my $started= $9;
    my $time= $10;
    my $cmd= $11;
    
    $inventory->addProcesses({
      'USER' => $user,
      'PID' => $pid,
      'CPU' => $cpu,
      'MEM' => $mem,
      'VSZ' => $vsz,
      'RSS' => $rss,
      'TTY' => $tty,
      'STAT' => $stat,
      'STARTED' => $started,
      'TIME' => $time,
      'CMD' => $cmd
      });
    }
  }
close(PS); 
}

1;
