package FusionInventory::Agent::Task::Deploy::ActionProcessor::Action::Cmd;

use strict;
use warnings;

use Fcntl qw(SEEK_END);
use UNIVERSAL::require;

use English qw(-no_match_vars);

sub _evaluateRet {
    my ($retChecks, $buf, $exitStatus) = @_;

    if (ref($retChecks) ne 'ARRAY') {
        return [ 1, 'ok, no check to evaluate.' ];
    }

    foreach my $retCheck (@$retChecks) {

        if ($retCheck->{type} eq 'okCode') {
            foreach (@{$retCheck->{values}}) {
                if ($exitStatus == $_) {
                    return [ 1, "exit status is ok: $_" ];
                }
            }
        } elsif ($retCheck->{type} eq 'okPattern') {
            foreach (@{$retCheck->{values}}) {
                next unless length($_);
                if ($$buf =~ /$_/) {
                    return [ 1, "ok pattern found in log: /$_/" ];
                }
            }
        } elsif ($retCheck->{type} eq 'errorCode') {
            foreach (@{$retCheck->{values}}) {
                if ($exitStatus == $_) {
                    return [ 0, "exit status is not ok: `$_'" ];
                }
            }
        } elsif ($retCheck->{type} eq 'errorPattern') {
            foreach (@{$retCheck->{values}}) {
                next unless length($_);
                if ($$buf =~ /$_/) {
                    return [ 0, "error pattern found in log: /$_/" ];
                }
            }
        }
    }
    return [ 0, '' ];
}

sub runOnUnix {
    my ($params, $logger) = @_;

    my $buf = `$params->{exec} 2>&1` || '';
    my $errMsg = $ERRNO;
    $logger->debug("Run: ".$buf);
    my $exitStatus = $CHILD_ERROR >> 8;
    $logger->debug("exitStatus: ".$exitStatus);

    return ($buf, $errMsg, $exitStatus);
}

sub runOnWindows {
    my ($params) = @_;

    FusionInventory::Agent::Tools::Win32->require;

    my ($exitcode, $fd) = FusionInventory::Agent::Tools::Win32::runCommand(
        command => $params->{exec}
    );


    $fd->seek(-2000, SEEK_END);

    my $buf;
    while(my $line = readline($fd)) {
        $buf .= $line;
    }

    my $errMsg;
    if ($exitcode eq '293') {
        $errMsg = "timeout";
    }


    return ($buf, $errMsg, $exitcode);
}


sub do {
    my ($params, $logger) = @_;
    return { 0, ["Internal agent error"]} unless $params->{exec};

    my %envsSaved;


    if ($params->{envs}) {
        foreach my $key (keys %{$params->{envs}}) {
            $envsSaved{$key} = $ENV{$key};
            $ENV{$key} = $params->{envs}{$key};
        }
    }

    my $buf;
    my $errMsg;
    my $exitStatus;


    if ($OSNAME eq 'MSWin32') {
        ($buf, $errMsg, $exitStatus) = runOnWindows(@_);
    } else {
        ($buf, $errMsg, $exitStatus) = runOnUnix(@_);
    }

    my $logLineLimit =  $params->{logLineLimit} || 10;

    my @msg;
    if($buf) {
        my @lines = split('\n', $buf);
        foreach my $line (reverse @lines) {
            chomp($line);
            shift @msg if @msg > $logLineLimit;
            unshift @msg, $line;
        }
    }
    shift @msg if @msg > $logLineLimit;

# Use the retChecks key to know if the command exec is successful
    my $t = _evaluateRet ($params->{retChecks}, \$buf, $exitStatus);

    my $status = $t->[0];
    push @msg, "--------------------------------";
    push @msg, "error msg: `$errMsg'" if $errMsg;
    push @msg, "exit status: `$exitStatus'";
    push @msg, $t->[1];

    foreach (@msg) {
        $logger->debug($_);
    }
    $logger->debug("exitStatus: ".$exitStatus);;

    if ($params->{envs}) {
        foreach my $key (keys %envsSaved) {
            $ENV{$key} = $envsSaved{$key};
        }
    }

    return {
        status => $status,
        msg => \@msg,
    }
}

1;
