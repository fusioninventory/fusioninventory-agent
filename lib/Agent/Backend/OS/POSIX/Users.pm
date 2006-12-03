package Ocsinventory::Agent::Backend::OS::POSIX::Users;

sub check {
# Useless check for a posix system i guess
	my @who = `who 2>/dev/null`;
	return 1 if @who;
	return;
}

# Initialise the distro entry
sub run {
	my $h = shift;

	my %user;
        # Logged on users
        for(`who`){
                $user{$1} = 1 if /^(\S+)./;
        }

	my $UsersLoggedIn = join "/", keys %user;


	$h->{'CONTENT'}{'HARDWARE'}{'USERID'} = [$UsersLoggedIn];

}



1;
