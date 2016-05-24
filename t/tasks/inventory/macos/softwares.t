#!/usr/bin/perl

use strict;
use warnings;
use lib 't/lib';

use Test::Deep;
use Test::Exception;
use Test::More;
use Test::NoWarnings;

use FusionInventory::Test::Inventory;
use FusionInventory::Agent::Task::Inventory::MacOS::Softwares;

use Data::Dumper;

my %tests = (
    'sample2' => [
                           {
                             'INSTALLDATE' => '2009-06-30 07:29',
                             'NAME' => '50onPaletteServer',
                             'PUBLISHER' => undef,
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '1.0.3'
                           },
                           {
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '3.4',
                             'INSTALLDATE' => '2011-02-20 15:34',
                             'NAME' => 'ARDAgent',
                             'PUBLISHER' => undef
                           },
                           {
                             'VERSION' => '4.7.3',
                             'COMMENTS' => '[Intel]',
                             'NAME' => 'ARM Help',
                             'PUBLISHER' => undef,
                             'INSTALLDATE' => '2011-01-05 17:56'
                           },
                           {
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '2.2',
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'NAME' => 'AU Lab',
                             'PUBLISHER' => '2.2 ©2010, Apple, Inc'
                           },
                           {
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '2.3.8',
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'NAME' => 'AVRCPAgent',
                             'PUBLISHER' => '2.3.8, Copyright (c) 2010 Apple Inc. All rights reserved.'
                           },
                           {
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '169.2',
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'NAME' => 'About Xcode',
                             'PUBLISHER' => 'About Xcode'
                           },
                           {
                             'VERSION' => '2.0',
                             'COMMENTS' => '[Intel]',
                             'NAME' => 'Accessibility Inspector',
                             'PUBLISHER' => 'Accessibility Inspector 2.0, Copyright 2002-2009 Apple Inc.',
                             'INSTALLDATE' => '2010-08-26 20:09'
                           },
                           {
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '1.2',
                             'INSTALLDATE' => '2010-08-26 20:09',
                             'PUBLISHER' => undef,
                             'NAME' => 'Accessibility Verifier'
                           },
                           {
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '6.5',
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'PUBLISHER' => undef,
                             'NAME' => 'AddPrinter'
                           },
                           {
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'NAME' => 'AddressBookManager',
                             'PUBLISHER' => undef,
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '2.0.3'
                           },
                           {
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'PUBLISHER' => undef,
                             'NAME' => 'AddressBookSync',
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '2.0.3'
                           },
                           {
                             'PUBLISHER' => '1.4.1, Copyright 2001-2010 The Adium Team',
                             'NAME' => 'Adium',
                             'INSTALLDATE' => '2011-01-11 23:31',
                             'VERSION' => '1.4.1',
                             'COMMENTS' => '[Universal]'
                           },
                           {
                             'VERSION' => '10.1.102.64',
                             'COMMENTS' => '[Universal]',
                             'PUBLISHER' => undef,
                             'NAME' => 'Adobe Flash Player Install Manager',
                             'INSTALLDATE' => '2010-11-11 19:54'
                           },
                           {
                             'PUBLISHER' => 'Adobe® Acrobat® 9.4.2, ©1984-2010 Adobe Systems Incorporated. All rights reserved.',
                             'NAME' => 'Adobe Reader',
                             'INSTALLDATE' => '2010-09-23 13:46',
                             'VERSION' => '9.4.2',
                             'COMMENTS' => '[Intel]'
                           },
                           {
                             'PUBLISHER' => '9.4.2, ©2009-2010 Adobe Systems Incorporated. All rights reserved.',
                             'NAME' => 'Adobe Reader Updater',
                             'INSTALLDATE' => '2011-03-23 12:46',
                             'VERSION' => '9.4.2',
                             'COMMENTS' => '[Universal]'
                           },
                           {
                             'INSTALLDATE' => '2011-03-02 20:58',
                             'PUBLISHER' => 'Adobe Updater 6.2.0.1474, Copyright � 2002-2008 by Adobe Systems Incorporated. All rights reserved.',
                             'NAME' => 'Adobe Updater',
                             'COMMENTS' => '[Intel]',
                             'VERSION' => 'Adobe Updater 6.2.0.1474'
                           },
                           {
                             'VERSION' => '1.5.5',
                             'COMMENTS' => '[Universal]',
                             'NAME' => 'Agent de la borne d’accès AirPort',
                             'PUBLISHER' => '1.5.5 (155.2), Copyright © 2006-2009 Apple Inc. All Rights Reserved.',
                             'INSTALLDATE' => '2011-01-05 17:56'
                           },
                           {
                             'VERSION' => '7.0',
                             'COMMENTS' => '[Intel]',
                             'NAME' => 'Aide-mémoire',
                             'PUBLISHER' => undef,
                             'INSTALLDATE' => '2009-05-19 07:28'
                           },
                           {
                             'INSTALLDATE' => '2010-12-27 14:23',
                             'NAME' => 'Alerts Daemon',
                             'PUBLISHER' => '12.2.8 (101117), © 2007 Microsoft Corporation. All rights reserved.',
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '12.2.8'
                           },
                           {
                             'VERSION' => '5.0.3',
                             'COMMENTS' => '[Intel]',
                             'NAME' => 'Aperçu',
                             'PUBLISHER' => '5.0.1, Copyright 2002-2009 Apple Inc.',
                             'INSTALLDATE' => '2011-01-05 17:56'
                           },
                           {
                             'VERSION' => '1.0',
                             'COMMENTS' => '[Intel]',
                             'NAME' => 'App Store',
                             'PUBLISHER' => undef,
                             'INSTALLDATE' => '2011-02-20 15:34'
                           },
                           {
                             'INSTALLDATE' => '2009-07-21 09:41',
                             'PUBLISHER' => '6.2.1, Copyright © 2000–2009 Apple Inc. All rights reserved.',
                             'NAME' => 'Apple80211Agent',
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '6.2.1'
                           },
                           {
                             'COMMENTS' => '[Intel]',
                             'VERSION' => undef,
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'NAME' => 'AppleFileServer',
                             'PUBLISHER' => undef
                           },
                           {
                             'VERSION' => '2.0.3',
                             'COMMENTS' => '[Intel]',
                             'NAME' => 'AppleGraphicsWarning',
                             'PUBLISHER' => 'Version 2.0.3, Copyright Apple Inc., 2008',
                             'INSTALLDATE' => '2009-05-19 07:27'
                           },
                           {
                             'NAME' => 'AppleMobileDeviceHelper',
                             'PUBLISHER' => undef,
                             'INSTALLDATE' => '2011-03-18 12:21',
                             'VERSION' => '3.1',
                             'COMMENTS' => '[Universal]'
                           },
                           {
                             'VERSION' => '3.1',
                             'COMMENTS' => '[Universal]',
                             'PUBLISHER' => undef,
                             'NAME' => 'AppleMobileSync',
                             'INSTALLDATE' => '2011-03-18 12:21'
                           },
                           {
                             'INSTALLDATE' => '2009-05-19 11:07',
                             'PUBLISHER' => undef,
                             'NAME' => 'AppleScript Runner',
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '1.0.2'
                           },
                           {
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '1.4',
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'NAME' => 'Application Loader',
                             'PUBLISHER' => undef
                           },
                           {
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'NAME' => 'Assistant Boot Camp',
                             'PUBLISHER' => 'Boot Camp Assistant 3.0.1, Copyright © 2009 Apple Inc. All rights reserved',
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '3.0.1'
                           },
                           {
                             'INSTALLDATE' => '2011-01-13 17:28',
                             'PUBLISHER' => '14.0.0 (100825), © 2010 Microsoft Corporation. All rights reserved.',
                             'NAME' => 'Assistant Installation de Microsoft Office',
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '14.0.0'
                           },
                           {
                             'VERSION' => '12.2.8',
                             'COMMENTS' => '[Universal]',
                             'PUBLISHER' => '12.2.8 (101117), © 2007 Microsoft Corporation. All rights reserved.',
                             'NAME' => 'Assistant Installation de Microsoft Office 2008',
                             'INSTALLDATE' => '2010-12-27 14:23'
                           },
                           {
                             'INSTALLDATE' => '2010-07-07 14:24',
                             'PUBLISHER' => undef,
                             'NAME' => 'Assistant de certification',
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '3.0'
                           },
                           {
                             'PUBLISHER' => undef,
                             'NAME' => 'Assistant migration',
                             'INSTALLDATE' => '2009-07-01 09:17',
                             'VERSION' => '3.0',
                             'COMMENTS' => '[Intel]'
                           },
                           {
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '10.6',
                             'INSTALLDATE' => '2009-07-31 09:25',
                             'PUBLISHER' => '10.6',
                             'NAME' => 'Assistant réglages'
                           },
                           {
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '2.3.8',
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'PUBLISHER' => '2.3.8, Copyright (c) 2010 Apple Inc. All rights reserved.',
                             'NAME' => 'Assistant réglages Bluetooth'
                           },
                           {
                             'VERSION' => '1.6',
                             'COMMENTS' => '[Intel]',
                             'PUBLISHER' => '1.6',
                             'NAME' => 'Assistant réglages de réseau',
                             'INSTALLDATE' => '2009-05-19 11:15'
                           },
                           {
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'NAME' => 'AutoImporter',
                             'PUBLISHER' => '6.0, © Copyright 2000-2009 Apple Inc., all rights reserved.',
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '6.0.1'
                           },
                           {
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'PUBLISHER' => '2.1.1, Copyright © 2004-2009 Apple Inc. All rights reserved.',
                             'NAME' => 'Automator',
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '2.1.1'
                           },
                           {
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'NAME' => 'Automator Launcher',
                             'PUBLISHER' => '1.2, Copyright © 2004-2009 Apple Inc. All rights reserved.',
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '1.2'
                           },
                           {
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'PUBLISHER' => '1.1, Copyright © 2006-2009 Apple Inc. All rights reserved.',
                             'NAME' => 'Automator Runner',
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '1.1'
                           },
                           {
                             'INSTALLDATE' => '2008-07-09 00:45',
                             'NAME' => 'À propos d’AHT',
                             'PUBLISHER' => 'Apple Hardware Test Read Me',
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '1.1'
                           },
                           {
                             'PUBLISHER' => '12.2.8 (101117), © 2007 Microsoft Corporation. All rights reserved.',
                             'NAME' => 'Bibliothèque de projets Microsoft',
                             'INSTALLDATE' => '2010-12-27 14:23',
                             'VERSION' => '12.2.8',
                             'COMMENTS' => '[Universal]'
                           },
                           {
                             'VERSION' => '8.1',
                             'COMMENTS' => '[Universal]',
                             'NAME' => 'Bienvenue sur Leopard',
                             'PUBLISHER' => 'Welcome to Leopard',
                             'INSTALLDATE' => '2008-07-23 21:27'
                           },
                           {
                             'VERSION' => '4.7.3',
                             'COMMENTS' => '[Intel]',
                             'NAME' => 'BigTop',
                             'PUBLISHER' => undef,
                             'INSTALLDATE' => '2011-01-05 17:56'
                           },
                           {
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'NAME' => 'Bluetooth Diagnostics Utility',
                             'PUBLISHER' => '2.3.6, Copyright (c) 2010 Apple Inc. All rights reserved.',
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '2.3.6'
                           },
                           {
                             'PUBLISHER' => '2.3.6, Copyright (c) 2010 Apple Inc. All rights reserved.',
                             'NAME' => 'Bluetooth Explorer',
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'VERSION' => '2.3.6',
                             'COMMENTS' => '[Universal]'
                           },
                           {
                             'PUBLISHER' => '2.3.8, Copyright (c) 2010 Apple Inc. All rights reserved.',
                             'NAME' => 'BluetoothAudioAgent',
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'VERSION' => '2.3.8',
                             'COMMENTS' => '[Universal]'
                           },
                           {
                             'PUBLISHER' => '6.0, © Copyright 2004-2009 Apple Inc., all rights reserved.',
                             'NAME' => 'BluetoothCamera',
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'VERSION' => '6.0',
                             'COMMENTS' => '[Universal]'
                           },
                           {
                             'VERSION' => '2.3.8',
                             'COMMENTS' => '[Universal]',
                             'NAME' => 'BluetoothUIServer',
                             'PUBLISHER' => '2.3.8, Copyright (c) 2010 Apple Inc. All rights reserved.',
                             'INSTALLDATE' => '2011-01-05 17:56'
                           },
                           {
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '1.5.6',
                             'INSTALLDATE' => '2006-07-18 08:00',
                             'PUBLISHER' => undef,
                             'NAME' => 'Bonjour Browser'
                           },
                           {
                             'VERSION' => '3.00',
                             'COMMENTS' => '[Intel]',
                             'PUBLISHER' => 'ver3.00, ©2005-2009 Brother Industries, Ltd. All Rights Reserved.',
                             'NAME' => 'Brother Contrôleur d\'état',
                             'INSTALLDATE' => '2009-05-19 03:15'
                           },
                           {
                             'VERSION' => '2.0.2',
                             'COMMENTS' => '[Intel]',
                             'NAME' => 'Brother Scanner',
                             'PUBLISHER' => '2.0.2, Copyright 2009 Brother Industries, LTD.',
                             'INSTALLDATE' => '2009-06-29 02:52'
                           },
                           {
                             'PUBLISHER' => '2.5.4a0, (c) 2004 Python Software Foundation.',
                             'NAME' => 'Build Applet',
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'VERSION' => '2.5.4',
                             'COMMENTS' => undef
                           },
                           {
                             'INSTALLDATE' => '2010-07-07 14:24',
                             'NAME' => 'CCacheServer',
                             'PUBLISHER' => '6.5 Copyright © 2008 Massachusetts Institute of Technology',
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '6.5.10'
                           },
                           {
                             'VERSION' => '4.7.3',
                             'COMMENTS' => '[Intel]',
                             'PUBLISHER' => undef,
                             'NAME' => 'CHUD Remover',
                             'INSTALLDATE' => '2011-01-05 17:56'
                           },
                           {
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '1.7.1',
                             'INSTALLDATE' => '2009-06-15 08:18',
                             'PUBLISHER' => 'CIJAutoSetupTool.app version 1.7.0, Copyright CANON INC. 2007-2008 All Rights Reserved.',
                             'NAME' => 'CIJAutoSetupTool'
                           },
                           {
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '1.0.0',
                             'INSTALLDATE' => '2009-06-15 08:19',
                             'PUBLISHER' => 'CIJScannerRegister version 1.0.0, Copyright CANON INC. 2009 All Rights Reserved.',
                             'NAME' => 'CIJScannerRegister'
                           },
                           {
                             'VERSION' => '4.7.3',
                             'COMMENTS' => '[Intel]',
                             'NAME' => 'CPUPalette',
                             'PUBLISHER' => undef,
                             'INSTALLDATE' => '2011-01-05 17:56'
                           },
                           {
                             'VERSION' => '4.5.3',
                             'COMMENTS' => '[Intel]',
                             'NAME' => 'Calculette',
                             'PUBLISHER' => undef,
                             'INSTALLDATE' => '2010-07-07 14:24'
                           },
                           {
                             'VERSION' => '7.17.10',
                             'COMMENTS' => '[Intel]',
                             'PUBLISHER' => 'Canon IJ Printer Utility version 7.17.10, Copyright CANON INC. 2001-2009 All Rights Reserved.',
                             'NAME' => 'Canon IJ Printer Utility',
                             'INSTALLDATE' => '2009-06-15 09:22'
                           },
                           {
                             'NAME' => 'Canon IJScanner1',
                             'PUBLISHER' => '1.0.0, Copyright CANON INC. 2009 All Rights Reserved',
                             'INSTALLDATE' => '2009-06-15 08:19',
                             'VERSION' => '1.0.0',
                             'COMMENTS' => '[Intel]'
                           },
                           {
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '1.0.0',
                             'INSTALLDATE' => '2009-06-15 08:18',
                             'PUBLISHER' => '1.0.0, Copyright CANON INC. 2009 All Rights Reserved',
                             'NAME' => 'Canon IJScanner2'
                           },
                           {
                             'INSTALLDATE' => '2009-05-19 04:12',
                             'PUBLISHER' => undef,
                             'NAME' => 'Capture',
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '1.5'
                           },
                           {
                             'PUBLISHER' => undef,
                             'NAME' => 'Carnet d’adresses',
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'VERSION' => '5.0.3',
                             'COMMENTS' => '[Intel]'
                           },
                           {
                             'VERSION' => '14.0.2',
                             'COMMENTS' => '[Intel]',
                             'NAME' => 'Centre de téléchargement Microsoft',
                             'PUBLISHER' => '14.0.2 (101115), © 2010 Microsoft Corporation. All rights reserved.',
                             'INSTALLDATE' => '2011-01-13 17:38'
                           },
                           {
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '1.0.4',
                             'INSTALLDATE' => '2009-07-02 09:49',
                             'NAME' => 'CharacterPalette',
                             'PUBLISHER' => undef
                           },
                           {
                             'INSTALLDATE' => '2009-05-19 08:09',
                             'PUBLISHER' => '2.4.2, Copyright 2003-2009 Apple Inc.',
                             'NAME' => 'Chess',
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '2.4.2'
                           },
                           {
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'PUBLISHER' => undef,
                             'NAME' => 'ChineseHandwriting',
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '1.0.1'
                           },
                           {
                             'INSTALLDATE' => '2009-05-19 04:18',
                             'PUBLISHER' => 'Chinese Text Converter 1.1',
                             'NAME' => 'ChineseTextConverterService',
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '1.2'
                           },
                           {
                             'NAME' => 'Cisco AnyConnect VPN Client',
                             'PUBLISHER' => undef,
                             'INSTALLDATE' => '2010-02-15 16:08',
                             'VERSION' => '1.0',
                             'COMMENTS' => '[Intel]'
                           },
                           {
                             'VERSION' => '8.0',
                             'COMMENTS' => '[Universal]',
                             'NAME' => 'Cisco Network Assistant',
                             'PUBLISHER' => 'InstallAnywhere 8.0, Copyright © 2006 Macrovision Corporation.',
                             'INSTALLDATE' => '2011-03-13 00:14'
                           },
                           {
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '1.3',
                             'INSTALLDATE' => '2009-07-02 15:19',
                             'NAME' => 'Clipboard Viewer',
                             'PUBLISHER' => undef
                           },
                           {
                             'VERSION' => '0.66',
                             'COMMENTS' => '[Universal]',
                             'NAME' => 'CocoaPacketAnalyzer',
                             'PUBLISHER' => undef,
                             'INSTALLDATE' => '2009-11-20 15:22'
                           },
                           {
                             'VERSION' => '3.7.2',
                             'COMMENTS' => '[Intel]',
                             'NAME' => 'Colorimètre numérique',
                             'PUBLISHER' => '3.7.2, Copyright 2001-2008 Apple Inc. All Rights Reserved.',
                             'INSTALLDATE' => '2009-05-28 07:06'
                           },
                           {
                             'NAME' => 'CompactPhotosmart',
                             'PUBLISHER' => 'HP Compact Photosmart Driver 3.0, Copyright (c) 1994-2009 Hewlett-Packard Development Company, L.P.',
                             'INSTALLDATE' => '2009-06-16 13:50',
                             'VERSION' => '3.0',
                             'COMMENTS' => '[Intel]'
                           },
                           {
                             'PUBLISHER' => undef,
                             'NAME' => 'Configuration actions de dossier',
                             'INSTALLDATE' => '2009-05-19 11:07',
                             'VERSION' => '1.1.4',
                             'COMMENTS' => '[Intel]'
                           },
                           {
                             'NAME' => 'Configuration audio et MIDI',
                             'PUBLISHER' => '3.0.3, Copyright 2002-2010 Apple, Inc.',
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'VERSION' => '3.0.3',
                             'COMMENTS' => '[Intel]'
                           },
                           {
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '2.1.0',
                             'INSTALLDATE' => '2011-01-13 17:28',
                             'NAME' => 'Connexion Bureau à Distance',
                             'PUBLISHER' => '2.1.0 (100825), © 2010 Microsoft Corporation. All rights reserved.'
                           },
                           {
                             'INSTALLDATE' => '2009-04-07 02:42',
                             'PUBLISHER' => undef,
                             'NAME' => 'Console',
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '10.6.3'
                           },
                           {
                             'INSTALLDATE' => '2010-08-26 20:09',
                             'PUBLISHER' => undef,
                             'NAME' => 'Core Image Fun House',
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '2.1.43'
                           },
                           {
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'PUBLISHER' => 'Copyright © 2009 Apple Inc.',
                             'NAME' => 'CoreLocationAgent',
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '12.1'
                           },
                           {
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'NAME' => 'CoreServicesUIAgent',
                             'PUBLISHER' => 'Copyright © 2009 Apple Inc.',
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '41.5'
                           },
                           {
                             'VERSION' => '10.6.3',
                             'COMMENTS' => '[Universal]',
                             'NAME' => 'CrashReporterPrefs',
                             'PUBLISHER' => undef,
                             'INSTALLDATE' => '2011-01-05 17:56'
                           },
                           {
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '6.0',
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'PUBLISHER' => '6.0, © Copyright 2003-2009 Apple  Inc., all rights reserved.',
                             'NAME' => 'Création de page Web'
                           },
                           {
                             'PUBLISHER' => '1.7, Copyright 2006-2008 Apple Inc.',
                             'NAME' => 'Dashboard',
                             'INSTALLDATE' => '2011-02-20 15:34',
                             'VERSION' => '1.7',
                             'COMMENTS' => '[Universal]'
                           },
                           {
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '3.0.2',
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'PUBLISHER' => undef,
                             'NAME' => 'Dashcode'
                           },
                           {
                             'VERSION' => '1.0.4',
                             'COMMENTS' => '[Intel]',
                             'NAME' => 'Database Events',
                             'PUBLISHER' => undef,
                             'INSTALLDATE' => '2009-05-19 11:07'
                           },
                           {
                             'VERSION' => '3.0',
                             'COMMENTS' => '[Intel]',
                             'NAME' => 'Deskjet',
                             'PUBLISHER' => 'HP Deskjet Driver 3.0, Copyright (c) 1994-2009 Hewlett-Packard Development Company, L.P.',
                             'INSTALLDATE' => '2009-06-18 13:21'
                           },
                           {
                             'VERSION' => '1.1.3',
                             'COMMENTS' => '[Universal]',
                             'NAME' => 'Diagnostic réseau',
                             'PUBLISHER' => undef,
                             'INSTALLDATE' => '2010-07-07 14:24'
                           },
                           {
                             'PUBLISHER' => undef,
                             'NAME' => 'Dictionnaire',
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'VERSION' => '2.1.3',
                             'COMMENTS' => '[Intel]'
                           },
                           {
                             'NAME' => 'DiskImageMounter',
                             'PUBLISHER' => undef,
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'VERSION' => '10.6.5',
                             'COMMENTS' => '[Intel]'
                           },
                           {
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '287',
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'PUBLISHER' => undef,
                             'NAME' => 'DiskImages UI Agent'
                           },
                           {
                             'NAME' => 'DivX Community',
                             'PUBLISHER' => undef,
                             'INSTALLDATE' => '2009-11-17 00:47',
                             'VERSION' => '1.1.0',
                             'COMMENTS' => '[PowerPC]'
                           },
                           {
                             'NAME' => 'DivX Converter',
                             'PUBLISHER' => undef,
                             'INSTALLDATE' => '2009-12-28 21:33',
                             'VERSION' => '1.3',
                             'COMMENTS' => '[Universal]'
                           },
                           {
                             'VERSION' => '7.2 (build 10_0_0_183)',
                             'COMMENTS' => '[Intel]',
                             'NAME' => 'DivX Player',
                             'PUBLISHER' => undef,
                             'INSTALLDATE' => '2009-12-28 21:33'
                           },
                           {
                             'PUBLISHER' => undef,
                             'NAME' => 'DivX Products',
                             'INSTALLDATE' => '2009-11-17 00:47',
                             'VERSION' => '1.1.0',
                             'COMMENTS' => '[PowerPC]'
                           },
                           {
                             'INSTALLDATE' => '2009-11-17 00:47',
                             'NAME' => 'DivX Support',
                             'PUBLISHER' => undef,
                             'COMMENTS' => '[PowerPC]',
                             'VERSION' => '1.1.0'
                           },
                           {
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '1.1',
                             'INSTALLDATE' => '2009-11-17 00:47',
                             'NAME' => 'DivXUpdater',
                             'PUBLISHER' => undef
                           },
                           {
                             'NAME' => 'Dock',
                             'PUBLISHER' => 'Dock 1.7',
                             'INSTALLDATE' => '2011-02-20 15:34',
                             'VERSION' => '1.7',
                             'COMMENTS' => '[Intel]'
                           },
                           {
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '6.0',
                             'INSTALLDATE' => '2011-03-08 12:21',
                             'NAME' => 'DockPlistEdit',
                             'PUBLISHER' => undef
                           },
                           {
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'PUBLISHER' => undef,
                             'NAME' => 'EM64T Help',
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '4.7.3'
                           },
                           {
                             'NAME' => 'EPIJAutoSetupTool2',
                             'PUBLISHER' => 'EPIJAutoSetupTool2 Copyright (C) SEIKO EPSON CORPORATION 2001-2009. All rights reserved.',
                             'INSTALLDATE' => '2009-07-09 06:55',
                             'VERSION' => '8.02',
                             'COMMENTS' => '[Intel]'
                           },
                           {
                             'VERSION' => '5.0',
                             'COMMENTS' => '[Intel]',
                             'NAME' => 'EPSON Scanner',
                             'PUBLISHER' => '5.0, Copyright 2003 EPSON',
                             'INSTALLDATE' => '2009-07-09 06:57'
                           },
                           {
                             'VERSION' => undef,
                             'COMMENTS' => '[Universal]',
                             'NAME' => 'Embed',
                             'PUBLISHER' => undef,
                             'INSTALLDATE' => '2009-04-25 04:11'
                           },
                           {
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '8.02',
                             'INSTALLDATE' => '2009-07-09 06:55',
                             'NAME' => 'Epson Printer Utility Lite',
                             'PUBLISHER' => 'Epson Printer Utility Lite version 8.02'
                           },
                           {
                             'VERSION' => '12.1.0',
                             'COMMENTS' => '[Universal]',
                             'NAME' => 'Equation Editor',
                             'PUBLISHER' => '12.1.0 (080205), © 2007 Microsoft Corporation.  All rights reserved.',
                             'INSTALLDATE' => '2009-07-02 11:50'
                           },
                           {
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '1.1',
                             'INSTALLDATE' => '2011-02-20 15:34',
                             'NAME' => 'Exposé',
                             'PUBLISHER' => '1.1, Copyright 2007-2008 Apple Inc.'
                           },
                           {
                             'NAME' => 'Extract',
                             'PUBLISHER' => undef,
                             'INSTALLDATE' => '2009-04-25 04:11',
                             'VERSION' => undef,
                             'COMMENTS' => '[Universal]'
                           },
                           {
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '2.3.8',
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'PUBLISHER' => '2.3.8, Copyright (c) 2010 Apple Inc. All rights reserved.',
                             'NAME' => 'Échange de fichiers Bluetooth'
                           },
                           {
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '2.3',
                             'INSTALLDATE' => '2009-04-24 15:41',
                             'NAME' => 'Éditeur AppleScript',
                             'PUBLISHER' => undef
                           },
                           {
                             'VERSION' => '14.0.0',
                             'COMMENTS' => '[Intel]',
                             'NAME' => 'Éditeur d\'équations Microsoft',
                             'PUBLISHER' => undef,
                             'INSTALLDATE' => '2011-01-13 17:28'
                           },
                           {
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'NAME' => 'File Sync',
                             'PUBLISHER' => '© Copyright 2009 Apple Inc., all rights reserved.',
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '5.0.3'
                           },
                           {
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'PUBLISHER' => undef,
                             'NAME' => 'FileMerge',
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '2.5'
                           },
                           {
                             'NAME' => 'FileSyncAgent',
                             'PUBLISHER' => '© Copyright 2009 Apple Inc., all rights reserved.',
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'VERSION' => '5.0.3',
                             'COMMENTS' => '[Intel]'
                           },
                           {
                             'VERSION' => '10.6.7',
                             'COMMENTS' => '[Intel]',
                             'NAME' => 'Finder',
                             'PUBLISHER' => 'Mac OS X Finder 10.6.7',
                             'INSTALLDATE' => '2011-02-20 15:34'
                           },
                           {
                             'VERSION' => '1.0.2',
                             'COMMENTS' => '[Intel]',
                             'NAME' => 'Folder Actions Dispatcher',
                             'PUBLISHER' => undef,
                             'INSTALLDATE' => '2009-05-19 11:07'
                           },
                           {
                             'VERSION' => '1.1',
                             'COMMENTS' => '[Intel]',
                             'NAME' => 'FontRegistryUIAgent',
                             'PUBLISHER' => 'Copyright © 2008 Apple Inc.',
                             'INSTALLDATE' => '2010-07-07 14:24'
                           },
                           {
                             'INSTALLDATE' => '2009-05-19 04:17',
                             'NAME' => 'FontSyncScripting',
                             'PUBLISHER' => 'FontSync Scripting 2.0. Copyright © 2000-2008 Apple Inc.',
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '2.0.6'
                           },
                           {
                             'INSTALLDATE' => '2009-12-30 12:35',
                             'NAME' => 'Free42-Binary',
                             'PUBLISHER' => undef,
                             'COMMENTS' => undef,
                             'VERSION' => undef
                           },
                           {
                             'COMMENTS' => undef,
                             'VERSION' => undef,
                             'INSTALLDATE' => '2009-12-30 12:35',
                             'NAME' => 'Free42-Decimal',
                             'PUBLISHER' => undef
                           },
                           {
                             'VERSION' => '2.2.1',
                             'COMMENTS' => '[Universal]',
                             'NAME' => 'Front Row',
                             'PUBLISHER' => undef,
                             'INSTALLDATE' => '2009-07-22 10:50'
                           },
                           {
                             'PUBLISHER' => 'GarageBand 4.1.2 (248.7), Copyright © 2007 by Apple Inc.',
                             'NAME' => 'GarageBand',
                             'INSTALLDATE' => '2009-07-01 15:59',
                             'VERSION' => '4.1.2',
                             'COMMENTS' => '[Universal]'
                           },
                           {
                             'PUBLISHER' => 'v1.9.2.1599. Copyright 2007-2009 Google Inc. All rights reserved.',
                             'NAME' => 'GoogleTalkPlugin',
                             'INSTALLDATE' => '2011-02-24 13:10',
                             'VERSION' => '1.9.2.1599',
                             'COMMENTS' => '[Intel]'
                           },
                           {
                             'INSTALLDATE' => '2011-02-24 13:10',
                             'PUBLISHER' => 'v1.9.2.1599. Copyright 2007-2009 Google Inc. All rights reserved.',
                             'NAME' => 'GoogleVoiceAndVideoUninstaller',
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '1.9.2.1599'
                           },
                           {
                             'PUBLISHER' => undef,
                             'NAME' => 'Grapher',
                             'INSTALLDATE' => '2009-04-07 02:42',
                             'VERSION' => '2.1',
                             'COMMENTS' => '[Intel]'
                           },
                           {
                             'VERSION' => '1.6',
                             'COMMENTS' => '[Intel]',
                             'NAME' => 'HALLab',
                             'PUBLISHER' => undef,
                             'INSTALLDATE' => '2011-01-05 17:56'
                           },
                           {
                             'PUBLISHER' => 'HP Printer Utility version 8.1.0, Copyright (c) 2005-2010 Hewlett-Packard Development Company, L.P.',
                             'NAME' => 'HP Printer Utility',
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'VERSION' => '8.1.0',
                             'COMMENTS' => '[Intel]'
                           },
                           {
                             'PUBLISHER' => 'Copyright 2010 Hewlett-Packard Company',
                             'NAME' => 'HP Scanner 3',
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'VERSION' => '3.2.9',
                             'COMMENTS' => '[Universal]'
                           },
                           {
                             'VERSION' => '4.8.5',
                             'COMMENTS' => '[Intel]',
                             'PUBLISHER' => 'HP Utility version 4.8.5, Copyright (c) 2005-2010 Hewlett-Packard Development Company, L.P.',
                             'NAME' => 'HP Utility',
                             'INSTALLDATE' => '2011-01-05 17:56'
                           },
                           {
                             'PUBLISHER' => '1.0, Copyright © 2009 Hewlett-Packard Development Company, L.P.',
                             'NAME' => 'HPFaxBackend',
                             'INSTALLDATE' => '2009-07-25 08:52',
                             'VERSION' => '3.1.0',
                             'COMMENTS' => '[Universal]'
                           },
                           {
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '1.1.52',
                             'INSTALLDATE' => '2009-07-24 10:03',
                             'PUBLISHER' => '1.1.52, Copyright 2009 Hewlett-Packard Company',
                             'NAME' => 'HPScanner'
                           },
                           {
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '4.0',
                             'INSTALLDATE' => '2010-08-26 20:09',
                             'NAME' => 'Help Indexer',
                             'PUBLISHER' => undef
                           },
                           {
                             'NAME' => 'HelpViewer',
                             'PUBLISHER' => undef,
                             'INSTALLDATE' => '2010-07-07 14:24',
                             'VERSION' => '5.0.3',
                             'COMMENTS' => '[Intel]'
                           },
                           {
                             'PUBLISHER' => undef,
                             'NAME' => 'IA32 Help',
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'VERSION' => '4.7.3',
                             'COMMENTS' => '[Intel]'
                           },
                           {
                             'VERSION' => '2.1',
                             'COMMENTS' => '[Intel]',
                             'PUBLISHER' => undef,
                             'NAME' => 'IORegistryExplorer',
                             'INSTALLDATE' => '2010-08-26 20:09'
                           },
                           {
                             'NAME' => 'Icon Composer',
                             'PUBLISHER' => undef,
                             'INSTALLDATE' => '2010-08-26 20:09',
                             'VERSION' => '2.1',
                             'COMMENTS' => '[Intel]'
                           },
                           {
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '6.0.2',
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'PUBLISHER' => '6.0.2, © Copyright 2000-2010 Apple Inc. All rights reserved.',
                             'NAME' => 'Image Capture Extension'
                           },
                           {
                             'VERSION' => '6.0',
                             'COMMENTS' => '[Universal]',
                             'NAME' => 'Image Capture Web Server',
                             'PUBLISHER' => '6.0, © Copyright 2003-2009 Apple Inc., all rights reserved.',
                             'INSTALLDATE' => '2011-01-05 17:56'
                           },
                           {
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '1.1.4',
                             'INSTALLDATE' => '2009-05-19 11:07',
                             'PUBLISHER' => undef,
                             'NAME' => 'Image Events'
                           },
                           {
                             'VERSION' => '6.0.1',
                             'COMMENTS' => '[Intel]',
                             'PUBLISHER' => '6.0, © Copyright 2003-2009 Apple Inc., all rights reserved.',
                             'NAME' => 'ImageCaptureService',
                             'INSTALLDATE' => '2011-01-05 17:56'
                           },
                           {
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'PUBLISHER' => undef,
                             'NAME' => 'IncompatibleAppDisplay',
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '300.4'
                           },
                           {
                             'PUBLISHER' => '10.6.0, Copyright 1997-2009 Apple, Inc.',
                             'NAME' => 'Informations Système',
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'VERSION' => '10.6.0',
                             'COMMENTS' => '[Universal]'
                           },
                           {
                             'VERSION' => '1.0',
                             'COMMENTS' => '[Intel]',
                             'NAME' => 'InkServer',
                             'PUBLISHER' => '1.0, Copyright 2008 Apple Inc.',
                             'INSTALLDATE' => '2009-05-19 04:18'
                           },
                           {
                             'VERSION' => '3.0',
                             'COMMENTS' => '[Intel]',
                             'NAME' => 'Inkjet',
                             'PUBLISHER' => 'HP Inkjet Driver 3.0, Copyright (c) 1994-2009 Hewlett-Packard Development Company, L.P.',
                             'INSTALLDATE' => '2009-06-16 12:48'
                           },
                           {
                             'NAME' => 'Inkjet1',
                             'PUBLISHER' => 'HP Inkjet 1 Driver 2.1.2, Copyright (c) 1994-2009 Hewlett-Packard Development Company, L.P.',
                             'INSTALLDATE' => '2009-06-16 15:54',
                             'VERSION' => '2.1.2',
                             'COMMENTS' => '[Intel]'
                           },
                           {
                             'INSTALLDATE' => '2009-06-16 15:21',
                             'NAME' => 'Inkjet3',
                             'PUBLISHER' => 'HP Inkjet 3 Driver 2.0, Copyright (c) 1994-2009 Hewlett-Packard Development Company, L.P.',
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '2.0'
                           },
                           {
                             'PUBLISHER' => 'HP Inkjet 4 Driver 2.2, Copyright (c) 1994-2009 Hewlett-Packard Development Company, L.P.',
                             'NAME' => 'Inkjet4',
                             'INSTALLDATE' => '2009-06-16 15:17',
                             'VERSION' => '2.2',
                             'COMMENTS' => '[Intel]'
                           },
                           {
                             'INSTALLDATE' => '2009-06-16 14:00',
                             'NAME' => 'Inkjet5',
                             'PUBLISHER' => 'HP Inkjet 5 Driver 2.1, Copyright (c) 1994-2009 Hewlett-Packard Development Company, L.P.',
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '2.1'
                           },
                           {
                             'INSTALLDATE' => '2009-06-16 10:36',
                             'PUBLISHER' => 'HP Inkjet 6 Driver 1.0, Copyright (c) 1994-2009 Hewlett-Packard Development Company, L.P.',
                             'NAME' => 'Inkjet6',
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '1.0'
                           },
                           {
                             'NAME' => 'Inkjet8',
                             'PUBLISHER' => 'HP Inkjet 8 Driver 2.1, Copyright (c) 1994-2009 Hewlett-Packard Development Company, L.P.',
                             'INSTALLDATE' => '2009-06-16 11:59',
                             'VERSION' => '2.1',
                             'COMMENTS' => '[Intel]'
                           },
                           {
                             'INSTALLDATE' => '2010-02-19 00:40',
                             'PUBLISHER' => undef,
                             'NAME' => 'Install Helper',
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '1.0'
                           },
                           {
                             'PUBLISHER' => 'Remote Install Mac OS X 1.1.1, Copyright © 2007-2009 Apple Inc. All rights reserved',
                             'NAME' => 'Installation à distance de Mac OS X',
                             'INSTALLDATE' => '2009-05-19 04:13',
                             'VERSION' => '1.1.1',
                             'COMMENTS' => '[Intel]'
                           },
                           {
                             'NAME' => 'Instruments',
                             'PUBLISHER' => undef,
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'VERSION' => '2.7',
                             'COMMENTS' => '[Intel]'
                           },
                           {
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'NAME' => 'Interface Builder',
                             'PUBLISHER' => undef,
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '3.2.5'
                           },
                           {
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '13.4.0',
                             'INSTALLDATE' => '2011-03-18 12:21',
                             'PUBLISHER' => undef,
                             'NAME' => 'Jar Bundler'
                           },
                           {
                             'INSTALLDATE' => '2011-03-18 12:21',
                             'NAME' => 'Jar Launcher',
                             'PUBLISHER' => undef,
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '13.4.0'
                           },
                           {
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '13.4.0',
                             'INSTALLDATE' => '2011-03-18 12:21',
                             'PUBLISHER' => undef,
                             'NAME' => 'Java VisualVM'
                           },
                           {
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '13.4.0',
                             'INSTALLDATE' => '2011-03-18 12:21',
                             'NAME' => 'Java Web Start',
                             'PUBLISHER' => undef
                           },
                           {
                             'VERSION' => '6.5.10',
                             'COMMENTS' => '[Universal]',
                             'NAME' => 'KerberosAgent',
                             'PUBLISHER' => undef,
                             'INSTALLDATE' => '2010-07-07 14:24'
                           },
                           {
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '10.5.0',
                             'INSTALLDATE' => '2009-05-19 07:45',
                             'PUBLISHER' => undef,
                             'NAME' => 'KeyboardSetupAssistant'
                           },
                           {
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '2.0',
                             'INSTALLDATE' => '2009-06-11 08:11',
                             'NAME' => 'KeyboardViewer',
                             'PUBLISHER' => '2.0, Copyright © 2004-2009 Apple Inc., All Rights Reserved'
                           },
                           {
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '4.0.2',
                             'INSTALLDATE' => '2010-07-07 14:24',
                             'PUBLISHER' => undef,
                             'NAME' => 'Keychain Scripting'
                           },
                           {
                             'INSTALLDATE' => '2009-05-05 18:41',
                             'PUBLISHER' => '6.0, Copyright © 1997-2006 Apple Computer Inc., All Rights Reserved',
                             'NAME' => 'KoreanIM',
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '6.1'
                           },
                           {
                             'VERSION' => '4.2.0',
                             'COMMENTS' => '[Universal]',
                             'PUBLISHER' => undef,
                             'NAME' => 'Kotoeri',
                             'INSTALLDATE' => '2009-06-11 04:33'
                           },
                           {
                             'INSTALLDATE' => '2011-03-18 12:21',
                             'PUBLISHER' => undef,
                             'NAME' => 'Lanceur d’applets',
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '13.4.0'
                           },
                           {
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'NAME' => 'Language Chooser',
                             'PUBLISHER' => 'System Language Initializer',
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '20'
                           },
                           {
                             'PUBLISHER' => 'HP Laserjet Driver 1.0, Copyright (c) 1994-2009 Hewlett-Packard Development Company, L.P.',
                             'NAME' => 'Laserjet',
                             'INSTALLDATE' => '2009-06-22 14:27',
                             'VERSION' => '1.0',
                             'COMMENTS' => '[Intel]'
                           },
                           {
                             'VERSION' => '5.4',
                             'COMMENTS' => '[Intel]',
                             'NAME' => 'Lecteur DVD',
                             'PUBLISHER' => '5.4, Copyright © 2001-2010 by Apple Inc.  All Rights Reserved.',
                             'INSTALLDATE' => '2011-01-05 17:56'
                           },
                           {
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '3.2.45',
                             'INSTALLDATE' => '2009-07-01 07:26',
                             'PUBLISHER' => undef,
                             'NAME' => 'Lexmark Scanner'
                           },
                           {
                             'VERSION' => '1.1.26',
                             'COMMENTS' => '[Intel]',
                             'PUBLISHER' => '0.0.0 (v27), Copyright 2008 Lexmark International, Inc. All rights reserved.',
                             'NAME' => 'LexmarkCUPSDriver',
                             'INSTALLDATE' => '2009-07-01 07:26'
                           },
                           {
                             'INSTALLDATE' => '2009-07-25 07:43',
                             'PUBLISHER' => 'License',
                             'NAME' => 'License',
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '11'
                           },
                           {
                             'VERSION' => '2.2.2',
                             'COMMENTS' => '[Intel]',
                             'PUBLISHER' => '2.2.2, Copyright © 2003-2010 Apple Inc.',
                             'NAME' => 'Livre des polices',
                             'INSTALLDATE' => '2011-01-05 17:56'
                           },
                           {
                             'PUBLISHER' => undef,
                             'NAME' => 'Log Viewer',
                             'INSTALLDATE' => '2011-03-09 10:12',
                             'VERSION' => '17289',
                             'COMMENTS' => '[Intel]'
                           },
                           {
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '2.0.1',
                             'INSTALLDATE' => '2009-08-01 01:21',
                             'NAME' => 'MÀJ du programme interne Bluetooth',
                             'PUBLISHER' => undef
                           },
                           {
                             'VERSION' => '4.4',
                             'COMMENTS' => '[Intel]',
                             'PUBLISHER' => undef,
                             'NAME' => 'Mail',
                             'INSTALLDATE' => '2011-01-05 17:56'
                           },
                           {
                             'PUBLISHER' => '6.0, © Copyright 2003-2009 Apple Inc., all rights reserved.',
                             'NAME' => 'MakePDF',
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'VERSION' => '6.0',
                             'COMMENTS' => '[Universal]'
                           },
                           {
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'NAME' => 'MallocDebug',
                             'PUBLISHER' => undef,
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '1.7.1'
                           },
                           {
                             'NAME' => 'ManagedClient',
                             'PUBLISHER' => undef,
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'VERSION' => '2.3',
                             'COMMENTS' => '[Universal]'
                           },
                           {
                             'VERSION' => '6.0.3',
                             'COMMENTS' => '[Universal]',
                             'PUBLISHER' => '6.0.3, © Copyright 2000-2010 Apple Inc. All rights reserved.',
                             'NAME' => 'MassStorageCamera',
                             'INSTALLDATE' => '2011-01-05 17:56'
                           },
                           {
                             'INSTALLDATE' => '2009-04-25 04:11',
                             'NAME' => 'Match',
                             'PUBLISHER' => undef,
                             'COMMENTS' => '[Universal]',
                             'VERSION' => undef
                           },
                           {
                             'VERSION' => '3.9.14.0',
                             'COMMENTS' => '[Intel]',
                             'NAME' => 'Meeting Center',
                             'PUBLISHER' => undef,
                             'INSTALLDATE' => '2011-02-22 09:28'
                           },
                           {
                             'PUBLISHER' => undef,
                             'NAME' => 'MemoryCard Ejector',
                             'INSTALLDATE' => '2010-01-13 18:16',
                             'VERSION' => '1.1',
                             'COMMENTS' => '[PowerPC]'
                           },
                           {
                             'INSTALLDATE' => '2011-01-13 17:38',
                             'PUBLISHER' => '2.3.1 (101115), © 2010 Microsoft Corporation. All rights reserved.',
                             'NAME' => 'Microsoft AutoUpdate',
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '2.3.1'
                           },
                           {
                             'VERSION' => '12.2.8',
                             'COMMENTS' => '[Universal]',
                             'NAME' => 'Microsoft Cert Manager',
                             'PUBLISHER' => '12.2.8 (101117), © 2007 Microsoft Corporation. All rights reserved.',
                             'INSTALLDATE' => '2010-12-27 14:23'
                           },
                           {
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '12.2.8',
                             'INSTALLDATE' => '2010-12-27 14:23',
                             'NAME' => 'Microsoft Chart Converter',
                             'PUBLISHER' => '12.2.8 (101117), © 2007 Microsoft Corporation. All rights reserved.'
                           },
                           {
                             'INSTALLDATE' => '2011-01-13 17:38',
                             'NAME' => 'Microsoft Clip Gallery',
                             'PUBLISHER' => '14.0.2 (101115), © 2010 Microsoft Corporation. All rights reserved.',
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '14.0.2'
                           },
                           {
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '13.0.0',
                             'INSTALLDATE' => '2011-01-13 17:28',
                             'NAME' => 'Microsoft Communicator',
                             'PUBLISHER' => '13.0.0 (100825), © 2010 Microsoft Corporation. All rights reserved.'
                           },
                           {
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '12.2.8',
                             'INSTALLDATE' => '2010-12-27 14:23',
                             'NAME' => 'Microsoft Database Daemon',
                             'PUBLISHER' => '12.2.8 (101117), © 2007 Microsoft Corporation. All rights reserved.'
                           },
                           {
                             'PUBLISHER' => '12.2.8 (101117), © 2007 Microsoft Corporation. All rights reserved.',
                             'NAME' => 'Microsoft Database Utility',
                             'INSTALLDATE' => '2010-12-27 14:23',
                             'VERSION' => '12.2.8',
                             'COMMENTS' => '[Universal]'
                           },
                           {
                             'INSTALLDATE' => '2010-12-27 14:23',
                             'PUBLISHER' => '12.2.8 (101117), © 2009 Microsoft Corporation. All rights reserved.',
                             'NAME' => 'Microsoft Document Connection',
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '12.2.8'
                           },
                           {
                             'VERSION' => '12.2.8',
                             'COMMENTS' => '[Universal]',
                             'NAME' => 'Microsoft Entourage',
                             'PUBLISHER' => '12.2.8 (101117), © 2007 Microsoft Corporation. All rights reserved.',
                             'INSTALLDATE' => '2010-12-27 14:23'
                           },
                           {
                             'VERSION' => '12.2.8',
                             'COMMENTS' => '[Universal]',
                             'PUBLISHER' => '12.2.8 (101117), © 2007 Microsoft Corporation. All rights reserved.',
                             'NAME' => 'Microsoft Excel',
                             'INSTALLDATE' => '2010-12-27 14:23'
                           },
                           {
                             'VERSION' => '12.2.8',
                             'COMMENTS' => '[Universal]',
                             'NAME' => 'Microsoft Graph',
                             'PUBLISHER' => '12.2.8 (101117), © 2007 Microsoft Corporation. All rights reserved.',
                             'INSTALLDATE' => '2010-12-27 14:23'
                           },
                           {
                             'VERSION' => '1.1.1',
                             'COMMENTS' => '[Universal]',
                             'NAME' => 'Microsoft Help Viewer',
                             'PUBLISHER' => '1.1.1 (100910), © 2007 Microsoft Corporation. All rights reserved.',
                             'INSTALLDATE' => '2010-11-11 14:54'
                           },
                           {
                             'PUBLISHER' => '6.0.3 (070803), © 2006 Microsoft Corporation. All rights reserved.',
                             'NAME' => 'Microsoft Messenger',
                             'INSTALLDATE' => '2009-07-02 11:49',
                             'VERSION' => '6.0.3',
                             'COMMENTS' => '[Universal]'
                           },
                           {
                             'NAME' => 'Microsoft Outlook',
                             'PUBLISHER' => '14.0.2 (101115), © 2010 Microsoft Corporation. All rights reserved.',
                             'INSTALLDATE' => '2011-01-13 17:38',
                             'VERSION' => '14.0.2',
                             'COMMENTS' => '[Intel]'
                           },
                           {
                             'INSTALLDATE' => '2010-12-27 14:23',
                             'NAME' => 'Microsoft PowerPoint',
                             'PUBLISHER' => '12.2.8 (101117), © 2007 Microsoft Corporation. All rights reserved.',
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '12.2.8'
                           },
                           {
                             'INSTALLDATE' => '2007-12-06 01:00',
                             'NAME' => 'Microsoft Query',
                             'PUBLISHER' => '10.0.0 (1204)  Copyright 1995-2002 Microsoft Corporation.  All rights reserved.',
                             'COMMENTS' => '[PowerPC]',
                             'VERSION' => '10.0.0'
                           },
                           {
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '1.1.0',
                             'INSTALLDATE' => '2011-01-13 17:38',
                             'PUBLISHER' => '1.1.0 (101115), © 2010 Microsoft Corporation. All rights reserved.',
                             'NAME' => 'Microsoft Ship Asserts'
                           },
                           {
                             'INSTALLDATE' => '2010-12-27 14:23',
                             'NAME' => 'Microsoft Sync Services',
                             'PUBLISHER' => '12.2.8 (101117), © 2007 Microsoft Corporation. All rights reserved.',
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '12.2.8'
                           },
                           {
                             'VERSION' => '12.2.8',
                             'COMMENTS' => '[Universal]',
                             'PUBLISHER' => '12.2.8 (101117), © 2007 Microsoft Corporation. All rights reserved.',
                             'NAME' => 'Microsoft Word',
                             'INSTALLDATE' => '2010-12-27 14:23'
                           },
                           {
                             'INSTALLDATE' => '2010-07-07 14:24',
                             'NAME' => 'MiniTerm',
                             'PUBLISHER' => 'Terminal window application for PPP',
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '1.5'
                           },
                           {
                             'VERSION' => '4.0.6',
                             'COMMENTS' => '[Universal]',
                             'NAME' => 'Mise à jour de logiciels',
                             'PUBLISHER' => 'Software Update version 4.0, Copyright © 2000-2009, Apple Inc. All rights reserved.',
                             'INSTALLDATE' => '2011-02-20 15:34'
                           },
                           {
                             'VERSION' => '10.6',
                             'COMMENTS' => '[Intel]',
                             'PUBLISHER' => undef,
                             'NAME' => 'Moniteur d’activité',
                             'INSTALLDATE' => '2009-07-31 09:18'
                           },
                           {
                             'PUBLISHER' => '12.2.8 (101117), © 2007 Microsoft Corporation. All rights reserved.',
                             'NAME' => 'My Day',
                             'INSTALLDATE' => '2010-12-27 14:23',
                             'VERSION' => '12.2.8',
                             'COMMENTS' => '[Universal]'
                           },
                           {
                             'VERSION' => '2.1',
                             'COMMENTS' => '[Universal]',
                             'NAME' => 'NetAuthAgent',
                             'PUBLISHER' => undef,
                             'INSTALLDATE' => '2010-07-07 14:24'
                           },
                           {
                             'PUBLISHER' => undef,
                             'NAME' => 'Network Connect',
                             'INSTALLDATE' => '2011-03-09 10:12',
                             'VERSION' => '17289',
                             'COMMENTS' => '[Intel]'
                           },
                           {
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '17289',
                             'INSTALLDATE' => '2011-03-09 10:12',
                             'PUBLISHER' => undef,
                             'NAME' => 'Network Diagnostic Utility'
                           },
                           {
                             'PUBLISHER' => 'Network Recording Player version 2.2, Copyright WebEx Communications, Inc. 2006',
                             'NAME' => 'Network Recording Player',
                             'INSTALLDATE' => '2010-02-25 21:36',
                             'VERSION' => '2.2.0',
                             'COMMENTS' => '[Intel]'
                           },
                           {
                             'VERSION' => '1.2.0',
                             'COMMENTS' => '[Intel]',
                             'PUBLISHER' => 'Nimbuzz for Mac OS X, version 1.2.0',
                             'NAME' => 'Nimbuzz',
                             'INSTALLDATE' => '2010-09-17 21:43'
                           },
                           {
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '2.3.8',
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'NAME' => 'OBEXAgent',
                             'PUBLISHER' => '2.3.8, Copyright (c) 2010 Apple Inc. All rights reserved.'
                           },
                           {
                             'VERSION' => '1.4.1',
                             'COMMENTS' => '[Intel]',
                             'PUBLISHER' => '1.4.1 (141.6), Copyright © 2007-2009 Apple Inc. All Rights Reserved.',
                             'NAME' => 'ODSAgent',
                             'INSTALLDATE' => '2010-07-07 14:24'
                           },
                           {
                             'NAME' => 'Officejet',
                             'PUBLISHER' => 'HP Officejet Driver 3.0, Copyright (c) 1994-2009 Hewlett-Packard Development Company, L.P.',
                             'INSTALLDATE' => '2009-06-16 14:48',
                             'VERSION' => '3.0',
                             'COMMENTS' => '[Intel]'
                           },
                           {
                             'COMMENTS' => '[PowerPC]',
                             'VERSION' => '12.2.8',
                             'INSTALLDATE' => '2010-12-27 14:23',
                             'PUBLISHER' => '12.2.8 (101117), © 2007 Microsoft Corporation. All rights reserved.',
                             'NAME' => 'Open XML for Charts'
                           },
                           {
                             'PUBLISHER' => '12.2.8 (101117), © 2007 Microsoft Corporation. All rights reserved.',
                             'NAME' => 'Open XML for Excel',
                             'INSTALLDATE' => '2010-12-27 14:23',
                             'VERSION' => '12.2.8',
                             'COMMENTS' => '[PowerPC]'
                           },
                           {
                             'INSTALLDATE' => '2010-08-26 20:09',
                             'PUBLISHER' => '1.5, Copyright © 2009 Apple Inc.',
                             'NAME' => 'OpenGL Driver Monitor',
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '1.5'
                           },
                           {
                             'VERSION' => '4.2',
                             'COMMENTS' => '[Universal]',
                             'PUBLISHER' => '4.2, Copyright 2003-2009 Apple, Inc.',
                             'NAME' => 'OpenGL Profiler',
                             'INSTALLDATE' => '2011-01-05 17:56'
                           },
                           {
                             'VERSION' => '2.1',
                             'COMMENTS' => '[Intel]',
                             'PUBLISHER' => undef,
                             'NAME' => 'OpenGL Shader Builder',
                             'INSTALLDATE' => '2010-08-26 20:09'
                           },
                           {
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '3.2.0',
                             'INSTALLDATE' => '2010-02-01 18:33',
                             'PUBLISHER' => 'OpenOffice.org 3.2.0 [320m8(Build:9472)]',
                             'NAME' => 'OpenOffice'
                           },
                           {
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '12.2.8',
                             'INSTALLDATE' => '2010-12-27 14:23',
                             'PUBLISHER' => '12.2.8 (101117), © 2007 Microsoft Corporation. All rights reserved.',
                             'NAME' => 'Organigramme hiérarchique'
                           },
                           {
                             'INSTALLDATE' => '2009-05-19 08:01',
                             'PUBLISHER' => '4.6, Copyright 2008 Apple Computer, Inc.',
                             'NAME' => 'Outil d’étalonnage du moniteur',
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '4.6'
                           },
                           {
                             'NAME' => 'P-touch Status Monitor',
                             'PUBLISHER' => 'ver2.00, © 2005-2008 Brother Industries, Ltd.',
                             'INSTALLDATE' => '2009-06-29 02:54',
                             'VERSION' => '2.00',
                             'COMMENTS' => '[Intel]'
                           },
                           {
                             'VERSION' => '4.5.0',
                             'COMMENTS' => '[Universal]',
                             'NAME' => 'PMC Index',
                             'PUBLISHER' => undef,
                             'INSTALLDATE' => '2009-07-02 15:19'
                           },
                           {
                             'NAME' => 'PSPP',
                             'PUBLISHER' => undef,
                             'INSTALLDATE' => '2009-12-30 12:33',
                             'VERSION' => '@VERSION@',
                             'COMMENTS' => undef
                           },
                           {
                             'PUBLISHER' => '6.0.4, © Copyright 2004-2010 Apple Inc. All rights reserved.',
                             'NAME' => 'PTPCamera',
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'VERSION' => '6.0.4',
                             'COMMENTS' => '[Universal]'
                           },
                           {
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'PUBLISHER' => undef,
                             'NAME' => 'PackageMaker',
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '3.0.4'
                           },
                           {
                             'PUBLISHER' => '2.3.6, Copyright (c) 2010 Apple Inc. All rights reserved.',
                             'NAME' => 'PacketLogger',
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'VERSION' => '2.3.6',
                             'COMMENTS' => '[Universal]'
                           },
                           {
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '6.0',
                             'INSTALLDATE' => '2011-03-08 12:21',
                             'PUBLISHER' => '6.0.11994.637942, Copyright 2005-2011 Parallels Holdings, Ltd. and its affiliates',
                             'NAME' => 'Parallels Desktop'
                           },
                           {
                             'INSTALLDATE' => '2011-03-08 12:21',
                             'PUBLISHER' => '6.0.11994.637942, Copyright 2005-2011 Parallels Holdings, Ltd. and its affiliates',
                             'NAME' => 'Parallels Mounter',
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '6.0'
                           },
                           {
                             'NAME' => 'Parallels Service',
                             'PUBLISHER' => '6.0.11994.637942, Copyright 2005-2011 Parallels Holdings, Ltd. and its affiliates',
                             'INSTALLDATE' => '2011-03-21 23:57',
                             'VERSION' => '6.0',
                             'COMMENTS' => '[Intel]'
                           },
                           {
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '6.0.11994.637942',
                             'INSTALLDATE' => '2011-03-08 12:21',
                             'NAME' => 'Parallels Transporter',
                             'PUBLISHER' => '6.0.11994.637942, Copyright 2005-2011 Parallels Holdings, Ltd. and its affiliates'
                           },
                           {
                             'NAME' => 'ParentalControls',
                             'PUBLISHER' => '2.0, Copyright Apple Inc. 2007-2009',
                             'INSTALLDATE' => '2011-02-20 15:34',
                             'VERSION' => '2.0',
                             'COMMENTS' => '[Universal]'
                           },
                           {
                             'NAME' => 'Partage d’écran',
                             'PUBLISHER' => '1.1.1, Copyright © 2007-2009 Apple Inc., All Rights Reserved.',
                             'INSTALLDATE' => '2009-07-02 08:11',
                             'VERSION' => '1.1.1',
                             'COMMENTS' => '[Universal]'
                           },
                           {
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'NAME' => 'Photo Booth',
                             'PUBLISHER' => undef,
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '3.0.3'
                           },
                           {
                             'VERSION' => '4.0',
                             'COMMENTS' => '[Intel]',
                             'NAME' => 'Photosmart',
                             'PUBLISHER' => 'HP Photosmart Driver 4.0, Copyright (c) 1994-2009 Hewlett-Packard Development Company, L.P.',
                             'INSTALLDATE' => '2009-06-16 12:03'
                           },
                           {
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '3.0',
                             'INSTALLDATE' => '2009-06-16 11:32',
                             'NAME' => 'PhotosmartPro',
                             'PUBLISHER' => 'HP Photosmart Pro Driver 3.0, Copyright (c) 1994-2009 Hewlett-Packard Development Company, L.P.'
                           },
                           {
                             'INSTALLDATE' => '2010-08-26 20:09',
                             'PUBLISHER' => undef,
                             'NAME' => 'Pixie',
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '2.3'
                           },
                           {
                             'PUBLISHER' => undef,
                             'NAME' => 'PluginIM',
                             'INSTALLDATE' => '2009-05-19 07:36',
                             'VERSION' => '1.1',
                             'COMMENTS' => '[Universal]'
                           },
                           {
                             'VERSION' => '4.7.3',
                             'COMMENTS' => '[Intel]',
                             'NAME' => 'PowerPC Help',
                             'PUBLISHER' => undef,
                             'INSTALLDATE' => '2011-01-05 17:56'
                           },
                           {
                             'NAME' => 'PreferenceSyncClient',
                             'PUBLISHER' => undef,
                             'INSTALLDATE' => '2009-07-02 08:17',
                             'VERSION' => '2.0',
                             'COMMENTS' => '[Universal]'
                           },
                           {
                             'INSTALLDATE' => '2009-07-01 15:59',
                             'PUBLISHER' => 'GarageBand Getting Started',
                             'NAME' => 'Premiers contacts avec GarageBand',
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '1.0.2'
                           },
                           {
                             'INSTALLDATE' => '2009-07-01 15:59',
                             'NAME' => 'Premiers contacts avec iMovie 08',
                             'PUBLISHER' => 'iMovie 08 Getting Started',
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '1.0.2'
                           },
                           {
                             'INSTALLDATE' => '2009-07-01 15:59',
                             'NAME' => 'Premiers contacts avec iWeb',
                             'PUBLISHER' => 'iWeb Getting Started',
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '1.0.2'
                           },
                           {
                             'INSTALLDATE' => '2011-03-18 12:21',
                             'PUBLISHER' => undef,
                             'NAME' => 'Préférences Java',
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '13.4.0'
                           },
                           {
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '7.0',
                             'INSTALLDATE' => '2009-06-27 08:09',
                             'NAME' => 'Préférences Système',
                             'PUBLISHER' => undef
                           },
                           {
                             'VERSION' => '6.5',
                             'COMMENTS' => '[Universal]',
                             'PUBLISHER' => undef,
                             'NAME' => 'Printer Setup Utility',
                             'INSTALLDATE' => '2011-01-05 17:56'
                           },
                           {
                             'VERSION' => '6.5',
                             'COMMENTS' => '[Universal]',
                             'PUBLISHER' => undef,
                             'NAME' => 'PrinterProxy',
                             'INSTALLDATE' => '2011-01-05 17:56'
                           },
                           {
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '0.9.1',
                             'INSTALLDATE' => '2010-01-26 17:57',
                             'NAME' => 'Prism',
                             'PUBLISHER' => 'Prism 0.9.1, © 2007 Contributors'
                           },
                           {
                             'PUBLISHER' => undef,
                             'NAME' => 'Problem Reporter',
                             'INSTALLDATE' => '2011-02-20 15:34',
                             'VERSION' => '10.6.6',
                             'COMMENTS' => '[Universal]'
                           },
                           {
                             'INSTALLDATE' => '2009-06-27 08:18',
                             'NAME' => 'Programme d’installation',
                             'PUBLISHER' => '3.0, Copyright © 2000-2006 Apple Computer Inc., All Rights Reserved',
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '4.0'
                           },
                           {
                             'VERSION' => undef,
                             'COMMENTS' => '[Universal]',
                             'PUBLISHER' => undef,
                             'NAME' => 'Proof',
                             'INSTALLDATE' => '2009-04-25 04:11'
                           },
                           {
                             'NAME' => 'Property List Editor',
                             'PUBLISHER' => undef,
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'VERSION' => '5.3',
                             'COMMENTS' => '[Universal]'
                           },
                           {
                             'INSTALLDATE' => '2011-03-18 12:21',
                             'NAME' => 'PubSubAgent',
                             'PUBLISHER' => undef,
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '1.0.5'
                           },
                           {
                             'VERSION' => '2.5.4',
                             'COMMENTS' => '[Universal]',
                             'NAME' => 'Python',
                             'PUBLISHER' => '2.5.4a0, (c) 2004 Python Software Foundation.',
                             'INSTALLDATE' => '2009-07-08 08:55'
                           },
                           {
                             'NAME' => 'Python Launcher',
                             'PUBLISHER' => '2.5.4, © 001-2006 Python Software Foundation',
                             'INSTALLDATE' => '2009-07-08 08:56',
                             'VERSION' => '2.5.4',
                             'COMMENTS' => '[Universal]'
                           },
                           {
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '4.0',
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'PUBLISHER' => undef,
                             'NAME' => 'Quartz Composer'
                           },
                           {
                             'VERSION' => '1.2',
                             'COMMENTS' => '[Intel]',
                             'PUBLISHER' => undef,
                             'NAME' => 'Quartz Composer Visualizer',
                             'INSTALLDATE' => '2010-08-26 20:09'
                           },
                           {
                             'VERSION' => '4.1',
                             'COMMENTS' => '[Intel]',
                             'NAME' => 'Quartz Debug',
                             'PUBLISHER' => 'Quartz Debug 4.1',
                             'INSTALLDATE' => '2011-01-05 17:56'
                           },
                           {
                             'VERSION' => '10.0',
                             'COMMENTS' => '[Intel]',
                             'PUBLISHER' => '10.0, Copyright © 2009-2010 Apple Inc. All Rights Reserved.',
                             'NAME' => 'QuickTime Player',
                             'INSTALLDATE' => '2011-01-05 17:56'
                           },
                           {
                             'INSTALLDATE' => '2009-04-09 22:41',
                             'PUBLISHER' => '7.6.6, Copyright © 1989-2009 Apple Inc. All Rights Reserved',
                             'NAME' => 'QuickTime Player 7',
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '7.6.6'
                           },
                           {
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '12.2.8',
                             'INSTALLDATE' => '2010-12-27 14:23',
                             'PUBLISHER' => '12.2.8 (101117), © 2007 Microsoft Corporation. All rights reserved.',
                             'NAME' => 'Rappels Microsoft Office'
                           },
                           {
                             'INSTALLDATE' => '2009-06-15 08:18',
                             'PUBLISHER' => undef,
                             'NAME' => 'Raster2CanonIJ',
                             'COMMENTS' => undef,
                             'VERSION' => undef
                           },
                           {
                             'VERSION' => '4.7.3',
                             'COMMENTS' => '[Intel]',
                             'PUBLISHER' => undef,
                             'NAME' => 'Reggie SE',
                             'INSTALLDATE' => '2011-01-05 17:56'
                           },
                           {
                             'NAME' => 'Remove',
                             'PUBLISHER' => undef,
                             'INSTALLDATE' => '2009-04-25 04:11',
                             'VERSION' => undef,
                             'COMMENTS' => '[Universal]'
                           },
                           {
                             'INSTALLDATE' => '2009-04-25 04:11',
                             'NAME' => 'Rename',
                             'PUBLISHER' => undef,
                             'COMMENTS' => '[Universal]',
                             'VERSION' => undef
                           },
                           {
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '1.3',
                             'INSTALLDATE' => '2010-08-26 20:09',
                             'PUBLISHER' => '1.3, Copyright © 2002-2005 Apple Computer, Inc.',
                             'NAME' => 'Repeat After Me'
                           },
                           {
                             'NAME' => 'Résolution des conflits',
                             'PUBLISHER' => '1.0, Copyright Apple Computer Inc. 2004',
                             'INSTALLDATE' => '2009-07-18 08:22',
                             'VERSION' => '5.2',
                             'COMMENTS' => '[Universal]'
                           },
                           {
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '4.3',
                             'INSTALLDATE' => '2009-05-19 07:35',
                             'PUBLISHER' => '4.0, Copyright © 1997-2009 Apple Inc., All Rights Reserved',
                             'NAME' => 'SCIM'
                           },
                           {
                             'PUBLISHER' => undef,
                             'NAME' => 'SLLauncher',
                             'INSTALLDATE' => '2011-01-20 23:50',
                             'VERSION' => '1.0',
                             'COMMENTS' => '[Intel]'
                           },
                           {
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '1.9',
                             'INSTALLDATE' => '2010-08-26 20:09',
                             'PUBLISHER' => undef,
                             'NAME' => 'SRLanguageModeler'
                           },
                           {
                             'INSTALLDATE' => '2011-03-18 12:21',
                             'PUBLISHER' => '5.0.4, Copyright © 2003-2011 Apple Inc.',
                             'NAME' => 'Safari',
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '5.0.4'
                           },
                           {
                             'VERSION' => '2.00.29',
                             'COMMENTS' => '[Intel]',
                             'NAME' => 'Samsung Scanner',
                             'PUBLISHER' => 'Copyright (C) 2004-2009 Samsung Electronics Co., Ltd.',
                             'INSTALLDATE' => '2009-07-01 07:26'
                           },
                           {
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '4.7.3',
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'PUBLISHER' => undef,
                             'NAME' => 'Saturn'
                           },
                           {
                             'PUBLISHER' => undef,
                             'NAME' => 'ScreenReaderUIServer',
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'VERSION' => '3.4.0',
                             'COMMENTS' => '[Universal]'
                           },
                           {
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '3.0.3',
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'PUBLISHER' => undef,
                             'NAME' => 'ScreenSaverEngine'
                           },
                           {
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '5.2',
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'NAME' => 'SecurityAgent',
                             'PUBLISHER' => undef
                           },
                           {
                             'INSTALLDATE' => '2009-05-19 04:17',
                             'PUBLISHER' => undef,
                             'NAME' => 'SecurityFixer',
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '10.6'
                           },
                           {
                             'NAME' => 'SecurityProxy',
                             'PUBLISHER' => undef,
                             'INSTALLDATE' => '2009-05-21 04:37',
                             'VERSION' => '1.0',
                             'COMMENTS' => '[Universal]'
                           },
                           {
                             'VERSION' => '10.6.3',
                             'COMMENTS' => '[Intel]',
                             'NAME' => 'ServerJoiner',
                             'PUBLISHER' => undef,
                             'INSTALLDATE' => '2009-07-19 09:18'
                           },
                           {
                             'NAME' => 'Service de résumé',
                             'PUBLISHER' => 'Summary Service Version  2',
                             'INSTALLDATE' => '2009-05-19 07:27',
                             'VERSION' => '2.0',
                             'COMMENTS' => '[Intel]'
                           },
                           {
                             'INSTALLDATE' => '2011-03-09 10:12',
                             'NAME' => 'Session Timer',
                             'PUBLISHER' => undef,
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '17289'
                           },
                           {
                             'PUBLISHER' => undef,
                             'NAME' => 'Set Info',
                             'INSTALLDATE' => '2009-04-25 04:11',
                             'VERSION' => undef,
                             'COMMENTS' => '[Universal]'
                           },
                           {
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'PUBLISHER' => undef,
                             'NAME' => 'Shark',
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '4.7.3'
                           },
                           {
                             'COMMENTS' => '[Universal]',
                             'VERSION' => undef,
                             'INSTALLDATE' => '2009-04-25 04:11',
                             'NAME' => 'Show Info',
                             'PUBLISHER' => undef
                           },
                           {
                             'NAME' => 'Signalement d\'erreurs Microsoft',
                             'PUBLISHER' => '2.2.5 (101115), © 2010 Microsoft Corporation. All rights reserved.',
                             'INSTALLDATE' => '2011-01-13 17:38',
                             'VERSION' => '2.2.5',
                             'COMMENTS' => '[Universal]'
                           },
                           {
                             'INSTALLDATE' => '2010-02-08 15:15',
                             'PUBLISHER' => 'Skype version 2.8.0.851 (16248), Copyright © 2004-2010 Skype Technologies S.A.',
                             'NAME' => 'Skype',
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '2.8.0.851'
                           },
                           {
                             'INSTALLDATE' => '2010-08-26 20:09',
                             'NAME' => 'SleepX',
                             'PUBLISHER' => undef,
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '2.7'
                           },
                           {
                             'VERSION' => '1.0A',
                             'COMMENTS' => '[Universal]',
                             'PUBLISHER' => undef,
                             'NAME' => 'SolidWorks eDrawings',
                             'INSTALLDATE' => '2007-06-26 10:15'
                           },
                           {
                             'PUBLISHER' => '1.1, Copyright 2007-2008 Apple Inc.',
                             'NAME' => 'Spaces',
                             'INSTALLDATE' => '2011-02-20 15:34',
                             'VERSION' => '1.1',
                             'COMMENTS' => '[Universal]'
                           },
                           {
                             'INSTALLDATE' => '2009-05-19 10:45',
                             'PUBLISHER' => undef,
                             'NAME' => 'SpeakableItems',
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '3.7.8'
                           },
                           {
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '3.8.1',
                             'INSTALLDATE' => '2009-05-29 02:38',
                             'NAME' => 'Speech Startup',
                             'PUBLISHER' => undef
                           },
                           {
                             'VERSION' => '3.8.1',
                             'COMMENTS' => '[Intel]',
                             'NAME' => 'SpeechFeedbackWindow',
                             'PUBLISHER' => undef,
                             'INSTALLDATE' => '2009-05-29 02:38'
                           },
                           {
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '3.11.1',
                             'INSTALLDATE' => '2009-05-29 02:37',
                             'NAME' => 'SpeechRecognitionServer',
                             'PUBLISHER' => undef
                           },
                           {
                             'INSTALLDATE' => '2009-07-12 07:23',
                             'PUBLISHER' => undef,
                             'NAME' => 'SpeechService',
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '3.10.35'
                           },
                           {
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '3.10.35',
                             'INSTALLDATE' => '2009-07-12 07:23',
                             'PUBLISHER' => undef,
                             'NAME' => 'SpeechSynthesisServer'
                           },
                           {
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '0.9',
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'NAME' => 'Spin Control',
                             'PUBLISHER' => 'Spin Control'
                           },
                           {
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'PUBLISHER' => undef,
                             'NAME' => 'SpindownHD',
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '4.7.3'
                           },
                           {
                             'VERSION' => '2.0',
                             'COMMENTS' => '[Intel]',
                             'NAME' => 'Spotlight',
                             'PUBLISHER' => undef,
                             'INSTALLDATE' => '2009-07-24 04:18'
                           },
                           {
                             'VERSION' => '12.2.8',
                             'COMMENTS' => '[Universal]',
                             'PUBLISHER' => '12.2.8 (101117), © 2007 Microsoft Corporation. All rights reserved.',
                             'NAME' => 'Supprimer Office',
                             'INSTALLDATE' => '2010-12-27 14:23'
                           },
                           {
                             'PUBLISHER' => undef,
                             'NAME' => 'SyncDiagnostics',
                             'INSTALLDATE' => '2009-07-18 08:23',
                             'VERSION' => '5.2',
                             'COMMENTS' => '[Universal]'
                           },
                           {
                             'NAME' => 'SyncServer',
                             'PUBLISHER' => '© 2002-2003 Apple',
                             'INSTALLDATE' => '2009-07-18 08:22',
                             'VERSION' => '5.2',
                             'COMMENTS' => '[Universal]'
                           },
                           {
                             'VERSION' => '14.0.2',
                             'COMMENTS' => '[Intel]',
                             'PUBLISHER' => '14.0.2 (101115), © 2010 Microsoft Corporation. All rights reserved.',
                             'NAME' => 'SyncServicesAgent',
                             'INSTALLDATE' => '2011-01-13 17:38'
                           },
                           {
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'PUBLISHER' => 'Syncrospector 3.0, © 2004 Apple Computer, Inc., All rights reserved.',
                             'NAME' => 'Syncrospector',
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '5.2'
                           },
                           {
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '1.3.4',
                             'INSTALLDATE' => '2009-05-19 11:07',
                             'NAME' => 'System Events',
                             'PUBLISHER' => undef
                           },
                           {
                             'VERSION' => '1.6',
                             'COMMENTS' => '[Intel]',
                             'PUBLISHER' => 'SystemUIServer version 1.6, Copyright 2000-2009 Apple Computer, Inc.',
                             'NAME' => 'SystemUIServer',
                             'INSTALLDATE' => '2011-01-05 17:56'
                           },
                           {
                             'PUBLISHER' => '6.2, Copyright © 1997-2006 Apple Computer Inc., All Rights Reserved',
                             'NAME' => 'TCIM',
                             'INSTALLDATE' => '2009-07-07 08:48',
                             'VERSION' => '6.3',
                             'COMMENTS' => '[Universal]'
                           },
                           {
                             'PUBLISHER' => '6.0.1, © Copyright 2000-2010 Apple Inc., all rights reserved.',
                             'NAME' => 'TWAINBridge',
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'VERSION' => '6.0.1',
                             'COMMENTS' => '[Universal]'
                           },
                           {
                             'INSTALLDATE' => '2009-05-19 07:36',
                             'PUBLISHER' => 'Tamil Input Method 1.2',
                             'NAME' => 'TamilIM',
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '1.3'
                           },
                           {
                             'PUBLISHER' => '2.1.1, © 1995-2009 Apple Inc. All Rights Reserved.',
                             'NAME' => 'Terminal',
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'VERSION' => '2.1.1',
                             'COMMENTS' => '[Intel]'
                           },
                           {
                             'VERSION' => '1.6',
                             'COMMENTS' => '[Intel]',
                             'NAME' => 'TextEdit',
                             'PUBLISHER' => undef,
                             'INSTALLDATE' => '2009-06-27 08:06'
                           },
                           {
                             'NAME' => 'Thread Viewer',
                             'PUBLISHER' => 'Thread Viewer',
                             'INSTALLDATE' => '2009-07-02 15:19',
                             'VERSION' => '1.4',
                             'COMMENTS' => '[Universal]'
                           },
                           {
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '3.1.9',
                             'INSTALLDATE' => '2011-03-06 15:02',
                             'NAME' => 'Thunderbird',
                             'PUBLISHER' => 'Thunderbird 3.1.9'
                           },
                           {
                             'NAME' => 'Ticket Viewer',
                             'PUBLISHER' => undef,
                             'INSTALLDATE' => '2009-05-19 07:28',
                             'VERSION' => '1.0',
                             'COMMENTS' => '[Intel]'
                           },
                           {
                             'NAME' => 'Time Machine',
                             'PUBLISHER' => '1.1, Copyright 2007-2008 Apple Inc.',
                             'INSTALLDATE' => '2011-02-20 15:34',
                             'VERSION' => '1.1',
                             'COMMENTS' => '[Universal]'
                           },
                           {
                             'VERSION' => '2.0.1',
                             'COMMENTS' => '[Intel]',
                             'PUBLISHER' => '2.0.1, Copyright © 2007-2009 Apple Inc.',
                             'NAME' => 'Transfert de podcast',
                             'INSTALLDATE' => '2009-07-21 07:31'
                           },
                           {
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '6.0.1',
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'NAME' => 'Transfert d’images',
                             'PUBLISHER' => '6.0, © Copyright 2000-2009 Apple Inc., all rights reserved.'
                           },
                           {
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '4.1',
                             'INSTALLDATE' => '2010-07-07 14:24',
                             'NAME' => 'Trousseau d’accès',
                             'PUBLISHER' => undef
                           },
                           {
                             'INSTALLDATE' => '2009-07-01 16:27',
                             'NAME' => 'TrueCrypt',
                             'PUBLISHER' => undef,
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '6.2.1'
                           },
                           {
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '6.0',
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'PUBLISHER' => '6.0, © Copyright 2000-2009 Apple Inc., all rights reserved.',
                             'NAME' => 'Type1Camera'
                           },
                           {
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'PUBLISHER' => '6.0, © Copyright 2000-2009 Apple Inc., all rights reserved.',
                             'NAME' => 'Type2Camera',
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '6.0'
                           },
                           {
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'NAME' => 'Type3Camera',
                             'PUBLISHER' => '6.0, © Copyright 2001-2009 Apple Inc., all rights reserved.',
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '6.0'
                           },
                           {
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'NAME' => 'Type4Camera',
                             'PUBLISHER' => '6.0.1, © Copyright 2001-2010 Apple Inc. All rights reserved.',
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '6.0.1'
                           },
                           {
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'PUBLISHER' => '6.0, © Copyright 2001-2009 Apple Inc., all rights reserved.',
                             'NAME' => 'Type5Camera',
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '6.0'
                           },
                           {
                             'VERSION' => '6.0',
                             'COMMENTS' => '[Universal]',
                             'PUBLISHER' => '6.0, © Copyright 2002-2009 Apple Inc., all rights reserved.',
                             'NAME' => 'Type6Camera',
                             'INSTALLDATE' => '2011-01-05 17:56'
                           },
                           {
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '6.0',
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'NAME' => 'Type7Camera',
                             'PUBLISHER' => '6.0, © Copyright 2002-2009 Apple Inc., all rights reserved.'
                           },
                           {
                             'NAME' => 'Type8Camera',
                             'PUBLISHER' => '6.0.1, © Copyright 2002-2009 Apple Inc., all rights reserved.',
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'VERSION' => '6.0.1',
                             'COMMENTS' => '[Universal]'
                           },
                           {
                             'VERSION' => '1.1.1',
                             'COMMENTS' => '[Universal]',
                             'PUBLISHER' => 'URL Access Scripting 1.1, Copyright © 2002-2004 Apple Computer, Inc.',
                             'NAME' => 'URL Access Scripting',
                             'INSTALLDATE' => '2009-05-19 07:34'
                           },
                           {
                             'VERSION' => '4.0.0',
                             'COMMENTS' => '[Intel]',
                             'NAME' => 'USB Prober',
                             'PUBLISHER' => '4.0.0, Copyright © 2002-2010 Apple Inc. All Rights Reserved.',
                             'INSTALLDATE' => '2011-01-05 17:56'
                           },
                           {
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '1.0',
                             'INSTALLDATE' => '2010-02-15 16:08',
                             'PUBLISHER' => undef,
                             'NAME' => 'Uninstall AnyConnect'
                           },
                           {
                             'VERSION' => '8.0',
                             'COMMENTS' => '[Universal]',
                             'NAME' => 'Uninstall Cisco Network Assistant',
                             'PUBLISHER' => 'InstallAnywhere 8.0, Copyright © 2006 Macrovision Corporation.',
                             'INSTALLDATE' => '2011-03-13 00:14'
                           },
                           {
                             'VERSION' => '1.0',
                             'COMMENTS' => '[Universal]',
                             'NAME' => 'Uninstall DivX for Mac',
                             'PUBLISHER' => undef,
                             'INSTALLDATE' => '2009-11-17 00:47'
                           },
                           {
                             'VERSION' => '1.0',
                             'COMMENTS' => '[Intel]',
                             'PUBLISHER' => undef,
                             'NAME' => 'UnmountAssistantAgent',
                             'INSTALLDATE' => '2009-07-03 03:00'
                           },
                           {
                             'VERSION' => '3.1.0',
                             'COMMENTS' => '[Intel]',
                             'NAME' => 'UserNotificationCenter',
                             'PUBLISHER' => undef,
                             'INSTALLDATE' => '2009-05-19 04:13'
                           },
                           {
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'PUBLISHER' => '5.5.2, Copyright 2001-2010 Apple Inc.',
                             'NAME' => 'Utilitaire AirPort',
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '5.5.2'
                           },
                           {
                             'VERSION' => '1.1.1',
                             'COMMENTS' => '[Intel]',
                             'NAME' => 'Utilitaire AppleScript',
                             'PUBLISHER' => undef,
                             'INSTALLDATE' => '2009-05-19 07:34'
                           },
                           {
                             'VERSION' => '4.6.2',
                             'COMMENTS' => '[Intel]',
                             'NAME' => 'Utilitaire ColorSync',
                             'PUBLISHER' => '4.6.2, © Copyright 2009 Apple Inc.',
                             'INSTALLDATE' => '2009-05-19 08:00'
                           },
                           {
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'NAME' => 'Utilitaire RAID',
                             'PUBLISHER' => 'RAID Utility 1.0 (121), Copyright © 2007-2009 Apple Inc.',
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '1.2'
                           },
                           {
                             'VERSION' => '3.4.0',
                             'COMMENTS' => '[Universal]',
                             'NAME' => 'Utilitaire VoiceOver',
                             'PUBLISHER' => undef,
                             'INSTALLDATE' => '2011-01-05 17:56'
                           },
                           {
                             'PUBLISHER' => '14.0.2 (101115), © 2010 Microsoft Corporation. All rights reserved.',
                             'NAME' => 'Utilitaire de base de données Microsoft',
                             'INSTALLDATE' => '2011-01-13 17:38',
                             'VERSION' => '14.0.2',
                             'COMMENTS' => '[Intel]'
                           },
                           {
                             'NAME' => 'Utilitaire de disque',
                             'PUBLISHER' => 'Version 11.5.2, Copyright © 1999-2010 Apple Inc. All rights reserved.',
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'VERSION' => '11.5.2',
                             'COMMENTS' => '[Intel]'
                           },
                           {
                             'NAME' => 'Utilitaire de l\'imprimante Lexmark',
                             'PUBLISHER' => '1.0, Copyright 2008 Lexmark International, Inc. All rights reserved.',
                             'INSTALLDATE' => '2009-07-01 07:28',
                             'VERSION' => '1.2.10',
                             'COMMENTS' => '[Intel]'
                           },
                           {
                             'VERSION' => '1.4.6',
                             'COMMENTS' => '[Intel]',
                             'PUBLISHER' => 'Version 1.4.6, Copyright © 2000-2009 Apple Inc. All rights reserved.',
                             'NAME' => 'Utilitaire de réseau',
                             'INSTALLDATE' => '2009-06-25 04:25'
                           },
                           {
                             'NAME' => 'Utilitaire d’annuaire',
                             'PUBLISHER' => '2.2, Copyright © 2001–2008 Apple Inc.',
                             'INSTALLDATE' => '2009-05-19 11:08',
                             'VERSION' => '2.2',
                             'COMMENTS' => '[Intel]'
                           },
                           {
                             'NAME' => 'Utilitaire d’archive',
                             'PUBLISHER' => undef,
                             'INSTALLDATE' => '2009-06-18 07:01',
                             'VERSION' => '10.6',
                             'COMMENTS' => '[Intel]'
                           },
                           {
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '1.4.1',
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'PUBLISHER' => undef,
                             'NAME' => 'Utilitaire d’emplacement de mémoire'
                           },
                           {
                             'PUBLISHER' => undef,
                             'NAME' => 'Utilitaire d’emplacement d’extension',
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'VERSION' => '1.4.1',
                             'COMMENTS' => '[Intel]'
                           },
                           {
                             'PUBLISHER' => undef,
                             'NAME' => 'VPNClient',
                             'INSTALLDATE' => '2009-12-27 17:41',
                             'VERSION' => '4.9.01.0180',
                             'COMMENTS' => '[Universal]'
                           },
                           {
                             'NAME' => 'VidyoDesktop',
                             'PUBLISHER' => undef,
                             'INSTALLDATE' => '2010-10-19 21:26',
                             'VERSION' => '1.0',
                             'COMMENTS' => '[Intel]'
                           },
                           {
                             'INSTALLDATE' => '2010-10-19 21:26',
                             'PUBLISHER' => undef,
                             'NAME' => 'VidyoDesktop Uninstaller',
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '2.0.0'
                           },
                           {
                             'INSTALLDATE' => '2009-05-19 08:12',
                             'PUBLISHER' => undef,
                             'NAME' => 'VietnameseIM',
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '1.1'
                           },
                           {
                             'VERSION' => '4.0.4',
                             'COMMENTS' => '[Intel]',
                             'PUBLISHER' => 'Oracle VM VirtualBox Manager 4.0.4, © 2007-2011 Oracle Corporation',
                             'NAME' => 'VirtualBox',
                             'INSTALLDATE' => '2011-03-12 20:23'
                           },
                           {
                             'NAME' => 'Vodafone Mobile Connect',
                             'PUBLISHER' => 'Vodafone Mobile Connect 3G 2.11.04.00',
                             'INSTALLDATE' => '2010-01-13 18:16',
                             'VERSION' => 'Vodafone Mobile Connect 3G 2.11.04',
                             'COMMENTS' => '[Universal]'
                           },
                           {
                             'NAME' => 'VoiceOver',
                             'PUBLISHER' => undef,
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'VERSION' => '3.4.0',
                             'COMMENTS' => '[Universal]'
                           },
                           {
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '3.4.0',
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'PUBLISHER' => undef,
                             'NAME' => 'VoiceOver Quickstart'
                           },
                           {
                             'INSTALLDATE' => '2009-11-04 00:46',
                             'PUBLISHER' => '2.3.1.2 © 2005-2009 Telestream Inc. All Rights Reserved.',
                             'NAME' => 'WMV Player',
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '2.3.1.2'
                           },
                           {
                             'VERSION' => undef,
                             'COMMENTS' => undef,
                             'NAME' => 'WebKitPluginHost',
                             'PUBLISHER' => undef,
                             'INSTALLDATE' => '2011-01-05 17:56'
                           },
                           {
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '1.0',
                             'INSTALLDATE' => '2009-10-20 23:23',
                             'NAME' => 'WiFi Scanner',
                             'PUBLISHER' => undef
                           },
                           {
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '1.2.0',
                             'INSTALLDATE' => '2009-06-16 06:11',
                             'PUBLISHER' => '1.2.0, Copyright 1998-2009 Wireshark Development Team',
                             'NAME' => 'Wireshark'
                           },
                           {
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '8.4.19',
                             'INSTALLDATE' => '2009-07-23 05:18',
                             'PUBLISHER' => 'Wish Shell 8.4.19,',
                             'NAME' => 'Wish'
                           },
                           {
                             'NAME' => 'X11',
                             'PUBLISHER' => 'org.x.X11',
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'VERSION' => '2.3.6',
                             'COMMENTS' => undef
                           },
                           {
                             'NAME' => 'Xcode',
                             'PUBLISHER' => 'Xcode version 3.2.5',
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'VERSION' => '3.2.5',
                             'COMMENTS' => '[Universal]'
                           },
                           {
                             'PUBLISHER' => undef,
                             'NAME' => 'Yahoo! Sync',
                             'INSTALLDATE' => '2009-05-19 08:56',
                             'VERSION' => '1.3',
                             'COMMENTS' => '[Universal]'
                           },
                           {
                             'INSTALLDATE' => '2009-11-12 22:20',
                             'NAME' => 'Yahoo! Zimbra Desktop',
                             'PUBLISHER' => undef,
                             'COMMENTS' => undef,
                             'VERSION' => undef
                           },
                           {
                             'NAME' => 'Yap',
                             'PUBLISHER' => undef,
                             'INSTALLDATE' => '2009-12-30 12:33',
                             'VERSION' => undef,
                             'COMMENTS' => undef
                           },
                           {
                             'PUBLISHER' => 'Zimbra Desktop 1.0.4, (C) 2010 VMware Inc.',
                             'NAME' => 'Zimbra Desktop',
                             'INSTALLDATE' => '2010-07-07 16:21',
                             'VERSION' => '1.0.4',
                             'COMMENTS' => '[Intel]'
                           },
                           {
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '1.0.4',
                             'INSTALLDATE' => '2010-07-07 16:19',
                             'NAME' => 'Zimbra Desktop désinstallateur',
                             'PUBLISHER' => '1.0.4'
                           },
                           {
                             'VERSION' => '1.0',
                             'COMMENTS' => '[Universal]',
                             'NAME' => 'ZoneMonitor',
                             'PUBLISHER' => undef,
                             'INSTALLDATE' => '2009-07-02 15:19'
                           },
                           {
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '7.19.11.0',
                             'INSTALLDATE' => '2011-02-22 09:29',
                             'PUBLISHER' => undef,
                             'NAME' => 'asannotation2'
                           },
                           {
                             'VERSION' => '2.0',
                             'COMMENTS' => '[Universal]',
                             'PUBLISHER' => 'AFP Client Session Monitor, Copyright © 2000 - 2007, Apple Inc.',
                             'NAME' => 'check_afp',
                             'INSTALLDATE' => '2009-07-03 02:46'
                           },
                           {
                             'VERSION' => '8.02',
                             'COMMENTS' => '[Intel]',
                             'NAME' => 'commandtoescp',
                             'PUBLISHER' => 'commandtoescp Copyright (C) SEIKO EPSON CORPORATION 2001-2009. All rights reserved.',
                             'INSTALLDATE' => '2009-07-09 06:55'
                           },
                           {
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '1.11',
                             'INSTALLDATE' => '2009-06-15 14:48',
                             'NAME' => 'commandtohp',
                             'PUBLISHER' => 'HP Command File Filter 1.11, Copyright (c) 2006-2010 Hewlett-Packard Development Company, L.P.'
                           },
                           {
                             'PUBLISHER' => undef,
                             'NAME' => 'dotmacfx',
                             'INSTALLDATE' => '2010-07-07 14:24',
                             'VERSION' => '3.0',
                             'COMMENTS' => '[Universal]'
                           },
                           {
                             'PUBLISHER' => undef,
                             'NAME' => 'eaptlstrust',
                             'INSTALLDATE' => '2009-05-19 07:34',
                             'VERSION' => '10.0',
                             'COMMENTS' => '[Universal]'
                           },
                           {
                             'PUBLISHER' => 'HP Fax 4.1, Copyright (c) 2009-2010 Hewlett-Packard Development Company, L.P.',
                             'NAME' => 'fax',
                             'INSTALLDATE' => '2010-04-23 11:36',
                             'VERSION' => '4.1',
                             'COMMENTS' => '[Intel]'
                           },
                           {
                             'PUBLISHER' => undef,
                             'NAME' => 'g-coul',
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'VERSION' => '6.5',
                             'COMMENTS' => '[Universal]'
                           },
                           {
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '6.5',
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'PUBLISHER' => undef,
                             'NAME' => 'h-color-hp- imprimante couleur'
                           },
                           {
                             'VERSION' => '6.5',
                             'COMMENTS' => '[Universal]',
                             'NAME' => 'h-coul',
                             'PUBLISHER' => undef,
                             'INSTALLDATE' => '2011-01-05 17:56'
                           },
                           {
                             'NAME' => 'h-nb-toshiba- photocopieur multifonctions noir et blanc',
                             'PUBLISHER' => undef,
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'VERSION' => '6.5',
                             'COMMENTS' => '[Universal]'
                           },
                           {
                             'VERSION' => '6.5',
                             'COMMENTS' => '[Universal]',
                             'PUBLISHER' => undef,
                             'NAME' => 'h-nb1',
                             'INSTALLDATE' => '2011-01-05 17:56'
                           },
                           {
                             'VERSION' => '1.0.0',
                             'COMMENTS' => '[Intel]',
                             'PUBLISHER' => '1.0.0, (c) Copyright 2001-2010 Hewlett-Packard Development Company, L.P.',
                             'NAME' => 'hpPreProcessing',
                             'INSTALLDATE' => '2010-06-10 15:52'
                           },
                           {
                             'PUBLISHER' => 'hpdot4d 3.7.2, (c) Copyright 2005-2010 Hewlett-Packard Development Company, L.P.',
                             'NAME' => 'hpdot4d',
                             'INSTALLDATE' => '2010-07-07 14:23',
                             'VERSION' => '3.7.2',
                             'COMMENTS' => '[Intel]'
                           },
                           {
                             'VERSION' => '1.0.1',
                             'COMMENTS' => '[Intel]',
                             'PUBLISHER' => 'HP Photosmart Compact Photo Printer driver 1.0.1, Copyright (c) 2007-2009 Hewlett-Packard Development Company, L.P.',
                             'NAME' => 'hprastertojpeg',
                             'INSTALLDATE' => '2009-03-30 12:51'
                           },
                           {
                             'PUBLISHER' => undef,
                             'NAME' => 'iCal',
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'VERSION' => '4.0.4',
                             'COMMENTS' => '[Universal]'
                           },
                           {
                             'NAME' => 'iCal Helper',
                             'PUBLISHER' => undef,
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'VERSION' => '4.0.4',
                             'COMMENTS' => '[Universal]'
                           },
                           {
                             'INSTALLDATE' => '2010-07-07 14:24',
                             'NAME' => 'iChat',
                             'PUBLISHER' => undef,
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '5.0.3'
                           },
                           {
                             'NAME' => 'iChatAgent',
                             'PUBLISHER' => undef,
                             'INSTALLDATE' => '2010-07-07 14:24',
                             'VERSION' => '5.0.3',
                             'COMMENTS' => '[Intel]'
                           },
                           {
                             'NAME' => 'iMovie',
                             'PUBLISHER' => '7.1.4, Copyright © 2007-2008 Apple Inc. All Rights Reserved.',
                             'INSTALLDATE' => '2009-07-01 15:59',
                             'VERSION' => '7.1.4',
                             'COMMENTS' => '[Universal]'
                           },
                           {
                             'INSTALLDATE' => '2007-02-05 09:16',
                             'PUBLISHER' => 'iStumbler Release 98',
                             'NAME' => 'iStumbler',
                             'COMMENTS' => '[Universal]',
                             'VERSION' => 'Release 98'
                           },
                           {
                             'VERSION' => '3.1.2',
                             'COMMENTS' => '[Intel]',
                             'PUBLISHER' => '3.1.2, Copyright © 2003-2010 Apple Inc.',
                             'NAME' => 'iSync',
                             'INSTALLDATE' => '2011-01-05 17:56'
                           },
                           {
                             'VERSION' => '3.1',
                             'COMMENTS' => '[Universal]',
                             'NAME' => 'iSync Plug-in Maker',
                             'PUBLISHER' => undef,
                             'INSTALLDATE' => '2011-01-05 17:56'
                           },
                           {
                             'PUBLISHER' => '0.10',
                             'NAME' => 'iTerm',
                             'INSTALLDATE' => '2009-10-07 23:14',
                             'VERSION' => '0.10',
                             'COMMENTS' => '[Universal]'
                           },
                           {
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '10.2.1',
                             'INSTALLDATE' => '2011-03-18 12:21',
                             'PUBLISHER' => 'iTunes 10.2.1, © 2000-2011 Apple Inc. All rights reserved.',
                             'NAME' => 'iTunes'
                           },
                           {
                             'PUBLISHER' => '2.0.4, Copyright 2008 Apple Inc.',
                             'NAME' => 'iWeb',
                             'INSTALLDATE' => '2009-07-01 15:59',
                             'VERSION' => '2.0.4',
                             'COMMENTS' => '[Universal]'
                           },
                           {
                             'PUBLISHER' => undef,
                             'NAME' => 'kcSync',
                             'INSTALLDATE' => '2010-07-07 14:24',
                             'VERSION' => '3.0.1',
                             'COMMENTS' => '[Universal]'
                           },
                           {
                             'VERSION' => '6.1.1',
                             'COMMENTS' => '[Universal]',
                             'NAME' => 'loginwindow',
                             'PUBLISHER' => undef,
                             'INSTALLDATE' => '2011-01-05 17:56'
                           },
                           {
                             'PUBLISHER' => 'HP PDF Filter 1.3, Copyright (c) 2001-2009 Hewlett-Packard Development Company, L.P.',
                             'NAME' => 'pdftopdf',
                             'INSTALLDATE' => '2009-04-16 17:20',
                             'VERSION' => '1.3',
                             'COMMENTS' => '[Intel]'
                           },
                           {
                             'PUBLISHER' => 'pdftopdf2 version 8.02, Copyright (C) SEIKO EPSON CORPORATION 2001-2009. All rights reserved.',
                             'NAME' => 'pdftopdf2',
                             'INSTALLDATE' => '2009-07-09 06:55',
                             'VERSION' => '8.02',
                             'COMMENTS' => '[Intel]'
                           },
                           {
                             'VERSION' => '2.3',
                             'COMMENTS' => '[Intel]',
                             'PUBLISHER' => '1.0, Copyright Apple Inc. 2007',
                             'NAME' => 'quicklookd',
                             'INSTALLDATE' => '2011-01-05 17:56'
                           },
                           {
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '2.3',
                             'INSTALLDATE' => '2011-01-05 17:56',
                             'PUBLISHER' => '1.0, Copyright Apple Inc. 2007',
                             'NAME' => 'quicklookd32'
                           },
                           {
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '8.02',
                             'INSTALLDATE' => '2009-07-09 06:55',
                             'NAME' => 'rastertoescpII',
                             'PUBLISHER' => 'rastertoescpII Copyright (C) SEIKO EPSON CORPORATION 2001-2009. All rights reserved.'
                           },
                           {
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '4.1',
                             'INSTALLDATE' => '2010-04-23 11:36',
                             'NAME' => 'rastertofax',
                             'PUBLISHER' => 'HP Fax 4.1, Copyright (c) 2009-2010 Hewlett-Packard Development Company, L.P.'
                           },
                           {
                             'INSTALLDATE' => '2010-07-07 14:24',
                             'PUBLISHER' => '2.6',
                             'NAME' => 'rcd',
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '2.6'
                           },
                           {
                             'COMMENTS' => '[Intel]',
                             'VERSION' => '1.0',
                             'INSTALLDATE' => '2011-02-20 15:34',
                             'PUBLISHER' => undef,
                             'NAME' => 'store_helper'
                           },
                           {
                             'INSTALLDATE' => '2009-07-18 08:22',
                             'NAME' => 'syncuid',
                             'PUBLISHER' => '4.0, Copyright Apple Computer Inc. 2004',
                             'COMMENTS' => '[Universal]',
                             'VERSION' => '5.2'
                           },
                           {
                             'NAME' => 'vpndownloader',
                             'PUBLISHER' => undef,
                             'INSTALLDATE' => '2010-02-15 16:08',
                             'VERSION' => '1.0',
                             'COMMENTS' => '[Intel]'
                           },
                           {
                             'VERSION' => '1.8.1',
                             'COMMENTS' => '[Intel]',
                             'PUBLISHER' => undef,
                             'NAME' => 'webdav_cert_ui',
                             'INSTALLDATE' => '2011-01-05 17:56'
                           },
                           {
                             'NAME' => 'wxPerl',
                             'PUBLISHER' => undef,
                             'INSTALLDATE' => '2009-05-19 08:30',
                             'VERSION' => '1.0',
                             'COMMENTS' => '[Universal]'
                           }
                         ]
);

my $datesStr = {
    "7/8/15 11:11 PM" => '2015-07-08 23:11',
    "7/31/09 9:18 AM" => '2009-07-31 09:18',
    "1/13/10 6:16 PM" => '2010-01-13 18:16',
    "04/09/11 22:42" => '2011-04-09 22:42'
};

plan tests => 2 * scalar (keys %tests)
    + 1
    + scalar (keys %$datesStr)
    + 1;

for my $dateStr (keys %$datesStr) {
    my $formatted = FusionInventory::Agent::Task::Inventory::MacOS::Softwares::_formatDate($dateStr);
    ok ($formatted eq $datesStr->{$dateStr}, "'" . $datesStr->{$dateStr} ."' expected but got '" . $formatted . "'");
}

my $emptyString = FusionInventory::Agent::Task::Inventory::MacOS::Softwares::_formatDate("this string should be a date...");
ok ($emptyString eq '');

my $inventory = FusionInventory::Test::Inventory->new();

foreach my $test (keys %tests) {
    my $file = "resources/macos/system_profiler/$test.SPApplicationsDataType";
    my $softwares = FusionInventory::Agent::Task::Inventory::MacOS::Softwares::_getSoftwaresList(file => $file);
    cmp_deeply(
        [ sort { compare() } @{$softwares} ],
        [ sort { compare() } @{$tests{$test}} ],
        "$test: parsing"
    );
    lives_ok {
        $inventory->addEntry(section => 'SOFTWARES', entry => $_)
            foreach @$softwares;
    } "$test: registering";
}

sub compare {
    return
        $a->{NAME}  cmp $b->{NAME};
}
