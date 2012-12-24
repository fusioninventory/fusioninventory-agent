#!/usr/bin/perl

use strict;
use warnings;

use Test::Deep;
use Test::More;

use FusionInventory::Agent::Task::Inventory::Input::MacOS::Softwares;

my %tests = (
    'sample2' => [
          {
            PUBLISHER => '1.1, Copyright 2007-2008 Apple Inc.',
            NAME      => "Exposé",
            COMMENTS  => '[Universal]',
            VERSION   => '1.1'
          },
          {
            PUBLISHER => undef,
            NAME      => 'g-coul',
            COMMENTS  => '[Universal]',
            VERSION   => '6.5'
          },
          {
            PUBLISHER => undef,
            NAME      => 'ARM Help',
            COMMENTS  => '[Intel]',
            VERSION   => '4.7.3'
          },
          {
            PUBLISHER => 'Vodafone Mobile Connect 3G 2.11.04.00',
            NAME      => 'Vodafone Mobile Connect',
            COMMENTS  => '[Universal]',
            VERSION   => 'Vodafone Mobile Connect 3G 2.11.04'
          },
          {
            PUBLISHER => 'Terminal window application for PPP',
            NAME      => 'MiniTerm',
            COMMENTS  => '[Universal]',
            VERSION   => '1.5'
          },
          {
            PUBLISHER => "1.1.0 (101115), © 2010 Microsoft Corporation. All rights reserved.",
            NAME      => 'Microsoft Ship Asserts',
            COMMENTS  => '[Universal]',
            VERSION   => '1.1.0'
          },
          {
            PUBLISHER => 'SystemUIServer version 1.6, Copyright 2000-2009 Apple Computer, Inc.',
            NAME      => 'SystemUIServer',
            COMMENTS  => '[Intel]',
            VERSION   => '1.6'
          },
          {
            PUBLISHER => undef,
            NAME      => 'VidyoDesktop Uninstaller',
            COMMENTS  => '[Intel]',
            VERSION   => '2.0.0'
          },
          {
            PUBLISHER => '1.1.52, Copyright 2009 Hewlett-Packard Company',
            NAME      => 'HPScanner',
            COMMENTS  => '[Intel]',
            VERSION   => '1.1.52'
          },
          {
            PUBLISHER => "12.2.8 (101117), © 2007 Microsoft Corporation. All rights reserved.",
            NAME      => 'Open XML for Excel',
            COMMENTS  => '[PowerPC]',
            VERSION   => '12.2.8'
          },
          {
            PUBLISHER => 'Apple Hardware Test Read Me',
            NAME      => "À propos d’AHT",
            COMMENTS  => '[Universal]',
            VERSION   => '1.1'
          },
          {
            PUBLISHER => undef,
            NAME      => 'PowerPC Help',
            COMMENTS  => '[Intel]',
            VERSION   => '4.7.3'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Spotlight',
            COMMENTS  => '[Intel]',
            VERSION   => '2.0'
          },
          {
            PUBLISHER => undef,
            NAME      => 'SolidWorks eDrawings',
            COMMENTS  => '[Universal]',
            VERSION   => '1.0A'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Utilitaire AppleScript',
            COMMENTS  => '[Intel]',
            VERSION   => '1.1.1'
          },
          {
            PUBLISHER => "6.0, Copyright © 1997-2006 Apple Computer Inc., All Rights Reserved",
            NAME      => 'KoreanIM',
            COMMENTS  => '[Universal]',
            VERSION   => '6.1'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Java Web Start',
            COMMENTS  => '[Universal]',
            VERSION   => '13.4.0'
          },
          {
            PUBLISHER => undef,
            NAME      => 'SleepX',
            COMMENTS  => '[Intel]',
            VERSION   => '2.7'
          },
          {
            PUBLISHER => 'Canon IJ Printer Utility version 7.17.10, Copyright CANON INC. 2001-2009 All Rights Reserved.',
            NAME      => 'Canon IJ Printer Utility',
            COMMENTS  => '[Intel]',
            VERSION   => '7.17.10'
          },
          {
            PUBLISHER => undef,
            NAME      => 'TextEdit',
            COMMENTS  => '[Intel]',
            VERSION   => '1.6'
          },
          {
            PUBLISHER => undef,
            NAME      => 'SpeechSynthesisServer',
            COMMENTS  => '[Universal]',
            VERSION   => '3.10.35'
          },
          {
            PUBLISHER => "2.0, Copyright © 2004-2009 Apple Inc., All Rights Reserved",
            NAME      => 'KeyboardViewer',
            COMMENTS  => '[Universal]',
            VERSION   => '2.0'
          },
          {
            PUBLISHER => 'Spin Control',
            NAME      => 'Spin Control',
            COMMENTS  => '[Intel]',
            VERSION   => '0.9'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Yap',
            COMMENTS  => undef,
            VERSION   => undef
          },
          {
            PUBLISHER => undef,
            NAME      => 'AddressBookManager',
            COMMENTS  => '[Intel]',
            VERSION   => '2.0.3'
          },
          {
            PUBLISHER => "2.5.4, © 001-2006 Python Software Foundation",
            NAME      => 'Python Launcher',
            COMMENTS  => '[Universal]',
            VERSION   => '2.5.4'
          },
          {
            PUBLISHER => '2.4.2, Copyright 2003-2009 Apple Inc.',
            NAME      => 'Chess',
            COMMENTS  => '[Intel]',
            VERSION   => '2.4.2'
          },
          {
            PUBLISHER => undef,
            NAME      => 'EM64T Help',
            COMMENTS  => '[Intel]',
            VERSION   => '4.7.3'
          },
          {
            PUBLISHER => 'HP Fax 4.1, Copyright (c) 2009-2010 Hewlett-Packard Development Company, L.P.',
            NAME      => 'fax',
            COMMENTS  => '[Intel]',
            VERSION   => '4.1'
          },
          {
            PUBLISHER => "6.5 Copyright © 2008 Massachusetts Institute of Technology",
            NAME      => 'CCacheServer',
            COMMENTS  => '[Universal]',
            VERSION   => '6.5.10'
          },
          {
            PUBLISHER => 'hpdot4d 3.7.2, (c) Copyright 2005-2010 Hewlett-Packard Development Company, L.P.',
            NAME      => 'hpdot4d',
            COMMENTS  => '[Intel]',
            VERSION   => '3.7.2'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Front Row',
            COMMENTS  => '[Universal]',
            VERSION   => '2.2.1'
          },
          {
            PUBLISHER => "6.0, © Copyright 2001-2009 Apple Inc., all rights reserved.",
            NAME      => 'Type5Camera',
            COMMENTS  => '[Universal]',
            VERSION   => '6.0'
          },
          {
            PUBLISHER => undef,
            NAME      => 'SyncDiagnostics',
            COMMENTS  => '[Universal]',
            VERSION   => '5.2'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Accessibility Verifier',
            COMMENTS  => '[Intel]',
            VERSION   => '1.2'
          },
          {
            PUBLISHER => undef,
            NAME      => 'eaptlstrust',
            COMMENTS  => '[Universal]',
            VERSION   => '10.0'
          },
          {
            PUBLISHER => undef,
            NAME      => 'DivX Player',
            COMMENTS  => '[Intel]',
            VERSION   => '7.2 (build 10_0_0_183)'
          },
          {
            PUBLISHER => undef,
            NAME      => 'PreferenceSyncClient',
            COMMENTS  => '[Universal]',
            VERSION   => '2.0'
          },
          {
            PUBLISHER => "RAID Utility 1.0 (121), Copyright © 2007-2009 Apple Inc.",
            NAME      => 'Utilitaire RAID',
            COMMENTS  => '[Intel]',
            VERSION   => '1.2'
          },
          {
            PUBLISHER => 'pdftopdf2 version 8.02, Copyright (C) SEIKO EPSON CORPORATION 2001-2009. All rights reserved.',
            NAME      => 'pdftopdf2',
            COMMENTS  => '[Intel]',
            VERSION   => '8.02'
          },
          {
            PUBLISHER => '2.3.8, Copyright (c) 2010 Apple Inc. All rights reserved.',
            NAME      => 'BluetoothAudioAgent',
            COMMENTS  => '[Universal]',
            VERSION   => '2.3.8'
          },
          {
            PUBLISHER => 'Chinese Text Converter 1.1',
            NAME      => 'ChineseTextConverterService',
            COMMENTS  => '[Intel]',
            VERSION   => '1.2'
          },
          {
            PUBLISHER => "6.0, © Copyright 2000-2009 Apple Inc., all rights reserved.",
            NAME      => 'Type2Camera',
            COMMENTS  => '[Universal]',
            VERSION   => '6.0'
          },
          {
            PUBLISHER => undef,
            NAME      => 'PMC Index',
            COMMENTS  => '[Universal]',
            VERSION   => '4.5.0'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Set Info',
            COMMENTS  => '[Universal]',
            VERSION   => undef
          },
          {
            PUBLISHER => undef,
            NAME      => 'VidyoDesktop',
            COMMENTS  => '[Intel]',
            VERSION   => '1.0'
          },
          {
            PUBLISHER => '1.0, Copyright 2008 Lexmark International, Inc. All rights reserved.',
            NAME      => 'Utilitaire de l\'imprimante Lexmark',
            COMMENTS  => '[Intel]',
            VERSION   => '1.2.10'
          },
          {
            PUBLISHER => '4.6, Copyright 2008 Apple Computer, Inc.',
            NAME      => "Outil d’étalonnage du moniteur",
            COMMENTS  => '[Intel]',
            VERSION   => '4.6'
          },
          {
            PUBLISHER => 'HP Inkjet 8 Driver 2.1, Copyright (c) 1994-2009 Hewlett-Packard Development Company, L.P.',
            NAME      => 'Inkjet8',
            COMMENTS  => '[Intel]',
            VERSION   => '2.1'
          },
          {
            PUBLISHER => '1.0.0, Copyright CANON INC. 2009 All Rights Reserved',
            NAME      => 'Canon IJScanner1',
            COMMENTS  => '[Intel]',
            VERSION   => '1.0.0'
          },
          {
            PUBLISHER => undef,
            NAME      => 'SRLanguageModeler',
            COMMENTS  => '[Intel]',
            VERSION   => '1.9'
          },
          {
            PUBLISHER => '2.3.8, Copyright (c) 2010 Apple Inc. All rights reserved.',
            NAME      => 'OBEXAgent',
            COMMENTS  => '[Universal]',
            VERSION   => '2.3.8'
          },
          {
            PUBLISHER => undef,
            NAME      => 'h-coul',
            COMMENTS  => '[Universal]',
            VERSION   => '6.5'
          },
          {
            PUBLISHER => '6.0.11994.637942, Copyright 2005-2011 Parallels Holdings, Ltd. and its affiliates',
            NAME      => 'Parallels Mounter',
            COMMENTS  => '[Intel]',
            VERSION   => '6.0'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Photo Booth',
            COMMENTS  => '[Intel]',
            VERSION   => '3.0.3'
          },
          {
            PUBLISHER => "6.0, © Copyright 2000-2009 Apple Inc., all rights reserved.",
            NAME      => 'AutoImporter',
            COMMENTS  => '[Intel]',
            VERSION   => '6.0.1'
          },
          {
            PUBLISHER => undef,
            NAME      => 'DiskImageMounter',
            COMMENTS  => '[Intel]',
            VERSION   => '10.6.5'
          },
          {
            PUBLISHER => "7.6.6, Copyright © 1989-2009 Apple Inc. All Rights Reserved",
            NAME      => 'QuickTime Player 7',
            COMMENTS  => '[Intel]',
            VERSION   => '7.6.6'
          },
          {
            PUBLISHER => 'HP Inkjet 4 Driver 2.2, Copyright (c) 1994-2009 Hewlett-Packard Development Company, L.P.',
            NAME      => 'Inkjet4',
            COMMENTS  => '[Intel]',
            VERSION   => '2.2'
          },
          {
            PUBLISHER => '0.10',
            NAME      => 'iTerm',
            COMMENTS  => '[Universal]',
            VERSION   => '0.10'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Yahoo! Sync',
            COMMENTS  => '[Universal]',
            VERSION   => '1.3'
          },
          {
            PUBLISHER => "Software Update version 4.0, Copyright © 2000-2009, Apple Inc. All rights reserved.",
            NAME      => "Mise à jour de logiciels",
            COMMENTS  => '[Universal]',
            VERSION   => '4.0.6'
          },
          {
            PUBLISHER => undef,
            NAME      => 'DiskImages UI Agent',
            COMMENTS  => '[Intel]',
            VERSION   => '287'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Quartz Composer Visualizer',
            COMMENTS  => '[Intel]',
            VERSION   => '1.2'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Grapher',
            COMMENTS  => '[Intel]',
            VERSION   => '2.1'
          },
          {
            PUBLISHER => "12.1.0 (080205), © 2007 Microsoft Corporation.  All rights reserved.",
            NAME      => 'Equation Editor',
            COMMENTS  => '[Universal]',
            VERSION   => '12.1.0'
          },
          {
            PUBLISHER => 'CIJScannerRegister version 1.0.0, Copyright CANON INC. 2009 All Rights Reserved.',
            NAME      => 'CIJScannerRegister',
            COMMENTS  => '[Intel]',
            VERSION   => '1.0.0'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Embed',
            COMMENTS  => '[Universal]',
            VERSION   => undef
          },
          {
            PUBLISHER => "InstallAnywhere 8.0, Copyright © 2006 Macrovision Corporation.",
            NAME      => 'Uninstall Cisco Network Assistant',
            COMMENTS  => '[Universal]',
            VERSION   => '8.0'
          },
          {
            PUBLISHER => "14.0.2 (101115), © 2010 Microsoft Corporation. All rights reserved.",
            NAME      => "Centre de téléchargement Microsoft",
            COMMENTS  => '[Intel]',
            VERSION   => '14.0.2'
          },
          {
            PUBLISHER => undef,
            NAME      => 'VPNClient',
            COMMENTS  => '[Universal]',
            VERSION   => '4.9.01.0180'
          },
          {
            PUBLISHER => 'iStumbler Release 98',
            NAME      => 'iStumbler',
            COMMENTS  => '[Universal]',
            VERSION   => 'Release 98'
          },
          {
            PUBLISHER => '2.3.8, Copyright (c) 2010 Apple Inc. All rights reserved.',
            NAME      => "Assistant réglages Bluetooth",
            COMMENTS  => '[Universal]',
            VERSION   => '2.3.8'
          },
          {
            PUBLISHER => undef,
            NAME      => 'SecurityFixer',
            COMMENTS  => '[Intel]',
            VERSION   => '10.6'
          },
          {
            PUBLISHER => "6.0, © Copyright 2000-2009 Apple Inc., all rights reserved.",
            NAME      => 'Type1Camera',
            COMMENTS  => '[Universal]',
            VERSION   => '6.0'
          },
          {
            PUBLISHER => undef,
            NAME      => 'dotmacfx',
            COMMENTS  => '[Universal]',
            VERSION   => '3.0'
          },
          {
            PUBLISHER => '0.0.0 (v27), Copyright 2008 Lexmark International, Inc. All rights reserved.',
            NAME      => 'LexmarkCUPSDriver',
            COMMENTS  => '[Intel]',
            VERSION   => '1.1.26'
          },
          {
            PUBLISHER => undef,
            NAME      => 'IA32 Help',
            COMMENTS  => '[Intel]',
            VERSION   => '4.7.3'
          },
          {
            PUBLISHER => "6.0, © Copyright 2002-2009 Apple Inc., all rights reserved.",
            NAME      => 'Type6Camera',
            COMMENTS  => '[Universal]',
            VERSION   => '6.0'
          },
          {
            PUBLISHER => '2.3.8, Copyright (c) 2010 Apple Inc. All rights reserved.',
            NAME      => 'BluetoothUIServer',
            COMMENTS  => '[Universal]',
            VERSION   => '2.3.8'
          },
          {
            PUBLISHER => undef,
            NAME      => 'DivX Products',
            COMMENTS  => '[PowerPC]',
            VERSION   => '1.1.0'
          },
          {
            PUBLISHER => "Copyright © 2008 Apple Inc.",
            NAME      => 'FontRegistryUIAgent',
            COMMENTS  => '[Intel]',
            VERSION   => '1.1'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Database Events',
            COMMENTS  => '[Intel]',
            VERSION   => '1.0.4'
          },
          {
            PUBLISHER => '2.3.6, Copyright (c) 2010 Apple Inc. All rights reserved.',
            NAME      => 'Bluetooth Explorer',
            COMMENTS  => '[Universal]',
            VERSION   => '2.3.6'
          },
          {
            PUBLISHER => "12.2.8 (101117), © 2007 Microsoft Corporation. All rights reserved.",
            NAME      => 'Rappels Microsoft Office',
            COMMENTS  => '[Universal]',
            VERSION   => '12.2.8'
          },
          {
            PUBLISHER => "12.2.8 (101117), © 2007 Microsoft Corporation. All rights reserved.",
            NAME      => 'Microsoft PowerPoint',
            COMMENTS  => '[Universal]',
            VERSION   => '12.2.8'
          },
          {
            PUBLISHER => 'HP Compact Photosmart Driver 3.0, Copyright (c) 1994-2009 Hewlett-Packard Development Company, L.P.',
            NAME      => 'CompactPhotosmart',
            COMMENTS  => '[Intel]',
            VERSION   => '3.0'
          },
          {
            PUBLISHER => undef,
            NAME      => 'SpeakableItems',
            COMMENTS  => '[Intel]',
            VERSION   => '3.7.8'
          },
          {
            PUBLISHER => undef,
            NAME      => 'MemoryCard Ejector',
            COMMENTS  => '[PowerPC]',
            VERSION   => '1.1'
          },
          {
            PUBLISHER => "Copyright © 2009 Apple Inc.",
            NAME      => 'CoreServicesUIAgent',
            COMMENTS  => '[Intel]',
            VERSION   => '41.5'
          },
          {
            PUBLISHER => undef,
            NAME      => "Moniteur d’activité",
            COMMENTS  => '[Intel]',
            VERSION   => '10.6'
          },
          {
            PUBLISHER => 'HP Inkjet 1 Driver 2.1.2, Copyright (c) 1994-2009 Hewlett-Packard Development Company, L.P.',
            NAME      => 'Inkjet1',
            COMMENTS  => '[Intel]',
            VERSION   => '2.1.2'
          },
          {
            PUBLISHER => 'Tamil Input Method 1.2',
            NAME      => 'TamilIM',
            COMMENTS  => '[Intel]',
            VERSION   => '1.3'
          },
          {
            PUBLISHER => "Syncrospector 3.0, © 2004 Apple Computer, Inc., All rights reserved.",
            NAME      => 'Syncrospector',
            COMMENTS  => '[Universal]',
            VERSION   => '5.2'
          },
          {
            PUBLISHER => undef,
            NAME      => "Trousseau d’accès",
            COMMENTS  => '[Intel]',
            VERSION   => '4.1'
          },
          {
            PUBLISHER => undef,
            NAME      => 'UserNotificationCenter',
            COMMENTS  => '[Intel]',
            VERSION   => '3.1.0'
          },
          {
            PUBLISHER => undef,
            NAME      => 'SecurityAgent',
            COMMENTS  => '[Universal]',
            VERSION   => '5.2'
          },
          {
            PUBLISHER => 'HP Photosmart Pro Driver 3.0, Copyright (c) 1994-2009 Hewlett-Packard Development Company, L.P.',
            NAME      => 'PhotosmartPro',
            COMMENTS  => '[Intel]',
            VERSION   => '3.0'
          },
          {
            PUBLISHER => undef,
            NAME      => 'ScreenReaderUIServer',
            COMMENTS  => '[Universal]',
            VERSION   => '3.4.0'
          },
          {
            PUBLISHER => undef,
            NAME      => 'ZoneMonitor',
            COMMENTS  => '[Universal]',
            VERSION   => '1.0'
          },
          {
            PUBLISHER => undef,
            NAME      => 'AppleMobileDeviceHelper',
            COMMENTS  => '[Universal]',
            VERSION   => '3.1'
          },
          {
            PUBLISHER => "6.0.1, © Copyright 2000-2010 Apple Inc., all rights reserved.",
            NAME      => 'TWAINBridge',
            COMMENTS  => '[Universal]',
            VERSION   => '6.0.1'
          },
          {
            PUBLISHER => undef,
            NAME      => "Éditeur AppleScript",
            COMMENTS  => '[Intel]',
            VERSION   => '2.3'
          },
          {
            PUBLISHER => undef,
            NAME      => "Lanceur d’applets",
            COMMENTS  => '[Universal]',
            VERSION   => '13.4.0'
          },
          {
            PUBLISHER => undef,
            NAME      => 'SpindownHD',
            COMMENTS  => '[Intel]',
            VERSION   => '4.7.3'
          },
          {
            PUBLISHER => undef,
            NAME      => 'FileMerge',
            COMMENTS  => '[Intel]',
            VERSION   => '2.5'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Clipboard Viewer',
            COMMENTS  => '[Universal]',
            VERSION   => '1.3'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Jar Bundler',
            COMMENTS  => '[Universal]',
            VERSION   => '13.4.0'
          },
          {
            PUBLISHER => '2.5.4a0, (c) 2004 Python Software Foundation.',
            NAME      => 'Python',
            COMMENTS  => '[Universal]',
            VERSION   => '2.5.4'
          },
          {
            PUBLISHER => "6.0.1, © Copyright 2002-2009 Apple Inc., all rights reserved.",
            NAME      => 'Type8Camera',
            COMMENTS  => '[Universal]',
            VERSION   => '6.0.1'
          },
          {
            PUBLISHER => undef,
            NAME      => 'NetAuthAgent',
            COMMENTS  => '[Universal]',
            VERSION   => '2.1'
          },
          {
            PUBLISHER => "14.0.2 (101115), © 2010 Microsoft Corporation. All rights reserved.",
            NAME      => "Utilitaire de base de données Microsoft",
            COMMENTS  => '[Intel]',
            VERSION   => '14.0.2'
          },
          {
            PUBLISHER => 'commandtoescp Copyright (C) SEIKO EPSON CORPORATION 2001-2009. All rights reserved.',
            NAME      => 'commandtoescp',
            COMMENTS  => '[Intel]',
            VERSION   => '8.02'
          },
          {
            PUBLISHER => "12.2.8 (101117), © 2007 Microsoft Corporation. All rights reserved.",
            NAME      => 'Microsoft Word',
            COMMENTS  => '[Universal]',
            VERSION   => '12.2.8'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Application Loader',
            COMMENTS  => '[Intel]',
            VERSION   => '1.4'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Instruments',
            COMMENTS  => '[Intel]',
            VERSION   => '2.7'
          },
          {
            PUBLISHER => "5.4, Copyright © 2001-2010 by Apple Inc.  All Rights Reserved.",
            NAME      => 'Lecteur DVD',
            COMMENTS  => '[Intel]',
            VERSION   => '5.4'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Keychain Scripting',
            COMMENTS  => '[Universal]',
            VERSION   => '4.0.2'
          },
          {
            PUBLISHER => undef,
            NAME      => 'SpeechService',
            COMMENTS  => '[Universal]',
            VERSION   => '3.10.35'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Jar Launcher',
            COMMENTS  => '[Universal]',
            VERSION   => '13.4.0'
          },
          {
            PUBLISHER => 'Version 2.0.3, Copyright Apple Inc., 2008',
            NAME      => 'AppleGraphicsWarning',
            COMMENTS  => '[Intel]',
            VERSION   => '2.0.3'
          },
          {
            PUBLISHER => '3.0.3, Copyright 2002-2010 Apple, Inc.',
            NAME      => 'Configuration audio et MIDI',
            COMMENTS  => '[Intel]',
            VERSION   => '3.0.3'
          },
          {
            PUBLISHER => "6.0.2, © Copyright 2000-2010 Apple Inc. All rights reserved.",
            NAME      => 'Image Capture Extension',
            COMMENTS  => '[Universal]',
            VERSION   => '6.0.2'
          },
          {
            PUBLISHER => "Remote Install Mac OS X 1.1.1, Copyright © 2007-2009 Apple Inc. All rights reserved",
            NAME      => "Installation à distance de Mac OS X",
            COMMENTS  => '[Intel]',
            VERSION   => '1.1.1'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Match',
            COMMENTS  => '[Universal]',
            VERSION   => undef
          },
          {
            PUBLISHER => 'rastertoescpII Copyright (C) SEIKO EPSON CORPORATION 2001-2009. All rights reserved.',
            NAME      => 'rastertoescpII',
            COMMENTS  => '[Intel]',
            VERSION   => '8.02'
          },
          {
            PUBLISHER => undef,
            NAME      => 'System Events',
            COMMENTS  => '[Intel]',
            VERSION   => '1.3.4'
          },
          {
            PUBLISHER => undef,
            NAME      => 'IncompatibleAppDisplay',
            COMMENTS  => '[Universal]',
            VERSION   => '300.4'
          },
          {
            PUBLISHER => "6.2, Copyright © 1997-2006 Apple Computer Inc., All Rights Reserved",
            NAME      => 'TCIM',
            COMMENTS  => '[Universal]',
            VERSION   => '6.3'
          },
          {
            PUBLISHER => "Version 1.4.6, Copyright © 2000-2009 Apple Inc. All rights reserved.",
            NAME      => "Utilitaire de réseau",
            COMMENTS  => '[Intel]',
            VERSION   => '1.4.6'
          },
          {
            PUBLISHER => undef,
            NAME      => 'iChatAgent',
            COMMENTS  => '[Intel]',
            VERSION   => '5.0.3'
          },
          {
            PUBLISHER => undef,
            NAME      => 'iCal Helper',
            COMMENTS  => '[Universal]',
            VERSION   => '4.0.4'
          },
          {
            PUBLISHER => "7.1.4, Copyright © 2007-2008 Apple Inc. All Rights Reserved.",
            NAME      => 'iMovie',
            COMMENTS  => '[Universal]',
            VERSION   => '7.1.4'
          },
          {
            PUBLISHER => '6.0.11994.637942, Copyright 2005-2011 Parallels Holdings, Ltd. and its affiliates',
            NAME      => 'Parallels Desktop',
            COMMENTS  => '[Intel]',
            VERSION   => '6.0'
          },
          {
            PUBLISHER => "14.0.2 (101115), © 2010 Microsoft Corporation. All rights reserved.",
            NAME      => 'Microsoft Clip Gallery',
            COMMENTS  => '[Intel]',
            VERSION   => '14.0.2'
          },
          {
            PUBLISHER => 'Zimbra Desktop 1.0.4, (C) 2010 VMware Inc.',
            NAME      => 'Zimbra Desktop',
            COMMENTS  => '[Intel]',
            VERSION   => '1.0.4'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Console',
            COMMENTS  => '[Intel]',
            VERSION   => '10.6.3'
          },
          {
            PUBLISHER => "12.2.8 (101117), © 2007 Microsoft Corporation. All rights reserved.",
            NAME      => "Organigramme hiérarchique",
            COMMENTS  => '[Universal]',
            VERSION   => '12.2.8'
          },
          {
            PUBLISHER => "GarageBand 4.1.2 (248.7), Copyright © 2007 by Apple Inc.",
            NAME      => 'GarageBand',
            COMMENTS  => '[Universal]',
            VERSION   => '4.1.2'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Capture',
            COMMENTS  => '[Intel]',
            VERSION   => '1.5'
          },
          {
            PUBLISHER => "© Copyright 2009 Apple Inc., all rights reserved.",
            NAME      => 'File Sync',
            COMMENTS  => '[Intel]',
            VERSION   => '5.0.3'
          },
          {
            PUBLISHER => undef,
            NAME      => 'PSPP',
            COMMENTS  => undef,
            VERSION   => '@VERSION@'
          },
          {
            PUBLISHER => '1.0, Copyright Apple Computer Inc. 2004',
            NAME      => "Résolution des conflits",
            COMMENTS  => '[Universal]',
            VERSION   => '5.2'
          },
          {
            PUBLISHER => 'HP Inkjet 5 Driver 2.1, Copyright (c) 1994-2009 Hewlett-Packard Development Company, L.P.',
            NAME      => 'Inkjet5',
            COMMENTS  => '[Intel]',
            VERSION   => '2.1'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Meeting Center',
            COMMENTS  => '[Intel]',
            VERSION   => '3.9.14.0'
          },
          {
            PUBLISHER => "2.3.1 (101115), © 2010 Microsoft Corporation. All rights reserved.",
            NAME      => 'Microsoft AutoUpdate',
            COMMENTS  => '[Universal]',
            VERSION   => '2.3.1'
          },
          {
            PUBLISHER => "12.2.8 (101117), © 2007 Microsoft Corporation. All rights reserved.",
            NAME      => 'Microsoft Cert Manager',
            COMMENTS  => '[Universal]',
            VERSION   => '12.2.8'
          },
          {
            PUBLISHER => "12.2.8 (101117), © 2007 Microsoft Corporation. All rights reserved.",
            NAME      => 'Microsoft Database Utility',
            COMMENTS  => '[Universal]',
            VERSION   => '12.2.8'
          },
          {
            PUBLISHER => "6.0, © Copyright 2003-2009 Apple  Inc., all rights reserved.",
            NAME      => "Création de page Web",
            COMMENTS  => '[Universal]',
            VERSION   => '6.0'
          },
          {
            PUBLISHER => '1.0, Copyright 2008 Apple Inc.',
            NAME      => 'InkServer',
            COMMENTS  => '[Intel]',
            VERSION   => '1.0'
          },
          {
            PUBLISHER => '5.5.2, Copyright 2001-2010 Apple Inc.',
            NAME      => 'Utilitaire AirPort',
            COMMENTS  => '[Universal]',
            VERSION   => '5.5.2'
          },
          {
            PUBLISHER => 'HP Printer Utility version 8.1.0, Copyright (c) 2005-2010 Hewlett-Packard Development Company, L.P.',
            NAME      => 'HP Printer Utility',
            COMMENTS  => '[Intel]',
            VERSION   => '8.1.0'
          },
          {
            PUBLISHER => "4.6.2, © Copyright 2009 Apple Inc.",
            NAME      => 'Utilitaire ColorSync',
            COMMENTS  => '[Intel]',
            VERSION   => '4.6.2'
          },
          {
            PUBLISHER => 'Wish Shell 8.4.19,',
            NAME      => 'Wish',
            COMMENTS  => '[Intel]',
            VERSION   => '8.4.19'
          },
          {
            PUBLISHER => undef,
            NAME      => 'CrashReporterPrefs',
            COMMENTS  => '[Universal]',
            VERSION   => '10.6.3'
          },
          {
            PUBLISHER => undef,
            NAME      => 'KeyboardSetupAssistant',
            COMMENTS  => '[Intel]',
            VERSION   => '10.5.0'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Property List Editor',
            COMMENTS  => '[Universal]',
            VERSION   => '5.3'
          },
          {
            PUBLISHER => "12.2.8 (101117), © 2007 Microsoft Corporation. All rights reserved.",
            NAME      => 'Microsoft Entourage',
            COMMENTS  => '[Universal]',
            VERSION   => '12.2.8'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Folder Actions Dispatcher',
            COMMENTS  => '[Intel]',
            VERSION   => '1.0.2'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Reggie SE',
            COMMENTS  => '[Intel]',
            VERSION   => '4.7.3'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Mail',
            COMMENTS  => '[Intel]',
            VERSION   => '4.4'
          },
          {
            PUBLISHER => 'Quartz Debug 4.1',
            NAME      => 'Quartz Debug',
            COMMENTS  => '[Intel]',
            VERSION   => '4.1'
          },
          {
            PUBLISHER => "6.2.1, Copyright © 2000–2009 Apple Inc. All rights reserved.",
            NAME      => 'Apple80211Agent',
            COMMENTS  => '[Universal]',
            VERSION   => '6.2.1'
          },
          {
            PUBLISHER => '10.0.0 (1204)  Copyright 1995-2002 Microsoft Corporation.  All rights reserved.',
            NAME      => 'Microsoft Query',
            COMMENTS  => '[PowerPC]',
            VERSION   => '10.0.0'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Free42-Binary',
            COMMENTS  => undef,
            VERSION   => undef
          },
          {
            PUBLISHER => "AFP Client Session Monitor, Copyright © 2000 - 2007, Apple Inc.",
            NAME      => 'check_afp',
            COMMENTS  => '[Universal]',
            VERSION   => '2.0'
          },
          {
            PUBLISHER => "12.2.8 (101117), © 2007 Microsoft Corporation. All rights reserved.",
            NAME      => 'Microsoft Graph',
            COMMENTS  => '[Universal]',
            VERSION   => '12.2.8'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Raster2CanonIJ',
            COMMENTS  => undef,
            VERSION   => undef
          },
          {
            PUBLISHER => undef,
            NAME      => 'Dictionnaire',
            COMMENTS  => '[Intel]',
            VERSION   => '2.1.3'
          },
          {
            PUBLISHER => "Oracle VM VirtualBox Manager 4.0.4, © 2007-2011 Oracle Corporation",
            NAME      => 'VirtualBox',
            COMMENTS  => '[Intel]',
            VERSION   => '4.0.4'
          },
          {
            PUBLISHER => undef,
            NAME      => 'DivX Support',
            COMMENTS  => '[PowerPC]',
            VERSION   => '1.1.0'
          },
          {
            PUBLISHER => 'Dock 1.7',
            NAME      => 'Dock',
            COMMENTS  => '[Intel]',
            VERSION   => '1.7'
          },
          {
            PUBLISHER => "6.0, © Copyright 2003-2009 Apple Inc., all rights reserved.",
            NAME      => 'ImageCaptureService',
            COMMENTS  => '[Intel]',
            VERSION   => '6.0.1'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Uninstall AnyConnect',
            COMMENTS  => '[Universal]',
            VERSION   => '1.0'
          },
          {
            PUBLISHER => undef,
            NAME      => "Préférences Java",
            COMMENTS  => '[Universal]',
            VERSION   => '13.4.0'
          },
          {
            PUBLISHER => '2.3.6, Copyright (c) 2010 Apple Inc. All rights reserved.',
            NAME      => 'Bluetooth Diagnostics Utility',
            COMMENTS  => '[Universal]',
            VERSION   => '2.3.6'
          },
          {
            PUBLISHER => 'HP Inkjet Driver 3.0, Copyright (c) 1994-2009 Hewlett-Packard Development Company, L.P.',
            NAME      => 'Inkjet',
            COMMENTS  => '[Intel]',
            VERSION   => '3.0'
          },
          {
            PUBLISHER => "2.1.1, Copyright © 2004-2009 Apple Inc. All rights reserved.",
            NAME      => 'Automator',
            COMMENTS  => '[Intel]',
            VERSION   => '2.1.1'
          },
          {
            PUBLISHER => 'iMovie 08 Getting Started',
            NAME      => 'Premiers contacts avec iMovie 08',
            COMMENTS  => '[Universal]',
            VERSION   => '1.0.2'
          },
          {
            PUBLISHER => undef,
            NAME      => 'store_helper',
            COMMENTS  => '[Intel]',
            VERSION   => '1.0'
          },
          {
            PUBLISHER => 'Copyright 2010 Hewlett-Packard Company',
            NAME      => 'HP Scanner 3',
            COMMENTS  => '[Universal]',
            VERSION   => '3.2.9'
          },
          {
            PUBLISHER => 'License',
            NAME      => 'License',
            COMMENTS  => '[Universal]',
            VERSION   => '11'
          },
          {
            PUBLISHER => '3.7.2, Copyright 2001-2008 Apple Inc. All Rights Reserved.',
            NAME      => "Colorimètre numérique",
            COMMENTS  => '[Intel]',
            VERSION   => '3.7.2'
          },
          {
            PUBLISHER => 'Welcome to Leopard',
            NAME      => 'Bienvenue sur Leopard',
            COMMENTS  => '[Universal]',
            VERSION   => '8.1'
          },
          {
            PUBLISHER => "2.1.0 (100825), © 2010 Microsoft Corporation. All rights reserved.",
            NAME      => "Connexion Bureau à Distance",
            COMMENTS  => '[Intel]',
            VERSION   => '2.1.0'
          },
          {
            PUBLISHER => undef,
            NAME      => '50onPaletteServer',
            COMMENTS  => '[Universal]',
            VERSION   => '1.0.3'
          },
          {
            PUBLISHER => "URL Access Scripting 1.1, Copyright © 2002-2004 Apple Computer, Inc.",
            NAME      => 'URL Access Scripting',
            COMMENTS  => '[Universal]',
            VERSION   => '1.1.1'
          },
          {
            PUBLISHER => undef,
            NAME      => 'PubSubAgent',
            COMMENTS  => '[Universal]',
            VERSION   => '1.0.5'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Saturn',
            COMMENTS  => '[Intel]',
            VERSION   => '4.7.3'
          },
          {
            PUBLISHER => undef,
            NAME      => 'VietnameseIM',
            COMMENTS  => '[Universal]',
            VERSION   => '1.1'
          },
          {
            PUBLISHER => undef,
            NAME      => 'kcSync',
            COMMENTS  => '[Universal]',
            VERSION   => '3.0.1'
          },
          {
            PUBLISHER => undef,
            NAME      => 'asannotation2',
            COMMENTS  => '[Intel]',
            VERSION   => '7.19.11.0'
          },
          {
            PUBLISHER => undef,
            NAME      => 'App Store',
            COMMENTS  => '[Intel]',
            VERSION   => '1.0'
          },
          {
            PUBLISHER => '5.0.1, Copyright 2002-2009 Apple Inc.',
            NAME      => "Aperçu",
            COMMENTS  => '[Intel]',
            VERSION   => '5.0.3'
          },
          {
            PUBLISHER => 'iWeb Getting Started',
            NAME      => 'Premiers contacts avec iWeb',
            COMMENTS  => '[Universal]',
            VERSION   => '1.0.2'
          },
          {
            PUBLISHER => '2.5.4a0, (c) 2004 Python Software Foundation.',
            NAME      => 'Build Applet',
            COMMENTS  => undef,
            VERSION   => '2.5.4'
          },
          {
            PUBLISHER => undef,
            NAME      => "Diagnostic réseau",
            COMMENTS  => '[Universal]',
            VERSION   => '1.1.3'
          },
          {
            PUBLISHER => "Copyright © 2009 Apple Inc.",
            NAME      => 'CoreLocationAgent',
            COMMENTS  => '[Universal]',
            VERSION   => '12.1'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Show Info',
            COMMENTS  => '[Universal]',
            VERSION   => undef
          },
          {
            PUBLISHER => "Skype version 2.8.0.851 (16248), Copyright © 2004-2010 Skype Technologies S.A.",
            NAME      => 'Skype',
            COMMENTS  => '[Universal]',
            VERSION   => '2.8.0.851'
          },
          {
            PUBLISHER => undef,
            NAME      => "Préférences Système",
            COMMENTS  => '[Universal]',
            VERSION   => '7.0'
          },
          {
            PUBLISHER => "12.2.8 (101117), © 2007 Microsoft Corporation. All rights reserved.",
            NAME      => 'Microsoft Sync Services',
            COMMENTS  => '[Universal]',
            VERSION   => '12.2.8'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Java VisualVM',
            COMMENTS  => '[Universal]',
            VERSION   => '13.4.0'
          },
          {
            PUBLISHER => undef,
            NAME      => 'h-nb1',
            COMMENTS  => '[Universal]',
            VERSION   => '6.5'
          },
          {
            PUBLISHER => 'Thunderbird 3.1.9',
            NAME      => 'Thunderbird',
            COMMENTS  => '[Universal]',
            VERSION   => '3.1.9'
          },
          {
            PUBLISHER => undef,
            NAME      => 'HALLab',
            COMMENTS  => '[Intel]',
            VERSION   => '1.6'
          },
          {
            PUBLISHER => 'HP Inkjet 6 Driver 1.0, Copyright (c) 1994-2009 Hewlett-Packard Development Company, L.P.',
            NAME      => 'Inkjet6',
            COMMENTS  => '[Intel]',
            VERSION   => '1.0'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Cisco AnyConnect VPN Client',
            COMMENTS  => '[Intel]',
            VERSION   => '1.0'
          },
          {
            PUBLISHER => undef,
            NAME      => 'CHUD Remover',
            COMMENTS  => '[Intel]',
            VERSION   => '4.7.3'
          },
          {
            PUBLISHER => undef,
            NAME      => 'DivXUpdater',
            COMMENTS  => '[Universal]',
            VERSION   => '1.1'
          },
          {
            PUBLISHER => 'Accessibility Inspector 2.0, Copyright 2002-2009 Apple Inc.',
            NAME      => 'Accessibility Inspector',
            COMMENTS  => '[Intel]',
            VERSION   => '2.0'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Utilitaire VoiceOver',
            COMMENTS  => '[Universal]',
            VERSION   => '3.4.0'
          },
          {
            PUBLISHER => undef,
            NAME      => 'CharacterPalette',
            COMMENTS  => '[Universal]',
            VERSION   => '1.0.4'
          },
          {
            PUBLISHER => 'EPIJAutoSetupTool2 Copyright (C) SEIKO EPSON CORPORATION 2001-2009. All rights reserved.',
            NAME      => 'EPIJAutoSetupTool2',
            COMMENTS  => '[Intel]',
            VERSION   => '8.02'
          },
          {
            PUBLISHER => undef,
            NAME      => 'VoiceOver',
            COMMENTS  => '[Universal]',
            VERSION   => '3.4.0'
          },
          {
            PUBLISHER => 'v1.9.2.1599. Copyright 2007-2009 Google Inc. All rights reserved.',
            NAME      => 'GoogleVoiceAndVideoUninstaller',
            COMMENTS  => '[Universal]',
            VERSION   => '1.9.2.1599'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Lexmark Scanner',
            COMMENTS  => '[Intel]',
            VERSION   => '3.2.45'
          },
          {
            PUBLISHER => undef,
            NAME      => 'AddPrinter',
            COMMENTS  => '[Intel]',
            VERSION   => '6.5'
          },
          {
            PUBLISHER => "1.1, Copyright © 2006-2009 Apple Inc. All rights reserved.",
            NAME      => 'Automator Runner',
            COMMENTS  => '[Intel]',
            VERSION   => '1.1'
          },
          {
            PUBLISHER => undef,
            NAME      => 'MallocDebug',
            COMMENTS  => '[Universal]',
            VERSION   => '1.7.1'
          },
          {
            PUBLISHER => "12.2.8 (101117), © 2007 Microsoft Corporation. All rights reserved.",
            NAME      => "Bibliothèque de projets Microsoft",
            COMMENTS  => '[Universal]',
            VERSION   => '12.2.8'
          },
          {
            PUBLISHER => undef,
            NAME      => 'SpeechFeedbackWindow',
            COMMENTS  => '[Intel]',
            VERSION   => '3.8.1'
          },
          {
            PUBLISHER => "12.2.8 (101117), © 2007 Microsoft Corporation. All rights reserved.",
            NAME      => 'Alerts Daemon',
            COMMENTS  => '[Universal]',
            VERSION   => '12.2.8'
          },
          {
            PUBLISHER => 'CIJAutoSetupTool.app version 1.7.0, Copyright CANON INC. 2007-2008 All Rights Reserved.',
            NAME      => 'CIJAutoSetupTool',
            COMMENTS  => '[Intel]',
            VERSION   => '1.7.1'
          },
          {
            PUBLISHER => undef,
            NAME      => 'DivX Converter',
            COMMENTS  => '[Universal]',
            VERSION   => '1.3'
          },
          {
            PUBLISHER => undef,
            NAME      => 'HelpViewer',
            COMMENTS  => '[Intel]',
            VERSION   => '5.0.3'
          },
          {
            PUBLISHER => "1.0, Copyright © 2009 Hewlett-Packard Development Company, L.P.",
            NAME      => 'HPFaxBackend',
            COMMENTS  => '[Universal]',
            VERSION   => '3.1.0'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Proof',
            COMMENTS  => '[Universal]',
            VERSION   => undef
          },
          {
            PUBLISHER => "Adobe Updater 6.2.0.1474, Copyright � 2002-2008 by Adobe Systems Incorporated. All rights reserved.",
            NAME      => 'Adobe Updater',
            COMMENTS  => '[Intel]',
            VERSION   => 'Adobe Updater 6.2.0.1474'
          },
          {
            PUBLISHER => "2.2 ©2010, Apple, Inc",
            NAME      => 'AU Lab',
            COMMENTS  => '[Intel]',
            VERSION   => '2.2'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Configuration actions de dossier',
            COMMENTS  => '[Intel]',
            VERSION   => '1.1.4'
          },
          {
            PUBLISHER => undef,
            NAME      => 'ServerJoiner',
            COMMENTS  => '[Intel]',
            VERSION   => '10.6.3'
          },
          {
            PUBLISHER => "2.3.1.2 © 2005-2009 Telestream Inc. All Rights Reserved.",
            NAME      => 'WMV Player',
            COMMENTS  => '[Universal]',
            VERSION   => '2.3.1.2'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Pixie',
            COMMENTS  => '[Intel]',
            VERSION   => '2.3'
          },
          {
            PUBLISHER => undef,
            NAME      => "Utilitaire d’emplacement de mémoire",
            COMMENTS  => '[Intel]',
            VERSION   => '1.4.1'
          },
          {
            PUBLISHER => undef,
            NAME      => 'AppleScript Runner',
            COMMENTS  => '[Intel]',
            VERSION   => '1.0.2'
          },
          {
            PUBLISHER => undef,
            NAME      => 'wxPerl',
            COMMENTS  => '[Universal]',
            VERSION   => '1.0'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Problem Reporter',
            COMMENTS  => '[Universal]',
            VERSION   => '10.6.6'
          },
          {
            PUBLISHER => "Adobe® Acrobat® 9.4.2, ©1984-2010 Adobe Systems Incorporated. All rights reserved.",
            NAME      => 'Adobe Reader',
            COMMENTS  => '[Intel]',
            VERSION   => '9.4.2'
          },
          {
            PUBLISHER => 'v1.9.2.1599. Copyright 2007-2009 Google Inc. All rights reserved.',
            NAME      => 'GoogleTalkPlugin',
            COMMENTS  => '[Intel]',
            VERSION   => '1.9.2.1599'
          },
          {
            PUBLISHER => '2.3.8, Copyright (c) 2010 Apple Inc. All rights reserved.',
            NAME      => "Échange de fichiers Bluetooth",
            COMMENTS  => '[Universal]',
            VERSION   => '2.3.8'
          },
          {
            PUBLISHER => undef,
            NAME      => 'IORegistryExplorer',
            COMMENTS  => '[Intel]',
            VERSION   => '2.1'
          },
          {
            PUBLISHER => undef,
            NAME      => 'UnmountAssistantAgent',
            COMMENTS  => '[Intel]',
            VERSION   => '1.0'
          },
          {
            PUBLISHER => "6.0.3, © Copyright 2000-2010 Apple Inc. All rights reserved.",
            NAME      => 'MassStorageCamera',
            COMMENTS  => '[Universal]',
            VERSION   => '6.0.3'
          },
          {
            PUBLISHER => 'HP Fax 4.1, Copyright (c) 2009-2010 Hewlett-Packard Development Company, L.P.',
            NAME      => 'rastertofax',
            COMMENTS  => '[Intel]',
            VERSION   => '4.1'
          },
          {
            PUBLISHER => undef,
            NAME      => 'SpeechRecognitionServer',
            COMMENTS  => '[Intel]',
            VERSION   => '3.11.1'
          },
          {
            PUBLISHER => 'org.x.X11',
            NAME      => 'X11',
            COMMENTS  => undef,
            VERSION   => '2.3.6'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Network Connect',
            COMMENTS  => '[Intel]',
            VERSION   => '17289'
          },
          {
            PUBLISHER => "14.0.0 (100825), © 2010 Microsoft Corporation. All rights reserved.",
            NAME      => 'Assistant Installation de Microsoft Office',
            COMMENTS  => '[Intel]',
            VERSION   => '14.0.0'
          },
          {
            PUBLISHER => '1.0, Copyright Apple Inc. 2007',
            NAME      => 'quicklookd32',
            COMMENTS  => '[Intel]',
            VERSION   => '2.3'
          },
          {
            PUBLISHER => undef,
            NAME      => 'iSync Plug-in Maker',
            COMMENTS  => '[Universal]',
            VERSION   => '3.1'
          },
          {
            PUBLISHER => "1.3, Copyright © 2002-2005 Apple Computer, Inc.",
            NAME      => 'Repeat After Me',
            COMMENTS  => '[Intel]',
            VERSION   => '1.3'
          },
          {
            PUBLISHER => 'Thread Viewer',
            NAME      => 'Thread Viewer',
            COMMENTS  => '[Universal]',
            VERSION   => '1.4'
          },
          {
            PUBLISHER => 'HP Utility version 4.8.5, Copyright (c) 2005-2010 Hewlett-Packard Development Company, L.P.',
            NAME      => 'HP Utility',
            COMMENTS  => '[Intel]',
            VERSION   => '4.8.5'
          },
          {
            PUBLISHER => "2.2.2, Copyright © 2003-2010 Apple Inc.",
            NAME      => 'Livre des polices',
            COMMENTS  => '[Intel]',
            VERSION   => '2.2.2'
          },
          {
            PUBLISHER => "1.2, Copyright © 2004-2009 Apple Inc. All rights reserved.",
            NAME      => 'Automator Launcher',
            COMMENTS  => '[Intel]',
            VERSION   => '1.2'
          },
          {
            PUBLISHER => '2.6',
            NAME      => 'rcd',
            COMMENTS  => '[Intel]',
            VERSION   => '2.6'
          },
          {
            PUBLISHER => undef,
            NAME      => 'DivX Community',
            COMMENTS  => '[PowerPC]',
            VERSION   => '1.1.0'
          },
          {
            PUBLISHER => 'HP Laserjet Driver 1.0, Copyright (c) 1994-2009 Hewlett-Packard Development Company, L.P.',
            NAME      => 'Laserjet',
            COMMENTS  => '[Intel]',
            VERSION   => '1.0'
          },
          {
            PUBLISHER => 'HP Deskjet Driver 3.0, Copyright (c) 1994-2009 Hewlett-Packard Development Company, L.P.',
            NAME      => 'Deskjet',
            COMMENTS  => '[Intel]',
            VERSION   => '3.0'
          },
          {
            PUBLISHER => undef,
            NAME      => 'PrinterProxy',
            COMMENTS  => '[Universal]',
            VERSION   => '6.5'
          },
          {
            PUBLISHER => "1.5, Copyright © 2009 Apple Inc.",
            NAME      => 'OpenGL Driver Monitor',
            COMMENTS  => '[Intel]',
            VERSION   => '1.5'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Core Image Fun House',
            COMMENTS  => '[Intel]',
            VERSION   => '2.1.43'
          },
          {
            PUBLISHER => "4.0.0, Copyright © 2002-2010 Apple Inc. All Rights Reserved.",
            NAME      => 'USB Prober',
            COMMENTS  => '[Intel]',
            VERSION   => '4.0.0'
          },
          {
            PUBLISHER => undef,
            NAME      => 'BigTop',
            COMMENTS  => '[Intel]',
            VERSION   => '4.7.3'
          },
          {
            PUBLISHER => "FontSync Scripting 2.0. Copyright © 2000-2008 Apple Inc.",
            NAME      => 'FontSyncScripting',
            COMMENTS  => '[Universal]',
            VERSION   => '2.0.6'
          },
          {
            PUBLISHER => '1.0, Copyright Apple Inc. 2007',
            NAME      => 'quicklookd',
            COMMENTS  => '[Intel]',
            VERSION   => '2.3'
          },
          {
            PUBLISHER => "12.2.8 (101117), © 2007 Microsoft Corporation. All rights reserved.",
            NAME      => 'Assistant Installation de Microsoft Office 2008',
            COMMENTS  => '[Universal]',
            VERSION   => '12.2.8'
          },
          {
            PUBLISHER => "14.0.2 (101115), © 2010 Microsoft Corporation. All rights reserved.",
            NAME      => 'SyncServicesAgent',
            COMMENTS  => '[Intel]',
            VERSION   => '14.0.2'
          },
          {
            PUBLISHER => '1.1, Copyright 2007-2008 Apple Inc.',
            NAME      => 'Spaces',
            COMMENTS  => '[Universal]',
            VERSION   => '1.1'
          },
          {
            PUBLISHER => "12.2.8 (101117), © 2007 Microsoft Corporation. All rights reserved.",
            NAME      => 'Microsoft Excel',
            COMMENTS  => '[Universal]',
            VERSION   => '12.2.8'
          },
          {
            PUBLISHER => "3.1.2, Copyright © 2003-2010 Apple Inc.",
            NAME      => 'iSync',
            COMMENTS  => '[Intel]',
            VERSION   => '3.1.2'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Remove',
            COMMENTS  => '[Universal]',
            VERSION   => undef
          },
          {
            PUBLISHER => undef,
            NAME      => 'Printer Setup Utility',
            COMMENTS  => '[Universal]',
            VERSION   => '6.5'
          },
          {
            PUBLISHER => "InstallAnywhere 8.0, Copyright © 2006 Macrovision Corporation.",
            NAME      => 'Cisco Network Assistant',
            COMMENTS  => '[Universal]',
            VERSION   => '8.0'
          },
          {
            PUBLISHER => "6.0.1, © Copyright 2001-2010 Apple Inc. All rights reserved.",
            NAME      => 'Type4Camera',
            COMMENTS  => '[Universal]',
            VERSION   => '6.0.1'
          },
          {
            PUBLISHER => undef,
            NAME      => 'KerberosAgent',
            COMMENTS  => '[Universal]',
            VERSION   => '6.5.10'
          },
          {
            PUBLISHER => '2.3.6, Copyright (c) 2010 Apple Inc. All rights reserved.',
            NAME      => 'PacketLogger',
            COMMENTS  => '[Universal]',
            VERSION   => '2.3.6'
          },
          {
            PUBLISHER => undef,
            NAME      => 'h-nb-toshiba- photocopieur multifonctions noir et blanc',
            COMMENTS  => '[Universal]',
            VERSION   => '6.5'
          },
          {
            PUBLISHER => '5.0, Copyright 2003 EPSON',
            NAME      => 'EPSON Scanner',
            COMMENTS  => '[Intel]',
            VERSION   => '5.0'
          },
          {
            PUBLISHER => "6.0, © Copyright 2004-2009 Apple Inc., all rights reserved.",
            NAME      => 'BluetoothCamera',
            COMMENTS  => '[Universal]',
            VERSION   => '6.0'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Adobe Flash Player Install Manager',
            COMMENTS  => '[Universal]',
            VERSION   => '10.1.102.64'
          },
          {
            PUBLISHER => "6.0, © Copyright 2000-2009 Apple Inc., all rights reserved.",
            NAME      => "Transfert d’images",
            COMMENTS  => '[Intel]',
            VERSION   => '6.0.1'
          },
          {
            PUBLISHER => undef,
            NAME      => 'PluginIM',
            COMMENTS  => '[Universal]',
            VERSION   => '1.1'
          },
          {
            PUBLISHER => undef,
            NAME      => 'AppleMobileSync',
            COMMENTS  => '[Universal]',
            VERSION   => '3.1'
          },
          {
            PUBLISHER => '1.4.1, Copyright 2001-2010 The Adium Team',
            NAME      => 'Adium',
            COMMENTS  => '[Universal]',
            VERSION   => '1.4.1'
          },
          {
            PUBLISHER => '1.0.4',
            NAME      => "Zimbra Desktop désinstallateur",
            COMMENTS  => '[Universal]',
            VERSION   => '1.0.4'
          },
          {
            PUBLISHER => 'Network Recording Player version 2.2, Copyright WebEx Communications, Inc. 2006',
            NAME      => 'Network Recording Player',
            COMMENTS  => '[Intel]',
            VERSION   => '2.2.0'
          },
          {
            PUBLISHER => "1.1.1 (100910), © 2007 Microsoft Corporation. All rights reserved.",
            NAME      => 'Microsoft Help Viewer',
            COMMENTS  => '[Universal]',
            VERSION   => '1.1.1'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Install Helper',
            COMMENTS  => '[Intel]',
            VERSION   => '1.0'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Calculette',
            COMMENTS  => '[Intel]',
            VERSION   => '4.5.3'
          },
          {
            PUBLISHER => undef,
            NAME      => "Utilitaire d’emplacement d’extension",
            COMMENTS  => '[Intel]',
            VERSION   => '1.4.1'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Dashcode',
            COMMENTS  => '[Intel]',
            VERSION   => '3.0.2'
          },
          {
            PUBLISHER => 'HP Photosmart Compact Photo Printer driver 1.0.1, Copyright (c) 2007-2009 Hewlett-Packard Development Company, L.P.',
            NAME      => 'hprastertojpeg',
            COMMENTS  => '[Intel]',
            VERSION   => '1.0.1'
          },
          {
            PUBLISHER => undef,
            NAME      => "Aide-mémoire",
            COMMENTS  => '[Intel]',
            VERSION   => '7.0'
          },
          {
            PUBLISHER => undef,
            NAME      => 'VoiceOver Quickstart',
            COMMENTS  => '[Universal]',
            VERSION   => '3.4.0'
          },
          {
            PUBLISHER => '6.0.11994.637942, Copyright 2005-2011 Parallels Holdings, Ltd. and its affiliates',
            NAME      => 'Parallels Service',
            COMMENTS  => '[Intel]',
            VERSION   => '6.0'
          },
          {
            PUBLISHER => undef,
            NAME      => "Utilitaire d’archive",
            COMMENTS  => '[Intel]',
            VERSION   => '10.6'
          },
          {
            PUBLISHER => '4.2, Copyright 2003-2009 Apple, Inc.',
            NAME      => 'OpenGL Profiler',
            COMMENTS  => '[Universal]',
            VERSION   => '4.2'
          },
          {
            PUBLISHER => "Version 11.5.2, Copyright © 1999-2010 Apple Inc. All rights reserved.",
            NAME      => 'Utilitaire de disque',
            COMMENTS  => '[Intel]',
            VERSION   => '11.5.2'
          },
          {
            PUBLISHER => undef,
            NAME      => 'PackageMaker',
            COMMENTS  => '[Intel]',
            VERSION   => '3.0.4'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Image Events',
            COMMENTS  => '[Intel]',
            VERSION   => '1.1.4'
          },
          {
            PUBLISHER => undef,
            NAME      => 'DockPlistEdit',
            COMMENTS  => '[Universal]',
            VERSION   => '6.0'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Session Timer',
            COMMENTS  => '[Intel]',
            VERSION   => '17289'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Assistant migration',
            COMMENTS  => '[Intel]',
            VERSION   => '3.0'
          },
          {
            PUBLISHER => "13.0.0 (100825), © 2010 Microsoft Corporation. All rights reserved.",
            NAME      => 'Microsoft Communicator',
            COMMENTS  => '[Intel]',
            VERSION   => '13.0.0'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Free42-Decimal',
            COMMENTS  => undef,
            VERSION   => undef
          },
          {
            PUBLISHER => "ver2.00, © 2005-2008 Brother Industries, Ltd.",
            NAME      => 'P-touch Status Monitor',
            COMMENTS  => '[Intel]',
            VERSION   => '2.00'
          },
          {
            PUBLISHER => 'Copyright (C) 2004-2009 Samsung Electronics Co., Ltd.',
            NAME      => 'Samsung Scanner',
            COMMENTS  => '[Intel]',
            VERSION   => '2.00.29'
          },
          {
            PUBLISHER => '1.6',
            NAME      => "Assistant réglages de réseau",
            COMMENTS  => '[Intel]',
            VERSION   => '1.6'
          },
          {
            PUBLISHER => 'OpenOffice.org 3.2.0 [320m8(Build:9472)]',
            NAME      => 'OpenOffice',
            COMMENTS  => '[Intel]',
            VERSION   => '3.2.0'
          },
          {
            PUBLISHER => undef,
            NAME      => 'TrueCrypt',
            COMMENTS  => '[Universal]',
            VERSION   => '6.2.1'
          },
          {
            PUBLISHER => 'Epson Printer Utility Lite version 8.02',
            NAME      => 'Epson Printer Utility Lite',
            COMMENTS  => '[Intel]',
            VERSION   => '8.02'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Extract',
            COMMENTS  => '[Universal]',
            VERSION   => undef
          },
          {
            PUBLISHER => "1.1.1, Copyright © 2007-2009 Apple Inc., All Rights Reserved.",
            NAME      => "Partage d’écran",
            COMMENTS  => '[Universal]',
            VERSION   => '1.1.1'
          },
          {
            PUBLISHER => 'Nimbuzz for Mac OS X, version 1.2.0',
            NAME      => 'Nimbuzz',
            COMMENTS  => '[Intel]',
            VERSION   => '1.2.0'
          },
          {
            PUBLISHER => undef,
            NAME      => 'WiFi Scanner',
            COMMENTS  => '[Universal]',
            VERSION   => '1.0'
          },
          {
            PUBLISHER => '6.0.11994.637942, Copyright 2005-2011 Parallels Holdings, Ltd. and its affiliates',
            NAME      => 'Parallels Transporter',
            COMMENTS  => '[Intel]',
            VERSION   => '6.0.11994.637942'
          },
          {
            PUBLISHER => 'System Language Initializer',
            NAME      => 'Language Chooser',
            COMMENTS  => '[Intel]',
            VERSION   => '20'
          },
          {
            PUBLISHER => "6.0.3 (070803), © 2006 Microsoft Corporation. All rights reserved.",
            NAME      => 'Microsoft Messenger',
            COMMENTS  => '[Universal]',
            VERSION   => '6.0.3'
          },
          {
            PUBLISHER => undef,
            NAME      => 'iCal',
            COMMENTS  => '[Universal]',
            VERSION   => '4.0.4'
          },
          {
            PUBLISHER => "iTunes 10.2.1, © 2000-2011 Apple Inc. All rights reserved.",
            NAME      => 'iTunes',
            COMMENTS  => '[Universal]',
            VERSION   => '10.2.1'
          },
          {
            PUBLISHER => 'Mac OS X Finder 10.6.7',
            NAME      => 'Finder',
            COMMENTS  => '[Intel]',
            VERSION   => '10.6.7'
          },
          {
            PUBLISHER => undef,
            NAME      => 'AppleFileServer',
            COMMENTS  => '[Intel]',
            VERSION   => undef
          },
          {
            PUBLISHER => '1.7, Copyright 2006-2008 Apple Inc.',
            NAME      => 'Dashboard',
            COMMENTS  => '[Universal]',
            VERSION   => '1.7'
          },
          {
            PUBLISHER => "1.5.5 (155.2), Copyright © 2006-2009 Apple Inc. All Rights Reserved.",
            NAME      => "Agent de la borne d’accès AirPort",
            COMMENTS  => '[Universal]',
            VERSION   => '1.5.5'
          },
          {
            PUBLISHER => undef,
            NAME      => 'vpndownloader',
            COMMENTS  => '[Intel]',
            VERSION   => '1.0'
          },
          {
            PUBLISHER => '2.0, Copyright Apple Inc. 2007-2009',
            NAME      => 'ParentalControls',
            COMMENTS  => '[Universal]',
            VERSION   => '2.0'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Icon Composer',
            COMMENTS  => '[Intel]',
            VERSION   => '2.1'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Speech Startup',
            COMMENTS  => '[Intel]',
            VERSION   => '3.8.1'
          },
          {
            PUBLISHER => undef,
            NAME      => 'ChineseHandwriting',
            COMMENTS  => '[Intel]',
            VERSION   => '1.0.1'
          },
          {
            PUBLISHER => "Boot Camp Assistant 3.0.1, Copyright © 2009 Apple Inc. All rights reserved",
            NAME      => 'Assistant Boot Camp',
            COMMENTS  => '[Intel]',
            VERSION   => '3.0.1'
          },
          {
            PUBLISHER => "12.2.8 (101117), © 2009 Microsoft Corporation. All rights reserved.",
            NAME      => 'Microsoft Document Connection',
            COMMENTS  => '[Universal]',
            VERSION   => '12.2.8'
          },
          {
            PUBLISHER => undef,
            NAME      => 'ScreenSaverEngine',
            COMMENTS  => '[Universal]',
            VERSION   => '3.0.3'
          },
          {
            PUBLISHER => "4.0, Copyright © 1997-2009 Apple Inc., All Rights Reserved",
            NAME      => 'SCIM',
            COMMENTS  => '[Universal]',
            VERSION   => '4.3'
          },
          {
            PUBLISHER => undef,
            NAME      => 'webdav_cert_ui',
            COMMENTS  => '[Intel]',
            VERSION   => '1.8.1'
          },
          {
            PUBLISHER => 'Xcode version 3.2.5',
            NAME      => 'Xcode',
            COMMENTS  => '[Universal]',
            VERSION   => '3.2.5'
          },
          {
            PUBLISHER => undef,
            NAME      => 'ManagedClient',
            COMMENTS  => '[Universal]',
            VERSION   => '2.3'
          },
          {
            PUBLISHER => '10.6.0, Copyright 1997-2009 Apple, Inc.',
            NAME      => "Informations Système",
            COMMENTS  => '[Universal]',
            VERSION   => '10.6.0'
          },
          {
            PUBLISHER => "6.0, © Copyright 2002-2009 Apple Inc., all rights reserved.",
            NAME      => 'Type7Camera',
            COMMENTS  => '[Universal]',
            VERSION   => '6.0'
          },
          {
            PUBLISHER => undef,
            NAME      => 'CPUPalette',
            COMMENTS  => '[Intel]',
            VERSION   => '4.7.3'
          },
          {
            PUBLISHER => "9.4.2, ©2009-2010 Adobe Systems Incorporated. All rights reserved.",
            NAME      => 'Adobe Reader Updater',
            COMMENTS  => '[Universal]',
            VERSION   => '9.4.2'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Kotoeri',
            COMMENTS  => '[Universal]',
            VERSION   => '4.2.0'
          },
          {
            PUBLISHER => "© Copyright 2009 Apple Inc., all rights reserved.",
            NAME      => 'FileSyncAgent',
            COMMENTS  => '[Intel]',
            VERSION   => '5.0.3'
          },
          {
            PUBLISHER => "6.0, © Copyright 2003-2009 Apple Inc., all rights reserved.",
            NAME      => 'Image Capture Web Server',
            COMMENTS  => '[Universal]',
            VERSION   => '6.0'
          },
          {
            PUBLISHER => undef,
            NAME      => "MÀJ du programme interne Bluetooth",
            COMMENTS  => '[Intel]',
            VERSION   => '2.0.1'
          },
          {
            PUBLISHER => undef,
            NAME      => 'h-color-hp- imprimante couleur',
            COMMENTS  => '[Universal]',
            VERSION   => '6.5'
          },
          {
            PUBLISHER => "12.2.8 (101117), © 2007 Microsoft Corporation. All rights reserved.",
            NAME      => 'Open XML for Charts',
            COMMENTS  => '[PowerPC]',
            VERSION   => '12.2.8'
          },
          {
            PUBLISHER => 'About Xcode',
            NAME      => 'About Xcode',
            COMMENTS  => '[Universal]',
            VERSION   => '169.2'
          },
          {
            PUBLISHER => "5.0.4, Copyright © 2003-2011 Apple Inc.",
            NAME      => 'Safari',
            COMMENTS  => '[Intel]',
            VERSION   => '5.0.4'
          },
          {
            PUBLISHER => undef,
            NAME      => "Carnet d’adresses",
            COMMENTS  => '[Intel]',
            VERSION   => '5.0.3'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Yahoo! Zimbra Desktop',
            COMMENTS  => undef,
            VERSION   => undef
          },
          {
            PUBLISHER => "ver3.00, ©2005-2009 Brother Industries, Ltd. All Rights Reserved.",
            NAME      => "Brother Contrôleur d'état",
            COMMENTS  => '[Intel]',
            VERSION   => '3.00'
          },
          {
            PUBLISHER => '2.0.4, Copyright 2008 Apple Inc.',
            NAME      => 'iWeb',
            COMMENTS  => '[Universal]',
            VERSION   => '2.0.4'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Interface Builder',
            COMMENTS  => '[Intel]',
            VERSION   => '3.2.5'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Bonjour Browser',
            COMMENTS  => '[Universal]',
            VERSION   => '1.5.6'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Assistant de certification',
            COMMENTS  => '[Intel]',
            VERSION   => '3.0'
          },
          {
            PUBLISHER => "6.0, © Copyright 2003-2009 Apple Inc., all rights reserved.",
            NAME      => 'MakePDF',
            COMMENTS  => '[Universal]',
            VERSION   => '6.0'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Log Viewer',
            COMMENTS  => '[Intel]',
            VERSION   => '17289'
          },
          {
            PUBLISHER => "2.1.1, © 1995-2009 Apple Inc. All Rights Reserved.",
            NAME      => 'Terminal',
            COMMENTS  => '[Intel]',
            VERSION   => '2.1.1'
          },
          {
            PUBLISHER => '1.0.0, Copyright CANON INC. 2009 All Rights Reserved',
            NAME      => 'Canon IJScanner2',
            COMMENTS  => '[Intel]',
            VERSION   => '1.0.0'
          },
          {
            PUBLISHER => '10.6',
            NAME      => "Assistant réglages",
            COMMENTS  => '[Universal]',
            VERSION   => '10.6'
          },
          {
            PUBLISHER => "3.0, Copyright © 2000-2006 Apple Computer Inc., All Rights Reserved",
            NAME      => "Programme d’installation",
            COMMENTS  => '[Universal]',
            VERSION   => '4.0'
          },
          {
            PUBLISHER => "12.2.8 (101117), © 2007 Microsoft Corporation. All rights reserved.",
            NAME      => 'My Day',
            COMMENTS  => '[Universal]',
            VERSION   => '12.2.8'
          },
          {
            PUBLISHER => 'Summary Service Version  2',
            NAME      => "Service de résumé",
            COMMENTS  => '[Intel]',
            VERSION   => '2.0'
          },
          {
            PUBLISHER => "14.0.2 (101115), © 2010 Microsoft Corporation. All rights reserved.",
            NAME      => 'Microsoft Outlook',
            COMMENTS  => '[Intel]',
            VERSION   => '14.0.2'
          },
          {
            PUBLISHER => '1.2.0, Copyright 1998-2009 Wireshark Development Team',
            NAME      => 'Wireshark',
            COMMENTS  => '[Intel]',
            VERSION   => '1.2.0'
          },
          {
            PUBLISHER => 'HP Command File Filter 1.11, Copyright (c) 2006-2010 Hewlett-Packard Development Company, L.P.',
            NAME      => 'commandtohp',
            COMMENTS  => '[Intel]',
            VERSION   => '1.11'
          },
          {
            PUBLISHER => undef,
            NAME      => 'AddressBookSync',
            COMMENTS  => '[Intel]',
            VERSION   => '2.0.3'
          },
          {
            PUBLISHER => undef,
            NAME      => "Éditeur d'équations Microsoft",
            COMMENTS  => '[Intel]',
            VERSION   => '14.0.0'
          },
          {
            PUBLISHER => 'HP Inkjet 3 Driver 2.0, Copyright (c) 1994-2009 Hewlett-Packard Development Company, L.P.',
            NAME      => 'Inkjet3',
            COMMENTS  => '[Intel]',
            VERSION   => '2.0'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Ticket Viewer',
            COMMENTS  => '[Intel]',
            VERSION   => '1.0'
          },
          {
            PUBLISHER => "12.2.8 (101117), © 2007 Microsoft Corporation. All rights reserved.",
            NAME      => 'Supprimer Office',
            COMMENTS  => '[Universal]',
            VERSION   => '12.2.8'
          },
          {
            PUBLISHER => undef,
            NAME      => 'SLLauncher',
            COMMENTS  => '[Intel]',
            VERSION   => '1.0'
          },
          {
            PUBLISHER => undef,
            NAME      => 'WebKitPluginHost',
            COMMENTS  => undef,
            VERSION   => undef
          },
          {
            PUBLISHER => undef,
            NAME      => 'Uninstall DivX for Mac',
            COMMENTS  => '[Universal]',
            VERSION   => '1.0'
          },
          {
            PUBLISHER => "2.2, Copyright © 2001–2008 Apple Inc.",
            NAME      => "Utilitaire d’annuaire",
            COMMENTS  => '[Intel]',
            VERSION   => '2.2'
          },
          {
            PUBLISHER => 'HP PDF Filter 1.3, Copyright (c) 2001-2009 Hewlett-Packard Development Company, L.P.',
            NAME      => 'pdftopdf',
            COMMENTS  => '[Intel]',
            VERSION   => '1.3'
          },
          {
            PUBLISHER => '2.3.8, Copyright (c) 2010 Apple Inc. All rights reserved.',
            NAME      => 'AVRCPAgent',
            COMMENTS  => '[Universal]',
            VERSION   => '2.3.8'
          },
          {
            PUBLISHER => '4.0, Copyright Apple Computer Inc. 2004',
            NAME      => 'syncuid',
            COMMENTS  => '[Universal]',
            VERSION   => '5.2'
          },
          {
            PUBLISHER => '2.0.2, Copyright 2009 Brother Industries, LTD.',
            NAME      => 'Brother Scanner',
            COMMENTS  => '[Intel]',
            VERSION   => '2.0.2'
          },
          {
            PUBLISHER => undef,
            NAME      => 'iChat',
            COMMENTS  => '[Intel]',
            VERSION   => '5.0.3'
          },
          {
            PUBLISHER => "2.0.1, Copyright © 2007-2009 Apple Inc.",
            NAME      => 'Transfert de podcast',
            COMMENTS  => '[Intel]',
            VERSION   => '2.0.1'
          },
          {
            PUBLISHER => 'GarageBand Getting Started',
            NAME      => 'Premiers contacts avec GarageBand',
            COMMENTS  => '[Universal]',
            VERSION   => '1.0.2'
          },
          {
            PUBLISHER => "1.4.1 (141.6), Copyright © 2007-2009 Apple Inc. All Rights Reserved.",
            NAME      => 'ODSAgent',
            COMMENTS  => '[Intel]',
            VERSION   => '1.4.1'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Rename',
            COMMENTS  => '[Universal]',
            VERSION   => undef
          },
          {
            PUBLISHER => undef,
            NAME      => 'Shark',
            COMMENTS  => '[Intel]',
            VERSION   => '4.7.3'
          },
          {
            PUBLISHER => "10.0, Copyright © 2009-2010 Apple Inc. All Rights Reserved.",
            NAME      => 'QuickTime Player',
            COMMENTS  => '[Intel]',
            VERSION   => '10.0'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Quartz Composer',
            COMMENTS  => '[Intel]',
            VERSION   => '4.0'
          },
          {
            PUBLISHER => undef,
            NAME      => 'ARDAgent',
            COMMENTS  => '[Universal]',
            VERSION   => '3.4'
          },
          {
            PUBLISHER => "© 2002-2003 Apple",
            NAME      => 'SyncServer',
            COMMENTS  => '[Universal]',
            VERSION   => '5.2'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Network Diagnostic Utility',
            COMMENTS  => '[Intel]',
            VERSION   => '17289'
          },
          {
            PUBLISHER => undef,
            NAME      => 'SecurityProxy',
            COMMENTS  => '[Universal]',
            VERSION   => '1.0'
          },
          {
            PUBLISHER => undef,
            NAME      => 'CocoaPacketAnalyzer',
            COMMENTS  => '[Universal]',
            VERSION   => '0.66'
          },
          {
            PUBLISHER => undef,
            NAME      => 'Help Indexer',
            COMMENTS  => '[Intel]',
            VERSION   => '4.0'
          },
          {
            PUBLISHER => '1.1, Copyright 2007-2008 Apple Inc.',
            NAME      => 'Time Machine',
            COMMENTS  => '[Universal]',
            VERSION   => '1.1'
          },
          {
            PUBLISHER => "6.0, © Copyright 2001-2009 Apple Inc., all rights reserved.",
            NAME      => 'Type3Camera',
            COMMENTS  => '[Universal]',
            VERSION   => '6.0'
          },
          {
            PUBLISHER => "12.2.8 (101117), © 2007 Microsoft Corporation. All rights reserved.",
            NAME      => 'Microsoft Chart Converter',
            COMMENTS  => '[Universal]',
            VERSION   => '12.2.8'
          },
          {
            PUBLISHER => undef,
            NAME      => 'loginwindow',
            COMMENTS  => '[Universal]',
            VERSION   => '6.1.1'
          },
          {
            PUBLISHER => '1.0.0, (c) Copyright 2001-2010 Hewlett-Packard Development Company, L.P.',
            NAME      => 'hpPreProcessing',
            COMMENTS  => '[Intel]',
            VERSION   => '1.0.0'
          },
          {
            PUBLISHER => undef,
            NAME      => 'OpenGL Shader Builder',
            COMMENTS  => '[Intel]',
            VERSION   => '2.1'
          },
          {
            PUBLISHER => "12.2.8 (101117), © 2007 Microsoft Corporation. All rights reserved.",
            NAME      => 'Microsoft Database Daemon',
            COMMENTS  => '[Universal]',
            VERSION   => '12.2.8'
          },
          {
            PUBLISHER => 'HP Photosmart Driver 4.0, Copyright (c) 1994-2009 Hewlett-Packard Development Company, L.P.',
            NAME      => 'Photosmart',
            COMMENTS  => '[Intel]',
            VERSION   => '4.0'
          },
          {
            PUBLISHER => "2.2.5 (101115), © 2010 Microsoft Corporation. All rights reserved.",
            NAME      => 'Signalement d\'erreurs Microsoft',
            COMMENTS  => '[Universal]',
            VERSION   => '2.2.5'
          },
          {
            PUBLISHER => "Prism 0.9.1, © 2007 Contributors",
            NAME      => 'Prism',
            COMMENTS  => '[Intel]',
            VERSION   => '0.9.1'
          },
          {
            PUBLISHER => "6.0.4, © Copyright 2004-2010 Apple Inc. All rights reserved.",
            NAME      => 'PTPCamera',
            COMMENTS  => '[Universal]',
            VERSION   => '6.0.4'
          },
          {
            PUBLISHER => 'HP Officejet Driver 3.0, Copyright (c) 1994-2009 Hewlett-Packard Development Company, L.P.',
            NAME      => 'Officejet',
            COMMENTS  => '[Intel]',
            VERSION   => '3.0'
          },
    ]
);

plan tests => scalar keys %tests;

foreach my $test (keys %tests) {
    my $file = "resources/macos/system_profiler/$test.SPApplicationsDataType";
    my $softwares = FusionInventory::Agent::Task::Inventory::Input::MacOS::Softwares::_getSoftwaresList(file => $file);
    cmp_deeply(
        $softwares,
        $tests{$test},
        $test
    );
}
