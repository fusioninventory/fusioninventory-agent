package FusionInventory::Agent::Task::Inventory::OS::Solaris::Slots;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Solaris;

sub isInventoryEnabled {
    return can_run('prtdiag');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger = $params{logger};

    my $class = getClass();

    my @slots = 
        $class == 4 ? _getSlots4(logger => $logger, command => 'prtdiag') :
        $class == 5 ? _getSlots5(logger => $logger, command => 'prtdiag') :
                      _getSlotsDefault(logger => $logger, command => 'prtdiag') ;

    foreach my $slot (@slots) {
        $inventory->addSlot($slot);
    }
}

sub _getSlots4 {

    my $handle  = getFileHandle(@_);
    return unless $handle;

    my @slots;

    while (<$handle>) {
        next unless /pci/;
        my @pci = split(/ +/);
        push @slots, {
            DESCRIPTION => $pci[0] . " (" . $pci[1] . ")",
            DESIGNATION => $pci[3],
            NAME        => $pci[4] . " " . $pci[5],
        };
    }
    close $handle;

    return @slots;
}

sub _getSlots5 {

    my $handle  = getFileHandle(@_);
    return unless $handle;

    my @slots;
    my $flag;
    my $flag_pci;
    my $name;
    my $description;
    my $designation;
    my $status;

    while (<$handle>) {
        last if /^\=+/ && $flag_pci && $flag;

        if (/^=+\S+\s+IO Cards/) {
            $flag_pci = 1;
        }
        if ($flag_pci && /^-+/) {
            $flag = 1;
        }

        next unless $flag && $flag_pci;

        if (/^\s+(\d+)/){
            $name = "LSB " . $1;
        }
        if(/^\s+\S+\s+(\S+)/){
            $description = $1;
        }
        if(/^\s+\S+\s+\S+\s+(\S+)/){
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

    my $handle  = getFileHandle(@_);
    return unless $handle;

    my @slots;
    my $flag;
    my $flag_pci;
    my $name;
    my $description;
    my $designation;
    my $status;

    while (<$handle>) {
        last if /^\=+/ && $flag_pci;
        next if /^\s+/ && $flag_pci;
        if (/^=+\s+IO Cards/) {
            $flag_pci = 1;
        }
        if ($flag_pci && /^-+/) {
            $flag = 1;
        }

        next unless $flag && $flag_pci;

        if(/^(\S+)\s+/){
            $name = $1;
        }
        if(/(\S+)\s*$/){
            $designation = $1;
        }
        if(/^\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+(\S+)/){
            $description = $1;
        }
        if(/^\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+(\S+)/){
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
