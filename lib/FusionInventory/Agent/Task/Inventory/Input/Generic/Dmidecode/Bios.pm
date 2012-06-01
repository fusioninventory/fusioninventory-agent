package FusionInventory::Agent::Task::Inventory::Input::Generic::Dmidecode::Bios;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Generic;

sub isEnabled {
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my ($bios, $hardware) = _getBiosHardware(logger => $logger);

    $inventory->setBios($bios) if $bios;
    $inventory->setHardware($hardware) if $hardware;
}

sub _getBiosHardware {
    my $parser = getDMIDecodeParser(@_);

    my $bios = {
        BMANUFACTURER => getSanitizedValue($parser, 'bios-vendor'),
        BDATE         => getSanitizedValue($parser, 'bios-release-date'),
        BVERSION      => getSanitizedValue($parser, 'bios-version'),
        MSN           => getSanitizedValue($parser, 'baseboard-serial-number'),
        MMODEL        => getSanitizedValue($parser, 'baseboard-product-name'),
        MMANUFACTURER => getSanitizedValue($parser, 'baseboard-manufacturer'),
        ASSETTAG      => getSanitizedValue($parser, 'chassis-asset-tag'),
        SKUNUMBER     => getSanitizedValue($parser, 'system-sku-number'),
        SSN           => getSanitizedValue($parser, 'system-serial-number'),
        SMANUFACTURER => getSanitizedValue($parser, 'system-manufacturer') ||
                         getSanitizedValue($parser, 'system-vendor'),
        SMODEL        => getSanitizedValue($parser, 'system-product')      ||
                         getSanitizedValue($parser, 'system-product-name'),
    };

    my $hardware = {
        UUID          => getSanitizedValue($parser,'system-uuid'),
        CHASSIS_TYPE  => getSanitizedValue($parser,'chassis-type')
    };

    my $vmsystem;
    if ($bios->{SMANUFACTURER} &&
        $bios->{SMANUFACTURER} =~ /^Microsoft Corporation$/ &&
        $bios->{SMODEL} &&
        $bios->{SMODEL} =~ /Virtual Machine/) {
        $vmsystem = 'Hyper-V';
    } elsif ($bios->{BMANUFACTURER}) {
        $vmsystem =
            $bios->{BMANUFACTURER} =~ /(QEMU|Bochs)/         ? 'QEMU'       :
            $bios->{BMANUFACTURER} =~ /(VirtualBox|innotek)/ ? 'VirtualBox' :
            $bios->{BMANUFACTURER} =~ /^Xen/                 ? 'Xen'        :
                                                               undef        ;
    } elsif ($bios->{SMODEL}) {
        $vmsystem =
            $bios->{SMODEL} =~ /VMware/          ? 'VMWare'          :
            $bios->{SMODEL} =~ /Virtual Machine/ ? 'Virtual Machine' :
                                                    undef            ;
    } elsif ($bios->{BVERSION}) {
        $vmsystem =
            $bios->{BVERSION} =~ /VirtualBox/ ? 'VirtualBox' : undef;
    }
    $hardware->{VMSYSTEM} = $vmsystem if $vmsystem;

    


    return $bios, $hardware;
}

1;
