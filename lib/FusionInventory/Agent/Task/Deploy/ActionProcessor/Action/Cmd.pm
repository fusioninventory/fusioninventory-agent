package FusionInventory::Agent::Task::Deploy::ActionProcessor::Action::Cmd;

use strict;
use warnings;

use Data::Dumper;

sub _evaluateRet {
    my ($retChecks, $log, $exitStatus) = @_;

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
                if ($$log =~ /$_/) {
                    return [ 1, "ok pattern found in log: /$_/" ];
                }
            }
        } elsif ($retCheck->{type} eq 'errorCode') {
            foreach (@{$retCheck->{values}}) {
                if ($exitStatus != $_) {
                    return [ 1, "exit status is not ok: `$_'" ];
                }
            }
        } elsif ($retCheck->{type} eq 'errorPattern') {
            foreach (@{$retCheck->{values}}) {
                next unless length($_);
                if ($$log =~ /$_/) {
                    return [ 0, "error pattern found in log: /$_/" ];
                }
            }
        }
    }
}

sub do {
    die unless $_[0]->{exec};
    print Dumper( $_[0]);

    my %envsSaved;


    if ($_[0]->{envs}) {
        foreach my $key (keys %{$_[0]->{envs}}) {
            $envsSaved{$key} = $ENV{$key};
            $ENV{$key} = $_[0]->{envs}{$key};
        }
    }

    my $buf = `$_[0]->{exec} 2>&1`;
    print "Run: ".$buf."\n";
    my $exitStatus = $? >> 8;

    my @retChecks;

    my @log;
    if($buf) {
        my @lines = split('\n', $buf);
        foreach my $line (reverse @lines) {
            chomp($line);
            shift @log if @log > 3;
            push @log, $line;
        }
    }

# Use the retChecks key to know if the command exec is successful
    my $t = _evaluateRet ($_[0]->{retChecks}, \$buf, $exitStatus);

    my $status = $t->[0];
    push @log, "--------------------------------";
    push @log, "exit status: `$exitStatus'";
    push @log, $t->[1];






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
