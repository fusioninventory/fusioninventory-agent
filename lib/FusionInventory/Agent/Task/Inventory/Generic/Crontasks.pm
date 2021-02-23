package FusionInventory::Agent::Task::Inventory::Generic::Crontasks;

use strict;
use warnings;

use parent 'FusionInventory::Agent::Task::Inventory::Module';

use English qw(-no_match_vars);

use File::Find;

use FusionInventory::Agent::Tools;

sub isEnabled {
    my (%params) = @_;

    # return if $params{no_category}->{crontasks};

    # Not working under win32
    return 0 if $OSNAME eq 'MSWin32';

    return
        canRun('crontab');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my %tasks;

    foreach my $task (_getTasks(logger => $logger)) {
        $inventory->addEntry(
            section => 'CRONTASKS',
            entry   => $task
        );
    }
    foreach my $task (_getUsersTasks(logger => $logger)) {
        $inventory->addEntry(
            section => 'CRONTASKS',
            entry   => $task
        );
    }
}

sub _getTasks {

    my @files;
    my @folders;
    push @files, '/etc/crontab';
    push @folders, '/etc/cron.d';
    if (-d '/etc/cron.daily') {
        push @folders, '/etc/cron.daily';
    }
    if (-d '/etc/cron.hourly') {
        push @folders, '/etc/cron.hourly';
    }
    if (-d '/etc/cron.monthly') {
        push @folders, '/etc/cron.monthly';
    }
    if (-d '/etc/cron.weekly') {
        push @folders, '/etc/cron.weekly';
    }

    my $searchFiles = sub {
        return if (($_ eq '.') || ($_ eq '..'));
        if (-d && $_ eq 'fp') {
            $File::Find::prune = 1;
            return;
        }
        return if (-d);
        push @files, $File::Find::name;
    };

    find($searchFiles, @folders);

    my @tasks;
    foreach my $filename (@files) {

        my (%params) = (
            file => '/etc/crontab',
            @_
        );

        my $handle = getFileHandle((
            file => $filename,
            @_
        ));
        continue unless $handle;

        my $description = '';
        my $pathFound = 0;
        while (my $line = <$handle>) {
            if ($line =~ /^PATH/) {
                $pathFound = 1;
                next;
            }
            next if !$pathFound;
            if ($line =~ /^[#\s*|]$/) {
                $description = '';
                next;
            }
            if ($line =~ /^#\s*\w/) {
                $description .= substr($line, 1);
            } else {
                my @args = split(/\s+/, $line, 7);
                push @tasks, {
                    NAME              => $args[6],
                    DESCRIPTION       => trimWhitespace($description),
                    COMMAND           => $args[6],
                    EXECUTION_MONTH   => $args[3],
                    EXECUTION_DAY     => $args[2],
                    EXECUTION_HOUR    => $args[1],
                    EXECUTION_MINUTE  => $args[0],
                    EXECUTION_WEEKDAY => $args[4],
                    USER_EXECUTION    => $args[5],
                    STORAGE           => $filename,
                    USER_STORAGE      => 'system',
                    STATUS            => 1
                };
            }
        }
        close $handle;
    }
    return @tasks;
}

sub _getUsersTasks {
    my (%params) = @_;

    my $logger    = $params{logger};

    my @tasks;
    foreach my $user (FusionInventory::Agent::Task::Inventory::Generic::Users::_getLocalUsers(logger => $logger)) {

        my $handle = getFileHandle((
            command => 'crontab -u '.$user->{LOGIN}.' -l',
            @_
        ));
        continue unless $handle;

        my $description = '';
        while (my $line = <$handle>) {
            $line =~ s/\R//g;
            if ($line =~ /^[#\s*|]$/) {
                $description = '';
                next;
            }
            if ($line =~ /^#\s*\w/) {
                $description .= substr($line, 1);
            } else {
                my @args = split(/\s+/, $line, 6);
                push @tasks, {
                    NAME              => $args[5],
                    DESCRIPTION       => trimWhitespace($description),
                    COMMAND           => $args[5],
                    EXECUTION_MONTH   => $args[3],
                    EXECUTION_DAY     => $args[2],
                    EXECUTION_HOUR    => $args[1],
                    EXECUTION_MINUTE  => $args[0],
                    EXECUTION_WEEKDAY => $args[4],
                    USER_EXECUTION    => $user->{LOGIN},
                    STORAGE           => $user->{LOGIN},
                    USER_STORAGE      => 'user',
                    STATUS            => 1
                };
            }
        }
        close $handle;
    }
    return @tasks;
}
1;
