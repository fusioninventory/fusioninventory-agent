package Ocsinventory::Agent::Backend::OS::POSIX::Hardware::Drives;
# TODO: move this in Linux if df output is not standard(i think so)
use strict;
sub check {
	my $df = `df -TP`;
	return 1 if $df =~ /\w+/;
	0
}

sub run {

	my $h = shift;
	$h->{'CONTENT'}{'DRIVES'} = [];

	foreach(`df -TP`) { # TODO retrive error
		if(/^(\S+)\s+(\S+)\s+(\S+)\s+(?:\S+)\s+(\S+)\s+(?:\S+)\s+(\S+)\n/){
# no virtual FS
			next if ($1 =~ /^(tmpfs|usbfs|proc|devpts|devshm)$/);
			push @values, ($1,$2,$5);
			push @{$h->{'CONTENT'}{'DRIVES'}}, {
				'TYPE'          => [ $1 ],
					'FILESYSTEM'    => [ $2 ],
					'TOTAL'         => [ sprintf("%i",($3/UNITE)) ],
					'FREE'          => [ sprintf("%i",($4/UNITE)) ],
					'VOLUMN'        => [ $5 ],
			};
		}
	}


}

1;
