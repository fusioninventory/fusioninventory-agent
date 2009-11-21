package Ocsinventory::Agent::Data;

sub save {
    my $config = shift;

	print "SAVE CONFIG IN:". $config->{'vardir'}."/config.dump\n";
	store ($config, $config->{'vardir'}.'/config.dump') or die;

}

sub restore {
    my $config = shift;

    my ($vardir) = @ARGV;

    my $file = "$vardir/config.dump";
	print "RESTORE CONFIG FROM: $file\n";
    if (-f $file) {
        return retrieve($file);
    }

}


1;
