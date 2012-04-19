package FusionInventory::Agent::Task::Inventory::Input::Win32::RegisteredUser;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

my $seen;

sub isEnabled {
    return
        1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $handle = getFileHandle(
        logger  => $logger,
        command => 'net user'
    );
    my @users;

    if ($handle) {

	for (my $i = 0;$i<4; $i++){
	    <$handle>;
	}
	my $line1=<$handle>;
	my $line2=<$handle>;
	my $line3=<$handle>;
	my @users;
	do {
	   my @splitted = split " ", $line1;
	   push @users, @splitted;
	    print "@users\n";
	    $line1=$line2;
	    $line2=$line3
	    
	}
        while ($line3 = <$handle>);

	foreach my $user (@users){
	    chomp $user;
	    print $user;
	    my $handle_user = getFileHandle(
		logger  => $logger,
		command => "net user $user"
		);

	    <$handle_user>;
	    my $realname= <$handle_user>;
	    my @real= (split /\s{2,}/, $realname);
	    print "real is $real[1]\n";
	    chomp $realname;
	     <$handle_user>; <$handle_user>; <$handle_user>; <$handle_user>;
	    my $expiration =  <$handle_user>;
	    my @expi = (split /\s{2,}/, $expiration);
	    print "expi is $expi[1]\n";
	    <$handle_user>;
	    chomp $expiration;
	    my $last= (split /\s{2,}/,<$handle_user>)[1];
	    chomp $last;
	    my $max= (split /\s{2,}/,<$handle_user> )[1] ;
	    chomp $max;
	    my $min = (split /\s{2,}/,<$handle_user> )[1] ;
	    chomp $min;
	     <$handle_user>; <$handle_user>; <$handle_user>;<$handle_user>;
	    my $script = (split /\s{2,}/,<$handle_user> )[1] ;
	    chomp $script;
	    <$handle_user>;
	   my $homedir =  (split /\s{2,}/,<$handle_user>)[1];
	    chomp $homedir;
	    print("$realname\n$expiration\n$last\n$max\n$min\n$script\n$homedir\n");
	}
    }
    close $handle;
}

1;
