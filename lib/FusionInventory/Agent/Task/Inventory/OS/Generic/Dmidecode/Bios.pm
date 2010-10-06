package FusionInventory::Agent::Task::Inventory::OS::Generic::Dmidecode::Bios;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return 1;
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};
    my $logger    = $params->{logger};

    my ($bios, $hardware) = _getBiosHardware($logger);

    $inventory->setBios($bios) if $bios;
    $inventory->setHardware($hardware) if $hardware;
}

sub _getBiosHardware {
    my ($logger, $file) = @_;

    my $infos = getInfosFromDmidecode($logger, $file);
    my $bios_info    = $infos->{0}->[0];
    my $system_info  = $infos->{1}->[0];
    my $base_info    = $infos->{2}->[0];
    my $chassis_info = $infos->{3}->[0];
    my $cpu_info     = $infos->{4}->[0];

    my $bios = {
        BMANUFACTURER => $bios_info->{'Vendor'},
        BDATE         => $bios_info->{'Release Date'},
        BVERSION      => $bios_info->{'Version'},
        ASSETTAG      => $chassis_info->{'Asset Tag'}
    };

    $bios->{SMODEL} =
        $system_info->{'Product'}      ||
        $system_info->{'Product Name'} ||
        $base_info->{'Product Name'};

    $bios->{SMANUFACTURER} =
        $system_info->{'Manufacturer'} ||
        $system_info->{'Vendor'}       ||
        $base_info->{'Manufacturer'};

    $bios->{SSN} =
        $system_info->{'Serial Number'} ||
        $base_info->{'Serial Number'};

    if (!$bios->{SSN} && $cpu_info->{'ID'}) {
        $bios->{SSN} = $cpu_info->{'ID'};
        $bios->{SSN} =~ s/ /-/g;
    }

    my $hardware = {
        UUID => $system_info->{'UUID'}
    };

    my $vmsystem;
    if ($bios->{BMANUFACTURER}) {
        $vmsystem =
            $bios->{BMANUFACTURER} =~ /(QEMU|Bochs)/ ? 'QEMU'       :
            $bios->{BMANUFACTURER} =~ /VirtualBox/   ? 'VirtualBox' :
            $bios->{BMANUFACTURER} =~ /^Xen/         ? 'Xen'        :
                                                       undef   ;
    } elsif ($bios->{SMODEL}) {
        $vmsystem =
            $bios->{SMODEL} =~ /VMware/          ? 'VMWare'          :
            $bios->{SMODEL} =~ /Virtual Machine/ ? 'Virtual Machine' :
                                                    undef        ;
    }
    $hardware->{VMSYSTEM} = $vmsystem;
    return $bios, $hardware;
}

1;
