package FusionInventory::Agent::Task::Inventory::Input::Linux::RegisteredUser;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

my $seen;

# inventory is enabled if you can read /etc/passwd
sub isEnabled {
    return
        canRead("/etc/passwd");
}



sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $handle = getFileHandle(
        logger  => $logger,
        file => '/etc/passwd'
    );
    my @users;

    if ($handle) {
# read /etc/passwd until last line
        while (my $line = <$handle>) {

            next unless $line =~ /^(\S+)/;

            my @splitted_line = split (/:|\n/,$line);

            # process password information
            my @shadow_line = getpasswordinfo(
                user=>$splitted_line[0],
                logger  => $logger
                );


           # process password age (number of days since creation)
            my $time = time();
            my $passwordAge = int ($time/24/3600)-$shadow_line[2];

            # password information hash datas
            my %password_data= (
                PASSWORD_AGE     => $passwordAge,
                MINIMUM_AGE      => $shadow_line[3],
                MAXIMUM_AGE      => $shadow_line[4],
                WARNING_PERIOD   => $shadow_line[5],
                INACTIVITY       => $shadow_line[6]
                );

            my $password = treat_datas(
                datas => \%password_data
                );

            # process information on user
            my @info_line = split (/,/,$splitted_line[4]);

            # user information hash
            my %personnal_info = (
                FULLNAME => $info_line[0],
                ADDRESS => $info_line[1],
                PHONE => $info_line[2],
                OTHER => $info_line[3]
                );


            my $info = treat_datas(
                datas => \%personnal_info
                );


            # user data
            my %user_data= (
                NAME                => $splitted_line[0],
                UID                 => $splitted_line[2],
                GID                 => $splitted_line[3],
                PASSWORD            => $password,
                HOMEDIR             => $splitted_line[5],
                COMMAND_INTERPRETER => $splitted_line[6],
                EXPIRATION_DATE     => $shadow_line[7],
                INFORMATION         => $info
                );

            my $user = treat_datas(
                datas => \%user_data
                );

            #add that user into array
            push @users,$user;
        }

        my $registered = { USER => \@users};

        $inventory->addEntry(
            section => 'REGISTERED_USERS',
            entry   => $registered
            );
    }
    close $handle;
}


# give information about password in /etc/shadow for a given user
sub getshadow{

    my (%params) = @_;
    my $user = $params{user};
    my $logger = $params{logger};
    my @shadow_line;
    my $shadow = getFileHandle(
        logger  => $logger,
        file => '/etc/shadow'
        );

    while (my $line = <$shadow>) {

     @shadow_line = split (/:|\n/,$line);

     if ($shadow_line[0] eq $user) {
        return @shadow_line;
     }
    }

    return undef;
}

# Remove empty value is hash
sub treat_datas {

    my (%params) = @_;
    my $target;
    my $datas = $params{datas};

    while (my ($key,$value)= each %{$datas}){

        if(defined $value) {
            $target->{$key} = $value unless $value eq '';
        }

   }

    return $target;
}

1;
