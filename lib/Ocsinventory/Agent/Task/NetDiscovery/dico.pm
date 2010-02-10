package Ocsinventory::Agent::Task::NetDiscovery::dico;

use strict;
use XML::Simple;

sub loadDico() {
   my $dico = '<?xml version="1.0" encoding="UTF-8"?>
<SNMPDISCOVERY>
   <DEVICE SYSDESCR="Ordinateur CHRP PowerPC IBM&#13;&#10;TCP/IP Client Support  version: 05.03.0000.0050" MANUFACTURER="0" TYPE="1"/>
   <DEVICE SYSDESCR="3Com SuperStack 3 Switch 4500 26-Port Software Version 3Com OS V3.02.00s56" MANUFACTURER="0" TYPE="2"/>
   <DEVICE SYSDESCR="3Com SuperStack 3 Switch 4500 50-Port Software Version 3Com OS V3.01.00s56p01" MANUFACTURER="" TYPE="2"/>
   <DEVICE SYSDESCR="3Com SuperStack 3" MANUFACTURER="0" TYPE="2" MODELSNMP="71" MAC=".1.3.6.1.2.1.17.1.1.0"/>
   <DEVICE SYSDESCR="3Com SuperStack II" MANUFACTURER="" TYPE="2"/>
   <DEVICE SYSDESCR="3Com Switch 3824" MANUFACTURER="" TYPE="2"/>
   <DEVICE SYSDESCR="3Com Switch 4210 PWR 9-Port Software Version 3Com OS V3.01.03s56" MANUFACTURER="" TYPE="2"/>
   <DEVICE SYSDESCR="3Com Switch 4210 PWR 9-Port Software Version 3Com OS V3.01.05s168" MANUFACTURER="" TYPE="2"/>
   <DEVICE SYSDESCR="3Com Switch 4500 50-Port Software Version 3Com OS V3.03.00s168" MANUFACTURER="" TYPE="2"/>
   <DEVICE SYSDESCR="3Com Switch 5500-EI 28-Port Software Version 3Com OS V3.03.02s168ep01" MANUFACTURER="" TYPE="2"/>
   <DEVICE SYSDESCR="3Com Switch 5500-EI 52-Port Software Version 3Com OS V3.03.02s168ep01" MANUFACTURER="" TYPE="2"/>
   <DEVICE SYSDESCR="3Com Switch 5500-EI PWR 28-Port Software Version 3Com OS V3.03.02s168ep01" MANUFACTURER="" TYPE="2"/>
   <DEVICE SYSDESCR="3Com Switch 5500G-EI 24-Port Software Version 3Com OS V3.03.01s168" MANUFACTURER="" TYPE="2"/>
   <DEVICE SYSDESCR="3Com Switch 5500G-EI 24-Port Software Version 3Com OS V3.03.02s168p01" MANUFACTURER="" TYPE="2"/>
   <DEVICE SYSDESCR="3Com Switch 5500G-EI SFP 24-Port Software Version 3Com OS V3.03.02s168p01" MANUFACTURER="" TYPE="2"/>
   <DEVICE SYSDESCR="3Com" MANUFACTURER="" TYPE="2"/>
   <DEVICE SYSDESCR="Apple AirPort - Apple Computer, 2006.  All rights Reserved" MANUFACTURER="0" TYPE="2" MODELSNMP="51"/>
   <DEVICE SYSDESCR="Brother NC-6400h, Firmware Ver.1.11  (06.12.20),MID 84UZ92" MANUFACTURER="0" TYPE="3"/>
   <DEVICE SYSDESCR="Brother NC-6400h, Firmware Ver.1.11  (06.12.20),MID 84UZ93" MANUFACTURER="0" TYPE="3" MODELSNMP="87" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Brother NC-6400h, Firmware Ver.1.15  (07.01.23),MID 8C5-B43,FID 2" MANUFACTURER="0" TYPE="3" MODELSNMP="197" SERIAL=".1.3.6.1.2.1.43.5.1.1.17.1" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Canon CLC-iR C2620-C1 /P" MANUFACTURER="0" TYPE="3" MODELSNMP="95" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Canon iR C2380 /P" MANUFACTURER="0" TYPE="3" MODELSNMP="46" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Canon iR C3380 /P" MANUFACTURER="0" TYPE="3" MODELSNMP="153" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Canon iR C3580 /P" MANUFACTURER="0" TYPE="3" MODELSNMP="46" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Canon iR2270 /P" MANUFACTURER="0" TYPE="3" MODELSNMP="53" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Canon iR3025 /P" MANUFACTURER="0" TYPE="3" MODELSNMP="53" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Canon iR5000 /P" MANUFACTURER="0" TYPE="3" MODELSNMP="99" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Deskjet 6940 series" MANUFACTURER="0" TYPE="3" MODELSNMP="189" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="HP Business Inkjet 2800" MANUFACTURER="0" TYPE="3" MODELSNMP="205" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="HP Color LaserJet 2605dn" MANUFACTURER="0" TYPE="3" MODELSNMP="181" SERIAL=".1.3.6.1.2.1.43.5.1.1.17.1" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="HP Color LaserJet 3600" MANUFACTURER="0" TYPE="3" MODELSNMP="181" SERIAL=".1.3.6.1.2.1.43.5.1.1.17.1" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="HP Color LaserJet CP2025n" MANUFACTURER="0" TYPE="3" MODELSNMP="181" SERIAL=".1.3.6.1.2.1.43.5.1.1.17.1" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="HP J4899A ProCurve Switch 2650, revision H.07.02, ROM H.07.01 (/sw/code/build/fish(f02))" MANUFACTURER="0" TYPE="2" MODELSNMP="75" SERIAL=".1.3.6.1.2.1.47.1.1.1.1.11.1" MAC=".1.3.6.1.2.1.17.1.1.0"/>
   <DEVICE SYSDESCR="HP LaserJet 2200" MANUFACTURER="0" TYPE="3" MODELSNMP="177" SERIAL=".1.3.6.1.2.1.43.5.1.1.17.1" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="HP LaserJet M3027 MFP" MANUFACTURER="0" TYPE="3" MODELSNMP="177" SERIAL=".1.3.6.1.2.1.43.5.1.1.17.1" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="HP LaserJet P2015 Series" MANUFACTURER="0" TYPE="3" MODELSNMP="177" SERIAL=".1.3.6.1.2.1.43.5.1.1.17.1" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="HP LaserJet P3005" MANUFACTURER="0" TYPE="3" MODELSNMP="177" SERIAL=".1.3.6.1.2.1.43.5.1.1.17.1" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="KONICA MINOLTA 250" MANUFACTURER="0" TYPE="3" MODELSNMP="58" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="KONICA MINOLTA 282" MANUFACTURER="0" TYPE="3" MODELSNMP="203" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="KONICA MINOLTA bizhub 500" MANUFACTURER="0" TYPE="3" MODELSNMP="58" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="KONICA MINOLTA bizhub 501" MANUFACTURER="0" TYPE="3" MODELSNMP="191" SERIAL=".1.3.6.1.2.1.43.5.1.1.17.1" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="KONICA MINOLTA bizhub C353" MANUFACTURER="0" TYPE="3" MODELSNMP="200" SERIAL=".1.3.6.1.2.1.43.5.1.1.17.1" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="FS-3900DN" MANUFACTURER="0" TYPE="3" MODELSNMP="59" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Lexmark E352dn version NZ0.NA.N004 kernel 2.6.10 All-N-1" MANUFACTURER="0" TYPE="3" MODELSNMP="165" SERIAL=".1.3.6.1.4.1.641.2.1.2.1.6.1" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Lexmark T430 version JX.JU.P101 kernel 2.4.0-test6 All-N-1" MANUFACTURER="0" TYPE="3" MODELSNMP="105" SERIAL=".1.3.6.1.4.1.641.2.1.2.1.6.1" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Lexmark T630 version 55.10.19 kernel 2.4.0-test6 All-N-1" MANUFACTURER="0" TYPE="3" MODELSNMP="194" SERIAL=".1.3.6.1.2.1.43.5.1.1.17.1" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Lexmark T640 version NS.NP.N219 kernel 2.6.6 All-N-1" MANUFACTURER="0" TYPE="3" MODELSNMP="104" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Lexmark T642 version NS.NP.N219 kernel 2.6.6 All-N-1" MANUFACTURER="0" TYPE="3" MODELSNMP="194" SERIAL=".1.3.6.1.2.1.43.5.1.1.17.1" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Lexmark X644e version NC0.NPS.N048 kernel 2.6.10 All-N-1" MANUFACTURER="0" TYPE="3" MODELSNMP="115" SERIAL=".1.3.6.1.4.1.641.2.1.2.1.6.1" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="ProCurve J4903A Switch 2824, revision I.10.43, ROM I.08.07 (/sw/code/build/mako(mkfs))" MANUFACTURER="0" TYPE="2" MODELSNMP="120" MAC=".1.3.6.1.2.1.17.1.1.0"/>
   <DEVICE SYSDESCR="hp LaserJet 1320 series" MANUFACTURER="0" TYPE="3" MODELSNMP="187" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="hp LaserJet 2300 series" MANUFACTURER="0" TYPE="3" MODELSNMP="177" SERIAL=".1.3.6.1.2.1.43.5.1.1.17.1" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="hp LaserJet 2420" MANUFACTURER="0" TYPE="3" MODELSNMP="177" SERIAL=".1.3.6.1.2.1.43.5.1.1.17.1" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="hp LaserJet 2430" MANUFACTURER="0" TYPE="3" MODELSNMP="177" SERIAL=".1.3.6.1.2.1.43.5.1.1.17.1" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="hp LaserJet 4250" MANUFACTURER="0" TYPE="3" MODELSNMP="178" SERIAL=".1.3.6.1.2.1.43.5.1.1.17.1" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="hp LaserJet 4300" MANUFACTURER="0" TYPE="3" MODELSNMP="178" SERIAL=".1.3.6.1.2.1.43.5.1.1.17.1" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="3Com SuperStack II Hub 10, SW version:3.16" MANUFACTURER="" TYPE="2"/>
   <DEVICE SYSDESCR="Broadband Residential Gateway" MANUFACTURER="" TYPE="2"/>
   <DEVICE SYSDESCR="Brother NC-4100h, Firmware Ver.1.04 (01.12.14),MID 54S312,FID 3" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="Brother NC-6400h, Firmware Ver.1.10 (06.02.27),MID 8C5-B45,FID 2" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="Brother NC-6400h, Firmware Ver.1.12 (06.04.20),MID 8C5-B45,FID 2" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="Brother NC-6400h, Firmware Ver.1.15 (07.01.23),MID 8C5-B45,FID 2" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="Brother NC-6500h, Firmware Ver.1.06 (07.04.16),MID 84E-101" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="Brother NC-6500h, Firmware Ver.1.09 (07.11.28),MID 84E-101" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="Canon CLC5000 series" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="Canon Inc., LBP-1760 Printer" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="Canon iR 3170C EUR /P" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="Canon iR C2880 /P" MANUFACTURER="0" TYPE="3" MODELSNMP="96" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Canon iR C2880-J1 /P" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="Canon iR C3080 /P" MANUFACTURER="0" TYPE="3" MODELSNMP="154" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Canon iR C3200 /P" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="Canon iR C3220 /P" MANUFACTURER="0" TYPE="3" MODELSNMP="96" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Canon iR C4080 /P" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="Canon iR C5185 /P" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="Canon iR1024 /P" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="Canon iR2200 /P" MANUFACTURER="0" TYPE="3" MODELSNMP="152" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Canon iR2230 /P" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="Canon iR2870 /P" MANUFACTURER="0" TYPE="3" MODELSNMP="53" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Cisco Internetwork Operating System Software &#13;&#10;IOS (tm) C2600 Software (C2600-I-M), Version 12.0(4)T,  RELEASE SOFTWARE (fc1)&#13;&#10;Copyright (c) 1986-1999 by cisco Systems, Inc.&#13;&#10;Compiled Wed 28-Apr-99 16:50 by kpma" MANUFACTURER="" TYPE="2"/>
   <DEVICE SYSDESCR="Cisco Internetwork Operating System Software &#13;&#10;IOS (tm) C2950 Software (C2950-I6K2L2Q4-M), Version 12.1(22)EA12, RELEASE SOFTWARE (fc1)&#13;&#10;Copyright (c) 1986-2008 by cisco Systems, Inc.&#13;&#10;Compiled Tue 08-Jul-08 00:03 by amvarma" MANUFACTURER="" TYPE="2"/>
   <DEVICE SYSDESCR="Cisco Internetwork Operating System Software &#13;&#10;IOS (tm) C2950 Software (C2950-I6Q4L2-M), Version 12.1(19)EA1c, RELEASE SOFTWARE (fc2)&#13;&#10;Copyright (c) 1986-2004 by cisco Systems, Inc.&#13;&#10;Compiled Mon 02-Feb-04 23:29 by yenanh" MANUFACTURER="" TYPE="2"/>
   <DEVICE SYSDESCR="Cisco IOS Software, 1841 Software (C1841-IPBASE-M), Version 12.4(1c), RELEASE SOFTWARE (fc1)&#13;&#10;Technical Support: http://www.cisco.com/techsupport&#13;&#10;Copyright (c) 1986-2005 by Cisco Systems, Inc.&#13;&#10;Compiled Tue 25-Oct-05 17:10 by evmiller" MANUFACTURER="" TYPE="2"/>
   <DEVICE SYSDESCR="Cisco IOS Software, C1200 Software (C1200-K9W7-M), Version 12.3(8)JA2, RELEASE SOFTWARE (fc1)&#13;&#10;Technical Support: http://www.cisco.com/techsupport&#13;&#10;Copyright (c) 1986-2006 by Cisco Systems, Inc.&#13;&#10;Compiled Tue 30-May-06 18:07 by pwade" MANUFACTURER="" TYPE="2"/>
   <DEVICE SYSDESCR="Cisco IOS Software, C1200 Software (C1200-K9W7-M), Version 12.3(8)JEA, RELEASE SOFTWARE (fc2)&#13;&#10;Technical Support: http://www.cisco.com/techsupport&#13;&#10;Copyright (c) 1986-2006 by Cisco Systems, Inc.&#13;&#10;Compiled Wed 23-Aug-06 16:42 by kellythw" MANUFACTURER="" TYPE="2"/>
   <DEVICE SYSDESCR="Cisco IOS Software, C1200 Software (C1200-K9W7-M), Version 12.3(8)JEA1, RELEASE SOFTWARE (fc1)&#13;&#10;Technical Support: http://www.cisco.com/techsupport&#13;&#10;Copyright (c) 1986-2007 by Cisco Systems, Inc.&#13;&#10;Compiled Mon 15-Jan-07 23:17 by kellythw" MANUFACTURER="" TYPE="2"/>
   <DEVICE SYSDESCR="Cisco IOS Software, C1200 Software (C1200-K9W7-M), Version 12.3(8)JEC, RELEASE SOFTWARE (fc1)&#13;&#10;Technical Support: http://www.cisco.com/techsupport&#13;&#10;Copyright (c) 1986-2007 by Cisco Systems, Inc.&#13;&#10;Compiled Thu 25-Oct-07 22:24 by dchih" MANUFACTURER="" TYPE="2"/>
   <DEVICE SYSDESCR="Cisco IOS Software, C2960 Software (C2960-LANBASE-M), Version 12.2(25)FX, RELEASE SOFTWARE (fc1)&#13;&#10;Copyright (c) 1986-2005 by Cisco Systems, Inc.&#13;&#10;Compiled Wed 12-Oct-05 22:05 by yenanh" MANUFACTURER="" TYPE="2"/>
   <DEVICE SYSDESCR="Cisco IOS Software, C2960 Software (C2960-LANBASE-M), Version 12.2(25)SEE1, RELEASE SOFTWARE (fc1)&#13;&#10;Copyright (c) 1986-2006 by Cisco Systems, Inc.&#13;&#10;Compiled Sun 21-May-06 21:33 by yenanh" MANUFACTURER="" TYPE="2"/>
   <DEVICE SYSDESCR="Cisco IOS Software, C2960 Software (C2960-LANBASE-M), Version 12.2(25)SEE2, RELEASE SOFTWARE (fc1)&#13;&#10;Copyright (c) 1986-2006 by Cisco Systems, Inc.&#13;&#10;Compiled Fri 28-Jul-06 04:33 by yenanh" MANUFACTURER="0" TYPE="2" MODELSNMP="118" SERIAL=".1.3.6.1.2.1.47.1.1.1.1.11.1001" MAC=".1.3.6.1.2.1.17.1.1.0"/>
   <DEVICE SYSDESCR="Cisco IOS Software, C2960 Software (C2960-LANBASE-M), Version 12.2(25)SEE3, RELEASE SOFTWARE (fc2)&#13;&#10;Copyright (c) 1986-2007 by Cisco Systems, Inc.&#13;&#10;Compiled Thu 22-Feb-07 13:57 by myl" MANUFACTURER="0" TYPE="2" MODELSNMP="162" SERIAL=".1.3.6.1.2.1.47.1.1.1.1.11.1001" MAC=".1.3.6.1.2.1.17.1.1.0"/>
   <DEVICE SYSDESCR="Cisco IOS Software, C2960 Software (C2960-LANBASE-M), Version 12.2(35)SE5, RELEASE SOFTWARE (fc1)&#13;&#10;Copyright (c) 1986-2007 by Cisco Systems, Inc.&#13;&#10;Compiled Thu 19-Jul-07 20:06 by nachen" MANUFACTURER="0" TYPE="2" MODELSNMP="162" SERIAL=".1.3.6.1.2.1.47.1.1.1.1.11.1001" MAC=".1.3.6.1.2.1.17.1.1.0"/>
   <DEVICE SYSDESCR="Cisco IOS Software, C2960 Software (C2960-LANBASEK9-M), Version 12.2(46)SE, RELEASE SOFTWARE (fc2)&#13;&#10;Copyright (c) 1986-2008 by Cisco Systems, Inc.&#13;&#10;Compiled Thu 21-Aug-08 15:59 by nachen" MANUFACTURER="" TYPE="2"/>
   <DEVICE SYSDESCR="Cisco IOS Software, C3560 Software (C3560-IPBASE-M), Version 12.2(25)SEE3, RELEASE SOFTWARE (fc2)&#13;&#10;Copyright (c) 1986-2007 by Cisco Systems, Inc.&#13;&#10;Compiled Thu 22-Feb-07 14:40 by myl" MANUFACTURER="" TYPE="2"/>
   <DEVICE SYSDESCR="Cisco IOS Software, C3560 Software (C3560-IPBASE-M), Version 12.2(35)SE5, RELEASE SOFTWARE (fc1)&#13;&#10;Copyright (c) 1986-2007 by Cisco Systems, Inc.&#13;&#10;Compiled Thu 19-Jul-07 18:15 by nachen" MANUFACTURER="" TYPE="2"/>
   <DEVICE SYSDESCR="Cisco IOS Software, C3750 Software (C3750-IPBASEK9-M), Version 12.2(46)SE, RELEASE SOFTWARE (fc2)&#13;&#10;Copyright (c) 1986-2008 by Cisco Systems, Inc.&#13;&#10;Compiled Thu 21-Aug-08 15:43 by nachen" MANUFACTURER="" TYPE="2"/>
   <DEVICE SYSDESCR="Cisco Systems Catalyst 1900,V9.00.00    " MANUFACTURER="" TYPE="2"/>
   <DEVICE SYSDESCR="Dell Laser Printer 3000cn; Net 6.31, Controller 200503021148, Engine 01.06.90" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="Dell Laser Printer 5100cn (Net 6.26, Controller 200408201123, Engine 01.00.03)" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="Dlink DES-3018 Fast Ethernet Switch" MANUFACTURER="" TYPE="2"/>
   <DEVICE SYSDESCR="EPSON AL-C2000 01.00" MANUFACTURER="0" TYPE="3" MODELSNMP="100" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="EPSON Type-B 10Base-T/100Base-TX Print Server" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="Fiery X3eTY 35C-KM" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="Hardware: x86 Family 15 Model 1 Stepping 2 AT/AT COMPATIBLE - Software: Windows 2000 Version 5.0 (Build 2195 Uniprocessor Free)" MANUFACTURER="" TYPE="1"/>
   <DEVICE SYSDESCR="Hardware: x86 Family 15 Model 2 Stepping 4 AT/AT COMPATIBLE - Software: Windows 2000 Version 5.1 (Build 2600 Uniprocessor Free)" MANUFACTURER="" TYPE="1"/>
   <DEVICE SYSDESCR="Hardware: x86 Family 15 Model 2 Stepping 7 AT/AT COMPATIBLE - Software: Windows 2000 Version 5.0 (Build 2195 Multiprocessor Free)" MANUFACTURER="" TYPE="1"/>
   <DEVICE SYSDESCR="Hardware: x86 Family 15 Model 2 Stepping 7 AT/AT COMPATIBLE - Software: Windows 2000 Version 5.1 (Build 2600 Multiprocessor Free)" MANUFACTURER="" TYPE="1"/>
   <DEVICE SYSDESCR="Hardware: x86 Family 15 Model 2 Stepping 7 AT/AT COMPATIBLE - Software: Windows 2000 Version 5.1 (Build 2600 Uniprocessor Free)" MANUFACTURER="" TYPE="1"/>
   <DEVICE SYSDESCR="Hardware: x86 Family 15 Model 2 Stepping 7 AT/AT COMPATIBLE - Software: Windows NT Version 4.0 (Build Number: 1381 Multiprocessor Free )" MANUFACTURER="" TYPE="1"/>
   <DEVICE SYSDESCR="Hardware: x86 Family 15 Model 2 Stepping 9 AT/AT COMPATIBLE - Software: Windows 2000 Version 5.0 (Build 2195 Multiprocessor Free)" MANUFACTURER="" TYPE="1"/>
   <DEVICE SYSDESCR="Hardware: x86 Family 15 Model 2 Stepping 9 AT/AT COMPATIBLE - Software: Windows 2000 Version 5.1 (Build 2600 Multiprocessor Free)" MANUFACTURER="" TYPE="1"/>
   <DEVICE SYSDESCR="Hardware: x86 Family 15 Model 2 Stepping 9 AT/AT COMPATIBLE - Software: Windows 2000 Version 5.1 (Build 2600 Uniprocessor Free)" MANUFACTURER="" TYPE="1"/>
   <DEVICE SYSDESCR="Hardware: x86 Family 15 Model 2 Stepping 9 AT/AT COMPATIBLE - Software: Windows NT Version 4.0 (Build Number: 1381 Uniprocessor Free )" MANUFACTURER="" TYPE="1"/>
   <DEVICE SYSDESCR="Hardware: x86 Family 15 Model 4 Stepping 10 AT/AT COMPATIBLE - Software: Windows 2000 Version 5.1 (Build 2600 Multiprocessor Free)" MANUFACTURER="" TYPE="1"/>
   <DEVICE SYSDESCR="Hardware: x86 Family 15 Model 4 Stepping 10 AT/AT COMPATIBLE - Software: Windows Version 5.2 (Build 3790 Multiprocessor Free)" MANUFACTURER="" TYPE="1"/>
   <DEVICE SYSDESCR="Hardware: x86 Family 15 Model 4 Stepping 3 AT/AT COMPATIBLE - Software: Windows 2000 Version 5.0 (Build 2195 Multiprocessor Free)" MANUFACTURER="" TYPE="1"/>
   <DEVICE SYSDESCR="Hardware: x86 Family 15 Model 4 Stepping 3 AT/AT COMPATIBLE - Software: Windows 2000 Version 5.1 (Build 2600 Multiprocessor Free)" MANUFACTURER="" TYPE="1"/>
   <DEVICE SYSDESCR="Hardware: x86 Family 6 Model 11 Stepping 1 AT/AT COMPATIBLE - Software: Windows 2000 Version 5.0 (Build 2195 Uniprocessor Free)" MANUFACTURER="" TYPE="1"/>
   <DEVICE SYSDESCR="Hardware: x86 Family 6 Model 11 Stepping 1 AT/AT COMPATIBLE - Software: Windows NT Version 4.0 (Build Number: 1381 Uniprocessor Free )" MANUFACTURER="" TYPE="1"/>
   <DEVICE SYSDESCR="Hardware: x86 Family 6 Model 11 Stepping 1 AT/AT COMPATIBLE - Software: Windows Version 5.2 (Build 3790 Multiprocessor Free)" MANUFACTURER="" TYPE="1"/>
   <DEVICE SYSDESCR="Hardware: x86 Family 6 Model 11 Stepping 1 AT/AT COMPATIBLE - Software: Windows Version 5.2 (Build 3790 Uniprocessor Free)" MANUFACTURER="" TYPE="1"/>
   <DEVICE SYSDESCR="Hardware: x86 Family 6 Model 13 Stepping 6 AT/AT COMPATIBLE - Software: Windows 2000 Version 5.1 (Build 2600 Uniprocessor Free)" MANUFACTURER="" TYPE="1"/>
   <DEVICE SYSDESCR="Hardware: x86 Family 6 Model 23 Stepping 10 AT/AT COMPATIBLE - Software: Windows Version 5.2 (Build 3790 Multiprocessor Free)" MANUFACTURER="" TYPE="1"/>
   <DEVICE SYSDESCR="Hardware: x86 Family 6 Model 23 Stepping 6 AT/AT COMPATIBLE - Software: Windows Version 5.2 (Build 3790 Multiprocessor Free)" MANUFACTURER="" TYPE="1"/>
   <DEVICE SYSDESCR="Hardware: x86 Family 6 Model 5 Stepping 2 AT/AT COMPATIBLE - Software: Windows 2000 Version 5.0 (Build 2195 Uniprocessor Free)" MANUFACTURER="" TYPE="1"/>
   <DEVICE SYSDESCR="Hardware: x86 Family 6 Model 8 Stepping 10 AT/AT COMPATIBLE - Software: Windows NT Version 4.0 (Build Number: 1381 Uniprocessor Free )" MANUFACTURER="" TYPE="1"/>
   <DEVICE SYSDESCR="Hardware: x86 Family 6 Model 8 Stepping 6 AT/AT COMPATIBLE - Software: Windows NT Version 4.0 (Build Number: 1381 Multiprocessor Free )" MANUFACTURER="" TYPE="1"/>
   <DEVICE SYSDESCR="Hardware: x86 Family 6 Model 8 Stepping 6 AT/AT COMPATIBLE - Software: Windows NT Version 4.0 (Build Number: 1381 Uniprocessor Free )" MANUFACTURER="" TYPE="1"/>
   <DEVICE SYSDESCR="hp business inkjet 3000" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="HP Color Inkjet CP1700" MANUFACTURER="0" TYPE="3" MODELSNMP="182" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="HP Color LaserJet 4500" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="hp color LaserJet 5550 " MANUFACTURER="0" TYPE="3" MODELSNMP="196" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="HP Color LaserJet 8550" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="HP Color LaserJet CP3505" MANUFACTURER="0" TYPE="3" MODELSNMP="180" SERIAL=".1.3.6.1.2.1.43.5.1.1.17.1" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="HP Color LaserJet CP3525" MANUFACTURER="0" TYPE="3" MODELSNMP="180" SERIAL=".1.3.6.1.2.1.43.5.1.1.17.1" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Cisco IOS Software, C3750 Software (C3750-I5-M), Version 12.2(25)SEA, RELEASE SOFTWARE (fc)^&#13;&#10;Copyright (c) 1986-2005 by Cisco Systems, Inc.&#13;&#10;Compiled Tue 25-Jan-05 20:26 by antonino" MANUFACTURER="0" TYPE="2" MODELSNMP="148" SERIAL=".1.3.6.1.2.1.47.1.1.1.1.11.1001" MAC=".1.3.6.1.2.1.17.1.1.0"/>
   <DEVICE SYSDESCR="HP Color LaserJet CM6030 MFP" MANUFACTURER="0" TYPE="3" MODELSNMP="185" SERIAL=".1.3.6.1.2.1.43.5.1.1.17.1" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="HP J4813A ProCurve Switch 2524, revision F.05.55, ROM F.02.01  (/sw/code/build/info(s02))" MANUFACTURER="0" TYPE="2" MODELSNMP="143" SERIAL=".1.3.6.1.2.1.47.1.1.1.1.11.1"/>
   <DEVICE SYSDESCR="PROCURVE J9028B - PB.03.02" MANUFACTURER="0" TYPE="2" MODELSNMP="144"/>
   <DEVICE SYSDESCR="TOSHIBA e-STUDIO353" MANUFACTURER="0" TYPE="3" MODELSNMP="142" SERIAL=".1.3.6.1.2.1.43.5.1.1.17.1" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="deskjet 6127" MANUFACTURER="0" TYPE="3" MODELSNMP="141" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="NRG DSm735 1.24.1 / NRG Network Printer C model / NRG Network Scanner C model" MANUFACTURER="0" TYPE="3" MODELSNMP="108" SERIAL=".1.3.6.1.4.1.367.3.2.1.2.1.4.0" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="HP Color LaserJet CP1515n" MANUFACTURER="0" TYPE="3" MODELSNMP="181" SERIAL=".1.3.6.1.2.1.43.5.1.1.17.1" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="HP Color LaserJet 3800" MANUFACTURER="0" TYPE="3" MODELSNMP="183" SERIAL=".1.3.6.1.2.1.43.5.1.1.17.1" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="HP J4093A ProCurve Switch 2424M, revision C.08.22, ROM C.06.01 (/sw/code/build/vgro(c08))" MANUFACTURER="" TYPE="2"/>
   <DEVICE SYSDESCR="HP J4121A ProCurve Switch 4000M, revision C.06.01, ROM C.06.01 (/sw/code/build/vgro(w99))" MANUFACTURER="" TYPE="2"/>
   <DEVICE SYSDESCR="HP J4812A ProCurve Switch 2512, revision F.02.02, ROM F.01.01 (/sw/code/build/info(f00))" MANUFACTURER="" TYPE="2"/>
   <DEVICE SYSDESCR="HP J4813A ProCurve Switch 2524, revision F.02.11, ROM F.02.01 (/sw/code/build/info(f00))" MANUFACTURER="" TYPE="2"/>
   <DEVICE SYSDESCR="HP J4813A ProCurve Switch 2524, revision F.04.08, ROM F.02.01 (/sw/code/build/info(f01))" MANUFACTURER="" TYPE="2"/>
   <DEVICE SYSDESCR="HP J4813A ProCurve Switch 2524, revision F.05.17, ROM F.02.01 (/sw/code/build/info(s02))" MANUFACTURER="" TYPE="2"/>
   <DEVICE SYSDESCR="HP J4900B ProCurve Switch 2626, revision H.08.67, ROM H.08.02 (/sw/code/build/fish(f04))" MANUFACTURER="" TYPE="2"/>
   <DEVICE SYSDESCR="HP LaserJet 1200" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="HP LaserJet 4000 Series" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="HP LaserJet 4050 Series " MANUFACTURER="0" TYPE="3" MODELSNMP="186" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="HP LaserJet 4100 Series" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="hp LaserJet 4200" MANUFACTURER="0" TYPE="3" MODELSNMP="178" SERIAL=".1.3.6.1.2.1.43.5.1.1.17.1" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="hp LaserJet 4350" MANUFACTURER="0" TYPE="3" MODELSNMP="178" SERIAL=".1.3.6.1.2.1.43.5.1.1.17.1" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="HP LaserJet 5100 Series" MANUFACTURER="0" TYPE="3" MODELSNMP="177" SERIAL=".1.3.6.1.2.1.43.5.1.1.17.1" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="HP LaserJet 5M" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="HP LaserJet 6P" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="HP LaserJet 8000 Series" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="HP LaserJet P1505n" MANUFACTURER="0" TYPE="3" MODELSNMP="184" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="HP LaserJet P4014" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="HP Officejet Pro K850" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="IBM NPS 530/532Print serverV5.36 Jul 7 1997" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="KONICA MINOLTA 350" MANUFACTURER="0" TYPE="3" MODELSNMP="57" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="KONICA MINOLTA bizhub C203" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="KONICA MINOLTA bizhub C352" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="KONICA MINOLTA bizhub C451" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="KONICA MINOLTA Di3510f" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="Lexmark C534 version NSF.NP.N016 kernel 2.6.6 All-N-1" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="Lexmark C920 version NS.NP.N210 kernel 2.6.6 All-N-1" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="Lexmark E342n version BR.H.P026 kernel 2.4.0-test6 All-N-1" MANUFACTURER="0" TYPE="3" MODELSNMP="164" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Lexmark T420 version 22.22.02 kernel 2.4.0-test6 All-N-1" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="Lexmark T632 version 55.10.20 kernel 2.4.0-test6 All-N-1" MANUFACTURER="0" TYPE="3" MODELSNMP="105" SERIAL=".1.3.6.1.4.1.641.2.1.2.1.6.1" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Lexmark T644 version NS.NP.N118 kernel 2.6.6 All-N-1" MANUFACTURER="0" TYPE="3" MODELSNMP="105" SERIAL=".1.3.6.1.4.1.641.2.1.2.1.6.1" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Lexmark T644 version NS0.NP.N014 kernel 2.6.6 All-N-1" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="NRG C7535hdn 1.11 / NRG Network Printer C model" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="NRG MP 161 1.00.1 / NRG Network Printer C model / NRG Network Scanner C model / NRG Network Facsimile C model" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="NRG MP 161 1.01 / NRG Network Printer C model / NRG Network Scanner C model / NRG Network Facsimile C model" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="NRG MP 161 1.02 / NRG Network Printer C model / NRG Network Scanner C model / NRG Network Facsimile C model" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="NRG MP 161 1.04 / NRG Network Printer C model / NRG Network Scanner C model / NRG Network Facsimile C model" MANUFACTURER="0" TYPE="3" MODELSNMP="166" SERIAL=".1.3.6.1.4.1.367.3.2.1.2.1.4.0" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="NRG MP 2510 1.02 / NRG Network Printer C model / NRG Network Scanner C model" MANUFACTURER="0" TYPE="3" MODELSNMP="108" SERIAL=".1.3.6.1.4.1.367.3.2.1.2.1.4.0" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="NRG MP 2510 1.02 / NRG Network Printer C model / NRG Network Scanner C model / NRG Network Facsimile C model" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="NRG MP 2550 1.01.3 / NRG Network Printer C model / NRG Network Scanner C model / NRG Network Facsimile C model" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="NRG MP 3010 1.02 / NRG Network Printer C model / NRG Network Scanner C model" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="NRG MP 3010 1.02 / NRG Network Printer C model / NRG Network Scanner C model / NRG Network Facsimile C model" MANUFACTURER="0" TYPE="3" MODELSNMP="108" SERIAL=".1.3.6.1.4.1.367.3.2.1.2.1.4.0" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="NRG MP 3350 1.01.3 / NRG Network Printer C model / NRG Network Scanner C model / NRG Network Facsimile C model" MANUFACTURER="0" TYPE="3" MODELSNMP="167" SERIAL=".1.3.6.1.2.1.43.5.1.1.17.1" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="NRG MP 3500 1.01 / NRG Network Printer C model / NRG Network Scanner C model" MANUFACTURER="0" TYPE="3" MODELSNMP="108" SERIAL=".1.3.6.1.4.1.367.3.2.1.2.1.4.0" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="NRG MP 3500 1.01 / NRG Network Printer C model / NRG Network Scanner C model / NRG Network Facsimile C model" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="NRG MP 3500 1.05 / NRG Network Printer C model / NRG Network Scanner C model / NRG Network Facsimile C model" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="NRG MP 4500 1.01 / NRG Network Printer C model / NRG Network Scanner C model / NRG Network Facsimile C model" MANUFACTURER="0" TYPE="3" MODELSNMP="168" SERIAL=".1.3.6.1.4.1.367.3.2.1.2.1.4.0" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="NRG MP 5500 2.04 / NRG Network Printer C model / NRG Network Scanner C model" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="NRG MP C3000 1.58 / NRG Network Printer C model / NRG Network Scanner C model / NRG Network Facsimile C model" MANUFACTURER="0" TYPE="3" MODELSNMP="110" SERIAL=".1.3.6.1.4.1.367.3.2.1.2.1.4.0" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="NRG MP C3000 1.62.1 / NRG Network Printer C model / NRG Network Scanner C model" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="NRG MP C3500 1.60 / NRG Network Printer C model / NRG Network Scanner C model / NRG Network Facsimile C model" MANUFACTURER="0" TYPE="3" MODELSNMP="110" SERIAL=".1.3.6.1.4.1.367.3.2.1.2.1.4.0" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="NRG SP 4100N 1.01 / NRG Network Printer C model" MANUFACTURER="0" TYPE="3" MODELSNMP="169" SERIAL=".1.3.6.1.2.1.43.5.1.1.17.1"/>
   <DEVICE SYSDESCR="NRG SP 4100N 1.04 / NRG Network Printer C model" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="NRG SP 4100N 1.05 / NRG Network Printer C model" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="NRG SP 8100DN 1.05 / NRG Network Printer C model" MANUFACTURER="0" TYPE="3" MODELSNMP="170" SERIAL=".1.3.6.1.4.1.367.3.2.1.2.1.4.0" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="NRG SP C410DN 1.07 / NRG Network Printer C model" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="NRG SP C410DN 1.10 / NRG Network Printer C model" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="NRG SP C410DN 1.11 / NRG Network Printer C model" MANUFACTURER="0" TYPE="3" MODELSNMP="175" SERIAL=".1.3.6.1.4.1.367.3.2.1.2.1.4.0" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="NRG SP C811DN 1.02 / NRG Network Printer C model" MANUFACTURER="0" TYPE="3" MODELSNMP="171" SERIAL=".1.3.6.1.4.1.367.3.2.1.2.1.4.0" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Officejet 6300 series" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="ProCurve J4899B Switch 2650, revision H.10.38, ROM H.08.02 (/sw/code/build/fish(mf_v10_fishp))" MANUFACTURER="" TYPE="2"/>
   <DEVICE SYSDESCR="ProCurve J4899B Switch 2650, revision H.10.50, ROM H.08.05 (/sw/code/build/fish(mkfs))" MANUFACTURER="" TYPE="2"/>
   <DEVICE SYSDESCR="ProCurve J4899B Switch 2650, revision H.10.74, ROM H.08.02 (/sw/code/build/fish(mkfs))" MANUFACTURER="0" TYPE="2" MODELSNMP="75" SERIAL=".1.3.6.1.2.1.47.1.1.1.1.11.1" MAC=".1.3.6.1.2.1.17.1.1.0"/>
   <DEVICE SYSDESCR="ProCurve J4899C Switch 2650, revision H.10.74, ROM H.08.05 (/sw/code/build/fish(mkfs))" MANUFACTURER="" TYPE="2"/>
   <DEVICE SYSDESCR="ProCurve J4900A Switch 2626, revision H.10.74, ROM H.08.02 (/sw/code/build/fish(mkfs))" MANUFACTURER="" TYPE="2"/>
   <DEVICE SYSDESCR="ProCurve J4900B Switch 2626, revision H.08.83, ROM H.08.02 (/sw/code/build/fish(ts_08_5))" MANUFACTURER="0" TYPE="2" MODELSNMP="157" SERIAL=".1.3.6.1.2.1.47.1.1.1.1.11.1" MAC=".1.3.6.1.2.1.17.1.1.0"/>
   <DEVICE SYSDESCR="ProCurve J4900B Switch 2626, revision H.08.98, ROM H.08.02 (/sw/code/build/fish(ts_08_5))" MANUFACTURER="" TYPE="2"/>
   <DEVICE SYSDESCR="ProCurve J4900B Switch 2626, revision H.10.31, ROM H.08.02 (/sw/code/build/fish(mkfs))" MANUFACTURER="" TYPE="2"/>
   <DEVICE SYSDESCR="ProCurve J4900B Switch 2626, revision H.10.50, ROM H.08.02 (/sw/code/build/fish(mkfs))" MANUFACTURER="" TYPE="2"/>
   <DEVICE SYSDESCR="ProCurve J4900B Switch 2626, revision H.10.50, ROM H.08.05 (/sw/code/build/fish(mkfs))" MANUFACTURER="" TYPE="2"/>
   <DEVICE SYSDESCR="ProCurve J4900B Switch 2626, revision H.10.74, ROM H.08.02 (/sw/code/build/fish(mkfs))" MANUFACTURER="" TYPE="2"/>
   <DEVICE SYSDESCR="ProCurve J4900C Switch 2626, revision H.10.74, ROM H.08.05 (/sw/code/build/fish(mkfs))" MANUFACTURER="" TYPE="2"/>
   <DEVICE SYSDESCR="ProCurve J4903A Switch 2824, revision I.08.98, ROM I.08.07 (/sw/code/build/mako(ts_08_5))" MANUFACTURER="0" TYPE="2" MODELSNMP="145" SERIAL=".1.3.6.1.2.1.47.1.1.1.1.11.1"/>
   <DEVICE SYSDESCR="PROCURVE J9029A - PA.02.06" MANUFACTURER="" TYPE="2"/>
   <DEVICE SYSDESCR="ProCurve J9085A Switch 2610-24, revision R.11.07, ROM R.10.06 (/sw/code/build/nemo(ndx))" MANUFACTURER="" TYPE="2"/>
   <DEVICE SYSDESCR="ProCurve J9088A Switch 2610-48, revision R.11.07, ROM R.10.06 (/sw/code/build/nemo(ndx))" MANUFACTURER="0" TYPE="2" MODELSNMP="75" SERIAL=".1.3.6.1.2.1.47.1.1.1.1.11.1" MAC=".1.3.6.1.2.1.17.1.1.0"/>
   <DEVICE SYSDESCR="RICOH Aficio 1515 0.29.04 / RICOH Network Printer C model / RICOH Network Scanner C model / RICOH Network Facsimile C model" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="RICOH Aficio 2016 0.40.12 / RICOH Network Printer C model / RICOH Network Scanner C model / RICOH Network Facsimile C model" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="RICOH Aficio 2018D 0.40.08 / RICOH Network Printer C model / RICOH Network Scanner C model / RICOH Network Facsimile C model" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="RICOH Aficio 2020 0.40.12 / RICOH Network Printer C model / RICOH Network Scanner C model" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="RICOH Aficio 2022 1.04 / RICOH Network Printer C model / RICOH Network Scanner C model / RICOH Network Facsimile C model" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="RICOH Aficio 3025 1.09.1 / RICOH Network Printer C model" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="RICOH Aficio 3025 1.11.2 / RICOH Network Printer C model / RICOH Network Scanner C model" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="RICOH Aficio 3030 1.23 / RICOH Network Printer C model / RICOH Network Scanner C model / RICOH Network Facsimile C model" MANUFACTURER="0" TYPE="3" MODELSNMP="108" SERIAL=".1.3.6.1.4.1.367.3.2.1.2.1.4.0" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="RICOH Aficio 3045 1.31 / RICOH Network Printer C model / RICOH Network Scanner C model" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="RICOH Aficio 3224C 1.12 / RICOH Network Printer C model / RICOH Network Scanner C model" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="RICOH Aficio 3232C 1.11 / RICOH Network Printer C model / RICOH Network Scanner C model / RICOH Network Facsimile C model" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="RICOH Aficio 3235C 1.27 / RICOH Network Printer C model / RICOH Network Scanner C model" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="RICOH Aficio 3245C 1.30 / RICOH Network Printer C model / RICOH Network Scanner C model" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="RICOH Aficio AP410N 1.05 / RICOH Network Printer C model" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="RICOH Aficio MP 161 1.04 / RICOH Network Printer C model / RICOH Network Scanner C model / RICOH Network Facsimile C model" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="RICOH Aficio MP 161 1.05 / RICOH Network Printer C model / RICOH Network Scanner C model / RICOH Network Facsimile C model" MANUFACTURER="0" TYPE="3" MODELSNMP="166" SERIAL=".1.3.6.1.4.1.367.3.2.1.2.1.4.0" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="RICOH Aficio MP 2000 1.05 / RICOH Network Printer C model / RICOH Network Scanner C model" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="RICOH Aficio MP 2000 1.09.1 / RICOH Network Printer C model / RICOH Network Scanner C model / RICOH Network Facsimile C model" MANUFACTURER="0" TYPE="3" MODELSNMP="109" SERIAL=".1.3.6.1.4.1.367.3.2.1.2.1.4.0" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="RICOH Aficio MP 2510 1.04 / RICOH Network Printer C model / RICOH Network Scanner C model / RICOH Network Facsimile C model" MANUFACTURER="0" TYPE="3" MODELSNMP="108" SERIAL=".1.3.6.1.4.1.367.3.2.1.2.1.4.0" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="RICOH Aficio MP 3350 1.01.3 / RICOH Network Printer C model / RICOH Network Scanner C model / RICOH Network Facsimile C model" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="RICOH Aficio MP 3350 1.08 / RICOH Network Printer C model / RICOH Network Scanner C model / RICOH Network Facsimile C model" MANUFACTURER="0" TYPE="3" MODELSNMP="172" SERIAL=".1.3.6.1.2.1.43.5.1.1.17.1" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="RICOH Aficio MP 3350 1.14 / RICOH Network Printer C model / RICOH Network Scanner C model / RICOH Network Facsimile C model" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="RICOH Aficio MP 4500 1.01 / RICOH Network Printer C model / RICOH Network Scanner C model" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="RICOH Aficio MP 5000 1.06 / RICOH Network Printer C model / RICOH Network Scanner C model / RICOH Network Facsimile C model" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="RICOH Aficio MP 7500 1.12 / RICOH Network Printer C model / RICOH Network Scanner C model" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="RICOH Aficio MP C2000 1.67 / RICOH Network Printer C model / RICOH Network Scanner C model" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="RICOH Aficio MP C2000 1.68 / RICOH Network Printer C model / RICOH Network Scanner C model / RICOH Network Facsimile C model" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="RICOH Aficio MP C3000 1.47.7 / RICOH Network Printer C model / RICOH Network Scanner C model" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="RICOH Aficio MP C3500 1.62 / RICOH Network Printer C model / RICOH Network Scanner C model" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="RICOH Aficio MP C3500 1.68 / RICOH Network Printer C model / RICOH Network Scanner C model / RICOH Network Facsimile C model" MANUFACTURER="0" TYPE="3" MODELSNMP="110" SERIAL=".1.3.6.1.4.1.367.3.2.1.2.1.4.0" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="RICOH Aficio MP C4000 1.13 / RICOH Network Printer C model / RICOH Network Scanner C model / RICOH Network Facsimile C model" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="RICOH Aficio MP C4000 1.16 / RICOH Network Printer C model / RICOH Network Scanner C model" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="RICOH Aficio MP C4500 1.67 / RICOH Network Printer C model / RICOH Network Scanner C model / RICOH Network Facsimile C model" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="RICOH Aficio SP 4100N 1.06 / RICOH Network Printer C model" MANUFACTURER="0" TYPE="3" MODELSNMP="173" SERIAL=".1.3.6.1.2.1.43.5.1.1.17.1" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="RICOH Aficio SP 4100N 1.08 / RICOH Network Printer C model" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="RICOH Aficio SP C410DN 1.11 / RICOH Network Printer C model" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="RICOH Aficio SP C420DN 1.00 / RICOH Network Printer C model" MANUFACTURER="0" TYPE="3" MODELSNMP="174" SERIAL=".1.3.6.1.2.1.43.5.1.1.17.1" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="RICOH Aficio SP C420DN 1.03 / RICOH Network Printer C model" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="RICOH Aficio SP C811DN 1.07 / RICOH Network Printer C model" MANUFACTURER="0" TYPE="3" MODELSNMP="175" SERIAL=".1.3.6.1.4.1.367.3.2.1.2.1.4.0" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="SHARP MX-2300N" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="SHARP MX-4101N" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="TOSHIBA e-STUDIO232" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="TOSHIBA e-STUDIO2500c" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="TOSHIBA e-STUDIO281c" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="TOSHIBA e-STUDIO2820C" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="TOSHIBA e-STUDIO351c" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="Xerox 4112;ESS PS1.203.0,IOT 45.26.0,HCF 3.17.0,FIN D3.7.4,IIT 15.4.1,IIT D14.0.4,ADF 12.2.2,SJFI3.0.10,SSMI1.9.0" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="Xerox Document Centre 432ST, v3.0 - post-launch, Multi-function System, ESS 3_2_1_3s, DCSYS XCE245, UI S3.69" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="Xerox Phaser 7300 DX v(2.08/15.52.08.29.2002/0.1.22/4.68) Printer 384MB LPM010175" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="Ordinateur CHRP PowerPC IBM&#13;&#10;TCP/IP Client Support version: 05.03.0000.0054" MANUFACTURER="" TYPE="1"/>
   <DEVICE SYSDESCR="HP J4813A ProCurve Switch 2524, revision F.05.61, ROM F.02.01  (/sw/code/build/info(s02))" MANUFACTURER="0" TYPE="2" MODELSNMP="65" MAC=".1.3.6.1.2.1.17.1.1.0"/>
   <DEVICE SYSDESCR="HP J4812A ProCurve Switch 2512, revision F.05.61, ROM F.01.01  (/sw/code/build/info(s02))" MANUFACTURER="0" TYPE="2" MODELSNMP="66" MAC=".1.3.6.1.2.1.17.1.1.0"/>
   <DEVICE SYSDESCR="Hardware: x86 Family 15 Model 4 Stepping 1 AT/AT COMPATIBLE - Software: Windows 2000 Version 5.0 (Build 2195 Multiprocessor Free)" MANUFACTURER="" TYPE="1"/>
   <DEVICE SYSDESCR="HP J4819A ProCurve Switch 5308xl, revision E.10.74, ROM E.05.05 (/sw/code/build/alpmo(m35))" MANUFACTURER="0" TYPE="2" MODELSNMP="64" SERIAL=".1.3.6.1.2.1.47.1.1.1.1.11.1" MAC=".1.3.6.1.2.1.17.1.1.0"/>
   <DEVICE SYSDESCR="HP LaserJet P4515" MANUFACTURER="0" TYPE="3" MODELSNMP="178" SERIAL=".1.3.6.1.2.1.43.5.1.1.17.1" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="KONICA MINOLTA bizhub 420" MANUFACTURER="0" TYPE="3" MODELSNMP="60" SERIAL=".1.3.6.1.2.1.43.5.1.1.17.1" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="KONICA MINOLTA bizhub C250" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="KONICA MINOLTA 362" MANUFACTURER="0" TYPE="3" MODELSNMP="57" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Xerox Phaser 6250DP;PS 4.8.0,Net 18.02.08.01.2003,Eng 1.1.2,OS 4.82;SN PWH564519" MANUFACTURER="0" TYPE="3" MODELSNMP="62" SERIAL=".1.3.6.1.2.1.43.5.1.1.17.1" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Hardware: x86 Family 15 Model 3 Stepping 4 AT/AT COMPATIBLE - Software: Windows 2000 Version 5.0 (Build 2195 Multiprocessor Free)" MANUFACTURER="" TYPE="1"/>
   <DEVICE SYSDESCR="Ordinateur CHRP PowerPC IBM&#13;&#10;TCP/IP Client Support  version: 05.03.0000.0061" MANUFACTURER="" TYPE="1"/>
   <DEVICE SYSDESCR="MF series printer" MANUFACTURER="0" TYPE="3" MODELSNMP="55" SERIAL=".1.3.6.1.2.1.43.5.1.1.17.1" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="hp business inkjet 1100" MANUFACTURER="0" TYPE="3" MODELSNMP="182" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Hardware: x86 Family 15 Model 2 Stepping 6 AT/AT COMPATIBLE - Software: Windows 2000 Version 5.0 (Build 2195 Multiprocessor Free)" MANUFACTURER="" TYPE="1"/>
   <DEVICE SYSDESCR="KONICA MINOLTA bizhub 600" MANUFACTURER="0" TYPE="3" MODELSNMP="61" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="hp LaserJet 9040" MANUFACTURER="0" TYPE="3" MODELSNMP="178" SERIAL=".1.3.6.1.2.1.43.5.1.1.17.1" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="hp LaserJet 3380" MANUFACTURER="" TYPE="3"/>
   <DEVICE SYSDESCR="HP LaserJet 8150 Series" MANUFACTURER="0" TYPE="3" MODELSNMP="177" SERIAL=".1.3.6.1.2.1.43.5.1.1.17.1" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="hp color LaserJet 4600" MANUFACTURER="0" TYPE="3" MODELSNMP="181" SERIAL=".1.3.6.1.2.1.43.5.1.1.17.1" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="KYOCERA Printer I/F IB-21G Ver 1.3.3" MANUFACTURER="0" TYPE="3" MODELSNMP="56" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Ordinateur CHRP PowerPC IBM&#13;&#10;Machine Type: 0x0800004c Processor id: 000811D2D700&#13;&#10;Base Operating System Runtime AIX version: 05.03.0000.0060&#13;&#10;TCP/IP Client Support  version: 05.03.0000.0061" MANUFACTURER="0" TYPE="1"/>
   <DEVICE SYSDESCR="KONICA MINOLTA bizhub C280" MANUFACTURER="0" TYPE="3" MODELSNMP="63" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Cisco IOS Software, s72033_rp Software (s72033_rp-ADVIPSERVICESK9_WAN-M), Version 12.2(33)SXI, RELEASE SOFTWARE (fc2)&#13;&#10;Technical Support: http://www.cisco.com/techsupport&#13;&#10;Copyright (c) 1986-2008 by Cisco Systems, Inc.&#13;&#10;Compiled Fri 07-Nov-08 04:00 by pro" MANUFACTURER="0" TYPE="2"/>
   <DEVICE SYSDESCR="Brother NC-6400h, Firmware Ver.1.01  (05.08.31),MID 84UZ92" MANUFACTURER="0" TYPE="3"/>
   <DEVICE SYSDESCR="Dell Laser Printer 1720dn version NM.NA.N094a-p1 kernel 2.6.10 All-N-1" MANUFACTURER="0" TYPE="3" MODELSNMP="48" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Dell Color Laser 3110cn; Net 8.43, Controller 200804091041, Engine 05.09.00" MANUFACTURER="0" TYPE="3"/>
   <DEVICE SYSDESCR="Dell Color Laser 5110cn; Net 8.43, Controller 200707111650, Engine 01.03.00" MANUFACTURER="0" TYPE="3"/>
   <DEVICE SYSDESCR="Dell Laser Printer 5210n version NS.NP.N224 kernel 2.6.6 All-N-1" MANUFACTURER="0" TYPE="3" MODELSNMP="48" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Xerox WorkCentre 7232;ESS PS1.205.0,IOT 10.3.0,FIN A5.3.0,IIT 20.5.1,ADF 20.0.0,FAX 1.30.58,SJFI3.0.8,SSMI1.7.1" MANUFACTURER="0" TYPE="3"/>
   <DEVICE SYSDESCR="TOSHIBA e-STUDIO 3520C" MANUFACTURER="0" TYPE="3" MODELSNMP="49" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Brother NC-9100h, Firmware Ver.1.05  (04.03.26),MID 8C5-945" MANUFACTURER="0" TYPE="3" MODELSNMP="42" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Dell  1815dn Series" MANUFACTURER="0" TYPE="3" MODELSNMP="43" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Dell 2330dn Laser Printer version NR.APS.N310 kernel 2.6.18.5 All-N-1" MANUFACTURER="0" TYPE="3" MODELSNMP="44" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Xerox WorkCentre M20i ; OS 1.22   Engine 4.1.08 NIC V1.08 DADF 1.04" MANUFACTURER="0" TYPE="3" MODELSNMP="45" SERIAL=".1.3.6.1.2.1.43.5.1.1.17.1" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Canon iR 3180C EUR /P" MANUFACTURER="0" TYPE="3" MODELSNMP="46" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Xerox WorkCentre M20i ; OS 3.02 Engine 4.1.12 NIC V1.08 DADF 1.04" MANUFACTURER="0" TYPE="3" MODELSNMP="47" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Dell Color Laser 3110cn; Net 8.43, Controller 200707111148, Engine 05.09.00" MANUFACTURER="0" TYPE="3" MODELSNMP="50" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="NRG MP 4500 1.01 / NRG Network Printer C model / NRG Network Scanner C model" MANUFACTURER="0" TYPE="3" MODELSNMP="52" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="NRG DSm645 2.40 / NRG Network Printer C model / NRG Network Scanner C model" MANUFACTURER="0" TYPE="3" MODELSNMP="52" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Xerox Phaser 6350DT;PS 3.11.0,Net 24.22.04.20.2005,Eng 3.1.0,OS 5.74" MANUFACTURER="0" TYPE="3" MODELSNMP="50" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="RICOH Aficio 2022 1.02.1 / RICOH Network Printer C model / RICOH Network Scanner C model" MANUFACTURER="0" TYPE="3" MODELSNMP="54" SERIAL=".1.3.6.1.4.1.367.3.2.1.2.1.4.0" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="RICOH Aficio 1022 5.20 / RICOH Network Printer C model" MANUFACTURER="0" TYPE="3" MODELSNMP="54" SERIAL=".1.3.6.1.4.1.367.3.2.1.2.1.4.0" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Dell Color Laser 3110cn; Net 8.41, Controller 200612221216, Engine 05.09.00" MANUFACTURER="0" TYPE="3" MODELSNMP="50" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Dell Laser Printer 5210n version NS.NP.N212 kernel 2.6.6 All-N-1" MANUFACTURER="0" TYPE="3" MODELSNMP="48" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="ProSafe 802.11b/g Wireless Access Point -WG102 V5.0.0" MANUFACTURER="0" TYPE="2" MODELSNMP="67"/>
   <DEVICE SYSDESCR="SonicWALL PRO 4100 (SonicOS Enhanced 4.0.0.5-1e)" MANUFACTURER="0" TYPE="2" MODELSNMP="68"/>
   <DEVICE SYSDESCR="3Com IntelliJack NJ225" MANUFACTURER="0" TYPE="2" MODELSNMP="70" SERIAL=".1.3.6.1.4.1.43.29.4.18.2.1.7.1" MAC=".1.3.6.1.2.1.17.1.1.0"/>
   <DEVICE SYSDESCR="OmniStack LS 6200" MANUFACTURER="0" TYPE="2" MODELSNMP="69" MAC=".1.3.6.1.2.1.17.1.1.0"/>
   <DEVICE SYSDESCR="Avaya Inc. - P330 Stackable Switch, SW version 4.1.1" MANUFACTURER="0" TYPE="2"/>
   <DEVICE SYSDESCR="Foundry Networks, Inc. FastIron SX 800-PREM, IronWare Version 03.2.00fT3e3 Compiled on Sep 10 2007 at 13:27:27 labeled as SXR03200f" MANUFACTURER="0" TYPE="2" MODELSNMP="72" MAC=".1.3.6.1.2.1.17.1.1.0"/>
   <DEVICE SYSDESCR="HP J4121A ProCurve Switch 4000M, revision C.09.28, ROM C.06.01 (/sw/code/build/vgro(c09))" MANUFACTURER="0" TYPE="2" MODELSNMP="73" MAC=".1.3.6.1.2.1.17.1.1.0"/>
   <DEVICE SYSDESCR="HP J4813A ProCurve Switch 2524, revision F.05.60, ROM F.02.01  (/sw/code/build/info(s02))" MANUFACTURER="0" TYPE="2" MODELSNMP="74" MAC=".1.3.6.1.2.1.17.1.1.0"/>
   <DEVICE SYSDESCR="HP J4865A ProCurve Switch 4108GL, revision G.07.70, ROM G.05.02 (/sw/code/build/gamo(m03))" MANUFACTURER="0" TYPE="2" MODELSNMP="75" MAC=".1.3.6.1.2.1.17.1.1.0"/>
   <DEVICE SYSDESCR="HP J4899A ProCurve Switch 2650, revision H.08.53, ROM H.08.02 (/sw/code/build/fish(f04))" MANUFACTURER="0" TYPE="2" MODELSNMP="76" MAC=".1.3.6.1.2.1.17.1.1.0"/>
   <DEVICE SYSDESCR="HP J4906A ProCurve Switch 3400cl-48G, revision M.08.51, ROM I.08.02 (/sw/code/build/makf(f04))" MANUFACTURER="0" TYPE="2" MODELSNMP="77" MAC=".1.3.6.1.2.1.17.1.1.0"/>
   <DEVICE SYSDESCR="GbE2c Ethernet Blade Switch for HP c-Class BladeSystem" MANUFACTURER="0" TYPE="2" MODELSNMP="51"/>
   <DEVICE SYSDESCR="ProCurve Access Point 530 WW J8987A, revision WA.01.19, boot version WAB.01.00" MANUFACTURER="0" TYPE="2" MODELSNMP="78" MAC=".1.3.6.1.2.1.17.1.1.0"/>
   <DEVICE SYSDESCR="FS726T" MANUFACTURER="0" TYPE="2" MODELSNMP="79" MAC=".1.3.6.1.2.1.17.1.1.0"/>
   <DEVICE SYSDESCR="Ethernet Switch 425-24T  HW:06       FW:3.5.0.2   SW:v3.5.0.06  BN:6 (c) Nortel Networks" MANUFACTURER="0" TYPE="2" MODELSNMP="80" MAC=".1.3.6.1.2.1.17.1.1.0"/>
   <DEVICE SYSDESCR="BayStack 450-12T HW:RevD  FW:V1.48 SW:v4.3.0.4 ISVN:2" MANUFACTURER="0" TYPE="2" MODELSNMP="81" MAC=".1.3.6.1.2.1.17.1.1.0"/>
   <DEVICE SYSDESCR="BayStack 450-24T HW:RevL  FW:V1.47 SW:v3.1.0.22  ISVN:1" MANUFACTURER="0" TYPE="2" MODELSNMP="81" MAC=".1.3.6.1.2.1.17.1.1.0"/>
   <DEVICE SYSDESCR="ATI AT-8000S" MANUFACTURER="0" TYPE="2" MODELSNMP="82" MAC=".1.3.6.1.2.1.17.1.1.0"/>
   <DEVICE SYSDESCR="Allied Telesyn Ethernet Switch AT-8524M - ATS62 v1.4.0" MANUFACTURER="0" TYPE="2" MODELSNMP="80" MAC=".1.3.6.1.2.1.17.1.1.0"/>
   <DEVICE SYSDESCR="Allied Telesis AT-9424Ts - ATS63 v3.0.0" MANUFACTURER="0" TYPE="2" MODELSNMP="83" MAC=".1.3.6.1.2.1.17.1.1.0"/>
   <DEVICE SYSDESCR="Summit200-48 - Version 7.3e.2 (Build 4) by Release_Master 02/24/05 19:20:09" MANUFACTURER="0" TYPE="2" MODELSNMP="84" MAC=".1.3.6.1.2.1.17.1.1.0"/>
   <DEVICE SYSDESCR="SMC 6624M TigerSwitch 10/100, revision F.02.06, ROM F.01.02" MANUFACTURER="0" TYPE="2" MODELSNMP="85" MAC=".1.3.6.1.2.1.17.1.1.0"/>
   <DEVICE SYSDESCR="Summit300-48 - Version 7.6e.4 (Build 4) by Release_Master 04/27/07 08:31:27" MANUFACTURER="0" TYPE="2" MODELSNMP="84" MAC=".1.3.6.1.2.1.17.1.1.0"/>
   <DEVICE SYSDESCR="CS131 v 3.77.47" MANUFACTURER="0" TYPE="5"/>
   <DEVICE SYSDESCR="Brother NC-5100h, Firmware Ver.1.50  (04.04.19),MID 84UZ74,FID 1" MANUFACTURER="0" TYPE="3" MODELSNMP="86" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Brother NC-6400h, Firmware Ver.1.04  (05.11.10),MID 84UZ92" MANUFACTURER="0" TYPE="3" MODELSNMP="86" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Brother NC-6600h, Firmware Ver.1.06  (07.11.21),MID 84UA03" MANUFACTURER="0" TYPE="3" MODELSNMP="42" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Brother NC-150h, Firmware Ver.0.09  ,MID 8CA-E46-001" MANUFACTURER="0" TYPE="3" MODELSNMP="88" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Brother NC-6400h, Firmware Ver.1.15  (07.01.23),MID 8C5-B45,FID 2" MANUFACTURER="0" TYPE="3" MODELSNMP="42" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="NRG MP C2500 1.59 / NRG Network Printer C model / NRG Network Scanner C model" MANUFACTURER="0" TYPE="3" MODELSNMP="89" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Xerox WorkCentre Pro Multifunction System; ESS 0.040.010.51172, IOT 50.0.0, UI 0.12.50.3, Finisher 24.10.0, Scanner 4.9.0" MANUFACTURER="0" TYPE="3" MODELSNMP="90" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Xerox WorkCentre Pro Multifunction System, ESS 0.C03.04.510.01, IOT 9.0.3, UI 0.1.4.51, Finisher 3.8.0, Scanner 1.4.0" MANUFACTURER="0" TYPE="3" MODELSNMP="91" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Xerox WorkCentre Pro 123;ESS 1.204.7,IOT 21.46.0,FIN B10.6.0,IIT 11.7.1,ADF 10.3.0,FAX 1.20.20" MANUFACTURER="0" TYPE="3" MODELSNMP="92" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Xerox WorkCentre M20i ; OS 3.02 Engine 4.1.12 NIC V2.16(M20i) DADF 1.06" MANUFACTURER="0" TYPE="3" MODELSNMP="47" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Xerox WorkCentre Pro Multifunction System, ESS 0.C03.04.044.01, IOT 8.0.0, UI 0.1.4.43, Scanner 1.3.0" MANUFACTURER="0" TYPE="3" MODELSNMP="91" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Canon LBP5360 /P" MANUFACTURER="0" TYPE="3" MODELSNMP="93" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Canon W8400PG /P" MANUFACTURER="0" TYPE="3" MODELSNMP="94" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Canon iR 3100C EUR /P" MANUFACTURER="0" TYPE="3" MODELSNMP="46" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Canon iR C2620 /P" MANUFACTURER="0" TYPE="3" MODELSNMP="46" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Canon iR2016 /P" MANUFACTURER="0" TYPE="3" MODELSNMP="97" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Canon iR2018 /P" MANUFACTURER="0" TYPE="3" MODELSNMP="98" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Canon iR1022 /P" MANUFACTURER="0" TYPE="3" MODELSNMP="97" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Canon iR3035 /P" MANUFACTURER="0" TYPE="3" MODELSNMP="53" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Canon iR3045 /P" MANUFACTURER="0" TYPE="3" MODELSNMP="53" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Canon iR4570 /P" MANUFACTURER="0" TYPE="3" MODELSNMP="53" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="EPSON AL-C8500 01.00" MANUFACTURER="0" TYPE="3" MODELSNMP="101" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Lexmark C720  Version 1.10.10  Ethernet 10/100." MANUFACTURER="0" TYPE="3" MODELSNMP="46" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Lexmark C912 version 72.00.13 kernel 2.4.0-test6 All-N-1" MANUFACTURER="0" TYPE="3" MODELSNMP="102" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Lexmark Optra T614  Version 3.14.16  Ethernet 10/100." MANUFACTURER="0" TYPE="3" MODELSNMP="103" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Lexmark T620  Version 5.20.26  FaxSCSI-Ethernet." MANUFACTURER="0" TYPE="3" MODELSNMP="103" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Lexmark T632 version 55.00.39 kernel 2.4.0-test6 All-N-1" MANUFACTURER="0" TYPE="3" MODELSNMP="103" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Lexmark T644 version NS.NP.N219 kernel 2.6.6 All-N-1" MANUFACTURER="0" TYPE="3" MODELSNMP="104" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="RICOH Aficio 3260C 1.24 / RICOH Network Printer C model / RICOH Network Scanner C model" MANUFACTURER="0" TYPE="3" MODELSNMP="106" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="RICOH Aficio MP C6000 1.05 / RICOH Network Printer C model / RICOH Network Scanner C model" MANUFACTURER="0" TYPE="3" MODELSNMP="107" SERIAL=".1.3.6.1.2.1.43.5.1.1.17.1" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="RICOH Aficio 3030 1.11.1 / RICOH Network Printer C model / RICOH Network Scanner C model" MANUFACTURER="0" TYPE="3" MODELSNMP="108" SERIAL=".1.3.6.1.4.1.367.3.2.1.2.1.4.0" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="RICOH Aficio MP 2500 1.00 / RICOH Network Printer C model / RICOH Network Scanner C model" MANUFACTURER="0" TYPE="3" MODELSNMP="109" SERIAL=".1.3.6.1.4.1.367.3.2.1.2.1.4.0" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="RICOH Aficio MP C2500 1.68 / RICOH Network Printer C model / RICOH Network Scanner C model / RICOH Network Facsimile C model" MANUFACTURER="0" TYPE="3" MODELSNMP="110" SERIAL=".1.3.6.1.4.1.367.3.2.1.2.1.4.0" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="RICOH Aficio MP C3500 1.66.1 / RICOH Network Printer C model / RICOH Network Scanner C model" MANUFACTURER="0" TYPE="3" MODELSNMP="111" SERIAL=".1.3.6.1.4.1.367.3.2.1.2.1.4.0" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="RICOH Aficio SP C222SF v1.50 / RICOH Network Printer C model /RICOH Network Scanner C model /RICOH Network Facsimile C model" MANUFACTURER="0" TYPE="3" MODELSNMP="112" SERIAL=".1.3.6.1.4.1.367.3.2.1.2.1.4.0" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Samsung ML-2850 Series OS 1.29.00.32 06-17-2008;Engine 1.01.21;NIC V4.01.02(ML-285x) 09-13-2007;S/N 4P21BAGQ800927V" MANUFACTURER="0" TYPE="3" MODELSNMP="113" SERIAL=".1.3.6.1.2.1.43.5.1.1.17.1" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Samsung CLP-610 Series; OS 1.29.01.22 11-23-2007;Engine 1.00.83;NIC V4.01.01(CLP-610) 10-01-2007;S/N 4D21B1BPC00621X" MANUFACTURER="0" TYPE="3" MODELSNMP="114" SERIAL=".1.3.6.1.2.1.43.5.1.1.17.1" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Brother NC-6400h, Firmware Ver.1.11b  (07.05.16),MID 84UZ92" MANUFACTURER="0" TYPE="3" MODELSNMP="86" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Brother NC-3100h, Firmware Ver.3.20  (00.08.31)" MANUFACTURER="0" TYPE="3" MODELSNMP="86" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Brother NC-3100h, Firmware Ver.1.20  (02.07.12),MID 84UZ34,FID 3" MANUFACTURER="0" TYPE="3" MODELSNMP="86" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Brother NC-4100h, Firmware Ver.1.12  (01.06.11),MID 54TU05,FID 2" MANUFACTURER="0" TYPE="3" MODELSNMP="116" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Brother NC-6800h, Firmware Ver.1.01  (08.12.12),MID 84UB03" MANUFACTURER="0" TYPE="3" MODELSNMP="86" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Brother NC-4100h, Firmware Ver.1.02  (07.02.27),MID 84TU07,FID 5" MANUFACTURER="0" TYPE="3" MODELSNMP="42" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Xerox WorkCentre Pro Multifunction System, ESS 0.C03.04.525.01, IOT 9.0.3, UI 0.1.4.525, Scanner 1.4.0" MANUFACTURER="0" TYPE="3" MODELSNMP="117" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Cisco Internetwork Operating System Software &#13;&#10;IOS (tm) C2900XL Software (C2900XL-C3H2S-M), Version 12.0(5)WC17, RELEASE SOFTWARE (fc1)&#13;&#10;Copyright (c) 1986-2007 by cisco Systems, Inc.&#13;&#10;Compiled Tue 13-Feb-07 15:27 by antonino&#13;&#10;" MANUFACTURER="0" TYPE="2" MODELSNMP="69" MAC=".1.3.6.1.2.1.17.1.1.0"/>
   <DEVICE SYSDESCR="NRG SP C410DN 1.09 / NRG Network Printer C model" MANUFACTURER="0" TYPE="3" MODELSNMP="89" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="HP J4813A ProCurve Switch 2524, revision F.04.08, ROM F.02.01  (/sw/code/build/info(f01))" MANUFACTURER="0" TYPE="2" MODELSNMP="119" MAC=".1.3.6.1.2.1.17.1.1.0"/>
   <DEVICE SYSDESCR="Canon LP17 /P" MANUFACTURER="0" TYPE="3" MODELSNMP="121" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Canon iR5000i /P" MANUFACTURER="0" TYPE="3" MODELSNMP="99" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="BladeCenter Advanced Management Module" MANUFACTURER="0" TYPE="2" MODELSNMP="67"/>
   <DEVICE SYSDESCR="Cisco Internetwork Operating System Software &#13;&#10;IOS (tm) CIGESM Software (CIGESM-I6Q4L2-M), Version 12.1(22)EA8a, RELEASE SOFTWARE (fc1)&#13;&#10;Copyright (c) 1986-2006 by cisco Systems, Inc.&#13;&#10;Compiled Fri 28-Jul-06 14:55 by weiliu" MANUFACTURER="0" TYPE="2" MODELSNMP="122" MAC=".1.3.6.1.2.1.17.1.1.0"/>
   <DEVICE SYSDESCR="Nortel Networks Layer2-7 GbE Switch Module" MANUFACTURER="0" TYPE="2" MODELSNMP="78" MAC=".1.3.6.1.2.1.17.1.1.0"/>
   <DEVICE SYSDESCR="ATI 8000S" MANUFACTURER="0" TYPE="2" MODELSNMP="123" MAC=".1.3.6.1.2.1.17.1.1.0"/>
   <DEVICE SYSDESCR="D-Link Access Point" MANUFACTURER="0" TYPE="2" MODELSNMP="51"/>
   <DEVICE SYSDESCR="DES-3526 Fast-Ethernet Switch" MANUFACTURER="0" TYPE="2" MODELSNMP="124"/>
   <DEVICE SYSDESCR="DES-3550 Fast-Ethernet Switch" MANUFACTURER="0" TYPE="2" MODELSNMP="83" MAC=".1.3.6.1.2.1.17.1.1.0"/>
   <DEVICE SYSDESCR="APC Web/SNMP Management Card (MB:v3.6.8 PF:v2.6.4 PN:apc_hw02_aos_264.bin AF1:v2.6.1 AN1:apc_hw02_sumx_261.bin MN:AP9617 HR:A10 SN: ZA0533007458 MD:08/10/2005) (Embedded PowerNet SNMP Agent SW v2.2 compatible)" MANUFACTURER="0" TYPE="5"/>
   <DEVICE SYSDESCR="Cisco IOS Software, C870 Software (C870-ADVIPSERVICESK9-M), Version 12.4(4)T7, RELEASE SOFTWARE (fc1)&#13;&#10;Technical Support: http://www.cisco.com/techsupport&#13;&#10;Copyright (c) 1986-2006 by Cisco Systems, Inc.&#13;&#10;Compiled Wed 29-Nov-06 00:43 by kellythw" MANUFACTURER="0" TYPE="2" MODELSNMP="125" SERIAL=".1.3.6.1.2.1.47.1.1.1.1.11.1"/>
   <DEVICE SYSDESCR="DES-3326S Fast-Ethernet Switch" MANUFACTURER="0" TYPE="2" MODELSNMP="126"/>
   <DEVICE SYSDESCR="HP ProCurve Access Point 420: v2.1.7 v3.0.6" MANUFACTURER="0" TYPE="2" MODELSNMP="127"/>
   <DEVICE SYSDESCR="Cisco IOS Software, C1310 Software (C1310-K9W7-M), Version 12.4(10b)JA1, RELEASE SOFTWARE (fc2)&#13;&#10;Technical Support: http://www.cisco.com/techsupport&#13;&#10;Copyright (c) 1986-2008 by Cisco Systems, Inc.&#13;&#10;Compiled Wed 30-Jan-08 12:18 by prod_rel_team" MANUFACTURER="0" TYPE="2" MODELSNMP="125" SERIAL=".1.3.6.1.2.1.47.1.1.1.1.11.1"/>
   <DEVICE SYSDESCR="RICOH Aficio 1035 5.25 / RICOH Network Printer C model" MANUFACTURER="0" TYPE="3" MODELSNMP="128" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="ProCurve J8773A Switch 4208vl, revision L.11.20, ROM L.10.03 (/sw/code/build/rmm(rm11))" MANUFACTURER="0" TYPE="2" MODELSNMP="77" MAC=".1.3.6.1.2.1.17.1.1.0"/>
   <DEVICE SYSDESCR="ES-2048" MANUFACTURER="0" TYPE="2" MODELSNMP="129"/>
   <DEVICE SYSDESCR="ES-2108PWR" MANUFACTURER="0" TYPE="2" MODELSNMP="72" MAC=".1.3.6.1.2.1.17.1.1.0"/>
   <DEVICE SYSDESCR="NWA-3100" MANUFACTURER="0" TYPE="2" MODELSNMP="130"/>
   <DEVICE SYSDESCR="ZyWALL USG 300" MANUFACTURER="0" TYPE="2" MODELSNMP="131"/>
   <DEVICE SYSDESCR="FreeBSD F60-XA307610700202 4.11-RELEASE-p25  NETASQ Secure BSD (NS-BSD)  i386" MANUFACTURER="0" TYPE="2" MODELSNMP="132"/>
   <DEVICE SYSDESCR="HP Color LaserJet 4550 " MANUFACTURER="0" TYPE="3" MODELSNMP="179" SERIAL=".1.3.6.1.2.1.43.5.1.1.17.1" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="HP Color LaserJet 4700" MANUFACTURER="0" TYPE="3" MODELSNMP="180" SERIAL=".1.3.6.1.2.1.43.5.1.1.17.1" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Cisco Systems Catalyst 1900" MANUFACTURER="0" TYPE="2" MODELSNMP="150" MAC=".1.3.6.1.2.1.17.1.1.0"/>
   <DEVICE SYSDESCR="Xerox WorkCentre C226" MANUFACTURER="0" TYPE="3" MODELSNMP="151" SERIAL=".1.3.6.1.2.1.43.5.1.1.17.1" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Canon iR3300 /P" MANUFACTURER="0" TYPE="3" MODELSNMP="152" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Brother NC-6200h, Firmware Ver.1.03  (04.11.18),MID 84UZ82,FID 1" MANUFACTURER="0" TYPE="3" MODELSNMP="155" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="HP J4093A ProCurve Switch 2424M, revision C.09.09, ROM C.06.01 (/sw/code/build/vgro(c09))" MANUFACTURER="0" TYPE="2" MODELSNMP="156" SERIAL=".1.3.6.1.4.1.11.2.36.1.1.2.9.0" MAC=".1.3.6.1.2.1.17.1.1.0"/>
   <DEVICE SYSDESCR="HP J4813A ProCurve Switch 2524, revision F.05.17, ROM F.02.01  (/sw/code/build/info(s02))" MANUFACTURER="0" TYPE="2" MODELSNMP="75" SERIAL=".1.3.6.1.2.1.47.1.1.1.1.11.1" MAC=".1.3.6.1.2.1.17.1.1.0"/>
   <DEVICE SYSDESCR="HP J4903A ProCurve Switch 2824, revision I.07.68, ROM I.08.07 (/sw/code/build/mako(m03))" MANUFACTURER="0" TYPE="2" MODELSNMP="158" SERIAL=".1.3.6.1.2.1.47.1.1.1.1.11.1" MAC=".1.3.6.1.2.1.17.1.1.0"/>
   <DEVICE SYSDESCR="ProCurve J4905A Switch 3400cl-24G, revision M.10.41, ROM I.08.12 (/sw/code/build/makf(mkfs))" MANUFACTURER="0" TYPE="2" MODELSNMP="75" SERIAL=".1.3.6.1.2.1.47.1.1.1.1.11.1" MAC=".1.3.6.1.2.1.17.1.1.0"/>
   <DEVICE SYSDESCR="HP J4121A ProCurve Switch 4000M, revision C.09.09, ROM C.06.01 (/sw/code/build/vgro(c09))" MANUFACTURER="0" TYPE="2" MODELSNMP="159" SERIAL=".1.3.6.1.4.1.11.2.36.1.1.2.9.0" MAC=".1.3.6.1.2.1.17.1.1.0"/>
   <DEVICE SYSDESCR="ProCurve J8697A Switch 5406zl, revision K.12.57, ROM K.12.12 (/sw/code/build/btm(t2g))" MANUFACTURER="0" TYPE="2" MODELSNMP="75" SERIAL=".1.3.6.1.2.1.47.1.1.1.1.11.1" MAC=".1.3.6.1.2.1.17.1.1.0"/>
   <DEVICE SYSDESCR="Xerox Phaser 4510N; OS 7.76, PS 4.1.0, Eng 2.01.00.00, Net 34.50.08.09.2007" MANUFACTURER="0" TYPE="3" MODELSNMP="160" SERIAL=".1.3.6.1.2.1.43.5.1.1.17.1" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="HP J4813A ProCurve Switch 2524, revision F.05.65, ROM F.01.01  (/sw/code/build/info(s02))" MANUFACTURER="0" TYPE="2" MODELSNMP="158" SERIAL=".1.3.6.1.2.1.47.1.1.1.1.11.1" MAC=".1.3.6.1.2.1.17.1.1.0"/>
   <DEVICE SYSDESCR="HP J4865A ProCurve Switch 4108GL, revision G.07.53, ROM G.05.02 (/sw/code/build/gamo(m03))" MANUFACTURER="0" TYPE="2" MODELSNMP="158" SERIAL=".1.3.6.1.2.1.47.1.1.1.1.11.1" MAC=".1.3.6.1.2.1.17.1.1.0"/>
   <DEVICE SYSDESCR="Xerox WorkCentre Pro Multifunction System, ESS 0.R01.02.366.01, IOT 23.35.0, UI 0.2.92.12, Finisher 9.15.0, Scanner 15.7.0" MANUFACTURER="0" TYPE="3" MODELSNMP="161" SERIAL=".1.3.6.1.2.1.43.5.1.1.17.1" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Evolution 1500" MANUFACTURER="0" TYPE="5"/>
   <DEVICE SYSDESCR="Evolution 800" MANUFACTURER="0" TYPE="5"/>
   <DEVICE SYSDESCR="EXtreme 1000C" MANUFACTURER="0" TYPE="5"/>
   <DEVICE SYSDESCR="Evolution 850" MANUFACTURER="0" TYPE="5"/>
   <DEVICE SYSDESCR="Cisco IOS Software, C2960 Software (C2960-LANBASEK9-M), Version 12.2(52)SE, RELEASE SOFTWARE (fc3)&#13;&#10;Copyright (c) 1986-2009 by Cisco Systems, Inc.&#13;&#10;Compiled Fri 25-Sep-09 08:49 by sasyamal" MANUFACTURER="0" TYPE="2" MODELSNMP="163" SERIAL=".1.3.6.1.2.1.47.1.1.1.1.11.1001" MAC=".1.3.6.1.2.1.17.1.1.0"/>
   <DEVICE SYSDESCR="Cisco IOS Software, Catalyst 4500 L3 Switch Software (cat4500-ENTSERVICESK9-M), Version 12.2(37)SG1, RELEASE SOFTWARE (fc2)&#13;&#10;Technical Support: http://www.cisco.com/techsupport&#13;&#10;Copyright (c) 1986-2007 by Cisco Systems, Inc.&#13;&#10;Compiled Mon 30-Jul-07 13:47" MANUFACTURER="0" TYPE="2" MODELSNMP="176" SERIAL=".1.3.6.1.2.1.47.1.1.1.1.11.1" MAC=".1.3.6.1.2.1.17.1.1.0"/>
   <DEVICE SYSDESCR="Photosmart D7200 series" MANUFACTURER="0" TYPE="3" MODELSNMP="188" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="HP P" MANUFACTURER="0" TYPE="2" MODELSNMP="190" MAC=".1.3.6.1.2.1.17.1.1.0"/>
   <DEVICE SYSDESCR="ITIUM 4030" MANUFACTURER="0" TYPE="1"/>
   <DEVICE SYSDESCR="HP ProCurve Access Point 420: v2.2.3 v3.0.6" MANUFACTURER="0" TYPE="2" MODELSNMP="190" MAC=".1.3.6.1.2.1.17.1.1.0"/>
   <DEVICE SYSDESCR="ProCurve J4905A Switch 3400cl-24G, revision M.10.30, ROM I.08.12 (/sw/code/build/makf(mkfs))" MANUFACTURER="0" TYPE="2" MODELSNMP="192" SERIAL=".1.3.6.1.2.1.47.1.1.1.1.11.1" MAC=".1.3.6.1.2.1.17.1.1.0"/>
   <DEVICE SYSDESCR="Evolution 500" MANUFACTURER="0" TYPE="5"/>
   <DEVICE SYSDESCR="HP J4899B ProCurve Switch 2650, revision H.08.67, ROM H.08.02 (/sw/code/build/fish(f04))" MANUFACTURER="0" TYPE="2"/>
   <DEVICE SYSDESCR="FS-C5200DN" MANUFACTURER="0" TYPE="3" MODELSNMP="193" SERIAL=".1.3.6.1.2.1.43.5.1.1.17.1" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Lexmark T654 version NR.APS.N368 kernel 2.6.18.5 All-N-1" MANUFACTURER="0" TYPE="3" MODELSNMP="105" SERIAL=".1.3.6.1.4.1.641.2.1.2.1.6.1" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="ProCurve Secure Router 7102dl, Version: 08.03, Date: Fri Jul 20 09:41:03 2007" MANUFACTURER="0" TYPE="2" MODELSNMP="195" SERIAL=".1.3.6.1.2.1.47.1.1.1.1.11.1"/>
   <DEVICE SYSDESCR="HP J4902A ProCurve Switch 6108, revision H.07.90, ROM H.07.40 (/sw/code/build/fish(ff03))" MANUFACTURER="0" TYPE="2" MODELSNMP="158" SERIAL=".1.3.6.1.2.1.47.1.1.1.1.11.1" MAC=".1.3.6.1.2.1.17.1.1.0"/>
   <DEVICE SYSDESCR="HL-5140 series" MANUFACTURER="0" TYPE="3" MODELSNMP="196" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Evolution 650" MANUFACTURER="0" TYPE="5"/>
   <DEVICE SYSDESCR="HL-1850_1870N series" MANUFACTURER="0" TYPE="3" MODELSNMP="196" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="HL-5270DN series" MANUFACTURER="0" TYPE="3" MODELSNMP="196" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Brother NC-4100h, Firmware Ver.1.10  (02.07.12),MID 84UZ23,FID 4" MANUFACTURER="0" TYPE="3" MODELSNMP="155" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Brother NC-6800h, Firmware Ver.1.01  (08.12.12),MID 84UB07" MANUFACTURER="0" TYPE="3" MODELSNMP="198" SERIAL=".1.3.6.1.2.1.43.5.1.1.17.1" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Comet 30K_3_1" MANUFACTURER="0" TYPE="5"/>
   <DEVICE SYSDESCR="IP-Console-Switch-4x1x16 01.03.25.00" MANUFACTURER="0" TYPE="2" MODELSNMP="130"/>
   <DEVICE SYSDESCR="hp LaserJet 9050" MANUFACTURER="0" TYPE="3" MODELSNMP="178" SERIAL=".1.3.6.1.2.1.43.5.1.1.17.1" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="ProCurve J9086A Switch 2610-24/12PWR, revision R.11.22, ROM R.10.06 (/sw/code/build/nemo(ndx))" MANUFACTURER="0" TYPE="2" MODELSNMP="158" SERIAL=".1.3.6.1.2.1.47.1.1.1.1.11.1" MAC=".1.3.6.1.2.1.17.1.1.0"/>
   <DEVICE SYSDESCR="ProCurve J8762A Switch 2600-8-PWR, revision H.10.74, ROM H.08.03 (/sw/code/build/fish(mkfs))" MANUFACTURER="0" TYPE="2" MODELSNMP="158" SERIAL=".1.3.6.1.2.1.47.1.1.1.1.11.1" MAC=".1.3.6.1.2.1.17.1.1.0"/>
   <DEVICE SYSDESCR="ProCurve J9089A Switch 2610-48-PWR, revision R.11.25, ROM R.10.06 (/sw/code/build/nemo(ndx))" MANUFACTURER="0" TYPE="2" MODELSNMP="158" SERIAL=".1.3.6.1.2.1.47.1.1.1.1.11.1" MAC=".1.3.6.1.2.1.17.1.1.0"/>
   <DEVICE SYSDESCR="ProCurve Secure Router 7102dl, Version: 14.04, Date: Wed Oct 14 11:33:27 2009" MANUFACTURER="0" TYPE="2" MODELSNMP="199" SERIAL=".1.3.6.1.2.1.47.1.1.1.1.11.1"/>
   <DEVICE SYSDESCR="HP J4812A ProCurve Switch 2512, revision F.05.59, ROM F.02.01  (/sw/code/build/info(s02))" MANUFACTURER="0" TYPE="2" MODELSNMP="129"/>
   <DEVICE SYSDESCR="Brother NC-6400h, Firmware Ver.1.12  (06.04.20),MID 8C5-B35,FID 2" MANUFACTURER="0" TYPE="3" MODELSNMP="197" SERIAL=".1.3.6.1.2.1.43.5.1.1.17.1" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Brother NC-6400h, Firmware Ver.1.06  (05.12.29),MID 84UZ92" MANUFACTURER="0" TYPE="3" MODELSNMP="201" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Brother NC-6800h, Firmware Ver.1.02  (09.01.22),MID 8C5-D16,FID 2" MANUFACTURER="0" TYPE="3" MODELSNMP="202" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="DesignJet 500PS+HPGL2 (C7770C)" MANUFACTURER="0" TYPE="3" MODELSNMP="196" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Brother NC-130h, Firmware Ver.E  ,MID 8CA-E35-001" MANUFACTURER="0" TYPE="3" MODELSNMP="204" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Deskjet 6800" MANUFACTURER="0" TYPE="3" MODELSNMP="189" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Brother NC-6400h, Firmware Ver.1.08  (06.05.08),MID 84UZ93" MANUFACTURER="0" TYPE="3" MODELSNMP="198" SERIAL=".1.3.6.1.2.1.43.5.1.1.17.1" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Brother NC-6400h, Firmware Ver.1.09  (06.07.13),MID 84UZ93" MANUFACTURER="0" TYPE="3" MODELSNMP="198" SERIAL=".1.3.6.1.2.1.43.5.1.1.17.1" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Brother NC-6400h, Firmware Ver.1.06  (05.12.29),MID 84UZ93" MANUFACTURER="0" TYPE="3" MODELSNMP="206" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Hardware: x86 Family 6 Model 10 Stepping 4 AT/AT COMPATIBLE - Software: Windows 2000 Version 5.0 (Build 2195 Multiprocessor Free)" MANUFACTURER="0" TYPE="1"/>
   <DEVICE SYSDESCR="OKI OkiLAN 3100e Rev.n252v144 10/100BASE Ethernet Print Server: Attached to OKIPAGE 14i Rev.01.07: (C)2000 Oki UK Limited" MANUFACTURER="0" TYPE="3" MODELSNMP="155" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Brother NC-6200h, Firmware Ver.G  ,MID 8C5-A45,FID 2" MANUFACTURER="0" TYPE="3" MODELSNMP="207" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Brother NC-4100h, Firmware Ver.1.11  (01.02.26),MID 54TU05,FID 2" MANUFACTURER="0" TYPE="3" MODELSNMP="208" MAC=".1.3.6.1.2.1.2.2.1.6"/>
   <DEVICE SYSDESCR="Brother NC-4100h, Firmware Ver.1.01  (02.09.06),MID 84TU07,FID 5" MANUFACTURER="0" TYPE="3" MODELSNMP="155" MAC=".1.3.6.1.2.1.2.2.1.6"/>
</SNMPDISCOVERY>
';

   my $xmlDico = new XML::Simple;
   return XMLin($dico);

   1;
}

1;