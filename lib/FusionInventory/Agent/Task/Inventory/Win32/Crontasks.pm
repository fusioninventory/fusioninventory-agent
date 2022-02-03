package FusionInventory::Agent::Task::Inventory::Win32::Crontasks;

use strict;
use warnings;

use parent 'FusionInventory::Agent::Task::Inventory::Module';

use English qw(-no_match_vars);

use File::Find;
use XML::XPath;
use XML::XPath::XMLParser;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Win32;

sub isEnabled {
    my (%params) = @_;
    return 1;
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

}

sub _getTasks {

    my @files;

    my $searchFiles = sub {
        return if (($_ eq '.') || ($_ eq '..'));
        if (-d && $_ eq 'fp') {
            $File::Find::prune = 1;
            return;
        }
        return if (-d);
        push @files, $File::Find::name;
    };

    find($searchFiles, 'C:\Windows\System32\Tasks');

    my @tasks;
    foreach my $filename (@files) {
        my $xp = XML::XPath->new(filename => $filename);
        my @path = split(/\//, $filename);

        my $completeCommand = '';
        my $nodes = $xp->findnodes('/Task/Actions/Exec');
        foreach my $node ($nodes->get_nodelist) {
            if ($completeCommand ne '') {
                $completeCommand .= ' && ';
            }
            my $command = $node->find('Command')->string_value;
            my $arguments = $node->find('Arguments')->string_value;
            my $workingDir = $node->find('WorkingDirectory')->string_value;
            if ($workingDir ne '') {
                $completeCommand .= $workingDir.' && ';
            }
            if ($command ne '') {
                $completeCommand .= $command;
            }
            if ($arguments ne '') {
                $completeCommand .= ' '.$arguments;
            }
        }

        my $executionMinute = '';
        my $executionHour = '';
        my $executionDay = '';
        my $executionMonth = '';
        my $executionWeekday = '';

        my $triggers = $xp->findnodes('/Task/Triggers/CalendarTrigger');
        foreach my $trigger ($triggers->get_nodelist) {
            my $interval = $trigger->find('Repetition/Interval')->string_value;
            my $daysInterval = $trigger->find('ScheduleByDay/DaysInterval')->string_value;
            my $startDate = $trigger->find('StartBoundary')->string_value;

            if ($interval =~ /(\w+)(\d+)(\w+)/) {
                if ($3 eq 'M') {
                    $executionMinute = '*/'.$2;
                    $executionHour = '*';
                    $executionDay = '*';
                    $executionMonth = '*';
                    $executionWeekday = '*';
                } elsif ($3 eq 'H') {
                    $executionMinute = '0';
                    $executionHour = '*/'.$2;
                    $executionDay = '*';
                    $executionMonth = '*';
                    $executionWeekday = '*';
                } elsif ($3 eq 'D') {
                    $executionMinute = '0';
                    $executionHour = '0';
                    $executionDay = '*/'.$2;
                    $executionMonth = '*';
                    $executionWeekday = '*';
                }
            } else {
                # no interval, so get the start hour
                if ($startDate =~ /T(\d{2}):(\d{2})/) {
                    $executionMinute = ($2 + 0);
                    $executionHour = ($1 + 0);
                }
            }
            if ($trigger->find('ScheduleByDay')) {
                $executionDay = '*/'.$trigger->find('ScheduleByDay/DaysInterval')->string_value;
            }
            if ($trigger->find('DaysOfWeek')) {
                my @wdays;
                if ($trigger->find('DaysOfWeek/Sunday')) {
                    push(@wdays, 0);
                }
                if ($trigger->find('DaysOfWeek/Monday')) {
                    push(@wdays, 1);
                }
                if ($trigger->find('DaysOfWeek/Tuesday')) {
                    push(@wdays, 2);
                }
                if ($trigger->find('DaysOfWeek/Wednesday')) {
                    push(@wdays, 3);
                }
                if ($trigger->find('DaysOfWeek/Thursday')) {
                    push(@wdays, 4);
                }
                if ($trigger->find('DaysOfWeek/Friday')) {
                    push(@wdays, 5);
                }
                if ($trigger->find('DaysOfWeek/Saturday')) {
                    push(@wdays, 6);
                }
                $executionWeekday = join(",", @wdays);
            }
            if ($trigger->find('ScheduleByMonth')) {
                if ($trigger->find('ScheduleByMonth/DaysOfMonth')) {
                    my @wdays;
                    my $daysOfMonth = $trigger->findnodes('ScheduleByMonth/DaysOfMonth');
                    foreach my $day ($daysOfMonth->get_nodelist) {
                        push(@wdays, $day->string_value);
                    }
                    $executionDay = join(",", @wdays);
                }
                if ($trigger->find('ScheduleByMonth/Months')) {
                    my @months;
                    my $byMonths = $trigger->findnodes('ScheduleByMonth/Months');
                    if ($trigger->find('ScheduleByMonth/Months/January')) {
                        push(@months, 1);
                    }
                    if ($trigger->find('ScheduleByMonth/Months/February')) {
                        push(@months, 2);
                    }
                    if ($trigger->find('ScheduleByMonth/Months/March')) {
                        push(@months, 3);
                    }
                    if ($trigger->find('ScheduleByMonth/Months/April')) {
                        push(@months, 4);
                    }
                    if ($trigger->find('ScheduleByMonth/Months/May')) {
                        push(@months, 5);
                    }
                    if ($trigger->find('ScheduleByMonth/Months/June')) {
                        push(@months, 6);
                    }
                    if ($trigger->find('ScheduleByMonth/Months/July')) {
                        push(@months, 7);
                    }
                    if ($trigger->find('ScheduleByMonth/Months/August')) {
                        push(@months, 8);
                    }
                    if ($trigger->find('ScheduleByMonth/Months/September')) {
                        push(@months, 9);
                    }
                    if ($trigger->find('ScheduleByMonth/Months/October')) {
                        push(@months, 10);
                    }
                    if ($trigger->find('ScheduleByMonth/Months/November')) {
                        push(@months, 11);
                    }
                    if ($trigger->find('ScheduleByMonth/Months/December')) {
                        push(@months, 12);
                    }
                    $executionMonth = join(",", @months);
                }
            }
        }
        # Replace */1 in * (more simple to read)
        if ($executionMonth eq '*/1') {
            $executionMonth = '*';
        }
        if ($executionDay eq '*/1') {
            $executionDay = '*';
        }
        if ($executionHour eq '*/1') {
            $executionHour = '*';
        }
        if ($executionMinute eq '*/1') {
            $executionMinute = '*';
        }
        if ($executionWeekday eq '*/1') {
            $executionWeekday = '*';
        }
        my $status = 1;
        if ($xp->find('/Task/Settings/Enabled')->string_value ne 'true') {
            $status = 0;
        }


        push @tasks, {
            NAME              => $path[-1],
            DESCRIPTION       => $xp->find('/Task/RegistrationInfo/Description')->string_value,
            COMMAND           => $completeCommand,
            EXECUTION_MONTH   => $executionMonth,
            EXECUTION_DAY     => $executionDay,
            EXECUTION_HOUR    => $executionHour,
            EXECUTION_MINUTE  => $executionMinute,
            EXECUTION_WEEKDAY => $executionWeekday,
            USER_EXECUTION    => $xp->find('/Task/Principals/Principal/UserId')->string_value,
            STORAGE           => $filename,
            USER_STORAGE      => $xp->find('/Task/RegistrationInfo/Author')->string_value,
            STATUS            => $status
        };
    }

    return @tasks;
}
1;
