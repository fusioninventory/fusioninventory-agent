package Ocsinventory::Agent::Backend::Hardware::Memory;
use strict;
sub check {
	my $dmipath = `which dmidecode`;
	return 1 if $dmipath =~ /\w+/;
	0
}

sub run {

	my $h = shift;
	
	my @dmidecode = `dmidecode`; # TODO retrive error
	s/^\s+// for (@dmidecode);

	my ($n, $flag, @values);
        for(@dmidecode){
                if(/dmi type 17,/i){$flag=1; (defined($n))?($n++):($n=0);}

                if((/dmi type (\d+),/i) && ($flag)) {$flag=($1!='17'?0:1);}
                if((/^size\s*:\s*(\S+)/i) && ($flag)) { $h->{'CONTENT'}{'MEMORIES'}[$n]{'CAPACITY'}= [ $1 ]; push @values, $1}
                if((/^speed\s*:\s*(.+)/i) && ($flag)) {$h->{'CONTENT'}{'MEMORIES'}[$n]{'SPEED'}     = [ $1 ]; push @values, $1}
                if((/^type\s*:\s*(.+)/i) && ($flag)) {$h->{'CONTENT'}{'MEMORIES'}[$n]{'TYPE'}= [ $1 ]; push @values, $1}
                if((/^Form Factor\s*:\s*(.+)/i) && ($flag)) {$h->{'CONTENT'}{'MEMORIES'}[$n]{'DESCRIPTION'}= [ $1 ]; push @values, $1}
                if((/^Locator\s*:\s*(.+)/i) && ($flag)) {$h->{'CONTENT'}{'MEMORIES'}[$n]{'NUMSLOTS'} = [ $1 ]; push @values, $1}
        }
}

1;
