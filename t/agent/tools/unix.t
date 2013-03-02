#!/usr/bin/perl

use strict;
use warnings;

use English qw(-no_match_vars);
use Test::Deep;
use Test::More;

use FusionInventory::Agent::Tools::Unix;

my %df_tests = (
    'freebsd' => [
        {
            VOLUMN     => '/dev/ad4s1a',
            TOTAL      => '1447',
            FREE       => '965',
            TYPE       => '/',
            FILESYSTEM => 'ufs'
        },
        {
            VOLUMN     => '/dev/ad4s1g',
            TOTAL      => '138968',
            FREE       => '12851',
            TYPE       => '/Donnees',
            FILESYSTEM => 'ufs'
        },
        {
            VOLUMN     => '/dev/ad4s1e',
            TOTAL      => '495',
            FREE       => '397',
            TYPE       => '/tmp',
            FILESYSTEM => 'ufs'
        },
        {
            VOLUMN     => '/dev/ad4s1f',
            TOTAL      => '19832',
            FREE       => '5118',
            TYPE       => '/usr',
            FILESYSTEM => 'ufs'
        },
        {
            VOLUMN     => '/dev/ad4s1d',
            TOTAL      => '3880',
            FREE       => '2571',
            TYPE       => '/var',
            FILESYSTEM => 'ufs'
        }
    ],
    'linux' => [
        {
            VOLUMN     => '/dev/sda5',
            TOTAL      => '12106',
            FREE       => '6528',
            TYPE       => '/',
            FILESYSTEM => 'ext4'
        },
        {
            VOLUMN     => '/dev/sda3',
            TOTAL      => '60002',
            FREE       => '40540',
            TYPE       => '/media/windows',
            FILESYSTEM => 'fuseblk'
        },
        {
            VOLUMN     => '/dev/sda7',
            TOTAL      => '44110',
            FREE       => '21930',
            TYPE       => '/home',
            FILESYSTEM => 'crypt'
        }
    ],
    'netbsd' => [
        {
            VOLUMN     => '/dev/wd0a',
            TOTAL      => '15112',
            FREE       => '3581',
            TYPE       => '/',
            FILESYSTEM => undef
          }
    ],
    'openbsd' => [
        {
            VOLUMN     => '/dev/wd0a',
            TOTAL      => '784',
            FREE       => '174',
            TYPE       => '/',
            FILESYSTEM => undef
        },
        {
            VOLUMN     => '/dev/wd0e',
            TOTAL      => '251',
            FREE       => '239',
            TYPE       => '/home',
            FILESYSTEM => undef
        },
        {
            VOLUMN     => '/dev/wd0d',
            TOTAL      => '892',
            FREE       => '224',
            TYPE       => '/usr',
            FILESYSTEM => undef
        }
    ],
    'aix' => [
        {
            VOLUMN     => '/dev/hd4',
            TOTAL      => '2048',
            FREE       => '1065',
            TYPE       => '/',
            FILESYSTEM => undef
        },
        {
            VOLUMN     => '/dev/hd2',
            TOTAL      => '4864',
            FREE       => '2704',
            TYPE       => '/usr',
            FILESYSTEM => undef
        },
        {
            VOLUMN     => '/dev/hd9var',
            TOTAL      => '256',
            FREE       => '177',
            TYPE       => '/var',
            FILESYSTEM => undef
        },
        {
            VOLUMN     => '/dev/hd3',
            TOTAL      => '4096',
            FREE       => '837',
            TYPE       => '/tmp',
            FILESYSTEM => undef
        },
        {
            VOLUMN     => '/dev/fwdump',
            TOTAL      => '128',
            FREE       => '127',
            TYPE       => '/var/adm/ras/platform',
            FILESYSTEM => undef
        },
        {
            VOLUMN     => '/dev/hd1',
            TOTAL      => '2048',
            FREE       => '1027',
            TYPE       => '/home',
            FILESYSTEM => undef
        },
        {
            VOLUMN     => '/dev/hd11admin',
            TOTAL      => '128',
            FREE       => '127',
            TYPE       => '/admin',
            FILESYSTEM => undef
        },
        {
            VOLUMN     => '/dev/hd10opt',
            TOTAL      => '128',
            FREE       => '13',
            TYPE       => '/opt',
            FILESYSTEM => undef
        }
    ]
);

my @dhcp_leases_test = (
    {
        file   => 'dhclient-wlan0-1.lease',
        result => '192.168.0.254',
        if     => 'wlan0'
    },
    {
        file   => 'dhclient-wlan0-2.lease',
        result => '192.168.10.1',
        if     => 'wlan0'
    },
);

my %busybox_ps_tests = (
    busybox => [
        {
            VIRTUALMEMORY => '2536',
            PID           => '1',
            CMD           => 'init',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '0',
            PID           => '2',
            CMD           => '[kthreadd]',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '0',
            PID           => '3',
            CMD           => '[ksoftirqd/0]',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '0',
            PID           => '6',
            CMD           => '[migration/0]',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '0',
            PID           => '7',
            CMD           => '[migration/1]',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '0',
            PID           => '9',
            CMD           => '[ksoftirqd/1]',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '0',
            PID           => '11',
            CMD           => '[migration/2]',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '0',
            PID           => '13',
            CMD           => '[ksoftirqd/2]',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '0',
            PID           => '14',
            CMD           => '[migration/3]',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '0',
            PID           => '16',
            CMD           => '[ksoftirqd/3]',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '0',
            PID           => '17',
            CMD           => '[khelper]',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '0',
            PID           => '138',
            CMD           => '[sync_supers]',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '0',
            PID           => '140',
            CMD           => '[bdi-default]',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '0',
            PID           => '141',
            CMD           => '[kintegrityd]',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '0',
            PID           => '142',
            CMD           => '[kblockd]',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '0',
            PID           => '249',
            CMD           => '[ata_sff]',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '0',
            PID           => '257',
            CMD           => '[md]',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '0',
            PID           => '366',
            CMD           => '[rpciod]',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '0',
            PID           => '408',
            CMD           => '[kswapd0]',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '0',
            PID           => '409',
            CMD           => '[fsnotify_mark]',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '0',
            PID           => '410',
            CMD           => '[nfsiod]',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '96192',
            PID           => '597',
            CMD           => '/usr/syno/apache/bin/httpd -DHAVE_PHP',
            USER          => 'nobody'
        },
        {
            VIRTUALMEMORY => '95672',
            PID           => '800',
            CMD           => '/usr/syno/apache/bin/httpd -DHAVE_PHP',
            USER          => 'nobody'
        },
        {
            VIRTUALMEMORY => '0',
            PID           => '871',
            CMD           => '[kworker/0:0]',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '0',
            PID           => '983',
            CMD           => '[iscsi_eh]',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '0',
            PID           => '1004',
            CMD           => '[scsi_eh_0]',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '0',
            PID           => '1007',
            CMD           => '[scsi_eh_1]',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '0',
            PID           => '1010',
            CMD           => '[scsi_eh_2]',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '0',
            PID           => '1013',
            CMD           => '[scsi_eh_3]',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '0',
            PID           => '1016',
            CMD           => '[scsi_eh_4]',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '0',
            PID           => '1019',
            CMD           => '[scsi_eh_5]',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '0',
            PID           => '1025',
            CMD           => '[kworker/u:5]',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '0',
            PID           => '1026',
            CMD           => '[kworker/u:6]',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '0',
            PID           => '1037',
            CMD           => '[scsi_eh_6]',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '0',
            PID           => '1040',
            CMD           => '[scsi_eh_7]',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '0',
            PID           => '1136',
            CMD           => '[md0_raid1]',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '0',
            PID           => '1143',
            CMD           => '[md1_raid1]',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '0',
            PID           => '1501',
            CMD           => '[jbd2/md0-8]',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '0',
            PID           => '1502',
            CMD           => '[ext4-dio-unwrit]',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '0',
            PID           => '2058',
            CMD           => '[kworker/0:1]',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '12912',
            PID           => '2307',
            CMD           => 'sshd: root@pts/1',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '4752',
            PID           => '2345',
            CMD           => '-ash',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '11852',
            PID           => '2437',
            CMD           => '/usr/syno/bin/synonetbkpd -D',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '0',
            PID           => '2518',
            CMD           => '[kworker/3:2]',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '0',
            PID           => '2708',
            CMD           => '[khubd]',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '0',
            PID           => '2826',
            CMD           => '[crypto]',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '0',
            PID           => '3068',
            CMD           => '[ecryptfs-kthrea]',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '95908',
            PID           => '3124',
            CMD           => '/usr/syno/apache/bin/httpd -DHAVE_PHP',
            USER          => 'nobody'
        },
        {
            VIRTUALMEMORY => '98.1m',
            PID           => '3180',
            CMD           => '/usr/syno/apache/bin/httpd -DHAVE_PHP',
            USER          => 'nobody'
        },
        {
            VIRTUALMEMORY => '1472',
            PID           => '3439',
            CMD           => '/sbin/dhcpcd -n eth0 -t 30',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '2536',
            PID           => '3475',
            CMD           => '/sbin/syslogd -S',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '2536',
            PID           => '3480',
            CMD           => '/sbin/klogd',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '95644',
            PID           => '3981',
            CMD           => '/usr/syno/apache/bin/httpd -DHAVE_PHP',
            USER          => 'nobody'
        },
        {
            VIRTUALMEMORY => '12264',
            PID           => '4089',
            CMD           => '/usr/syno/apache/bin/httpd -f /usr/syno/apache/conf/httpd.conf-sys',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '12264',
            PID           => '4286',
            CMD           => '/usr/syno/apache/bin/httpd -f /usr/syno/apache/conf/httpd.conf-sys',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '55416',
            PID           => '4307',
            CMD           => '/usr/syno/mysql/libexec/mysqld --basedir=/usr/syno/mysql --datadir=/volume1/@database/mysql --user=admin --max_allowed_packet=8M',
            USER          => 'admin'
        },
        {
            VIRTUALMEMORY => '12264',
            PID           => '4476',
            CMD           => '/usr/syno/apache/bin/httpd -f /usr/syno/apache/conf/httpd.conf-sys',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '12256',
            PID           => '4766',
            CMD           => '/usr/syno/apache/bin/httpd -f /usr/syno/apache/conf/httpd.conf-sys',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '10908',
            PID           => '4785',
            CMD           => '/usr/syno/bin/findhostd',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '25228',
            PID           => '4811',
            CMD           => '/usr/syno/sbin/smbd -D',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '12092',
            PID           => '4819',
            CMD           => '/usr/syno/apache/bin/httpd -f /usr/syno/apache/conf/httpd.conf-sys',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '12092',
            PID           => '4820',
            CMD           => '/usr/syno/apache/bin/httpd -f /usr/syno/apache/conf/httpd.conf-sys',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '12092',
            PID           => '4821',
            CMD           => '/usr/syno/apache/bin/httpd -f /usr/syno/apache/conf/httpd.conf-sys',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '4752',
            PID           => '4822',
            CMD           => 'ps',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '0',
            PID           => '5489',
            CMD           => '[kworker/2:1]',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '9188',
            PID           => '5571',
            CMD           => '/usr/sbin/ntpd -p /var/run/ntpd.pid -g',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '9188',
            PID           => '5573',
            CMD           => '/usr/sbin/ntpd -p /var/run/ntpd.pid -g',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '9188',
            PID           => '5574',
            CMD           => '/usr/sbin/ntpd -p /var/run/ntpd.pid -g',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '0',
            PID           => '6038',
            CMD           => '[kworker/3:1]',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '0',
            PID           => '6115',
            CMD           => '[flush-9:0]',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '0',
            PID           => '6116',
            CMD           => '[flush-9:2]',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '13376',
            PID           => '6184',
            CMD           => 'scemd',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '13376',
            PID           => '6306',
            CMD           => 'scemd',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '13376',
            PID           => '6311',
            CMD           => 'scemd',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '0',
            PID           => '7321',
            CMD           => '[scsi_eh_8]',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '0',
            PID           => '7339',
            CMD           => '[usb-storage]',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '0',
            PID           => '7843',
            CMD           => '[kworker/1:1]',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '2540',
            PID           => '8035',
            CMD           => '/sbin/getty 115200 console',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '11988',
            PID           => '8357',
            CMD           => '/usr/syno/sbin/hotplugd',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '4748',
            PID           => '8371',
            CMD           => '/usr/sbin/inetd',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '13148',
            PID           => '8384',
            CMD           => '/usr/syno/sbin/snmpd -Ln -c /usr/syno/etc/snmpd.conf -p /var/run/snmpd.pid udp:161,udp6:161,tcp:161,tcp6:161',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '11696',
            PID           => '8587',
            CMD           => '/usr/syno/sbin/fileindexd',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '95228',
            PID           => '8635',
            CMD           => '/usr/syno/apache/bin/httpd -DHAVE_PHP',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '11292',
            PID           => '9466',
            CMD           => '/usr/syno/sbin/synosnmpcd',
            USER          => 'root'
        },
        {
            VIRTUALMEMORY => '12092',
            PID           => '9507',
            CMD           => '/usr/syno/apache/bin/httpd -f /usr/syno/apache/conf/httpd.conf-sys',
            USER          => 'root'
        },
        {
                VIRTUALMEMORY => '2232',
                PID           => '14163',
                CMD           => 'avahi-daemon: running [nas.local]',
                USER          => 'root'
        },
        {
                VIRTUALMEMORY => '0',
                PID           => '14994',
                CMD           => '[LIO_rd_dr]',
                USER          => 'root'
        },
        {
                VIRTUALMEMORY => '0',
                PID           => '15005',
                CMD           => '[iscsi_trx/1]',
                USER          => 'root'
        },
        {
                VIRTUALMEMORY => '0',
                PID           => '15006',
                CMD           => '[iscsi_ttx/1]',
                USER          => 'root'
        },
        {
                VIRTUALMEMORY => '0',
                PID           => '15007',
                CMD           => '[iscsi_trx/2]',
                USER          => 'root'
        },
        {
                VIRTUALMEMORY => '0',
                PID           => '15008',
                CMD           => '[iscsi_ttx/2]',
                USER          => 'root'
        },
        {
                VIRTUALMEMORY => '0',
                PID           => '15009',
                CMD           => '[iscsi_trx/3]',
                USER          => 'root'
        },
        {
                VIRTUALMEMORY => '0',
                PID           => '15010',
                CMD           => '[iscsi_ttx/3]',
                USER          => 'root'
        },
        {
                VIRTUALMEMORY => '0',
                PID           => '15011',
                CMD           => '[iscsi_trx/4]',
                USER          => 'root'
        },
        {
                VIRTUALMEMORY => '0',
                PID           => '15012',
                CMD           => '[iscsi_ttx/4]',
                USER          => 'root'
        },
        {
                VIRTUALMEMORY => '0',
                PID           => '15269',
                CMD           => '[iscsi_np]',
                USER          => 'root'
        },
        {
                VIRTUALMEMORY => '0',
                PID           => '15272',
                CMD           => '[iscsi_np]',
                USER          => 'root'
        },
        {
                VIRTUALMEMORY => '0',
                PID           => '15303',
                CMD           => '[LIO_fileio]',
                USER          => 'root'
        },
        {
                VIRTUALMEMORY => '18264',
                PID           => '16466',
                CMD           => '/usr/syno/sbin/nmbd -D',
                USER          => 'root'
        },
        {
                VIRTUALMEMORY => '22548',
                PID           => '16482',
                CMD           => '/usr/syno/sbin/winbindd -D',
                USER          => 'root'
        },
        {
                VIRTUALMEMORY => '22624',
                PID           => '16493',
                CMD           => '/usr/syno/sbin/winbindd -D',
                USER          => 'root'
        },
        {
                VIRTUALMEMORY => '22100',
                PID           => '16516',
                CMD           => '/usr/syno/sbin/winbindd -D',
                USER          => 'root'
        },
        {
                VIRTUALMEMORY => '22540',
                PID           => '16517',
                CMD           => '/usr/syno/sbin/winbindd -D',
                USER          => 'root'
        },
        {
                VIRTUALMEMORY => '22136',
                PID           => '16521',
                CMD           => '/usr/syno/sbin/winbindd -D',
                USER          => 'root'
        },
        {
                VIRTUALMEMORY => '24676',
                PID           => '16531',
                CMD           => '/usr/syno/sbin/smbd -D',
                USER          => 'root'
        },
        {
                VIRTUALMEMORY => '24788',
                PID           => '16538',
                CMD           => '/usr/syno/sbin/smbd -D',
                USER          => 'root'
        },
        {
                VIRTUALMEMORY => '1448',
                PID           => '17219',
                CMD           => '/sbin/portmap',
                USER          => '1'
        },
        {
                VIRTUALMEMORY => '0',
                PID           => '17222',
                CMD           => '[lockd]',
                USER          => 'root'
        },
        {
                VIRTUALMEMORY => '0',
                PID           => '17223',
                CMD           => '[nfsd4]',
                USER          => 'root'
        },
        {
                VIRTUALMEMORY => '0',
                PID           => '17224',
                CMD           => '[nfsd4_callbacks]',
                USER          => 'root'
        },
        {
                VIRTUALMEMORY => '0',
                PID           => '17225',
                CMD           => '[nfsd]',
                USER          => 'root'
        },
        {
                VIRTUALMEMORY => '0',
                PID           => '17226',
                CMD           => '[nfsd]',
                USER          => 'root'
        },
        {
                VIRTUALMEMORY => '0',
                PID           => '17227',
                CMD           => '[nfsd]',
                USER          => 'root'
        },
        {
                VIRTUALMEMORY => '0',
                PID           => '17228',
                CMD           => '[nfsd]',
                USER          => 'root'
        },
        {
                VIRTUALMEMORY => '0',
                PID           => '17229',
                CMD           => '[nfsd]',
                USER          => 'root'
        },
        {
                VIRTUALMEMORY => '0',
                PID           => '17230',
                CMD           => '[nfsd]',
                USER          => 'root'
        },
        {
                VIRTUALMEMORY => '0',
                PID           => '17231',
                CMD           => '[nfsd]',
                USER          => 'root'
        },
        {
                VIRTUALMEMORY => '0',
                PID           => '17232',
                CMD           => '[nfsd]',
                USER          => 'root'
        },
        {
                VIRTUALMEMORY => '7028',
                PID           => '17235',
                CMD           => '/usr/sbin/statd',
                USER          => 'root'
        },
        {
                VIRTUALMEMORY => '7096',
                PID           => '17238',
                CMD           => '/usr/sbin/mountd -p 892',
                USER          => 'root'
        },
        {
                VIRTUALMEMORY => '4748',
                PID           => '17401',
                CMD           => '/usr/sbin/crond',
                USER          => 'root'
        },
        {
                VIRTUALMEMORY => '20328',
                PID           => '17406',
                CMD           => '/usr/syno/bin/synomkthumbd',
                USER          => 'root'
        },
        {
                VIRTUALMEMORY => '20324',
                PID           => '17412',
                CMD           => '/usr/syno/sbin/synomkflvd',
                USER          => 'root'
        },
        {
                VIRTUALMEMORY => '13048',
                PID           => '18978',
                CMD           => 'sshd: root@pts/0',
                USER          => 'root'
        },
        {
                VIRTUALMEMORY => '4752',
                PID           => '18984',
                CMD           => '-ash',
                USER          => 'root'
        },
        {
                VIRTUALMEMORY => '0',
                PID           => '19872',
                CMD           => '[kworker/2:0]',
                USER          => 'root'
        },
        {
                VIRTUALMEMORY => '0',
                PID           => '21228',
                CMD           => '[md2_raid5]',
                USER          => 'root'
        },
        {
                VIRTUALMEMORY => '0',
                PID           => '25854',
                CMD           => '[kworker/1:2]',
                USER          => 'root'
        },
        {
                VIRTUALMEMORY => '12264',
                PID           => '28886',
                CMD           => '/usr/syno/apache/bin/httpd -f /usr/syno/apache/conf/httpd.conf-sys',
                USER          => 'root'
        },
        {
                VIRTUALMEMORY => '0',
                PID           => '29849',
                CMD           => '[jbd2/md2-8]',
                USER          => 'root'
        },
        {
                VIRTUALMEMORY => '0',
                PID           => '29850',
                CMD           => '[ext4-dio-unwrit]',
                USER          => 'root'
        },
        {
                VIRTUALMEMORY => '7188',
                PID           => '29896',
                CMD           => '/usr/syno/sbin/cupsd -C /usr/local/cups/cupsd.conf',
                USER          => 'root'
        },
        {
                VIRTUALMEMORY => '33336',
                PID           => '29971',
                CMD           => '/usr/syno/pgsql/bin/postgres -D /var/services/pgsql --config_file=/usr/syno/pgsql/etc/postgresql.conf --hba_file=/usr/syno/pgsql/',
                USER          => 'admin'
        },
        {
                VIRTUALMEMORY => '33336',
                PID           => '29973',
                CMD           => 'postgres: writer process   ',
                USER          => 'admin'
        },
        {
                VIRTUALMEMORY => '33336',
                PID           => '29974',
                CMD           => 'postgres: wal writer process   ',
                USER          => 'admin'
        },
        {
                VIRTUALMEMORY => '25132',
                PID           => '30086',
                CMD           => '/usr/syno/sbin/synoindexd',
                USER          => 'root'
        },
        {
                VIRTUALMEMORY => '2536',
                PID           => '30639',
                CMD           => '/bin/sh /usr/syno/mysql/bin/mysqld_safe --datadir=/volume1/@database/mysql --pid-file=/tmp/mysqld.pid --datadir=/volume1/@databas',
                USER          => 'root'
        },
        {
                VIRTUALMEMORY => '55416',
                PID           => '30706',
                CMD           => '/usr/syno/mysql/libexec/mysqld --basedir=/usr/syno/mysql --datadir=/volume1/@database/mysql --user=admin --max_allowed_packet=8M',
                USER          => 'admin'
        },
        {
                VIRTUALMEMORY => '55416',
                PID           => '30707',
                CMD           => '/usr/syno/mysql/libexec/mysqld --basedir=/usr/syno/mysql --datadir=/volume1/@database/mysql --user=admin --max_allowed_packet=8M',
                USER          => 'admin'
        },
        {
                VIRTUALMEMORY => '55416',
                PID           => '30708',
                CMD           => '/usr/syno/mysql/libexec/mysqld --basedir=/usr/syno/mysql --datadir=/volume1/@database/mysql --user=admin --max_allowed_packet=8M',
                USER          => 'admin'
        },
        {
                VIRTUALMEMORY => '55416',
                PID           => '30709',
                CMD           => '/usr/syno/mysql/libexec/mysqld --basedir=/usr/syno/mysql --datadir=/volume1/@database/mysql --user=admin --max_allowed_packet=8M',
                USER          => 'admin'
        },
        {
                VIRTUALMEMORY => '55416',
                PID           => '30710',
                CMD           => '/usr/syno/mysql/libexec/mysqld --basedir=/usr/syno/mysql --datadir=/volume1/@database/mysql --user=admin --max_allowed_packet=8M',
                USER          => 'admin'
        },
        {
                VIRTUALMEMORY => '55416',
                PID           => '30711',
                CMD           => '/usr/syno/mysql/libexec/mysqld --basedir=/usr/syno/mysql --datadir=/volume1/@database/mysql --user=admin --max_allowed_packet=8M',
                USER          => 'admin'
        },
        {
                VIRTUALMEMORY => '55416',
                PID           => '30712',
                CMD           => '/usr/syno/mysql/libexec/mysqld --basedir=/usr/syno/mysql --datadir=/volume1/@database/mysql --user=admin --max_allowed_packet=8M',
                USER          => 'admin'
        },
        {
                VIRTUALMEMORY => '55416',
                PID           => '30713',
                CMD           => '/usr/syno/mysql/libexec/mysqld --basedir=/usr/syno/mysql --datadir=/volume1/@database/mysql --user=admin --max_allowed_packet=8M',
                USER          => 'admin'
        },
        {
                VIRTUALMEMORY => '55416',
                PID           => '30714',
                CMD           => '/usr/syno/mysql/libexec/mysqld --basedir=/usr/syno/mysql --datadir=/volume1/@database/mysql --user=admin --max_allowed_packet=8M',
                USER          => 'admin'
        },
        {
                VIRTUALMEMORY => '55416',
                PID           => '30715',
                CMD           => '/usr/syno/mysql/libexec/mysqld --basedir=/usr/syno/mysql --datadir=/volume1/@database/mysql --user=admin --max_allowed_packet=8M',
                USER          => 'admin'
        },
        {
                VIRTUALMEMORY => '55416',
                PID           => '30716',
                CMD           => '/usr/syno/mysql/libexec/mysqld --basedir=/usr/syno/mysql --datadir=/volume1/@database/mysql --user=admin --max_allowed_packet=8M',
                USER          => 'admin'
        },
        {
                VIRTUALMEMORY => '9948',
                PID           => '30968',
                CMD           => '/usr/syno/sbin/sshd',
                USER          => 'root'
        }
    ]
);

my ($sec, $min, $hour, $day, $month, $year, $wday, $yday, $isdst) = localtime(time);
my $format = "%04d-%02d-%02d";
my $today    = sprintf($format, $year + 1900, $month + 1, $day);
my $this_day = sprintf($format, $year + 1900, $month + 1, 3);
my $this_year = sprintf("%04d", $year + 1900);
my %other_ps_tests = (
    linux => [
        {
            VIRTUALMEMORY => '3984',
            CPUUSAGE      => '0.0',
            PID           => '1',
            CMD           => 'init [5]',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '0',
            CPUUSAGE      => '0.0',
            PID           => '2',
            CMD           => '[kthreadd]',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '0',
            CPUUSAGE      => '0.0',
            PID           => '3',
            CMD           => '[ksoftirqd/0]',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '0',
            CPUUSAGE      => '0.0',
            PID           => '6',
            CMD           => '[migration/0]',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '0',
            CPUUSAGE      => '0.0',
            PID           => '7',
            CMD           => '[migration/1]',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '0',
            CPUUSAGE      => '0.0',
            PID           => '9',
            CMD           => '[ksoftirqd/1]',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '0',
            CPUUSAGE      => '0.0',
            PID           => '10',
            CMD           => '[kworker/0:1]',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '0',
            CPUUSAGE      => '0.0',
            PID           => '11',
            CMD           => '[cpuset]',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '0',
            CPUUSAGE      => '0.0',
            PID           => '12',
            CMD           => '[khelper]',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '0',
            CPUUSAGE      => '0.0',
            PID           => '13',
            CMD           => '[netns]',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '0',
            CPUUSAGE      => '0.0',
            PID           => '14',
            CMD           => '[pm]',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '0',
            CPUUSAGE      => '0.0',
            PID           => '15',
            CMD           => '[sync_supers]',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '0',
            CPUUSAGE      => '0.0',
            PID           => '16',
            CMD           => '[bdi-default]',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '0',
            CPUUSAGE      => '0.0',
            PID           => '17',
            CMD           => '[kintegrityd]',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '0',
            CPUUSAGE      => '0.0',
            PID           => '18',
            CMD           => '[kblockd]',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '0',
            CPUUSAGE      => '0.0',
            PID           => '19',
            CMD           => '[kacpid]',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '0',
            CPUUSAGE      => '0.0',
            PID           => '20',
            CMD           => '[kacpi_notify]',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '0',
            CPUUSAGE      => '0.0',
            PID           => '21',
            CMD           => '[kacpi_hotplug]',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '0',
            CPUUSAGE      => '0.0',
            PID           => '22',
            CMD           => '[kseriod]',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '0',
            CPUUSAGE      => '0.0',
            PID           => '23',
            CMD           => '[kworker/1:1]',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '0',
            CPUUSAGE      => '0.0',
            PID           => '24',
            CMD           => '[khungtaskd]',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '0',
            CPUUSAGE      => '0.0',
            PID           => '25',
            CMD           => '[kswapd0]',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '0',
            CPUUSAGE      => '0.0',
            PID           => '26',
            CMD           => '[ksmd]',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '0',
            CPUUSAGE      => '0.0',
            PID           => '27',
            CMD           => '[fsnotify_mark]',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '0',
            CPUUSAGE      => '0.0',
            PID           => '28',
            CMD           => '[aio]',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '0',
            CPUUSAGE      => '0.0',
            PID           => '29',
            CMD           => '[crypto]',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '0',
            CPUUSAGE      => '0.0',
            PID           => '32',
            CMD           => '[kpsmoused]',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '0',
            CPUUSAGE      => '0.0',
            PID           => '48',
            CMD           => '[ata_sff]',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '0',
            CPUUSAGE      => '0.0',
            PID           => '51',
            CMD           => '[scsi_eh_0]',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '0',
            CPUUSAGE      => '0.0',
            PID           => '52',
            CMD           => '[scsi_eh_1]',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '0',
            CPUUSAGE      => '0.0',
            PID           => '53',
            CMD           => '[scsi_eh_2]',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '0',
            CPUUSAGE      => '0.0',
            PID           => '54',
            CMD           => '[scsi_eh_3]',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '0',
            CPUUSAGE      => '0.0',
            PID           => '55',
            CMD           => '[scsi_eh_4]',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '0',
            CPUUSAGE      => '0.0',
            PID           => '56',
            CMD           => '[scsi_eh_5]',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '0',
            CPUUSAGE      => '0.0',
            PID           => '65',
            CMD           => '[jbd2/sda5-8]',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '0',
            CPUUSAGE      => '0.0',
            PID           => '66',
            CMD           => '[ext4-dio-unwrit]',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '6688',
            CPUUSAGE      => '0.0',
            PID           => '95',
            CMD           => '/sbin/udevd -d',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '0',
            CPUUSAGE      => '0.0',
            PID           => '482',
            CMD           => '[khubd]',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '0',
            CPUUSAGE      => '0.0',
            PID           => '515',
            CMD           => '[kvm-irqfd-clean]',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '0',
            CPUUSAGE      => '0.0',
            PID           => '570',
            CMD           => '[kconservative]',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '0',
            CPUUSAGE      => '0.0',
            PID           => '571',
            CMD           => '[kondemand]',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '0',
            CPUUSAGE      => '0.0',
            PID           => '572',
            CMD           => '[kstriped]',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '0',
            CPUUSAGE      => '0.0',
            PID           => '612',
            CMD           => '[pccardd]',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '16992',
            CPUUSAGE      => '0.0',
            PID           => '617',
            CMD           => '/sbin/mount.ntfs-3g /dev/sda3 /media/windows -o rw,umask=000',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '3996',
            CPUUSAGE      => '0.0',
            PID           => '745',
            CMD           => '/usr/sbin/acpid',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '13804',
            CPUUSAGE      => '0.0',
            PID           => '752',
            CMD           => 'dbus-daemon --system',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => '499',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '43376',
            CPUUSAGE      => '0.0',
            PID           => '770',
            CMD           => 'hald',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => '494',
            MEM           => '0.1'
        },
        {
            VIRTUALMEMORY => '249596',
            CPUUSAGE      => '0.0',
            PID           => '775',
            CMD           => '/usr/sbin/console-kit-daemon --no-daemon',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.1'
        },
        {
            VIRTUALMEMORY => '186280',
            CPUUSAGE      => '0.0',
            PID           => '788',
            CMD           => '/usr/lib64/polkit-1/polkitd',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.1'
        },
        {
            VIRTUALMEMORY => '22428',
            CPUUSAGE      => '0.0',
            PID           => '801',
            CMD           => 'hald-runner',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '0',
            CPUUSAGE      => '0.0',
            PID           => '873',
            CMD           => '[usbhid_resumer]',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '24548',
            CPUUSAGE      => '0.0',
            PID           => '879',
            CMD           => 'hald-addon-input: Listening on /dev/input/event4 /dev/input/event3 /dev/input/event2 /dev/input/event0 /dev/input/event9 /dev/input/event11',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '24556',
            CPUUSAGE      => '0.0',
            PID           => '888',
            CMD           => '/usr/lib64/hal/hald-addon-cpufreq',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '20008',
            CPUUSAGE      => '0.0',
            PID           => '889',
            CMD           => 'hald-addon-acpi: listening on acpid socket /var/run/acpid.socket',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => '494',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '56768',
            CPUUSAGE      => '0.0',
            PID           => '948',
            CMD           => '/usr/sbin/gdm-binary -nodaemon',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '14640',
            CPUUSAGE      => '0.0',
            PID           => '970',
            CMD           => 'gpg-agent --keep-display --daemon --write-env-file /root/.gnupg/gpg-agent-info',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '79244',
            CPUUSAGE      => '0.0',
            PID           => '971',
            CMD           => '/usr/lib64/gdm-simple-slave --display-id /org/gnome/DisplayManager/Display1',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.1'
        },
        {
            VIRTUALMEMORY => '137752',
            CPUUSAGE      => '4.1',
            PID           => '974',
            CMD           => '/usr/bin/Xorg :0 -br -verbose -auth /var/run/gdm/auth-for-gdm-U67gq5/database -nolisten tcp vt7',
            TTY           => 'tty7',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '1.0'
        },
        {
            VIRTUALMEMORY => '0',
            CPUUSAGE      => '0.0',
            PID           => '978',
            CMD           => '[i915]',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '24540',
            CPUUSAGE      => '0.0',
            PID           => '984',
            CMD           => '/usr/lib64/hal/hald-addon-generic-backlight',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '24544',
            CPUUSAGE      => '0.0',
            PID           => '1034',
            CMD           => '/usr/lib64/hal/hald-addon-rfkill-killswitch',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '0',
            CPUUSAGE      => '0.0',
            PID           => '1035',
            CMD           => '[kmmcd]',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '0',
            CPUUSAGE      => '0.0',
            PID           => '1036',
            CMD           => '[khpsbpkt]',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '0',
            CPUUSAGE      => '0.0',
            PID           => '1055',
            CMD           => '[cfg80211]',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '0',
            CPUUSAGE      => '0.0',
            PID           => '1059',
            CMD           => '[knodemgrd_0]',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '0',
            CPUUSAGE      => '0.0',
            PID           => '1067',
            CMD           => '[iwlagn]',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '0',
            CPUUSAGE      => '0.0',
            PID           => '1070',
            CMD           => '[phy0]',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '0',
            CPUUSAGE      => '0.0',
            PID           => '1090',
            CMD           => '[hd-audio0]',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '226424',
            CPUUSAGE      => '0.0',
            PID           => '1213',
            CMD           => '/usr/lib64/polkit-gnome-authentication-agent-1',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'gdm',
            MEM           => '0.2'
        },
        {
            VIRTUALMEMORY => '98944',
            CPUUSAGE      => '0.0',
            PID           => '1233',
            CMD           => '/usr/lib64/gdm-session-worker',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.1'
        },
        {
            VIRTUALMEMORY => '121360',
            CPUUSAGE      => '0.0',
            PID           => '1244',
            CMD           => '/usr/lib64/upowerd',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.1'
        },
        {
            VIRTUALMEMORY => '24708',
            CPUUSAGE      => '0.0',
            PID           => '1288',
            CMD           => 'bash',
            TTY           => 'pts/1',
            STARTED       => $today . ' 23:00',
            USER          => 'root',
            MEM           => '0.1'
        },
        {
            VIRTUALMEMORY => '26388',
            CPUUSAGE      => '0.0',
            PID           => '1335',
            CMD           => '/usr/bin/atop -a -w /var/log/atop/atop_20101027 600',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.5'
        },
        {
            VIRTUALMEMORY => '6056',
            CPUUSAGE      => '0.0',
            PID           => '1357',
            CMD           => 'portreserve',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '11328',
            CPUUSAGE      => '0.0',
            PID           => '1366',
            CMD           => 'irqbalance',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '12380',
            CPUUSAGE      => '0.0',
            PID           => '1371',
            CMD           => '/usr/sbin/atd -l 1.8',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'daemon',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '0',
            CPUUSAGE      => '0.0',
            PID           => '1450',
            CMD           => '[flush-8:0]',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '6684',
            CPUUSAGE      => '0.0',
            PID           => '1614',
            CMD           => '/sbin/udevd -d',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '6684',
            CPUUSAGE      => '0.0',
            PID           => '1615',
            CMD           => '/sbin/udevd -d',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '24208',
            CPUUSAGE      => '0.0',
            PID           => '2051',
            CMD           => 'supervising syslog-ng',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '63076',
            CPUUSAGE      => '0.0',
            PID           => '2056',
            CMD           => 'syslog-ng',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.1'
        },
        {
            VIRTUALMEMORY => '158984',
            CPUUSAGE      => '0.0',
            PID           => '2062',
            CMD           => 'NetworkManager --pid-file=/var/run/NetworkManager/NetworkManager.pid',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.1'
        },
        {
            VIRTUALMEMORY => '60192',
            CPUUSAGE      => '0.0',
            PID           => '2079',
            CMD           => '/usr/sbin/modem-manager',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '25656',
            CPUUSAGE      => '0.0',
            PID           => '2154',
            CMD           => 'avahi-daemon: running [beria.local]',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'avahi',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '25532',
            CPUUSAGE      => '0.0',
            PID           => '2159',
            CMD           => 'avahi-daemon: chroot helper',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'avahi',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '14772',
            CPUUSAGE      => '0.0',
            PID           => '2161',
            CMD           => 'crond',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '43528',
            CPUUSAGE      => '0.0',
            PID           => '2180',
            CMD           => '/usr/sbin/sshd',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '21584',
            CPUUSAGE      => '0.0',
            PID           => '2186',
            CMD           => '/usr/sbin/wpa_supplicant -u',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '18272',
            CPUUSAGE      => '0.3',
            PID           => '2193',
            CMD           => '/usr/sbin/preload --verbose 1',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.2'
        },
        {
            VIRTUALMEMORY => '48908',
            CPUUSAGE      => '0.0',
            PID           => '2217',
            CMD           => '/usr/sbin/snmpd -Lsd -Lf /dev/null -p /var/run/snmpd -a -I -lmSensors',
            TTY           => '?',
            STARTED       => $today . ' 21:29',
            USER          => 'root',
            MEM           => '0.1'
        },
        {
            VIRTUALMEMORY => '9868',
            CPUUSAGE      => '0.0',
            PID           => '2726',
            CMD           => '/sbin/dhclient -d -4 -sf /usr/lib64/nm-dhcp-client.action -pf /var/run/dhclient-eth0.pid -lf /var/lib/dhcp/dhclient-5fb06bd0-0bb0-7ffb-45f1-d6edd65f3e03-eth0.lease -cf /var/run/nm-dhclient-eth0.conf eth0',
            TTY           => '?',
            STARTED       => $today . ' 21:30',
            USER          => 'root',
            MEM           => '0.1'
        },
        {
            VIRTUALMEMORY => '0',
            CPUUSAGE      => '0.0',
            PID           => '2843',
            CMD           => '[kauditd]',
            TTY           => '?',
            STARTED       => $today . ' 21:30',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '0',
            CPUUSAGE      => '0.0',
            PID           => '2883',
            CMD           => '[kdmflush]',
            TTY           => '?',
            STARTED       => $today . ' 21:30',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '0',
            CPUUSAGE      => '0.0',
            PID           => '2885',
            CMD           => '[kcryptd_io]',
            TTY           => '?',
            STARTED       => $today . ' 21:30',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '0',
            CPUUSAGE      => '0.0',
            PID           => '2886',
            CMD           => '[kcryptd]',
            TTY           => '?',
            STARTED       => $today . ' 21:30',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '0',
            CPUUSAGE      => '0.0',
            PID           => '2896',
            CMD           => '[jbd2/dm-0-8]',
            TTY           => '?',
            STARTED       => $today . ' 21:30',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '0',
            CPUUSAGE      => '0.0',
            PID           => '2897',
            CMD           => '[ext4-dio-unwrit]',
            TTY           => '?',
            STARTED       => $today . ' 21:30',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '132132',
            CPUUSAGE      => '0.0',
            PID           => '2901',
            CMD           => '/usr/bin/gnome-keyring-daemon --daemonize --login',
            TTY           => '?',
            STARTED       => $today . ' 21:30',
            USER          => '500',
            MEM           => '0.1'
        },
        {
            VIRTUALMEMORY => '230244',
            CPUUSAGE      => '0.0',
            PID           => '2911',
            CMD           => 'gnome-session',
            TTY           => '?',
            STARTED       => $today . ' 21:30',
            USER          => '500',
            MEM           => '0.2'
        },
        {
            VIRTUALMEMORY => '24544',
            CPUUSAGE      => '0.0',
            PID           => '2938',
            CMD           => 'gpg-agent --keep-display --daemon --write-env-file /home/guillaume/.gnupg/gpg-agent-info',
            TTY           => '?',
            STARTED       => $today . ' 21:30',
            USER          => '500',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '26332',
            CPUUSAGE      => '0.0',
            PID           => '2949',
            CMD           => 'ntpd -u ntp:ntp -p /var/run/ntpd.pid',
            TTY           => '?',
            STARTED       => $today . ' 21:30',
            USER          => 'ntp',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '3964',
            CPUUSAGE      => '0.0',
            PID           => '2958',
            CMD           => '/sbin/mingetty tty1',
            TTY           => 'tty1',
            STARTED       => $today . ' 21:30',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '3964',
            CPUUSAGE      => '0.0',
            PID           => '2959',
            CMD           => '/sbin/mingetty tty2',
            TTY           => 'tty2',
            STARTED       => $today . ' 21:30',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '3964',
            CPUUSAGE      => '0.0',
            PID           => '2960',
            CMD           => '/sbin/mingetty tty3',
            TTY           => 'tty3',
            STARTED       => $today . ' 21:30',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '3964',
            CPUUSAGE      => '0.0',
            PID           => '2961',
            CMD           => '/sbin/mingetty tty4',
            TTY           => 'tty4',
            STARTED       => $today . ' 21:30',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '3964',
            CPUUSAGE      => '0.0',
            PID           => '2962',
            CMD           => '/sbin/mingetty tty5',
            TTY           => 'tty5',
            STARTED       => $today . ' 21:30',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '3964',
            CPUUSAGE      => '0.0',
            PID           => '2963',
            CMD           => '/sbin/mingetty tty6',
            TTY           => 'tty6',
            STARTED       => $today . ' 21:30',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '12300',
            CPUUSAGE      => '0.0',
            PID           => '2967',
            CMD           => '/usr/bin/ssh-agent -- /usr/share/X11/xdm/Xsession GNOME',
            TTY           => '?',
            STARTED       => $today . ' 21:30',
            USER          => '500',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '19932',
            CPUUSAGE      => '0.0',
            PID           => '3016',
            CMD           => '/usr/bin/dbus-launch --exit-with-session --sh-syntax',
            TTY           => '?',
            STARTED       => $today . ' 21:30',
            USER          => '500',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '14204',
            CPUUSAGE      => '0.0',
            PID           => '3017',
            CMD           => '/usr/bin/dbus-daemon --fork --print-pid 5 --print-address 7 --session',
            TTY           => '?',
            STARTED       => $today . ' 21:30',
            USER          => '500',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '103212',
            CPUUSAGE      => '0.0',
            PID           => '3039',
            CMD           => 's2u --daemon=yes',
            TTY           => '?',
            STARTED       => $today . ' 21:30',
            USER          => '500',
            MEM           => '0.1'
        },
        {
            VIRTUALMEMORY => '57044',
            CPUUSAGE      => '0.0',
            PID           => '3045',
            CMD           => '/usr/lib64/gconfd-2',
            TTY           => '?',
            STARTED       => $today . ' 21:30',
            USER          => '500',
            MEM           => '0.1'
        },
        {
            VIRTUALMEMORY => '283628',
            CPUUSAGE      => '0.0',
            PID           => '3057',
            CMD           => '/usr/bin/pulseaudio --start --log-target=syslog',
            TTY           => '?',
            STARTED       => $today . ' 21:30',
            USER          => '500',
            MEM           => '0.1'
        },
        {
            VIRTUALMEMORY => '384604',
            CPUUSAGE      => '0.0',
            PID           => '3058',
            CMD           => '/usr/lib64/gnome-settings-daemon',
            TTY           => '?',
            STARTED       => $today . ' 21:30',
            USER          => '500',
            MEM           => '0.4'
        },
        {
            VIRTUALMEMORY => '162200',
            CPUUSAGE      => '0.0',
            PID           => '3060',
            CMD           => '/usr/lib64/rtkit-daemon',
            TTY           => '?',
            STARTED       => $today . ' 21:30',
            USER          => 'rtkit',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '178856',
            CPUUSAGE      => '0.0',
            PID           => '3065',
            CMD           => '/usr/lib64/pulse/gconf-helper',
            TTY           => '?',
            STARTED       => $today . ' 21:30',
            USER          => '500',
            MEM           => '0.1'
        },
        {
            VIRTUALMEMORY => '50084',
            CPUUSAGE      => '0.0',
            PID           => '3070',
            CMD           => '/usr/lib64/gvfsd',
            TTY           => '?',
            STARTED       => $today . ' 21:30',
            USER          => '500',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '266600',
            CPUUSAGE      => '0.0',
            PID           => '3075',
            CMD           => '/usr/lib64//gvfs-fuse-daemon /home/guillaume/.gvfs',
            TTY           => '?',
            STARTED       => $today . ' 21:30',
            USER          => '500',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '404296',
            CPUUSAGE      => '0.9',
            PID           => '3079',
            CMD           => '/usr/bin/metacity',
            TTY           => '?',
            STARTED       => $today . ' 21:30',
            USER          => '500',
            MEM           => '0.5'
        },
        {
            VIRTUALMEMORY => '287296',
            CPUUSAGE      => '0.0',
            PID           => '3090',
            CMD           => '/usr/lib64/gvfs-gdu-volume-monitor',
            TTY           => '?',
            STARTED       => $today . ' 21:30',
            USER          => '500',
            MEM           => '0.1'
        },
        {
            VIRTUALMEMORY => '125056',
            CPUUSAGE      => '0.0',
            PID           => '3092',
            CMD           => '/usr/lib64/udisks-daemon',
            TTY           => '?',
            STARTED       => $today . ' 21:30',
            USER          => 'root',
            MEM           => '0.1'
        },
        {
            VIRTUALMEMORY => '42744',
            CPUUSAGE      => '0.0',
            PID           => '3093',
            CMD           => 'udisks-daemon: not polling any devices',
            TTY           => '?',
            STARTED       => $today . ' 21:30',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '430428',
            CPUUSAGE      => '0.0',
            PID           => '3095',
            CMD           => 'gnome-panel',
            TTY           => '?',
            STARTED       => $today . ' 21:30',
            USER          => '500',
            MEM           => '0.5'
        },
        {
            VIRTUALMEMORY => '63616',
            CPUUSAGE      => '0.0',
            PID           => '3103',
            CMD           => '/usr/lib64/gvfs-gphoto2-volume-monitor',
            TTY           => '?',
            STARTED       => $today . ' 21:30',
            USER          => '500',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '638940',
            CPUUSAGE      => '0.0',
            PID           => '3104',
            CMD           => 'nautilus',
            TTY           => '?',
            STARTED       => $today . ' 21:30',
            USER          => '500',
            MEM           => '0.6'
        },
        {
            VIRTUALMEMORY => '373692',
            CPUUSAGE      => '0.0',
            PID           => '3105',
            CMD           => 'nm-applet --sm-disable',
            TTY           => '?',
            STARTED       => $today . ' 21:30',
            USER          => '500',
            MEM           => '0.4'
        },
        {
            VIRTUALMEMORY => '345712',
            CPUUSAGE      => '0.0',
            PID           => '3108',
            CMD           => '/usr/lib64/bonobo-activation-server --ac-activate --ior-output-fd=23',
            TTY           => '?',
            STARTED       => $today . ' 21:30',
            USER          => '500',
            MEM           => '0.1'
        },
        {
            VIRTUALMEMORY => '208244',
            CPUUSAGE      => '0.0',
            PID           => '3109',
            CMD           => 'bluetooth-applet',
            TTY           => '?',
            STARTED       => $today . ' 21:30',
            USER          => '500',
            MEM           => '0.2'
        },
        {
            VIRTUALMEMORY => '292036',
            CPUUSAGE      => '0.0',
            PID           => '3110',
            CMD           => 'gnome-power-manager',
            TTY           => '?',
            STARTED       => $today . ' 21:30',
            USER          => '500',
            MEM           => '0.3'
        },
        {
            VIRTUALMEMORY => '142256',
            CPUUSAGE      => '0.0',
            PID           => '3112',
            CMD           => 'pam-panel-icon',
            TTY           => '?',
            STARTED       => $today . ' 21:30',
            USER          => '500',
            MEM           => '0.2'
        },
        {
            VIRTUALMEMORY => '208004',
            CPUUSAGE      => '0.0',
            PID           => '3115',
            CMD           => '/usr/lib64/polkit-gnome-authentication-agent-1',
            TTY           => '?',
            STARTED       => $today . ' 21:30',
            USER          => '500',
            MEM           => '0.2'
        },
        {
            VIRTUALMEMORY => '169596',
            CPUUSAGE      => '0.0',
            PID           => '3116',
            CMD           => '/usr/lib64/gdu-notification-daemon',
            TTY           => '?',
            STARTED       => $today . ' 21:30',
            USER          => '500',
            MEM           => '0.2'
        },
        {
            VIRTUALMEMORY => '308936',
            CPUUSAGE      => '0.0',
            PID           => '3119',
            CMD           => 'gnome-volume-control-applet',
            TTY           => '?',
            STARTED       => $today . ' 21:30',
            USER          => '500',
            MEM           => '0.3'
        },
        {
            VIRTUALMEMORY => '342916',
            CPUUSAGE      => '0.0',
            PID           => '3129',
            CMD           => '/usr/lib64/notification-area-applet',
            TTY           => '?',
            STARTED       => $today . ' 21:30',
            USER          => '500',
            MEM           => '0.2'
        },
        {
            VIRTUALMEMORY => '352772',
            CPUUSAGE      => '0.0',
            PID           => '3130',
            CMD           => '/usr/lib64/wnck-applet',
            TTY           => '?',
            STARTED       => $today . ' 21:30',
            USER          => '500',
            MEM           => '0.3'
        },
        {
            VIRTUALMEMORY => '434404',
            CPUUSAGE      => '0.0',
            PID           => '3131',
            CMD           => '/usr/lib64/clock-applet',
            TTY           => '?',
            STARTED       => $today . ' 21:30',
            USER          => '500',
            MEM           => '0.5'
        },
        {
            VIRTUALMEMORY => '12372',
            CPUUSAGE      => '0.0',
            PID           => '3132',
            CMD           => '/sbin/pam_timestamp_check -d root',
            TTY           => '?',
            STARTED       => $today . ' 21:30',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '54576',
            CPUUSAGE      => '0.0',
            PID           => '3145',
            CMD           => '/usr/lib64/gvfsd-trash --spawner :1.12 /org/gtk/gvfs/exec_spaw/0',
            TTY           => '?',
            STARTED       => $today . ' 21:30',
            USER          => '500',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '244512',
            CPUUSAGE      => '0.0',
            PID           => '3153',
            CMD           => 'gnome-screensaver',
            TTY           => '?',
            STARTED       => $today . ' 21:30',
            USER          => '500',
            MEM           => '0.4'
        },
        {
            VIRTUALMEMORY => '50028',
            CPUUSAGE      => '0.0',
            PID           => '3155',
            CMD           => '/usr/lib64/gvfsd-metadata',
            TTY           => '?',
            STARTED       => $today . ' 21:30',
            USER          => '500',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '0',
            CPUUSAGE      => '0.0',
            PID           => '3157',
            CMD           => '[flush-252:0]',
            TTY           => '?',
            STARTED       => $today . ' 21:30',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '0',
            CPUUSAGE      => '0.0',
            PID           => '8703',
            CMD           => '[kworker/u:0]',
            TTY           => '?',
            STARTED       => $today . ' 23:11',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '386108',
            CPUUSAGE      => '0.1',
            PID           => '11452',
            CMD           => 'gnome-terminal',
            TTY           => '?',
            STARTED       => $today . ' 21:39',
            USER          => '500',
            MEM           => '0.5'
        },
        {
            VIRTUALMEMORY => '8120',
            CPUUSAGE      => '0.0',
            PID           => '11455',
            CMD           => 'gnome-pty-helper',
            TTY           => '?',
            STARTED       => $today . ' 21:39',
            USER          => '500',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '0',
            CPUUSAGE      => '0.0',
            PID           => '13767',
            CMD           => '[kworker/1:2]',
            TTY           => '?',
            STARTED       => $today . ' 22:28',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '0',
            CPUUSAGE      => '0.0',
            PID           => '26415',
            CMD           => '[kworker/0:2]',
            TTY           => '?',
            STARTED       => $today . ' 23:42',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '24824',
            CPUUSAGE      => '0.0',
            PID           => '28181',
            CMD           => 'bash',
            TTY           => 'pts/1',
            STARTED       => $today . ' 22:02',
            USER          => '500',
            MEM           => '0.1'
        },
        {
            VIRTUALMEMORY => '0',
            CPUUSAGE      => '0.0',
            PID           => '29659',
            CMD           => '[kworker/0:0]',
            TTY           => '?',
            STARTED       => $today . ' 23:48',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '0',
            CPUUSAGE      => '0.0',
            PID           => '30184',
            CMD           => '[kworker/u:2]',
            TTY           => '?',
            STARTED       => $today . ' 23:49',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '0',
            CPUUSAGE      => '0.0',
            PID           => '30244',
            CMD           => '[kworker/u:1]',
            TTY           => '?',
            STARTED       => $today . ' 22:54',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '8580',
            CPUUSAGE      => '0.0',
            PID           => '31822',
            CMD           => 'ps aux',
            TTY           => 'pts/1',
            STARTED       => $today . ' 23:52',
            USER          => '500',
            MEM           => '0.0'
        }
    ],
    macos => [
        {
            VIRTUALMEMORY => '2817480',
            CPUUSAGE      => '3.4',
            PID           => '1794',
            CMD           => '/Applications/Utilities/Terminal.app/Contents/MacOS/Terminal -psn_0_548998',
            TTY           => '??',
            STARTED       => $this_day,
            USER          => 'rousse',
            MEM           => '0.9'
        },
        {
            VIRTUALMEMORY => '5186628',
            CPUUSAGE      => '0.5',
            PID           => '1688',
            CMD           => '/Applications/Safari.app/Contents/MacOS/Safari -psn_0_483446',
            TTY           => '??',
            STARTED       => $this_day,
            USER          => 'rousse',
            MEM           => '6.4'
        },
        {
            VIRTUALMEMORY => '2771404',
            CPUUSAGE      => '0.4',
            PID           => '1614',
            CMD           => '/System/Library/Frameworks/ApplicationServices.framework/Frameworks/CoreGraphics.framework/Resources/WindowServer -daemon',
            TTY           => '??',
            STARTED       => $this_day,
            USER          => '_windowserver',
            MEM           => '1.5'
        },
        {
            VIRTUALMEMORY => '2452160',
            CPUUSAGE      => '0.1',
            PID           => '15',
            CMD           => '/usr/sbin/DirectoryService',
            TTY           => '??',
            STARTED       => $this_year . '-10-05',
            USER          => 'root',
            MEM           => '0.2'
        },
        {
            VIRTUALMEMORY => '2435468',
            CPUUSAGE      => '0.0',
            PID           => '28820',
            CMD           => '-bash',
            TTY           => 's002',
            STARTED       => $today . ' 10:08PM',
            USER          => 'rousse',
            MEM           => '0.1'
        },
        {
            VIRTUALMEMORY => '2436056',
            CPUUSAGE      => '0.0',
            PID           => '28819',
            CMD           => 'login -pf rousse',
            TTY           => 's002',
            STARTED       => $today . ' 10:08PM',
            USER          => 'root',
            MEM           => '0.1'
        },
        {
            VIRTUALMEMORY => '2493424',
            CPUUSAGE      => '0.0',
            PID           => '28611',
            CMD           => '/Applications/MacVim.app/Contents/MacOS/Vim -f -g lib/FusionInventory/Agent/Tools/Unix.pm',
            TTY           => '??',
            STARTED       => $today . ' 9:57PM',
            USER          => 'rousse',
            MEM           => '0.5'
        },
        {
            VIRTUALMEMORY => '2449852',
            CPUUSAGE      => '0.0',
            PID           => '28437',
            CMD           => 't/transmitter/connection.t (proxy)',
            TTY           => 's001',
            STARTED       => $today . ' 9:48PM',
            USER          => 'rousse',
            MEM           => '0.1'
        },
        {
            VIRTUALMEMORY => '2756744',
            CPUUSAGE      => '0.0',
            PID           => '26235',
            CMD           => '/System/Library/CoreServices/SystemUIServer.app/Contents/MacOS/SystemUIServer',
            TTY           => '??',
            STARTED       => sprintf($format, $year + 1900, $month + 1, 9),
            USER          => 'rousse',
            MEM           => '0.5'
        },
        {
            VIRTUALMEMORY => '2470032',
            CPUUSAGE      => '0.0',
            PID           => '25404',
            CMD           => '/usr/libexec/kextd',
            TTY           => '??',
            STARTED       => sprintf($format, $year + 1900, $month + 1, 5),
            USER          => 'root',
            MEM           => '0.3'
        },
        {
            VIRTUALMEMORY => '2457284',
            CPUUSAGE      => '0.0',
            PID           => '1902',
            CMD           => '/usr/bin/ssh-agent -l',
            TTY           => '??',
            STARTED       => $this_day,
            USER          => 'rousse',
            MEM           => '0.1'
        },
        {
            VIRTUALMEMORY => '2435468',
            CPUUSAGE      => '0.0',
            PID           => '1891',
            CMD           => '-bash',
            TTY           => 's001',
            STARTED       => $this_day,
            USER          => 'rousse',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '2436056',
            CPUUSAGE      => '0.0',
            PID           => '1890',
            CMD           => 'login -pf rousse',
            TTY           => 's001',
            STARTED       => $this_day,
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '2435468',
            CPUUSAGE      => '0.0',
            PID           => '1875',
            CMD           => 'bash',
            TTY           => 's000',
            STARTED       => $this_day,
            USER          => 'rousse',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '2435468',
            CPUUSAGE      => '0.0',
            PID           => '1798',
            CMD           => '-bash',
            TTY           => 's000',
            STARTED       => $this_day,
            USER          => 'rousse',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '2436056',
            CPUUSAGE      => '0.0',
            PID           => '1797',
            CMD           => 'login -pf rousse',
            TTY           => 's000',
            STARTED       => $this_day,
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '2787440',
            CPUUSAGE      => '0.0',
            PID           => '1732',
            CMD           => '/Applications/MacVim.app/Contents/MacOS/MacVim -psn_0_524416',
            TTY           => '??',
            STARTED       => $this_day,
            USER          => 'rousse',
            MEM           => '0.7'
        },
        {
            VIRTUALMEMORY => '2467120',
            CPUUSAGE      => '0.0',
            PID           => '1725',
            CMD           => '/System/Library/Services/AppleSpell.service/Contents/MacOS/AppleSpell -psn_0_520319',
            TTY           => '??',
            STARTED       => $this_day,
            USER          => 'rousse',
            MEM           => '0.1'
        },
        {
            VIRTUALMEMORY => '2772440',
            CPUUSAGE      => '0.0',
            PID           => '1720',
            CMD           => '/Applications/TextEdit.app/Contents/MacOS/TextEdit -psn_0_512125',
            TTY           => '??',
            STARTED       => $this_day,
            USER          => 'rousse',
            MEM           => '0.2'
        },
        {
            VIRTUALMEMORY => '2457564',
            CPUUSAGE      => '0.0',
            PID           => '1697',
            CMD           => '/System/Library/Frameworks/WebKit.framework/WebKitPluginAgent',
            TTY           => '??',
            STARTED       => $this_day,
            USER          => 'rousse',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '2463248',
            CPUUSAGE      => '0.0',
            PID           => '1657',
            CMD           => '/Applications/iTunes.app/Contents/Resources/iTunesHelper.app/Contents/MacOS/iTunesHelper -psn_0_458864',
            TTY           => '??',
            STARTED       => $this_day,
            USER          => 'rousse',
            MEM           => '0.1'
        },
        {
            VIRTUALMEMORY => '2731864',
            CPUUSAGE      => '0.0',
            PID           => '1655',
            CMD           => '/System/Library/CoreServices/AirPort Base Station Agent.app/Contents/MacOS/AirPort Base Station Agent -launchd -allowquit',
            TTY           => '??',
            STARTED       => $this_day,
            USER          => 'rousse',
            MEM           => '0.1'
        },
        {
            VIRTUALMEMORY => '2460332',
            CPUUSAGE      => '0.0',
            PID           => '1649',
            CMD           => '/usr/libexec/UserEventAgent -l Aqua',
            TTY           => '??',
            STARTED       => $this_day,
            USER          => 'rousse',
            MEM           => '0.2'
        },
        {
            VIRTUALMEMORY => '2435928',
            CPUUSAGE      => '0.0',
            PID           => '1644',
            CMD           => '/usr/sbin/pboard',
            TTY           => '??',
            STARTED       => $this_day,
            USER          => 'rousse',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '2480636',
            CPUUSAGE      => '0.0',
            PID           => '1638',
            CMD           => '/System/Library/Frameworks/ApplicationServices.framework/Frameworks/ATS.framework/Support/fontd',
            TTY           => '??',
            STARTED       => $this_day,
            USER          => 'rousse',
            MEM           => '0.1'
        },
        {
            VIRTUALMEMORY => '2831524',
            CPUUSAGE      => '0.0',
            PID           => '1634',
            CMD           => '/System/Library/CoreServices/Finder.app/Contents/MacOS/Finder',
            TTY           => '??',
            STARTED       => $this_day,
            USER          => 'rousse',
            MEM           => '1.0'
        },
        {
            VIRTUALMEMORY => '2799120',
            CPUUSAGE      => '0.0',
            PID           => '1632',
            CMD           => '/System/Library/CoreServices/Dock.app/Contents/MacOS/Dock',
            TTY           => '??',
            STARTED       => $this_day,
            USER          => 'rousse',
            MEM           => '0.6'
        },
        {
            VIRTUALMEMORY => '2775356',
            CPUUSAGE      => '0.0',
            PID           => '1613',
            CMD           => '/System/Library/CoreServices/loginwindow.app/Contents/MacOS/loginwindow console',
            TTY           => '??',
            STARTED       => $this_day,
            USER          => 'rousse',
            MEM           => '0.3'
        },
        {
            VIRTUALMEMORY => '2458512',
            CPUUSAGE      => '0.0',
            PID           => '590',
            CMD           => '/usr/sbin/cupsd -l',
            TTY           => '??',
            STARTED       => $this_year . '-10-05',
            USER          => 'root',
            MEM           => '0.1'
        },
        {
            VIRTUALMEMORY => '2456172',
            CPUUSAGE      => '0.0',
            PID           => '100',
            CMD           => '/sbin/launchd',
            TTY           => '??',
            STARTED       => $this_year . '-10-05',
            USER          => 'rousse',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '2453812',
            CPUUSAGE      => '0.0',
            PID           => '76',
            CMD           => '/usr/sbin/coreaudiod',
            TTY           => '??',
            STARTED       => $this_year . '-10-05',
            USER          => '_coreaudiod',
            MEM           => '0.3'
        },
        {
            VIRTUALMEMORY => '2438060',
            CPUUSAGE      => '0.0',
            PID           => '67',
            CMD           => '/System/Library/Frameworks/OpenGL.framework/Versions/A/Libraries/cvmsServ',
            TTY           => '??',
            STARTED       => $this_year . '-10-05',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '2497488',
            CPUUSAGE      => '0.0',
            PID           => '50',
            CMD           => '/System/Library/CoreServices/coreservicesd',
            TTY           => '??',
            STARTED       => $this_year . '-10-05',
            USER          => 'root',
            MEM           => '1.1'
        },
        {
            VIRTUALMEMORY => '2445648',
            CPUUSAGE      => '0.0',
            PID           => '41',
            CMD           => 'autofsd',
            TTY           => '??',
            STARTED       => $this_year . '-10-05',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '2434784',
            CPUUSAGE      => '0.0',
            PID           => '35',
            CMD           => '/sbin/dynamic_pager -F /private/var/vm/swapfile',
            TTY           => '??',
            STARTED       => $this_year . '-10-05',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '2451468',
            CPUUSAGE      => '0.0',
            PID           => '33',
            CMD           => '/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/CarbonCore.framework/Versions/A/Support/fseventsd',
            TTY           => '??',
            STARTED       => $this_year . '-10-05',
            USER          => 'root',
            MEM           => '0.1'
        },
        {
            VIRTUALMEMORY => '2446680',
            CPUUSAGE      => '0.0',
            PID           => '32',
            CMD           => '/usr/libexec/hidd',
            TTY           => '??',
            STARTED       => $this_year . '-10-05',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '2446768',
            CPUUSAGE      => '0.0',
            PID           => '30',
            CMD           => '/usr/sbin/KernelEventAgent',
            TTY           => '??',
            STARTED       => $this_year . '-10-05',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '2459112',
            CPUUSAGE      => '0.0',
            PID           => '28',
            CMD           => '/usr/sbin/mDNSResponder -launchd',
            TTY           => '??',
            STARTED       => $this_year . '-10-05',
            USER          => '_mdnsresponder',
            MEM           => '0.1'
        },
        {
            VIRTUALMEMORY => '2594096',
            CPUUSAGE      => '0.0',
            PID           => '27',
            CMD           => '/System/Library/Frameworks/CoreServices.framework/Frameworks/Metadata.framework/Support/mds',
            TTY           => '??',
            STARTED       => $this_year . '-10-05',
            USER          => 'root',
            MEM           => '1.5'
        },
        {
            VIRTUALMEMORY => '2459872',
            CPUUSAGE      => '0.0',
            PID           => '24',
            CMD           => '/usr/sbin/securityd -i',
            TTY           => '??',
            STARTED       => $this_year . '-10-05',
            USER          => 'root',
            MEM           => '0.1'
        },
        {
            VIRTUALMEMORY => '90960',
            CPUUSAGE      => '0.0',
            PID           => '21',
            CMD           => '/System/Library/PrivateFrameworks/MobileDevice.framework/Versions/A/Resources/usbmuxd -launchd',
            TTY           => '??',
            STARTED       => $this_year . '-10-05',
            USER          => '_usbmuxd',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '2435212',
            CPUUSAGE      => '0.0',
            PID           => '19',
            CMD           => '/usr/sbin/ntpd -c /private/etc/ntp-restrict.conf -n -g -p /var/run/ntpd.pid -f /var/db/ntp.drift',
            TTY           => '??',
            STARTED       => $this_year . '-10-05',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '2461200',
            CPUUSAGE      => '0.0',
            PID           => '17',
            CMD           => '/usr/sbin/blued',
            TTY           => '??',
            STARTED       => $this_year . '-10-05',
            USER          => 'root',
            MEM           => '0.1'
        },
        {
            VIRTUALMEMORY => '2446660',
            CPUUSAGE      => '0.0',
            PID           => '16',
            CMD           => '/usr/sbin/distnoted',
            TTY           => '??',
            STARTED       => $this_year . '-10-05',
            USER          => 'daemon',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '2457096',
            CPUUSAGE      => '0.0',
            PID           => '14',
            CMD           => '/usr/sbin/syslogd',
            TTY           => '??',
            STARTED       => $this_year . '-10-05',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '2474544',
            CPUUSAGE      => '0.0',
            PID           => '13',
            CMD           => '/usr/libexec/configd',
            TTY           => '??',
            STARTED       => $this_year . '-10-05',
            USER          => 'root',
            MEM           => '0.1'
        },
        {
            VIRTUALMEMORY => '2446808',
            CPUUSAGE      => '0.0',
            PID           => '12',
            CMD           => '/usr/sbin/diskarbitrationd',
            TTY           => '??',
            STARTED       => $this_year . '-10-05',
            USER          => 'root',
            MEM           => '0.1'
        },
        {
            VIRTUALMEMORY => '2444544',
            CPUUSAGE      => '0.0',
            PID           => '11',
            CMD           => '/usr/sbin/notifyd',
            TTY           => '??',
            STARTED       => $this_year . '-10-05',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '2434788',
            CPUUSAGE      => '0.0',
            PID           => '29474',
            CMD           => 'ps aux',
            TTY           => 's001',
            STARTED       => $today . ' 11:09PM',
            USER          => 'root',
            MEM           => '0.0'
        },
        {
            VIRTUALMEMORY => '2456680',
            CPUUSAGE      => '0.0',
            PID           => '1',
            CMD           => '/sbin/launchd',
            TTY           => '??',
            STARTED       => $this_year . '-10-05',
            USER          => 'root',
            MEM           => '0.1'
        },
        {
            VIRTUALMEMORY => '2465304',
            CPUUSAGE      => '0.0',
            PID           => '29442',
            CMD           => '/System/Library/Frameworks/CoreServices.framework/Frameworks/Metadata.framework/Versions/A/Support/mdworker MDSImporterWorker com.apple.Spotlight.ImporterWorker.89',
            TTY           => '??',
            STARTED       => $today . ' 11:07PM',
            USER          => '_spotlight',
            MEM           => '0.2'
        },
        {
            VIRTUALMEMORY => '2492400',
            CPUUSAGE      => '0.0',
            PID           => '29325',
            CMD           => '/Applications/MacVim.app/Contents/MacOS/Vim -f -g lib/FusionInventory/Agent/Task/Inventory/OS/Generic/Processes.pm',
            TTY           => '??',
            STARTED       => $today . ' 11:02PM',
            USER          => 'rousse',
            MEM           => '0.4'
        },
        {
            VIRTUALMEMORY => '2479516',
            CPUUSAGE      => '0.0',
            PID           => '28994',
            CMD           => '/System/Library/Frameworks/CoreServices.framework/Frameworks/Metadata.framework/Versions/A/Support/mdworker MDSImporterWorker com.apple.Spotlight.ImporterWorker.501',
            TTY           => '??',
            STARTED       => $today . ' 10:55PM',
            USER          => 'rousse',
            MEM           => '0.5'
        }
    ],
);

my %netstat_tests = (
    openbsd => {
        'default'     => '10.0.1.1',
        '10.0.1/24'   => 'link#1',
        '10.0.1.1'    => '00:1d:7e:43:96:57',
        '10.0.1.100'  => '00:13:77:b3:cf:0c',
        '10.0.1.115'  => '127.0.0.1',
        '127/8'       => '127.0.0.1',
        '127.0.0.1'   => '127.0.0.1',
        '224/4'       => '127.0.0.1'
    },
    netbsd => {
        'default'     => '10.0.1.1',
        '10.0.1/24'   => 'link#1',
        '10.0.1.1'    => '00:1d:7e:43:96:57',
        '10.0.1.101'  => '00:1e:c2:0c:36:27',
        '10.0.1.124'  => '127.0.0.1',
        '127/8'       => '127.0.0.1',
        '127.0.0.1'   => '127.0.0.1',
    },
    hpux1 => {
        '10.0.4.55' => '10.0.4.55',
        '10.0.4.32' => '10.0.4.55',
        '127.0.0.0' => '127.0.0.1',
        '127.0.0.1' => '127.0.0.1',
        '10.0.4.56' => '10.0.4.56',
        'default'   => '10.0.4.33'
    },
    hpux2 => {
        '127.0.0.0'      => '127.0.0.1',
        '192.168.210.0'  => '192.168.210.40',
        '10.0.0.48'      => '10.0.0.48',
        'default'        => '10.0.0.33',
        '10.0.0.32'      => '10.0.0.49',
        '10.0.0.49'      => '10.0.0.49',
        '192.168.210.40' => '192.168.210.40',
        '127.0.0.1'      => '127.0.0.1',
        '192.168.210.91' => '10.0.0.48'
    },
    'aix-5.3a' => {
        '192.168.2.1'   => '127.0.0.1',
        '192.168.2.0'   => '192.168.2.1',
        'default'       => '192.168.2.250',
        '192.168.2/24'  => '192.168.2.1',
        '192.168.2.255' => '192.168.2.1',
        '127/8'         => '127.0.0.1'
    },
    'aix-5.3c' => {
        '10.3.40.255'     => '10.3.40.160',
        '192.168.203/24'  => '192.168.203.160',
        '192.168.1.255'   => '192.168.1.160',
        '10/8'            => '10.3.0.254',
        '192.168.1.160'   => '127.0.0.1',
        '10.3.40.0'       => '10.3.40.160',
        '10.3.40/24'      => '10.3.40.160',
        '192.168.203.0'   => '192.168.203.160',
        '192.168.4/24'    => '192.168.4.160',
        '10.3.40.160'     => '127.0.0.1',
        '192.168.203.255' => '192.168.203.160',
        '192.168.4.0'     => '192.168.4.160',
        '192.168.4.160'   => '127.0.0.1',
        'default'         => '10.3.0.253',
        '192.168.1/24'    => '192.168.1.160',
        '192.168.1.0'     => '192.168.1.160',
        '192.168.201/24'  => '192.168.203.254',
        '192.168.4.255'   => '192.168.4.160',
        '127/8'           => '127.0.0.1',
        '192.168.203.160' => '127.0.0.1'
    },
    'aix-6.1a' => {
        '172.16.0.80'  => '127.0.0.1',
        '172.16.0.0'   => '172.16.0.80',
        '172.16.7.255' => '172.16.0.80',
        'default'      => '172.16.0.254',
        '10.0.0.0'     => '10.0.0.103',
        '10/21'        => '10.0.0.103',
        '10.0.0.103'   => '127.0.0.1',
        '192.0.0/24'   => '172.16.0.254',
        '10.0.7.255'   => '10.0.0.103',
        '127/8'        => '127.0.0.1',
        '172.16/21'    => '172.16.0.80',
        '39/16'        => '172.16.0.21'
    },
    'aix-6.1b' => {
        '192.168.4.1'     => '127.0.0.1',
        '192.168.1.1'     => '127.0.0.1',
        '192.168.203/24'  => '192.168.203.101',
        '192.168.1.255'   => '192.168.1.1',
        '10/8'            => '10.3.0.254',
        '192.168.203.101' => '127.0.0.1',
        '10.3.40.101'     => '127.0.0.1',
        '192.168.203.0'   => '192.168.203.101',
        '192.168.3.1'     => '127.0.0.1',
        '192.168.4/24'    => '192.168.4.1',
        '192.168.3.255'   => '192.168.3.1',
        '192.168.203.255' => '192.168.203.101',
        '192.168.4.0'     => '192.168.4.1',
        '10.3.0.0'        => '10.3.40.101',
        'default'         => '10.3.0.253',
        '10.3/16'         => '10.3.40.101',
        '192.168.3/24'    => '192.168.3.1',
        '192.168.1/24'    => '192.168.1.1',
        '192.168.201/24'  => '192.168.203.254',
        '192.168.1.0'     => '192.168.1.1',
        '192.168.4.255'   => '192.168.4.1',
        '192.168.3.0'     => '192.168.3.1',
        '10.3.255.255'    => '10.3.40.101',
        '127/8'           => '127.0.0.1'
    },
    linux1 => {
        '0.0.0.0'     => '192.168.0.254',
        '192.168.0.0' => '0.0.0.0'
    },
    macosx1 => {
        '192.168.0.254' => 'f4:ca:e5:42:38:37',
        '127.0.0.1'     => '127.0.0.1',
        '192.168.0.27'  => '127.0.0.1',
        'default'       => '192.168.0.254'
    }
);

my %mount_tests = (
    linux   => [ qw/ext4 tmpfs proc sysfs devpts binfmt_misc/ ],
    darwin  => [ qw/local union/ ],
    freebsd => [ qw/ufs/ ]
);

plan tests =>
    (scalar keys %df_tests)         +
    (scalar keys %busybox_ps_tests) +
    (scalar keys %other_ps_tests)   +
    (scalar keys %netstat_tests)    +
    (scalar keys %mount_tests)      +
    (scalar @dhcp_leases_test);

foreach my $test (keys %df_tests) {
    my $file = "resources/generic/df/$test";
    my @infos = getFilesystemsFromDf(file => $file);
    cmp_deeply(\@infos, $df_tests{$test}, "$test df parsing");
}

foreach my $test (keys %busybox_ps_tests) {
    my $file = "resources/generic/ps/$test";
    my @processes = FusionInventory::Agent::Tools::Unix::_getProcessesBusybox(file => $file);
    cmp_deeply(\@processes, $busybox_ps_tests{$test}, "$test ps parsing");
}

foreach my $test (keys %other_ps_tests) {
    my $file = "resources/generic/ps/$test";
    my @processes = FusionInventory::Agent::Tools::Unix::_getProcessesOther(file => $file);
    cmp_deeply(\@processes, $other_ps_tests{$test}, "$test ps parsing");
}

foreach my $test (@dhcp_leases_test) {
    my $file = "resources/generic/dhcp/$test->{file}";
    my $server = FusionInventory::Agent::Tools::Unix::_parseDhcpLeaseFile(undef, $test->{if}, $file);
    ok(
        $server && ($server eq $test->{result}),
        "Parse DHCP lease"
    );
}

foreach my $test (keys %netstat_tests) {
    my $file = "resources/generic/netstat/$test";
    my $routes = getRoutingTable(file => $file);
    cmp_deeply($routes, $netstat_tests{$test}, $test);
}

foreach my $test (keys %mount_tests) {
    my $file = "resources/generic/mount/$test";
    my @types = getFilesystemsTypesFromMount(file => $file);
    cmp_deeply(\@types, $mount_tests{$test}, $test);
}
