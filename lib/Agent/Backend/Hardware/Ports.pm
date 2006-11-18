package Ocsinventory::Agent::Backend::Hardware::Ports;
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
                if(/dmi type 8,/i){$flag=1; (defined($n))?($n++):($n=0);}
                if((/dmi type (\d+),/i) && ($flag)){($1!='8')?$flag=0:1;}
                if((/^internal reference designator\s*:\s*(.+)/i) && ($flag)) {
                        $h->{'CONTENT'}{'PORTS'}[$n]{'NAME'} = [ $1 ];
                        push @values, ($1);
                };
                if((/^external connector type\s*:\s*(.+)/i) && ($flag)) {
                        $h->{'CONTENT'}{'PORTS'}[$n]{'CAPTION'} = [ $1 ];
                        push @values, ($1);
                };
                if((/^internal connector type\s*:\s*(.+)/i) && ($flag)) {
                        $h->{'CONTENT'}{'PORTS'}[$n]{'DESCRIPTION'} = [ $1 ];
                        push @values, ($1);
                };
                if((/^port type\s*:\s*(.+)/i) && ($flag)) {
                        $h->{'CONTENT'}{'PORTS'}[$n]{'TYPE'} = [ $1 ];
                        push @values, ($1);
                };
        }

}

1;
