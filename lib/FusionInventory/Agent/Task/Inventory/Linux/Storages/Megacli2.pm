package FusionInventory::Agent::Task::Inventory::Linux::Storages::Megacli2;

use strict;
use warnings;

use parent 'FusionInventory::Agent::Task::Inventory::Module';

use File::Basename qw(basename);
use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Linux qw(getInfoFromSmartctl);

use constant RE => qr/^([^:]+?)\s*:\s*(.*\S)/;

sub isEnabled {
    return canRun('megacli') && canRun('smartctl');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    my $count = getFirstMatch(
        command => "megacli -adpCount",
        pattern => qr/Controller Count: (\d+)/
    );
    return unless $count;

    for (my $adp = 0; $adp < $count; $adp++) {
        my $adpinfo = _getAdpPciInfo(adp => $adp);
        my $block = _adpInfoToBlock($adpinfo);
        my $pdlist = _getPDlist(adp => $adp);
        my $ldinfo = _getLDinfo(adp => $adp);

        while (my ($id, $pd) = each %$pdlist) {
            # skip JBOD and Non-RAID
            next if (
                (defined $pd->{__diskgroup} &&
                 defined $ldinfo->{ $pd->{__diskgroup} } &&
                 defined $ldinfo->{ $pd->{__diskgroup} }->{'Number Of Drives'} &&
                 defined $ldinfo->{ $pd->{__diskgroup} }->{'Name'} &&
                 $ldinfo->{ $pd->{__diskgroup} }->{'Number Of Drives'} eq '1' &&
                 $ldinfo->{ $pd->{__diskgroup} }->{'Name'} =~ /NonRAID/)
                    ||
                $pd->{'Firmware state'} =~ /JBOD/
            );

            my $storage = getInfoFromSmartctl(
                device => '/dev/' . $block,
                extra  => '-d megaraid,' . $id);

            $inventory->addEntry(
                section => 'STORAGES',
                entry   => $storage,
            );
        }
    }
}

sub _getPDlist {
    my (%params) = @_;

    $params{command} = defined $params{adp} ? "megacli -pdlist -a$params{adp}" : undef;

    my (%srclist, %pdlist);
    my $n = 0;

    foreach my $line (getAllLines(%params)) {
        next unless $line =~ RE;
        my ($key, $val) = ($1, $2);
        $n++ if $key =~ /Enclosure Device ID/;
        $srclist{$n}->{$key} = $val;
    }

    for my $val (values %srclist) {
        next unless defined $val->{'Device Id'};

        $pdlist{ $val->{'Device Id'} } = $val;

        next unless defined $val->{'Drive\'s position'};
        ($val->{__diskgroup}, $val->{__span}, $val->{__arm}) =
            ($val->{'Drive\'s position'} =~ /DiskGroup: (\d+), Span: (\d+), Arm: (\d+)/);
    }

    return \%pdlist;
}

sub _getLDinfo {
    my (%params) = @_;

    $params{command} = defined $params{adp} ? "megacli -ldinfo -lAll -a$params{adp}" : undef;

    my %ldinfo;
    my $n = -1;

    foreach my $line (getAllLines(%params)) {
        next unless $line =~ RE;
        my ($key, $val) = ($1, $2);

        if ($key eq 'Virtual Drive') {
            ($n) = ($val =~ /^\s*(\d+)/);
        }

        $ldinfo{$n}->{$key} = $val;
    }

    return \%ldinfo;
}

sub _getAdpPciInfo {
    my (%params) = @_;

    $params{command} = defined $params{adp} ? "megacli -AdpGetPciInfo -a$params{adp}" : undef;

    my %adpinfo;
    foreach my $line (getAllLines(%params)) {
        next unless $line =~ RE;
        $adpinfo{$1} = $2;
    }

    return \%adpinfo;
}

sub _adpInfoToBlock {
    my ($adpinfo) = @_;

    my $pciid = sprintf "0000:%02s:%02s.%01s",
        $adpinfo->{'Bus Number'}, $adpinfo->{'Device Number'}, $adpinfo->{'Function Number'};

    my @blocks = glob "/sys/bus/pci/devices/$pciid/host*/target*/*/block/*";

    # return first block device name
    return basename(shift @blocks);
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Task::Inventory::Linux::Storages::Megacli2 - LSI Megaraid inventory

=head1 DESCRIPTION

Provides inventory of megaraid controllers using megacli and smartctl