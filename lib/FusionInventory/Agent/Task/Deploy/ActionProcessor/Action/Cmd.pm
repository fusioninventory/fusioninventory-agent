package FusionInventory::Agent::Task::Deploy::ActionProcessor::Action::Cmd;

use strict;
use warnings;

sub _evaluateRet {
    my ($retChecks, $buf, $exitStatus) = @_;

use Data::Dumper;
print Dumper($retChecks);
print Dumper($exitStatus);

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

    my $buf = `$params->{exec} 2>&1` || '';
    my $errMsg = $!;
    $logger->debug("Run: ".$buf);
    my $exitStatus = $? >> 8;
    $logger->debug("exitStatus: ".$exitStatus);;

    my @retChecks;

    my $logLineLimit =  $params->{logLineLimit} || 3;

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
