package FusionInventory::Agent::Task::Deploy::ActionProcessor::Action::Cmd; 

use IPC::Open3;
use Data::Dumper;
use POSIX ":sys_wait_h";
use IO::Select;

sub do {
    print Dumper(\@_);
    die unless @{$_[0]->{exec}};

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
                print "KEY $key == ".$_[0]->{envs}{$key}."\n";
        }
    }

    my $pid = open3(undef, \*READ,\*ERROR, @{$_[0]->{exec}});

    my $sel = new IO::Select();

    $sel->add(\*READ);
    $sel->add(\*ERROR);

    my($error,$answer)=('','');


    my $status;
    my $exitStatus;
    my @log;
    while(1){

        foreach my $h ($sel->can_read)
        {
            my $buf = '';
            sysread($h,$buf,4096);
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
        }
        my $t = waitpid($pid, WNOHANG);
        $exitStatus = $? >> 8;
        last if $t == $pid or $t == -1;
    }

    if ($exitStatus == 255) { # Failed to start
        $status = 0;
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

    print Dumper(\@log);

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
