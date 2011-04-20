package FusionInventory::Agent::Task::Inventory::OS::AIX::CPU;

use strict;
use warnings;

sub isInventoryEnabled {
    return 1;
}


sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    foreach my $cpu (_getCPUs(
        command => 'lsdev -Cc processor -F name',
        logger  => $logger
    )) {
        $inventory->addCPU($cpu);
    }
}

sub _getCPUs {
    my $handle = getFileHandle(@_);
    return unless $handle;

    my $aixversion = getFirstLine(command => 'uname -v');

    my @cpus;
    while (my $line = <$handle>) {
        chomp $line;
        my $device = $line;

        my $thread = 1;
        if ($aixversion < 5) {
            $thread = getFirstMatch(
                command => "lsattr -EOl $device -a 'state:type:smt_threads'",
                pattern => qr/:(\d+)$/
            );
        }

        my @lsattr = $aixversion < 5 ?
            _lsattr($device) :
            getAllLines(
                command => "lsattr -EOl $device -a 'state:type:frequency'"
            );

        my $name;
        my $frequency;
        my $core = 0;
        foreach my $attr (@lsattr) {
            next if $attr =~ /^#/;
            next unless $attr =~ /(.+):(.+):(.+)/;
            $core++;
            $frequency = ($3 % 1000000) >= 50000 ? 
                int($3 / 1000000) + 1 : int($3 / 1000000);
            $name = $2;
            $name =~ s/_/ /;
        }

        push @cpus, {
            NAME   => $name,
            SPEED  => $frequency,
            CORE   => $core,
            THREAD => $thread
        };
    }
    close $handle;

    return @cpus;
}

# try to simulate a modern lsattr output on AIX4
sub _lsattr {
    my ($device) = @_;

    my $handle = getFileHandle(
        command => "lsattr -EOl $device -a 'state:type'",
    );
    return unless $handle;

    my @lsattr;
    while (my $line = <$handle>) {
        chomp $line;
        my (undef, $type) = split(/:/, $line);

        my $frequency;
        # On older models, frequency is based on cpu model and uname
        SWITCH: {
            if (
                $type eq "PowerPC"     or
                $type eq "PowerPC_601" or
                $type eq "PowerPC_604"
            ) {
                my $uname = getFirstLine(command => 'uname -m');
                $frequency =
                    $uname =~ /E1D|EAD|C1D|R04|C4D|R4D/ ?  11200000 :
                    $uname =~ /34M/                     ? 133000000 :
                    $uname =~ /N4D/                     ? 150000000 :
                    $uname =~ /X4M|X4D/                 ? 200000000 :
                    $uname =~ /N4E|K04|K44/             ? 225000000 :
                    $uname =~ /N4F/                     ? 320000000 :
                    $uname =~ /K45/                     ? 360000000 :
                                                          undef     ;
                last SWITCH;
            }

            if ($type eq "PowerPC_RS64_III") {
                $frequency = 400000000;
                last SWITCH;
            }

            if ($type eq "PowerPC_620") {
                $frequency = 172000000;
                last SWITCH;
            }

            $frequency = 225000000;
        }

        push @lsattr, "$device:$frequency\n";
    }

    return @lsattr;
}

1;
