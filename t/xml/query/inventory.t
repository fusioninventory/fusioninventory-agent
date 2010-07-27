#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use Test::Exception;
use Config;
use FusionInventory::Agent;
use FusionInventory::Agent::XML::Query::Inventory;
use FusionInventory::Logger;

plan tests => 7;

my $inventory;
throws_ok {
    $inventory = FusionInventory::Agent::XML::Query::Inventory->new({
        token => 'foo'
    });
} qr/^No DEVICEID/, 'no device id';

lives_ok {
    $inventory = FusionInventory::Agent::XML::Query::Inventory->new({
        target => {
            deviceid => 'foo',
            vardir   => 'bar',
        },
        logger => FusionInventory::Logger->new(),
    });
} 'everything OK';

isa_ok($inventory, 'FusionInventory::Agent::XML::Query::Inventory');

my $content_init = <<EOF;
<?xml version="1.0" encoding="UTF-8"?>
<REQUEST>
  <CONTENT>
    <ACCESSLOG></ACCESSLOG>
    <BIOS>
    </BIOS>
    <HARDWARE>
      <ARCHNAME>$Config{archname}</ARCHNAME>
      <CHECKSUM>262143</CHECKSUM>
      <VMSYSTEM>Physical</VMSYSTEM>
    </HARDWARE>
    <NETWORKS>
    </NETWORKS>
    <VERSIONCLIENT>$FusionInventory::Agent::AGENT_STRING</VERSIONCLIENT>
  </CONTENT>
  <DEVICEID>foo</DEVICEID>
  <QUERY>INVENTORY</QUERY>
</REQUEST>
EOF
is($inventory->getContent(), $content_init, 'creation content');

$inventory->addCPU({
    NAME => 'void CPU',
    SPEED => 1456,
    MANUFACTURER => 'FusionInventory Developers',
    SERIAL => 'AEZVRV',
    THREAD => 3,
    CORE => 1
});

my $content_cpu = <<EOF;
<?xml version="1.0" encoding="UTF-8"?>
<REQUEST>
  <CONTENT>
    <ACCESSLOG></ACCESSLOG>
    <BIOS>
    </BIOS>
    <CPUS>
      <CORE>1</CORE>
      <MANUFACTURER>FusionInventory Developers</MANUFACTURER>
      <NAME>void CPU</NAME>
      <SERIAL>AEZVRV</SERIAL>
      <SPEED>1456</SPEED>
      <THREAD>3</THREAD>
    </CPUS>
    <HARDWARE>
      <ARCHNAME>$Config{archname}</ARCHNAME>
      <CHECKSUM>4099</CHECKSUM>
      <PROCESSORN>1</PROCESSORN>
      <PROCESSORS>1456</PROCESSORS>
      <PROCESSORT>void CPU</PROCESSORT>
      <VMSYSTEM>Physical</VMSYSTEM>
    </HARDWARE>
    <NETWORKS>
    </NETWORKS>
    <VERSIONCLIENT>$FusionInventory::Agent::AGENT_STRING</VERSIONCLIENT>
  </CONTENT>
  <DEVICEID>foo</DEVICEID>
  <QUERY>INVENTORY</QUERY>
</REQUEST>
EOF
is($inventory->getContent(), $content_cpu, 'CPU added');

$inventory->addDrive({
        FILESYSTEM => 'ext3',
        FREE => 9120,
        SERIAL => '7f8d8f98-15d7-4bdb-b402-46cbed25432b',
        TOTAL => 18777,
        TYPE => '/',
        VOLUMN => '/dev/sda2',
});
my $content_drive = <<EOF;
<?xml version="1.0" encoding="UTF-8"?>
<REQUEST>
  <CONTENT>
    <ACCESSLOG></ACCESSLOG>
    <BIOS>
    </BIOS>
    <CPUS>
      <CORE>1</CORE>
      <MANUFACTURER>FusionInventory Developers</MANUFACTURER>
      <NAME>void CPU</NAME>
      <SERIAL>AEZVRV</SERIAL>
      <SPEED>1456</SPEED>
      <THREAD>3</THREAD>
    </CPUS>
    <DRIVES>
      <FILESYSTEM>ext3</FILESYSTEM>
      <FREE>9120</FREE>
      <SERIAL>7f8d8f98-15d7-4bdb-b402-46cbed25432b</SERIAL>
      <TOTAL>18777</TOTAL>
      <TYPE>/</TYPE>
      <VOLUMN>/dev/sda2</VOLUMN>
    </DRIVES>
    <HARDWARE>
      <ARCHNAME>$Config{archname}</ARCHNAME>
      <CHECKSUM>513</CHECKSUM>
      <PROCESSORN>1</PROCESSORN>
      <PROCESSORS>1456</PROCESSORS>
      <PROCESSORT>void CPU</PROCESSORT>
      <VMSYSTEM>Physical</VMSYSTEM>
    </HARDWARE>
    <NETWORKS>
    </NETWORKS>
    <VERSIONCLIENT>$FusionInventory::Agent::AGENT_STRING</VERSIONCLIENT>
  </CONTENT>
  <DEVICEID>foo</DEVICEID>
  <QUERY>INVENTORY</QUERY>
</REQUEST>
EOF
is($inventory->getContent(), $content_drive, 'drive added');

$inventory->addSoftwareDeploymentPackage({ ORDERID => '1234567891' });
my $content_software = <<EOF;
<?xml version="1.0" encoding="UTF-8"?>
<REQUEST>
  <CONTENT>
    <ACCESSLOG></ACCESSLOG>
    <BIOS>
    </BIOS>
    <CPUS>
      <CORE>1</CORE>
      <MANUFACTURER>FusionInventory Developers</MANUFACTURER>
      <NAME>void CPU</NAME>
      <SERIAL>AEZVRV</SERIAL>
      <SPEED>1456</SPEED>
      <THREAD>3</THREAD>
    </CPUS>
    <DOWNLOAD>
      <HISTORY>
        <PACKAGE>
          <ID>1234567891</ID>
        </PACKAGE>
      </HISTORY>
    </DOWNLOAD>
    <DRIVES>
      <FILESYSTEM>ext3</FILESYSTEM>
      <FREE>9120</FREE>
      <SERIAL>7f8d8f98-15d7-4bdb-b402-46cbed25432b</SERIAL>
      <TOTAL>18777</TOTAL>
      <TYPE>/</TYPE>
      <VOLUMN>/dev/sda2</VOLUMN>
    </DRIVES>
    <HARDWARE>
      <ARCHNAME>$Config{archname}</ARCHNAME>
      <CHECKSUM>1</CHECKSUM>
      <PROCESSORN>1</PROCESSORN>
      <PROCESSORS>1456</PROCESSORS>
      <PROCESSORT>void CPU</PROCESSORT>
      <VMSYSTEM>Physical</VMSYSTEM>
    </HARDWARE>
    <NETWORKS>
    </NETWORKS>
    <VERSIONCLIENT>$FusionInventory::Agent::AGENT_STRING</VERSIONCLIENT>
  </CONTENT>
  <DEVICEID>foo</DEVICEID>
  <QUERY>INVENTORY</QUERY>
</REQUEST>
EOF
is($inventory->getContent(), $content_software, 'software added');
