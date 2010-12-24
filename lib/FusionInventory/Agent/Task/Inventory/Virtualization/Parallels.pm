package FusionInventory::Agent::Task::Inventory::Virtualization::Parallels;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    my $params = shift;

    # We don't want to scan user directories unless --scan-homedirs is used
    return 
        can_run('prlctl') &&
        $params->{config}->{'scan-homedirs'};
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    foreach my $user ( glob("/Users/*") ) {
        $user =~ s/.*\///; # Just keep the login
        next if $user =~ /Shared/i;
        next if $user =~ /^\./i; # skip hidden directory
        next if $user =~ /\ /;   # skip directory containing space
        next if $user =~ /'/;    # skip directory containing quote


        foreach my $machine (_parsePrlctlA(
                logger  => $logger,
                command => "su '$user' -c 'prlctl list -a'"
        )) {

            ($machine->{MEMORY}, $machine->{VCPU}) =
                _parsePrlctlA(
                    logger  => $logger,
                    command => "su '$user' -c 'prlctl list -i $machine->{UUID}'"
                );

            $inventory->addVirtualMachine($machine);
        }
    }
}

sub _parsePrlctlA {
    my $handle = getFileHandle(@_);

    return unless $handle;

    # get headers line first
    my $line = <$handle>;

    my @machines;
    foreach my $line (<$handle>) {
        chomp $line; 
        my @info = split(/\s+/, $line);
        my $uuid   = $info[0];
        my $status = $info[1];
        my $name   = $info[3];

        # Avoid security risk. Should never appends
        next if $uuid =~ /(;\||&)/;

        push @machines, {
            NAME      => $name,
            UUID      => $uuid,
            STATUS    => $status,
            SUBSYSTEM => "Parallels",
            VMTYPE    => "Parallels",
        };
    }

    close $handle;

    return @machines;
}

sub _parsePrlctlI {
    my $handle = getFileHandle(@_);

    my ($mem, $cpus);
    while (my $line = <$handle>) {
        if ($line =~ m/^\s\smemory\s(.*)Mb/) {
            $mem = $1;
        }
        if ($line =~ m/^\s\scpu\s(\d{1,2})/) {
            $cpus = $1;
        }
    }

    close $handle;

    return ($mem, $cpus);
}

1;
