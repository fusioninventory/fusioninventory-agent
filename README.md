# FusionInventory Agent

[![Travis Build Status](https://travis-ci.org/fusioninventory/fusioninventory-agent.svg?branch=master)](https://travis-ci.org/fusioninventory/fusioninventory-agent)
[![Appveyor Build status](https://ci.appveyor.com/api/projects/status/f2oh6p3qnr2bck1b?svg=true)](https://ci.appveyor.com/project/fusioninventory/fusioninventory-agent)
[![CircleCI Build status](https://circleci.com/gh/fusioninventory/fusioninventory-agent.svg?style=svg)](https://circleci.com/gh/fusioninventory/fusioninventory-agent)

## Summary

The FusionInventory agent is a generic management agent. It can perform a
certain number of tasks, according to its own execution plan, or on behalf of a
GLPI server with fusioninventory plugin, acting as a control point.

## Description

See [FusionInventory solution overview](http://fusioninventory.org/overview/)

## Dependencies

### Core

Minimum perl version: 5.8

Mandatory Perl modules:

* File::Which
* LWP::UserAgent
* Net::IP
* Text::Template
* UNIVERSAL::require
* XML::TreePP

Optional Perl modules:

* Compress::Zlib, for message compression
* HTTP::Daemon, for web interface
* IO::Socket::SSL, for HTTPS support
* LWP::Protocol::https, for HTTPS support
* Proc::Daemon, for daemon mode (Unix only)
* Proc::PID::File, for daemon mode (Unix only)

### Inventory task

Optional Perl modules:

* Net::CUPS, for printers detection
* Parse::EDID, for EDID data parsing
* DateTime, for reliable timezone name extraction

Optional programs:

* dmidecode, for DMI data retrieval
* lspci, for PCI bus scanning
* hdparm, for additional disk drive info retrieval
* monitor-get-edid-using-vbe, monitor-get-edid or get-edid, for EDID data access
* ssh-keyscan, for host SSH public key retrieval

### Network discovery tasks

Mandatory Perl modules:

* Thread::Queue

Optional Perl modules:

* Net::NBName, for NetBios method support
* Net::SNMP, for SNMP method support

Optional programs:

* nmap, for ICMP method support

### Network inventory tasks

Mandatory Perl modules:

* Net::SNMP
* Thread::Queue

Optional Perl modules:

* Crypt::DES, for SNMPv3 support

### Wake on LAN task

Optional Perl modules:

* Net::Write::Layer2, for ethernet method support

### Deploy task

Mandatory Perl modules:

* Archive::Extract
* Digest::SHA
* File::Copy::Recursive
* JSON::PP
* URI::Escape

Mandatory Perl modules for P2P Support:
* Net::Ping
* Parallel::ForkManager

## Related contribs

See [CONTRIB](CONTRIB.md) to find references to FusionInventory Agent related scritps/files

## Contacts

Project websites:

* main site: <http://www.fusioninventory.org>
* forge: <http://forge.fusioninventory.org>

Project mailing lists:

* <http://lists.alioth.debian.org/mailman/listinfo/fusioninventory-user>
* <http://lists.alioth.debian.org/mailman/listinfo/fusioninventory-devel>

Project IRC channel:

* #FusionInventory on FreeNode IRC Network

Please report any issues on project forge bugtracker.

## Active authors

* Guillaume Rousse <guillomovitch@gmail.com>
* Guillaume Bougard <gbougard@teclib.com>
* Thomas Lornet <tlornet@teclib.com>

Copyright 2006-2010 [OCS Inventory contributors](https://www.ocsinventory-ng.org/)

Copyright 2010-2017 [FusionInventory Team](http://fusioninventory.org)

Copyright 2011-2017 [Teclib Editions](http://www.teclib-edition.com/)

## License

This software is licensed under the terms of GPLv2+, see LICENSE file for
details.

## Additional pieces of software

The fusioninventory-injector script:

* author: Pascal Danek
* copyright: 2005 Pascal Danek

FusionInventory::Agent::Task::Inventory::Input::Virtualization::Vmsystem
contains code from imvirt:

* url: <http://micky.ibh.net/~liske/imvirt.html>
* author: Thomas Liske <liske@ibh.de>
* copyright: 2008 IBH IT-Service GmbH <http://www.ibh.de/>
* License: GPLv2+
