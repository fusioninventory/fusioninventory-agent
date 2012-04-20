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
        command => 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -command "([ADSI]\\"WinNT://localhost,computer\\" ).psbase.Children | ?{ $_.psbase.schemaclassname -eq \'user\' } | Format-List *"'
    );
    my @users;

    if ($handle) {
	
	my @users; 
	my $user;
	while(my $line=<$handle>){
	    if ($line =~ /^\n/) {
		push @users,$user;
		$user=();
	    }
	    elsif   ($line =~ m/^PasswordAge\s+:\s{(.+)}/){
		my $age = int $1/24/3600;
		$user->{PASSWORD}->{AGE} = $age;
		print ("$age\n");
	    } 
	    elsif   ($line =~ m/^FullName\s+:\s{(.+)}/){
		$user->{REALNAME} = $1;
		print ("$1\n");
	    }
	     elsif   ($line =~ m/^ HomeDirectory\s+:\s{(.+)}/){
		$user->{HOMEDIR} = $1;
		print ("$1\n");
	    }
	    elsif   ($line =~ m/^LoginScript\s+:\s{(.+)}/){
		$user->{COMMAND_INTERPRETER} = $1;
		print ("$1\n");
	    }
	    elsif   ($line =~ m/^Name\s+:\s{(.+)}/){
		$user->{NAME} = $1;
		print ("$1\n");
	    }
	    elsif   ($line =~ m/^MaxPasswordAge\s+:\s{(.+)}/){
		my $age = int $1/24/3600;
		$user->{PASSWORD}->{MAXIMUM_AGE} = $age;
		print ("$age\n");
	    }
	    elsif   ($line =~ m/^MinPasswordAge\s+:\s{(.+)}/){
		my $age = int $1/24/3600;
		$user->{PASSWORD}->{MINIMUM_AGE} = $age;
		print ("$age\n");
	    }	
	    elsif   ($line =~ m/^Path\s+:\sWinNT:\/\/(.+)\/.*\/.*/){
		$user->{REALM} = $1;
		print ("$1\n");
	    }
	}
	my $registered = { USER => \@users};  

	$inventory->addEntry(
            section => 'REGISTERED_USERS',
            entry   => $registered
            );
	close $handle;
    }
}

1;

=com
lane is MaxPasswordAge             : {3628800}
lane is MinPasswordAge             : {0}
lane is Path                       : WinNT://WORKGROUP/localhost/useraaaaaaaaaaa
aaaaa
=cut	   

