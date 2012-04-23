package FusionInventory::Agent::Task::Inventory::Input::Linux::RegisteredUser;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

my $seen;

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
        while (my $line = <$handle>) {

            next unless $line =~ /^(\S+)/;

            my @splitted_line = split (/:|\n/,$line);

            my @shadow_line = getshadow(
                user=>$splitted_line[0],
                logger  => $logger
                );

            my $time = time();
            my $date = int ($time/24/3600)-$shadow_line[2];

            my %password_data= (
                PASSWORD_AGE     => $date,
                MINIMUM_AGE      => $shadow_line[3],
                MAXIMUM_AGE      => $shadow_line[4],
                WARNING_PERIOD   => $shadow_line[5],
                INACTIVITY       => $shadow_line[6]
                );

            my $password = treat_datas(
                datas => \%password_data
                );

            my %user_data= (
                NAME                => $splitted_line[0],
                UID                 => $splitted_line[2],
                GID                 => $splitted_line[3],
                PASSWORD            => $password,
                HOMEDIR             => $splitted_line[5],
                COMMAND_INTERPRETER => $splitted_line[6],
                EXPIRATION_DATE     => $shadow_line[7],
                REALNAME            => $splitted_line[4]
                );

            my $user = treat_datas(
                datas => \%user_data
                );

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

sub treat_datas {

    my (%params) = @_;
    my $target;
    my $datas = $params{datas};

    while (my ($key,$value)= each %{$datas}){

        $target= treat_param(
            target => $target,
            key => $key,
            value => $value
            );
    }

    return $target;
}

sub treat_param{

    my (%params) = @_;
    my $target = $params{target};
    my $value = $params{value};
    my $key = $params{key};

   if(defined $value) {
        $target->{$key} = $value unless $value eq '';
    }

    return $target;
}

1;
