package FusionInventory::Agent::Task::Deploy::ActionProcessor::Action::Cmd; 

use strict;
use warnings;

use Data::Dumper;

sub do {
    die unless $_[0]->{exec};

    my @okPattern;
    my @errorPattern;
    my @okCode;
    my @errorCode;
    my %envsSaved;

    if ($_[0]->{okPattern}) {
        @okPattern = @{$_[0]->{okPattern}};
    }
    if ($_[0]->{errorPattern}) {
        @errorPattern = @{$_[0]->{errorPattern}};
    }
    if ($_[0]->{okCode}) {
        @okCode = @{$_[0]->{okCode}};
    }
    if ($_[0]->{errorCode}) {
        @errorCode = @{$_[0]->{errorCode}};
    }

    if ($_[0]->{envs}) {
        foreach my $key (keys %{$_[0]->{envs}}) {
            $envsSaved{$key} = $ENV{$key};
            $ENV{$key} = $_[0]->{envs}{$key};
        }
    }

    my $buf = `$_[0]->{exec} 2>&1`;
    my $exitStatus = $? >> 8;

    my $status;
    my @log;
    if($buf) {
        my @lines = split('\n', $buf);
        foreach my $line (reverse @lines) {
            chomp($line);
            shift @log if @log > 3;
            push @log, $line;

            if (!defined($status)) {
                foreach (@okPattern) {
                    $status = 1 if $line =~ /$_/;
                }
            }
            if (!defined($status)) {
                foreach (@errorPattern) {
                    $status = 0 if $line =~ /$_/;
                }
            }
        }
    }

    if ($exitStatus == 255) { # Failed to start
        $status = 0;
        push @log, 'Failed to start cmd';
    }

    if (!defined($status)) {
        foreach (@okCode) {
            $status = 1 if $exitStatus == $_;
        }
    }
    if (!defined($status)) {
        foreach (@errorCode) {
            $status = 0 if $exitStatus == $_;
        }
    }

    if ($_[0]->{envs}) {
        foreach my $key (keys %envsSaved) {
            $ENV{$key} = $envsSaved{$key};
        }
    }

    return {
        status => $status,
        log => \@log,
    }
}

1;
