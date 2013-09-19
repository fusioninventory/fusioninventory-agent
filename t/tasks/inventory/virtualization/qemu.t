#!/usr/bin/perl

use strict;
use warnings;

use Test::Deep;
use Test::More;
use Test::NoWarnings;

use FusionInventory::Agent::Task::Inventory::Virtualization::Qemu;

my @tests = (
    {
        CMD     => "qemu -hda /dev/hda -m 256 foobar",
        _result => { name => '/dev/hda', 'mem' => 256 }
    },
    {
        CMD =>
"kvm -k fr -name xppro --smbios type=1,manufacturer=MySelf,product=myBios,version=1.2.3,serial=myserial,uuid=BB123450-C977-11DF-1234-B01234557082 -vnc :1 -vga std -m 512 -net nic,model=rtl8139,macaddr=12:34:56:17:24:56 -net user -usb -usbdevice host:0a5c:5800 -usbdevice mouse -usbdevice host:0bb4:0c02 -redir tcp:3390::3389 xppro.raw -boot c",
        _result => {
            'serial' => 'myserial',
            'mem'    => 512,
            'uuid'   => 'BB123450-C977-11DF-1234-B01234557082',
            'name'   => 'xppro'
        }
    },
    {
        CMD =>
"qemu -hda /dev/hda -uuid BB123450-C977-11DF-1234-B01234557082 -m 256 -name foobar",
        _result => {
            'name' => 'foobar',
            'mem'  => 256,
            'uuid' => 'BB123450-C977-11DF-1234-B01234557082'
        }
    },
);

plan tests => (scalar @tests) + 1;

foreach my $test (@tests) {
    my $values =
      FusionInventory::Agent::Task::Inventory::Virtualization::Qemu::_parseProcessList(
        $test);
    cmp_deeply( $values, $test->{_result} );
}
