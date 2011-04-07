package FusionInventory::Agent::Task::Inventory::OS::MacOS::Bios;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled {
    return 
        -r '/usr/sbin/system_profiler' &&
        can_load("Mac::SysProfile");
}

sub doInventory {
    my ($params) = @_;

    my $inventory = $params->{inventory};

    my $prof = Mac::SysProfile->new();
    my $info = $prof->gettype('SPHardwareDataType');
    return unless ref $info eq 'HASH';

    $info = $info->{'Hardware Overview'};

    my $ioregInfo;
#+-o iMac7,1  <class IOPlatformExpertDevice, registered, matched, active, busy 0, retain 24>
#    {
#      "IOBusyInterest" = "IOCommand is not serializable"
#      "IOInterruptControllers" = ("io-apic-0")
#      "IOPlatformSerialNumber" = "0"
#      "clock-frequency" = <00e1f505>
#      "version" = <"1.0">
#      "product-name" = <"iMac7,1">
#      "serial-number" = <30003000000000000000000000300000000000000000000000000000000000000000000000000000000000>
#      "IOInterruptSpecifiers" = (<0900000007000000>)
#      "model" = <"iMac7,1">
#      "IOPlatformUUID" = "00000000-0000-1000-8000-0800276E729D"
#      "manufacturer" = <"innotek GmbH">
#      "IOPlatformArgs" = <00b0ac0000a0680010cfb80000000000>
#      "name" = <"/">
#      "compatible" = <"iMac7,1">
#      "IOPolledInterface" = "SMCPolledInterface is not serializable"
#    }
    my $in;
    foreach (`ioreg -l`) {
       $in = 1 if /<class IOPlatformExpertDevice/;
       if ($in) {
           if (/"(\S+)"\s*=\s*(.*)/) {
               my $k = $1;
               my $t = $2;
               $t =~ s/<(.*)>/$1/;
               $t =~ s/"(.*)"/$1/;
               $ioregInfo->{$k} = $t;
           } elsif (/^[\|\s]*}\s*$/) {
               $in=0;
               last; 
           }
        }
    }

    # set the bios informaiton from the apple system profiler
    $inventory->setBios({
        SMANUFACTURER => $ioregInfo->{'manufacturer'} || 'Apple Inc', # duh
        SMODEL        => $info->{'Model Identifier'} || $info->{'Machine Model'},
        #       SSN             => $h->{'Serial Number'}
        # New method to get the SSN, because of MacOS 10.5.7 update
        # system_profiler gives 'Serial Number (system): XXXXX' where 10.5.6
        # and lower give 'Serial Number: XXXXX'
        SSN           => $info->{'Serial Number'} || $info->{'Serial Number (system)'} || $ioregInfo->{'serial-number'},
        BVERSION      => $info->{'Boot ROM Version'},
    });

    $inventory->setHardware({
        UUID => $info->{'Hardware UUID'} || $ioregInfo->{'IOPlatformUUID'}
    });
}

1;
