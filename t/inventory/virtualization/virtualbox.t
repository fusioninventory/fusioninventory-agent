#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use FusionInventory::Agent::Logger;
use FusionInventory::Agent::Task::Inventory::Virtualization::VirtualBox;

my %tests = (
    sample1 => [
        {
            VMTYPE    => 'VirtualBox',
            NAME      => 'Fusion-UsineRefav',
            SUBSYSTEM => 'Oracle VM VirtualBox',
            STATUS    => 'off',
            MEMORY    => '855MB',
            UUID      => '03a37b40-31f0-4c10-8a92-472d02b02221',
            VCPU      => 1
        },
        {
            VMTYPE    => 'VirtualBox',
            NAME      => 'Client-Leopard2',
            SUBSYSTEM => 'Oracle VM VirtualBox',
            STATUS    => 'off',
            MEMORY    => '1024MB',
            UUID      => 'd2ba1d3d-f682-4e25-b5a7-47eea52253bc',
            VCPU      => 1
        },
        {
            VMTYPE    => 'VirtualBox',
            NAME      => 'Client-Snow64',
            SUBSYSTEM => 'Oracle VM VirtualBox',
            STATUS    => 'off',
            MEMORY    => '512MB',
            UUID      => '509c9563-05c7-4654-b8a4-ce7d639148bc',
            VCPU      => 1
        },
        {
            VMTYPE    => 'VirtualBox',
            NAME      => 'Client-Win2k',
            SUBSYSTEM => 'Oracle VM VirtualBox',
            STATUS    => 'off',
            MEMORY    => '256MB',
            UUID      => 'dba8762a-ed1e-4984-ba06-dad9ed981a5a',
            VCPU      => 1
        },
        {
            VMTYPE    => 'VirtualBox',
            NAME      => 'OpenSuse',
            SUBSYSTEM => 'Oracle VM VirtualBox',
            STATUS    => 'off',
            MEMORY    => '512MB',
            UUID      => '6047a446-06fd-45ad-8829-cb2b7d81c8a2',
            VCPU      => 1
        },
        {
            VMTYPE    => 'VirtualBox',
            NAME      => 'OpenSolaris',
            SUBSYSTEM => 'Oracle VM VirtualBox',
            STATUS    => 'off',
            MEMORY    => '768MB',
            UUID      => '201ca94e-66fb-4d3f-b2af-6d1b4746e77b',
            VCPU      => 1
        },
        {
            VMTYPE    => 'VirtualBox',
            NAME      => 'Mandriva',
            SUBSYSTEM => 'Oracle VM VirtualBox',
            STATUS    => 'off',
            MEMORY    => '512MB',
            UUID      => '46f9d625-923a-41fb-8518-53c58a041142',
            VCPU      => 1
        },
        {
            VMTYPE    => 'VirtualBox',
            NAME      => 'openbsd47',
            SUBSYSTEM => 'Oracle VM VirtualBox',
            STATUS    => 'off',
            MEMORY    => '671MB',
            UUID      => '347850fa-1279-4678-89eb-19f53f1f021c',
            VCPU      => 1
        },
        {
            VMTYPE    => 'VirtualBox',
            NAME      => 'netbsd',
            SUBSYSTEM => 'Oracle VM VirtualBox',
            STATUS    => 'off',
            MEMORY    => '64MB',
            UUID      => '4ddac902-a4f6-4ccb-a1a4-73dd6c90c1b2',
            VCPU      => 1
        }
    ],
    sample2 => [
          {
            VMTYPE    => 'VirtualBox',
            NAME      => 'refab',
            SUBSYSTEM => 'Oracle VM VirtualBox',
            STATUS    => 'off',
            MEMORY    => '855MB',
            UUID      => '03a37b40-31f0-4c10-8a92-472d02b02221',
            VCPU      => 1
          },
          {
            VMTYPE    => 'VirtualBox',
            NAME      => 'OSX 10.6 64bits',
            SUBSYSTEM => 'Oracle VM VirtualBox',
            STATUS    => 'off',
            MEMORY    => '384MB',
            UUID      => '509c9563-05c7-4654-b8a4-ce7d639148bc',
            VCPU      => 1
          },
          {
            VMTYPE    => 'VirtualBox',
            NAME      => 'Win2k SP4',
            SUBSYSTEM => 'Oracle VM VirtualBox',
            STATUS    => 'running',
            MEMORY    => '256MB',
            UUID      => 'dba8762a-ed1e-4984-ba06-dad9ed981a5a',
            VCPU      => 1
          },
          {
            VMTYPE    => 'VirtualBox',
            NAME      => 'OpenSuse 11.3',
            SUBSYSTEM => 'Oracle VM VirtualBox',
            STATUS    => 'off',
            MEMORY    => '512MB',
            UUID      => '6047a446-06fd-45ad-8829-cb2b7d81c8a2',
            VCPU      => 1
          },
          {
            VMTYPE    => 'VirtualBox',
            NAME      => 'Mandriva 2010.1',
            SUBSYSTEM => 'Oracle VM VirtualBox',
            STATUS    => 'off',
            MEMORY    => '512MB',
            UUID      => '46f9d625-923a-41fb-8518-53c58a041142',
            VCPU      => 1
          },
          {
            VMTYPE    => 'VirtualBox',
            NAME      => 'OpenBSD 4.7',
            SUBSYSTEM => 'Oracle VM VirtualBox',
            STATUS    => 'off',
            MEMORY    => '671MB',
            UUID      => '347850fa-1279-4678-89eb-19f53f1f021c',
            VCPU      => 1
          },
          {
            VMTYPE    => 'VirtualBox',
            NAME      => 'NetBSD 5.0',
            SUBSYSTEM => 'Oracle VM VirtualBox',
            STATUS    => 'off',
            MEMORY    => '64MB',
            UUID      => '4ddac902-a4f6-4ccb-a1a4-73dd6c90c1b2',
            VCPU      => 1
          },
          {
            VMTYPE    => 'VirtualBox',
            NAME      => 'Debian 3.1',
            SUBSYSTEM => 'Oracle VM VirtualBox',
            STATUS    => 'off',
            MEMORY    => '384MB',
            UUID      => '3cf86f84-4c0d-4c2b-a720-b1182712b4ac',
            VCPU      => 1
          },
          {
            VMTYPE    => 'VirtualBox',
            NAME      => 'OpenBSD 4.5',
            SUBSYSTEM => 'Oracle VM VirtualBox',
            STATUS    => 'off',
            MEMORY    => '64MB',
            UUID      => 'c47c7521-e3de-42a0-918a-3ade7ac27bfe',
            VCPU      => 1
          },
          {
            VMTYPE    => 'VirtualBox',
            NAME      => 'OSX 10.4 Server',
            SUBSYSTEM => 'Oracle VM VirtualBox',
            STATUS    => 'off',
            MEMORY    => '512MB',
            UUID      => '97310b6c-a66d-4228-a959-c1f28c095828',
            VCPU      => 1
          },
          {
            VMTYPE    => 'VirtualBox',
            NAME      => 'OSX 10.5',
            SUBSYSTEM => 'Oracle VM VirtualBox',
            STATUS    => 'off',
            MEMORY    => '1024MB',
            UUID      => '7f5e9dfe-57b0-45f0-b466-252926ef16ed',
            VCPU      => 1
          },
          {
            VMTYPE    => 'VirtualBox',
            NAME      => 'OpenBSD 4.6',
            SUBSYSTEM => 'Oracle VM VirtualBox',
            STATUS    => 'off',
            MEMORY    => '64MB',
            UUID      => '6f0ac84f-01ab-4351-8187-d20d725a4bad',
            VCPU      => 1
          },
          {
            VMTYPE    => 'VirtualBox',
            NAME      => 'Debian 5.0',
            SUBSYSTEM => 'Oracle VM VirtualBox',
            STATUS    => 'off',
            MEMORY    => '384MB',
            UUID      => 'b65c2ec0-cb10-41b0-80a5-6db7f76b0b92',
            VCPU      => 1
          },
          {
            VMTYPE    => 'VirtualBox',
            NAME      => 'SME Server 7.3',
            SUBSYSTEM => 'Oracle VM VirtualBox',
            STATUS    => 'off',
            MEMORY    => '512MB',
            UUID      => 'daa80142-de88-4f9a-9b0f-18a6778be5b1',
            VCPU      => 1
          },
          {
            VMTYPE    => 'VirtualBox',
            NAME      => 'OpenBSD 4.8',
            SUBSYSTEM => 'Oracle VM VirtualBox',
            STATUS    => 'off',
            MEMORY    => '64MB',
            UUID      => 'e0bcc4df-58de-4fae-8a51-bf878bca497f',
            VCPU      => 1
          },
          {
            VMTYPE    => 'VirtualBox',
            NAME      => 'Mandrake 10.2',
            SUBSYSTEM => 'Oracle VM VirtualBox',
            STATUS    => 'off',
            MEMORY    => '512MB',
            UUID      => '69cf25f6-95ff-4b2d-b823-c3a4b86c9f88',
            VCPU      => 1
          },
          {
            VMTYPE    => 'VirtualBox',
            NAME      => 'Mandrake 9.2',
            SUBSYSTEM => 'Oracle VM VirtualBox',
            STATUS    => 'off',
            MEMORY    => '512MB',
            UUID      => '77059174-4a9d-4082-b0a6-c49880fd88a0',
            VCPU      => 1
          },
          {
            VMTYPE    => 'VirtualBox',
            NAME      => 'Mandriva 2007.1',
            SUBSYSTEM => 'Oracle VM VirtualBox',
            STATUS    => 'off',
            MEMORY    => '512MB',
            UUID      => 'f4a6155f-d675-45ae-a342-d12853e21113',
            VCPU      => 1
          },
          {
            VMTYPE    => 'VirtualBox',
            NAME      => 'centos39',
            SUBSYSTEM => 'Oracle VM VirtualBox',
            STATUS    => 'running',
            MEMORY    => '512MB',
            UUID      => 'ae698cfc-492a-4c7b-848f-8c17d24bc76e',
            VCPU      => 1
          },
          {
            VMTYPE    => 'VirtualBox',
            NAME      => 'NetBSD 5.1 i386',
            SUBSYSTEM => 'Oracle VM VirtualBox',
            STATUS    => 'off',
            MEMORY    => '384MB',
            UUID      => '032fcb87-72e1-4fb4-b835-0c1ee2dba305',
            VCPU      => 1
          },
          {
            VMTYPE    => 'VirtualBox',
            NAME      => 'NetBSD 4 64bits',
            SUBSYSTEM => 'Oracle VM VirtualBox',
            STATUS    => 'off',
            MEMORY    => '242MB',
            UUID      => '5937e442-3fce-477c-8b87-95494d86ddce',
            VCPU      => 1
          },
          {
            VMTYPE    => 'VirtualBox',
            NAME      => 'OpenIndiana',
            SUBSYSTEM => 'Oracle VM VirtualBox',
            STATUS    => 'off',
            MEMORY    => '768MB',
            UUID      => '016826f0-3df6-4967-9a77-881be007ad1e',
            VCPU      => 1
          },
          {
            VMTYPE    => 'VirtualBox',
            NAME      => 'OpenSolaris86',
            SUBSYSTEM => 'Oracle VM VirtualBox',
            STATUS    => 'off',
            MEMORY    => '768MB',
            UUID      => '88a5e8cd-ca9e-4ff4-b279-bfc74b16761a',
            VCPU      => 1
          },
          {
            VMTYPE    => 'VirtualBox',
            NAME      => 'FreeBSD53',
            SUBSYSTEM => 'Oracle VM VirtualBox',
            STATUS    => 'off',
            MEMORY    => '128MB',
            UUID      => '9e81b803-2e9e-4972-958d-430f31e80291',
            VCPU      => 1
          },
          {
            VMTYPE    => 'VirtualBox',
            NAME      => 'Nextena',
            SUBSYSTEM => 'Oracle VM VirtualBox',
            STATUS    => 'off',
            MEMORY    => '768MB',
            UUID      => 'c077f44d-cb77-4940-bda7-7683eec75ca2',
            VCPU      => 1
          },
          {
            VMTYPE    => 'VirtualBox',
            NAME      => 'Slackware 10',
            SUBSYSTEM => 'Oracle VM VirtualBox',
            STATUS    => 'off',
            MEMORY    => '96MB',
            UUID      => 'bb4f337f-abd0-4527-af12-c68913a96285',
            VCPU      => 1
          },
          {
            VMTYPE    => 'VirtualBox',
            NAME      => 'Slackware 11',
            SUBSYSTEM => 'Oracle VM VirtualBox',
            STATUS    => 'off',
            MEMORY    => '512MB',
            UUID      => 'bb172db8-87b6-499f-b829-c4cb021dada5',
            VCPU      => 1
          },
          {
            VMTYPE    => 'VirtualBox',
            NAME      => 'Slackware12',
            SUBSYSTEM => 'Oracle VM VirtualBox',
            STATUS    => 'off',
            MEMORY    => '512MB',
            UUID      => '7ec3ecc4-7564-4824-8dc9-6e3c24d26fd3',
            VCPU      => 1
          },
          {
            VMTYPE    => 'VirtualBox',
            NAME      => 'Redhat 9',
            SUBSYSTEM => 'Oracle VM VirtualBox',
            STATUS    => 'off',
            MEMORY    => '512MB',
            UUID      => '4c19502e-00df-4f3c-a25e-54850514cd53',
            VCPU      => 1
          },
          {
            VMTYPE    => 'VirtualBox',
            NAME      => 'Solaris 11 Express',
            SUBSYSTEM => 'Oracle VM VirtualBox',
            STATUS    => 'off',
            MEMORY    => '384MB',
            UUID      => '2f944139-f0fc-455a-bcbf-93cb5d1942cc',
            VCPU      => 1
          },
          {
            VMTYPE    => 'VirtualBox',
            NAME      => 'NetBSD 5.1 64 bits',
            SUBSYSTEM => 'Oracle VM VirtualBox',
            STATUS    => 'off',
            MEMORY    => '256MB',
            UUID      => '1de6959e-4031-400d-b398-40b754d8c93d',
            VCPU      => 1
          },
          {
            VMTYPE    => 'VirtualBox',
            NAME      => 'XP 64',
            SUBSYSTEM => 'Oracle VM VirtualBox',
            STATUS    => 'off',
            MEMORY    => '512MB',
            UUID      => '73406cb8-016a-47e7-ae21-11a3b63228c0',
            VCPU      => 1
          }
    ]
);

plan tests => scalar keys %tests;

foreach my $test (keys %tests) {
    my $file = "resources/virtualization/vboxmanage/$test";
    my @machines = FusionInventory::Agent::Task::Inventory::Virtualization::VirtualBox::_parseVBoxManage(file => $file);
    is_deeply(\@machines, $tests{$test}, $test);
}
