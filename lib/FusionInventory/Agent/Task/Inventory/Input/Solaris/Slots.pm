package FusionInventory::Agent::Task::Inventory::Input::Solaris::Slots;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Solaris;

sub isEnabled {
    return canRun('prtdiag');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $class = getClass();

    my @slots =
        $class == SOLARIS_ENTERPRISE_T ? _getSlots4(logger => $logger) :
        $class == SOLARIS_ENTERPRISE   ? _getSlots5(logger => $logger) :
                                         _getSlotsDefault(logger => $logger);

    foreach my $slot (@slots) {
        $inventory->addEntry(
            section => 'SLOTS',
            entry   => $slot
        );
    }
}

sub _getSlots4 {
    my (%params) = (
        command => 'prtdiag',
        @_
    );

    my $handle  = getFileHandle(%params);
    return unless $handle;

    my @slots;

    while (my $line = <$handle>) {
        next unless $line =~ /^(\S+) \s+ PCI[EX] \s+ (\S+) (?:\s+ (\S+))?/x;
        push @slots, {
            NAME        => $1,
            DESIGNATION => $2,
            DESCRIPTION => $3
        };
    }
    close $handle;

    return @slots;
}

sub _getSlots5 {
    my (%params) = (
        command => 'prtdiag',
        @_
    );

    my $handle  = getFileHandle(%params);
    return unless $handle;

    my @slots;
    my $flag;
    my $flag_pci;
    my $name;
    my $description;
    my $designation;

    while (my $line = <$handle>) {
        last if $line =~ /^\=+/ && $flag_pci && $flag;

        if ($line =~ /^=+\S+\s+IO Cards/) {
            $flag_pci = 1;
        }
        if ($flag_pci && $line =~ /^-+/) {
            $flag = 1;
        }

        next unless $flag && $flag_pci;

        if ($line =~ /^\s+(\d+)/) {
            $name = "LSB " . $1;
        }
        if ($line =~ /^\s+\S+\s+(\S+)/) {
            $description = $1;
        }
        if ($line =~ /^\s+\S+\s+\S+\s+(\S+)/) {
            $designation = $1;
        }

        push @slots, {
            DESCRIPTION => $description,
            DESIGNATION => $designation,
            NAME        => $name,
        }
    }
    close $handle;

    return @slots;
}

sub _getSlotsDefault {
    my (%params) = (
        command => 'prtdiag',
        @_
    );

    my $handle = getFileHandle(%params);
    return unless $handle;

    my @slots;
    my $flag;
    my $flag_pci;
    my $name;
    my $description;
    my $designation;
    my $status;

    while (my $line = <$handle>) {
        last if $line =~ /^\=+/ && $flag_pci;
        next if $line =~ /^\s+/ && $flag_pci;
        if ($line =~ /^=+\s+IO Cards/) {
            $flag_pci = 1;
        }
        if ($flag_pci && $line =~ /^-+/) {
            $flag = 1;
        }

        next unless $flag && $flag_pci;

        if ($line =~ /^(\S+)\s+/){
            $name = $1;
        }
        if ($line =~ /(\S+)\s*$/){
            $designation = $1;
        }
        if ($line =~ /^\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+(\S+)/) {
            $description = $1;
        }
        if ($line =~ /^\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+(\S+)/) {
            $status = $1;
        }
        push @slots, {
            DESCRIPTION => $description,
            DESIGNATION => $designation,
            NAME        => $name,
            STATUS      => $status,
        }
    }
    close $handle;

    return @slots;
}

1;
