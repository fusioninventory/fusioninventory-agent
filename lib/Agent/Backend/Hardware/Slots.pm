package Ocsinventory::Agent::Backend::Hardware::Slots;
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
                if(/dmi type 9,/i){$flag=1; (defined($n))?($n++):($n=0);}
                if((/dmi type (\d+),/i) && ($flag)){($1!='9')?$flag=0:1;}
                if((/^id\s*:\s*(.+)/i) && ($flag)){
                        $h->{'CONTENT'}{'SLOTS'}[$n]{'DESIGNATION'} = [ $1 ];
                        push @values, ($1);
                };
                if((/^type\s*:\s*(.+)/i) && ($flag)){
                        $h->{'CONTENT'}{'SLOTS'}[$n]{'DESCRIPTION'} = [ $1 ];
                        push @values, ($1);
                };
                if((/^designation\s*:\s*(.+)/i) && ($flag)){
                        $h->{'CONTENT'}{'SLOTS'}[$n]{'NAME'}= [ $1 ];
                        push @values, ($1);
                };
                if((/^current usage\s*:\s*(.+)/i) && ($flag)){
                        $h->{'CONTENT'}{'SLOTS'}[$n]{'STATUS'} = [ $1 ];
                        push @values, ($1);
                };
        }

}

1;
