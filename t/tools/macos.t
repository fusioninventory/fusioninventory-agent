#!/usr/bin/perl

use strict;
use warnings;
use FusionInventory::Agent::Tools::MacOS;
use FusionInventory::Logger;
use Test::More;

my %tests = (
    'system_profiler_full_10.5-powerpc' => {
        'Locations' => {
            'Automatic' => {
                'Services' => {
                    'FireWire' => {
                        'Type' => 'FireWire',
                        'IPv6' => {
                            'Configuration Method' => 'Automatic'
                        },
                        'BSD Device Name' => 'fw0',
                        'IPv4' => {
                            'Configuration Method' => 'DHCP'
                        },
                        'Proxies' => {
                            'FTP Passive Mode' => 'Yes',
                            'Exceptions List' => '*.local, 169.254/16'
                        },
                        'Hardware (MAC) Address' => '00:14:51:ff:fe:1a:c8:e2'
                    },
                    'Ethernet' => {
                        'Type' => 'Ethernet',
                        'IPv6' => {
                            'Configuration Method' => 'Automatic'
                        },
                        'BSD Device Name' => 'en0',
                        'AppleTalk' => {
                            'Configuration Method' => 'Node'
                        },
                        'IPv4' => {
                            'Configuration Method' => 'DHCP'
                        },
                        'Proxies' => {
                            'FTP Passive Mode' => 'Yes',
                            'Exceptions List' => '*.local, 169.254/16'
                        },
                        'Hardware (MAC) Address' => '00:14:51:61:ef:08',
                        'DNS' => {
                            'Server Addresses' => '10.0.1.1',
                            'Search Domains' => 'lan'
                        }
                    },
                    'Bluetooth' => {
                        'Type' => 'PPP',
                        'IPv6' => {
                            'Configuration Method' => 'Automatic'
                        },
                        'IPv4' => {
                            'Configuration Method' => 'PPP'
                        },
                        'Proxies' => {
                            'FTP Passive Mode' => 'Yes'
                        },
                        'PPP' => {
                            'IPCP Compression VJ' => 'Yes',
                            'Idle Reminder' => 'No',
                            'Dial On Demand' => 'No',
                            'Idle Reminder Time' => '1800',
                            'Disconnect On Fast User Switch' => 'Yes',
                            'Disconnect On Logout' => 'Yes',
                            'ACSP Enabled' => 'No',
                            'Log File' => '/var/log/ppp.log',
                            'Disconnect On Idle Time' => '600',
                            'Redial Enabled' => 'Yes',
                            'Verbose Logging' => 'No',
                            'Redial Interval' => '5',
                            'Use Terminal Script' => 'No',
                            'Disconnect On Sleep' => 'Yes',
                            'LCP Echo Failure' => '4',
                            'Disconnect On Idle' => 'Yes',
                            'LCP Echo Interval' => '10',
                            'Redial Count' => '1',
                            'LCP Echo Enabled' => 'No',
                            'Display Terminal Window' => 'No'
                        }
                    },
                    'AirPort' => {
                        'Type' => 'Ethernet',
                        'IPv6' => {
                            'Configuration Method' => 'Automatic'
                        },
                        'BSD Device Name' => 'en1',
                        'AppleTalk' => {
                            'Configuration Method' => 'Node'
                        },
                        'IPv4' => {
                            'Configuration Method' => 'DHCP'
                        },
                        'Proxies' => {
                            'FTP Passive Mode' => 'Yes',
                            'Exceptions List' => '*.local, 169.254/16'
                        },
                        'Hardware (MAC) Address' => '00:14:51:61:ef:09'
                    }
                },
                'Active Location' => 'Yes'
            }
        },
        'PCI Cards' => {
            'Apple 5714' => {
                'Slot' => 'GIGE',
                'Subsystem Vendor ID' => '0x106b',
                'Revision ID' => '0x0003',
                'Device ID' => '0x166a',
                'Type' => 'network',
                'Driver Installed' => 'Yes',
                'Subsystem ID' => '0x0085',
                'Bus' => 'PCI',
                'Name' => 'bcom5714',
                'Vendor ID' => '0x14e4'
            },
            'GeForce 6600' => {
                'Slot' => 'SLOT-1',
                'Subsystem Vendor ID' => '0x10de',
                'Link Width' => 'x16',
                'Revision ID' => '0x00a4',
                'Device ID' => '0x0141',
                'Type' => 'display',
                'Driver Installed' => 'Yes',
                'Subsystem ID' => '0x0010',
                'Link Speed' => '2.5 GT/s',
                'ROM Revision' => '2149',
                'Bus' => 'PCI',
                'Name' => 'NVDA,Display-B',
                'Vendor ID' => '0x10de'
            }
        },
        'USB' => {
            'USB Bus' => {
                'Host Controller Driver' => 'AppleUSBOHCI',
                'USB Optical Mouse' => {
                    'Location ID' => '0x2b100000',
                    'Version' => '2.00',
                    'Current Available (mA)' => '500',
                    'Speed' => 'Up to 1.5 Mb/sec',
                    'Product ID' => '0x4d15',
                    'Current Required (mA)' => '100',
                    'Vendor ID' => '0x0461  (Primax Electronics)'
                },
                'PCI Device ID' => '0x0035',
                'Host Controller Location' => 'Built In USB',
                'Bus Number' => '0x2b',
                'PCI Vendor ID' => '0x1033',
                'PCI Revision ID' => '0x0043'
            },
            'USB High-Speed Bus' => {
                'Flash Disk' => {
                    'Location ID' => '0x4b400000',
                    'Volumes' => {
                        'disk1s1' => {
                            'File System' => 'MS-DOS FAT32',
                            'Writable' => 'Yes',
                            'Capacity' => '1,96 GB',
                            'Available' => '1,96 GB'
                        }
                    },
                    'Product ID' => '0x2092',
                    'Current Required (mA)' => '100',
                    'Serial Number' => '110074973765',
                    'Detachable Drive' => 'Yes',
                    'Capacity' => '1,96 GB',
                    'Removable Media' => 'Yes',
                    'Version' => '1.00',
                    'Mac OS 9 Drivers' => 'No',
                    'Current Available (mA)' => '500',
                    'Speed' => 'Up to 480 Mb/sec',
                    'BSD Name' => 'disk1',
                    'S.M.A.R.T. status' => 'Not Supported',
                    'Partition Map Type' => 'MBR (Master Boot Record)',
                    'Manufacturer' => 'USB 2.0',
                    'Vendor ID' => '0x1e3d  (Chipsbrand Technologies (HK) Co., Limited)'
                },
                'Host Controller Driver' => 'AppleUSBEHCI',
                'PCI Device ID' => '0x00e0',
                'Host Controller Location' => 'Built In USB',
                'Bus Number' => '0x4b',
                'DataTraveler 2.0' => {
                    'Location ID' => '0x4b100000',
                    'Volumes' => {
                        'disk2s1' => {
                            'File System' => 'MS-DOS FAT32',
                            'Writable' => 'Yes',
                            'Capacity' => '3,76 GB',
                            'Available' => '678,8 MB'
                        }
                    },
                    'Product ID' => '0x1607',
                    'Current Required (mA)' => '100',
                    'Serial Number' => '89980116200801151425097A',
                    'Detachable Drive' => 'Yes',
                    'Capacity' => '3,76 GB',
                    'Removable Media' => 'Yes',
                    'Version' => '2.00',
                    'Mac OS 9 Drivers' => 'No',
                    'Current Available (mA)' => '500',
                    'Speed' => 'Up to 480 Mb/sec',
                    'BSD Name' => 'disk2',
                    'S.M.A.R.T. status' => 'Not Supported',
                    'Partition Map Type' => 'MBR (Master Boot Record)',
                    'Manufacturer' => 'Kingston',
                    'Vendor ID' => '0x0951  (Kingston Technology Company)'
                },
                'PCI Revision ID' => '0x0004',
                'PCI Vendor ID' => '0x1033'
            }
        },
        'ATA' => {
            'ATA Bus' => {
                'HL-DT-ST DVD-RW GWA-4165B' => {
                    'Revision' => 'C006',
                    'Detachable Drive' => 'No',
                    'Serial Number' => 'B6FD7234EC63',
                    'Protocol' => 'ATAPI',
                    'Unit Number' => {
                        'Low Power Polling' => 'No',
                        'Socket Type' => 'Internal',
                        'Power Off' => 'No'
                    },
                    'Model' => 'HL-DT-ST DVD-RW GWA-4165B'
                }
            }
        },
        'Audio (Built In)' => {
            'Built-in Sound Card' => {
                'Formats' => {
                    'PCM 24' => {
                        'Sample Rates' => '32 KHz, 44.1 KHz, 48 KHz, 64 KHz, 88.2 KHz, 96 KHz',
                        'Mixable' => 'Yes',
                        'Channels' => '2',
                        'Bit Width' => '32',
                        'Bit Depth' => '24'
                    },
                    'PCM 16' => {
                        'Sample Rates' => '32 KHz, 44.1 KHz, 48 KHz, 64 KHz, 88.2 KHz, 96 KHz',
                        'Mixable' => 'Yes',
                        'Channels' => '2',
                        'Bit Width' => '16',
                        'Bit Depth' => '16'
                    },
                    'AC3 16' => {
                        'Sample Rates' => '32 KHz, 44.1 KHz, 48 KHz, 64 KHz, 88.2 KHz, 96 KHz',
                        'Mixable' => 'No',
                        'Channels' => '2',
                        'Bit Width' => '16',
                        'Bit Depth' => '16'
                    }
                },
                'Devices' => {
                    'Crystal Semiconductor CS84xx' => {
                        'Inputs and Outputs' => {
                            'S/PDIF Digital Input' => {
                                'Playthrough' => 'No',
                                'PluginID' => 'Topaz',
                                'Controls' => 'Mute'
                            }
                        }
                    }
                }
            }
        },
        'Disc Burning' => {
            'HL-DT-ST DVD-RW GWA-4165B' => {
                'Reads DVD' => 'Yes',
                'Cache' => '2048 KB',
                'Write Strategies' => 'CD-TAO, CD-SAO, CD-Raw, DVD-DAO',
                'Media' => 'Insert media and refresh to show available burn speeds',
                'Interconnect' => 'ATAPI',
                'DVD-Write' => '-R, -RW, +R, +R DL, +RW',
                'Burn Support' => 'Yes (Apple Shipping Drive)',
                'CD-Write' => '-R, -RW',
                'Firmware Revision' => 'C006'
            }
        },
        'Power' => {
            'Hardware Configuration' => {
                'UPS Installed' => 'No'
            },
            'System Power Settings' => {
                'AC Power' => {
                    'System Sleep Timer (Minutes)' => {
                        'Reduce Processor Speed' => 'No',
                        'Dynamic Power Step' => 'Yes',
                        'Display Sleep Timer (Minutes)' => '3',
                        'Disk Sleep Timer (Minutes)' => '10',
                        'Automatic Restart On Power Loss' => 'No',
                        'Sleep On Power Button' => 'Yes',
                        'Wake On AC Change' => 'No',
                        'Wake On Clamshell Open' => 'Yes',
                        'Wake On Modem Ring' => 'Yes',
                        'Wake On LAN' => 'Yes'
                    }
                }
            }
        },
        'Universal Access' => {
            'Universal Access Information' => {
                'Zoom' => 'Off',
                'Display' => 'Black on White',
                'Slow Keys' => 'Off',
                'Flash Screen' => 'Off',
                'Mouse Keys' => 'Off',
                'Sticky Keys' => 'Off',
                'VoiceOver' => 'Off',
                'Cursor Magnification' => 'Off'
            }
        },
        'Volumes' => {
            'home' => {
                'Mounted From' => 'map auto_home',
                'Mount Point' => '/home',
                'Type' => 'autofs',
                'Automounted' => 'Yes'
            },
            'net' => {
                'Mounted From' => 'map -hosts',
                'Mount Point' => '/net',
                'Type' => 'autofs',
                'Automounted' => 'Yes'
            }
        },
        'Network' => {
            'FireWire' => {
                'Has IP Assigned' => 'No',
                'Type' => 'FireWire',
                'IPv6' => {
                    'Configuration Method' => 'Automatic'
                },
                'BSD Device Name' => 'fw0',
                'Ethernet' => {
                    'Media Subtype' => 'Auto Select',
                    'MAC Address' => '00:14:51:ff:fe:1a:c8:e2',
                    'Media Options' => 'Full Duplex'
                },
                'Hardware' => 'FireWire',
                'Proxies' => {
                    'FTP Passive Mode' => 'Yes',
                    'Exceptions List' => '*.local, 169.254/16'
                }
            },
            'Ethernet' => {
                'Has IP Assigned' => 'Yes',
                'IPv6' => {
                    'Configuration Method' => 'Automatic'
                },
                'BSD Device Name' => 'en0',
                'Ethernet' => {
                    'Media Subtype' => '100baseTX',
                    'MAC Address' => '00:14:51:61:ef:08',
                    'Media Options' => 'Full Duplex, flow-control'
                },
                'AppleTalk' => {
                    'Node ID' => '4',
                    'Network ID' => '65420',
                    'Interface Name' => 'en0',
                    'Default Zone' => '*',
                    'Configuration Method' => 'Node'
                },
                'Hardware' => 'Ethernet',
                'DNS' => {
                    'Server Addresses' => '10.0.1.1',
                    'Domain Name' => 'lan',
                    'Search Domains' => 'lan'
                },
                'DHCP Server Responses' => {
                    'Domain Name' => 'lan',
                    'Lease Duration (seconds)' => {
                        'Routers' => '10.0.1.1',
                        'Subnet Mask' => '255.255.255.0',
                        'Server Identifier' => '10.0.1.1',
                        'DHCP Message Type' => '0x05'
                    },
                    'Domain Name Servers' => '10.0.1.1'
                },
                'Type' => 'Ethernet',
                'IPv4 Addresses' => '10.0.1.110',
                'IPv4' => {
                    'Router' => '10.0.1.1',
                    'NetworkSignature' => 'IPv4.Router=10.0.1.1;IPv4.RouterHardwareAddress=00:1d:7e:43:96:57',
                    'Interface Name' => 'en0',
                    'Configuration Method' => 'DHCP',
                    'Subnet Masks' => '255.255.255.0',
                    'Addresses' => '10.0.1.110'
                },
                'Proxies' => {
                    'FTP Passive Mode' => 'Yes',
                    'Exceptions List' => '*.local, 169.254/16'
                }
            },
            'Bluetooth' => {
                'Has IP Assigned' => 'No',
                'Type' => 'PPP (PPPSerial)',
                'IPv6' => {
                    'Configuration Method' => 'Automatic'
                },
                'BSD Device Name' => 'Bluetooth-Modem',
                'IPv4' => {
                    'Configuration Method' => 'PPP'
                },
                'Hardware' => 'Modem',
                'Proxies' => {
                    'FTP Passive Mode' => 'Yes'
                }
            },
            'AirPort' => {
                'Has IP Assigned' => 'No',
                'IPv6' => {
                    'Configuration Method' => 'Automatic'
                },
                'BSD Device Name' => 'en1',
                'Ethernet' => {
                    'MAC Address' => '00:14:51:61:ef:09',
                    'Media Options' => {
                        'Media Subtype' => 'Auto Select'
                    }
                },
                'Hardware' => 'AirPort',
                'Type' => 'AirPort',
                'IPv4' => {
                    'Configuration Method' => 'DHCP'
                },
                'Proxies' => {
                    'FTP Passive Mode' => 'Yes',
                    'Exceptions List' => '*.local, 169.254/16'
                }
            }
        },
        'Hardware' => {
            'Hardware Overview' => {
                'Model Identifier' => 'PowerMac11,2',
                'Boot ROM Version' => '5.2.7f1',
                'Processor Speed' => '2.3 GHz',
                'Hardware UUID' => '00000000-0000-1000-8000-00145161EF08',
                'Bus Speed' => '1.15 GHz',
                'Processor Name' => 'PowerPC G5 (1.1)',
                'Model Name' => 'Power Mac G5',
                'Number Of CPUs' => '2',
                'Memory' => '2 GB',
                'Serial Number (system)' => 'CK54202SR6V',
                'L2 Cache (per CPU)' => '1 MB'
            }
        },
        'Diagnostics' => {
            'Power On Self-Test' => {
                'Result' => 'Passed',
                'Last Run' => '25/07/10 13:10'
            }
        },
        'Serial-ATA' => {
            'Serial-ATA Bus' => {
                'Maxtor 6B250S0' => {
                    'Volumes' => {
                        'disk0s5' => {
                            'File System' => 'Journaled HFS+',
                            'Writable' => 'Yes',
                            'Capacity' => '212,09 GB',
                            'Available' => '211,8 GB'
                        },
                        'disk0s3' => {
                            'File System' => 'Journaled HFS+',
                            'Writable' => 'Yes',
                            'Capacity' => '21,42 GB',
                            'Available' => '6,69 GB'
                        }
                    },
                    'Revision' => 'BANC1E50',
                    'Detachable Drive' => 'No',
                    'Serial Number' => 'B623KFXH',
                    'Capacity' => '233,76 GB',
                    'Model' => 'Maxtor 6B250S0',
                    'Removable Media' => 'No',
                    'BSD Name' => 'disk0',
                    'Protocol' => 'ata',
                    'Unit Number' => {
                        'Mac OS 9 Drivers' => 'No',
                        'Socket Type' => 'Serial-ATA',
                        'S.M.A.R.T. status' => 'Verified',
                        'Partition Map Type' => 'APM (Apple Partition Map)',
                        'Bay Name' => '"B (lower)"'
                    }
                }
            }
        },
        'FireWire' => {
            'FireWire Bus' => {
                'Maximum Speed' => 'Up to 800 Mb/sec',
                'Unknown Device' => {
                    'Maximum Speed' => 'Up to 400 Mb/sec',
                    'Manufacturer' => 'Unknown',
                    'Model' => 'Unknown',
                    'Connection Speed' => 'Unknown'
                },
                '(1394 ATAPI,Rev 1.00)' => {
                    'Maximum Speed' => 'Up to 400 Mb/sec',
                    'Sub-units' => {
                        '(1394 ATAPI,Rev 1.00) Unit' => {
                            'Firmware Revision' => '0x12804',
                            'Sub-units' => {
                                '(1394 ATAPI,Rev 1.00) SBP-LUN' => {
                                    'Volumes' => {
                                        'disk3s3' => {
                                            'File System' => 'Journaled HFS+',
                                            'Writable' => 'Yes',
                                            'Capacity' => '186,19 GB',
                                            'Available' => '36,07 GB'
                                        }
                                    },
                                    'Mac OS 9 Drivers' => 'No',
                                    'BSD Name' => 'disk3',
                                    'S.M.A.R.T. status' => 'Not Supported',
                                    'Partition Map Type' => 'APM (Apple Partition Map)',
                                    'Capacity' => '186,31 GB',
                                    'Removable Media' => 'Yes'
                                }
                            },
                            'Product Revision Level' => {},
                            'Unit Spec ID' => '0x609E',
                            'Unit Software Version' => '0x10483'
                        }
                    },
                    'Manufacturer' => 'Prolific PL3507 Combo Device',
                    'GUID' => '0x50770E0000043E',
                    'Model' => '0x1',
                    'Connection Speed' => 'Up to 400 Mb/sec'
                }
            }
        },
        'Software' => {
            'System Software Overview' => {
                'Time since boot' => '30 minutes',
                'Boot Mode' => 'Normal',
                'Boot Volume' => 'osx105',
                'System Version' => 'Mac OS X 10.5.8 (9L31a)',
                'Kernel Version' => 'Darwin 9.8.0',
                'User Name' => 'fusioninventory (fusioninventory)',
                'Computer Name' => 'g5'
            }
        },
        'Memory' => {
            'DIMM5/J7200' => {
                'Part Number' => 'Empty',
                'Type' => 'Empty',
                'Speed' => 'Empty',
                'Size' => 'Empty',
                'Status' => 'Empty',
                'Serial Number' => 'Empty',
                'Manufacturer' => 'Empty'
            },
            'DIMM3/J7000' => {
                'Part Number' => 'Empty',
                'Type' => 'Empty',
                'Speed' => 'Empty',
                'Size' => 'Empty',
                'Status' => 'Empty',
                'Serial Number' => 'Empty',
                'Manufacturer' => 'Empty'
            },
            'DIMM2/J6900' => {
                'Part Number' => 'Empty',
                'Type' => 'Empty',
                'Speed' => 'Empty',
                'Size' => 'Empty',
                'Status' => 'Empty',
                'Serial Number' => 'Empty',
                'Manufacturer' => 'Empty'
            },
            'DIMM0/J6700' => {
                'Part Number' => 'Unknown',
                'Type' => 'DDR2 SDRAM',
                'Speed' => 'PC2-4200U-444',
                'Size' => '1 GB',
                'Status' => 'OK',
                'Serial Number' => 'Unknown',
                'Manufacturer' => 'Unknown'
            },
            'DIMM6/J7300' => {
                'Part Number' => 'Empty',
                'Type' => 'Empty',
                'Speed' => 'Empty',
                'Size' => 'Empty',
                'Status' => 'Empty',
                'Serial Number' => 'Empty',
                'Manufacturer' => 'Empty'
            },
            'DIMM1/J6800' => {
                'Part Number' => 'Unknown',
                'Type' => 'DDR2 SDRAM',
                'Speed' => 'PC2-4200U-444',
                'Size' => '1 GB',
                'Status' => 'OK',
                'Serial Number' => 'Unknown',
                'Manufacturer' => 'Unknown'
            },
            'DIMM4/J7100' => {
                'Part Number' => 'Empty',
                'Type' => 'Empty',
                'Speed' => 'Empty',
                'Size' => 'Empty',
                'Status' => 'Empty',
                'Serial Number' => 'Empty',
                'Manufacturer' => 'Empty'
            },
            'DIMM7/J7400' => {
                'Part Number' => 'Empty',
                'Type' => 'Empty',
                'Speed' => 'Empty',
                'Size' => 'Empty',
                'Status' => 'Empty',
                'Serial Number' => 'Empty',
                'Manufacturer' => 'Empty'
            }
        },
        'Firewall' => {
            'Firewall Settings' => {
                'Mode' => 'Allow all incoming connections'
            }
        },
        'Printers' => {
            'Photosmart C4500 series [38705D]' => {
                'PPD' => 'HP Photosmart C4500 series',
                'Print Server' => 'Local',
                'PPD File Version' => '3.1',
                'URI' => 'mdns://Photosmart%20C4500%20series%20%5B38705D%5D._pdl-datastream._tcp.local./?bidi',
                'Default' => 'Yes',
                'Status' => 'Idle',
                'Driver Version' => '3.1',
                'PostScript Version' => '(3011.104) 0'
            }
        },
        'Graphics/Displays' => {
            'NVIDIA GeForce 6600' => {
                'Displays' => {
                    'Display Connector' => {
                        'Status' => 'No Display Connected'
                    },
                    'ASUS VH222' => {
                        'Quartz Extreme' => 'Supported',
                        'Core Image' => 'Hardware Accelerated',
                        'Main Display' => 'Yes',
                        'Resolution' => '1680 x 1050 @ 60 Hz',
                        'Depth' => '32-Bit Color',
                        'Mirror' => 'Off',
                        'Online' => 'Yes',
                        'Rotation' => 'Supported'
                    }
                },
                'Slot' => 'SLOT-1',
                'PCIe Lane Width' => 'x16',
                'Chipset Model' => 'GeForce 6600',
                'Revision ID' => '0x00a4',
                'Device ID' => '0x0141',
                'Vendor' => 'NVIDIA (0x10de)',
                'Type' => 'Display',
                'ROM Revision' => '2149',
                'Bus' => 'PCIe',
                'VRAM (Total)' => '256 MB'
            }
        }
    },
    'system_profiler_full_10.6-intel' => {
        'Locations' => {
            'Automatic' => {
                'Services' => {
                    'Bluetooth DUN' => {
                        'Type' => 'PPP',
                        'IPv6' => {
                            'Configuration Method' => 'Automatic'
                        },
                        'IPv4' => {
                            'Configuration Method' => 'PPP'
                        },
                        'Proxies' => {
                            'FTP Passive Mode' => 'Yes'
                        },
                        'PPP' => {
                            'IPCP Compression VJ' => 'Yes',
                            'Idle Reminder' => 'No',
                            'Idle Reminder Time' => '1800',
                            'Disconnect on Logout' => 'Yes',
                            'ACSP Enabled' => 'No',
                            'Log File' => '/var/log/ppp.log',
                            'Redial Enabled' => 'Yes',
                            'Verbose Logging' => 'No',
                            'Dial on Demand' => 'No',
                            'Redial Interval' => '5',
                            'Use Terminal Script' => 'No',
                            'Disconnect on Idle Timer' => '600',
                            'Disconnect on Sleep' => 'Yes',
                            'LCP Echo Failure' => '4',
                            'Disconnect on Idle' => 'Yes',
                            'Disconnect on Fast User Switch' => 'Yes',
                            'LCP Echo Interval' => '10',
                            'Redial Count' => '1',
                            'LCP Echo Enabled' => 'No',
                            'Display Terminal Window' => 'No'
                        }
                    },
                    'Parallels Host-Only Networking Adapter' => {
                        'Type' => 'Ethernet',
                        'IPv6' => {
                            'Configuration Method' => 'Automatic'
                        },
                        'BSD Device Name' => 'en3',
                        'IPv4' => {
                            'Configuration Method' => 'Manual',
                            'Subnet Masks' => '255.255.255.0',
                            'Addresses' => '192.168.1.16'
                        },
                        'Proxies' => {
                            'Exclude Simple Hostnames' => 'No',
                            'Auto Discovery Enabled' => 'No',
                            'FTP Passive Mode' => 'Yes',
                            'Proxy Configuration Method' => '2'
                        },
                        'Hardware (MAC) Address' => '00:1c:42:00:00:09'
                    },
                    'Parallels Shared Networking Adapter' => {
                        'Type' => 'Ethernet',
                        'IPv6' => {
                            'Configuration Method' => 'Automatic'
                        },
                        'BSD Device Name' => 'en2',
                        'IPv4' => {
                            'Configuration Method' => 'Manual',
                            'Subnet Masks' => '255.255.255.0',
                            'Addresses' => '192.168.0.11'
                        },
                        'Proxies' => {
                            'Exclude Simple Hostnames' => 'No',
                            'Auto Discovery Enabled' => 'No',
                            'FTP Passive Mode' => 'Yes',
                            'Proxy Configuration Method' => '2'
                        },
                        'Hardware (MAC) Address' => '00:1c:42:00:00:08'
                    },
                    'FireWire' => {
                        'Type' => 'FireWire',
                        'IPv6' => {
                            'Configuration Method' => 'Automatic'
                        },
                        'BSD Device Name' => 'fw0',
                        'IPv4' => {
                            'Configuration Method' => 'DHCP'
                        },
                        'Proxies' => {
                            'FTP Passive Mode' => 'Yes',
                            'Exceptions List' => '*.local, 169.254/16'
                        },
                        'Hardware (MAC) Address' => '00:1e:52:ff:fe:67:eb:68'
                    },
                    'Ethernet' => {
                        'Type' => 'Ethernet',
                        'IPv6' => {
                            'Configuration Method' => 'Automatic'
                        },
                        'BSD Device Name' => 'en0',
                        'IPv4' => {
                            'Configuration Method' => 'DHCP'
                        },
                        'Proxies' => {
                            'FTP Passive Mode' => 'Yes',
                            'Exceptions List' => '*.local, 169.254/16'
                        },
                        'Hardware (MAC) Address' => '00:1e:c2:0c:36:27'
                    },
                    'AirPort' => {
                        'Type' => 'IEEE80211',
                        'IPv6' => {
                            'Configuration Method' => 'Automatic'
                        },
                        'BSD Device Name' => 'en1',
                        'IPv4' => {
                            'Configuration Method' => 'DHCP'
                        },
                        'Proxies' => {
                            'HTTP Proxy Server' => '195.221.21.146',
                            'HTTP Proxy Port' => '80',
                            'FTP Passive Mode' => 'Yes',
                            'HTTP Proxy Enabled' => 'No',
                            'Exceptions List' => '*.local, 169.254/16'
                        },
                        'Hardware (MAC) Address' => '00:1e:c2:a7:26:6f',
                        'IEEE80211' => {
                            'Join Mode' => 'Automatic',
                            'Disconnect on Logout' => 'No',
                            'PowerEnabled' => {},
                            'PreferredNetworks' => {
                                'Unique Network ID' => '905AE8BA-BD26-48F3-9486-AE5BC72FE642',
                                'RememberRecentNetworks' => '1',
                                'SecurityType' => 'WPA2 Personal',
                                'Unique Password ID' => '907EDC44-8C27-44A0-B5F5-2D04E1A5942A',
                                'SSID_STR' => 'freewa'
                            },
                            'JoinModeFallback' => 'Prompt'
                        }
                    }
                },
                'Active Location' => 'Yes'
            }
        },
        'USB' => {
            'USB Bus' => {
                'Host Controller Driver' => 'AppleUSBUHCI',
                'PCI Device ID' => '0x2834',
                'Bluetooth USB Host Controller' => {
                    'Location ID' => '0x1a100000',
                    'Version' => '19.65',
                    'Current Available (mA)' => '500',
                    'Speed' => 'Up to 12 Mb/sec',
                    'Product ID' => '0x8206',
                    'Current Required (mA)' => {},
                    'Manufacturer' => 'Apple Inc.',
                    'Vendor ID' => '0x05ac  (Apple Inc.)'
                },
                'Host Controller Location' => 'Built-in USB',
                'Bus Number' => '0x1a',
                'PCI Vendor ID' => '0x8086',
                'PCI Revision ID' => '0x0003'
            },
            'USB High-Speed Bus' => {
                'Keyboard Hub' => {
                    'Location ID' => '0xfa200000',
                    'Optical USB Mouse' => {
                        'Location ID' => '0xfa230000',
                        'Version' => ' 3.40',
                        'Current Available (mA)' => '100',
                        'Speed' => 'Up to 1.5 Mb/sec',
                        'Product ID' => '0xc016',
                        'Current Required (mA)' => '100',
                        'Manufacturer' => 'Logitech',
                        'Vendor ID' => '0x046d  (Logitech Inc.)'
                    },
                    'Flash Disk      ' => {
                        'Location ID' => '0xfa210000',
                        'Volumes' => {
                            'SANS TITRE' => {
                                'Mount Point' => '/Volumes/SANS TITRE',
                                'File System' => 'MS-DOS FAT32',
                                'Writable' => 'Yes',
                                'BSD Name' => 'disk1s1',
                                'Capacity' => '2,11 GB (2 109 671 424 bytes)',
                                'Available' => '2,11 GB (2 105 061 376 bytes)'
                            }
                        },
                        'Product ID' => '0x2092',
                        'Current Required (mA)' => '100',
                        'Serial Number' => '110074973765',
                        'Detachable Drive' => 'Yes',
                        'Capacity' => '2,11 GB (2 109 734 912 bytes)',
                        'Removable Media' => 'Yes',
                        'Version' => ' 1.00',
                        'Current Available (mA)' => '100',
                        'Speed' => 'Up to 480 Mb/sec',
                        'BSD Name' => 'disk1',
                        'S.M.A.R.T. status' => 'Not Supported',
                        'Partition Map Type' => 'MBR (Master Boot Record)',
                        'Manufacturer' => 'USB 2.0',
                        'Vendor ID' => '0x1e3d  (Chipsbrand Technologies (HK) Co., Limited)'
                    },
                    'Product ID' => '0x1006',
                    'Current Required (mA)' => '300',
                    'Serial Number' => '000000000000',
                    'Version' => '94.15',
                    'Speed' => 'Up to 480 Mb/sec',
                    'Current Available (mA)' => '500',
                    'Apple Keyboard' => {
                        'Location ID' => '0xfa220000',
                        'Version' => ' 0.69',
                        'Current Available (mA)' => '100',
                        'Speed' => 'Up to 1.5 Mb/sec',
                        'Product ID' => '0x0221',
                        'Current Required (mA)' => '20',
                        'Manufacturer' => 'Apple, Inc',
                        'Vendor ID' => '0x05ac  (Apple Inc.)'
                    },
                    'Manufacturer' => 'Apple, Inc.',
                    'Vendor ID' => '0x05ac  (Apple Inc.)'
                },
                'Host Controller Driver' => 'AppleUSBEHCI',
                'PCI Device ID' => '0x283a',
                'Host Controller Location' => 'Built-in USB',
                'Bus Number' => '0xfa',
                'PCI Vendor ID' => '0x8086',
                'PCI Revision ID' => '0x0003'
            }
        },
        'ATA' => {
            'ATA Bus' => {
                'MATSHITADVD-R   UJ-875' => {
                    'Revision' => 'DB09',
                    'Detachable Drive' => 'No',
                    'Serial Number' => '            fG424F9E',
                    'Protocol' => 'ATAPI',
                    'Unit Number' => {
                        'Low Power Polling' => 'Yes',
                        'Socket Type' => 'Internal',
                        'Power Off' => 'No'
                    },
                    'Model' => 'MATSHITADVD-R   UJ-875'
                }
            }
        },
        'Audio (Built In)' => {
            'Intel High Definition Audio' => {
                'Speaker' => {
                    'Connection' => 'Internal'
                },
                'S/PDIF Optical Digital Audio Input' => {
                    'Connection' => 'Combination Input'
                },
                'Headphone' => {
                    'Connection' => 'Combination Output'
                },
                'Internal Microphone' => {
                    'Connection' => 'Internal'
                },
                'Line Input' => {
                    'Connection' => 'Combination Input'
                },
                'Audio ID' => '50',
                'S/PDIF Optical Digital Audio Output' => {
                    'Connection' => 'Combination Output'
                }
            }
        },
        'Disc Burning' => {
            'MATSHITA DVD-R   UJ-875' => {
                'Reads DVD' => 'Yes',
                'Cache' => '2048 KB',
                'Write Strategies' => 'CD-TAO, CD-SAO, DVD-DAO',
                'Media' => 'To show the available burn speeds, insert a disc and choose View > Refresh',
                'Interconnect' => 'ATAPI',
                'DVD-Write' => '-R, -R DL, -RW, +R, +R DL, +RW',
                'Burn Support' => 'Yes (Apple Shipping Drive)',
                'CD-Write' => '-R, -RW',
                'Firmware Revision' => 'DB09'
            }
        },
        'Bluetooth' => {
            'Devices (Paired, Favorites, etc)' => {
                'Device' => {
                    'Type' => 'Mobile Phone',
                    'Connected' => 'No',
                    'Paired' => 'Yes',
                    'Services' => 'Dial-up Networking, OBEX File Transfer, Voice GW, Object Push, Voice GW, WBTEXT, Advanced audio source, Serial Port',
                    'Address' => '00-1e-e2-27-e9-02',
                    'Manufacturer' => 'Broadcom (0x3, 0x2222)',
                    'Name' => 'SGH-D880',
                    'Favorite' => 'Yes'
                }
            },
            'Apple Bluetooth Software Version' => '2.3.3f8',
            'Outgoing Serial Ports' => {
                'Serial Port 1' => {
                    'Address' => {
                        'Name' => 'Bluetooth-Modem'
                    },
                    'RFCOMM Channel' => {
                        'Requires Authentication' => 'No'
                    }
                }
            },
            'Services' => {
                'Bluetooth File Transfer' => {
                    'Folder other devices can browse' => '~/Public',
                    'Requires Authentication' => 'Yes',
                    'State' => 'Enabled'
                },
                'Bluetooth File Exchange' => {
                    'When receiving items' => 'Prompt for each file',
                    'Folder for accepted items' => '~/Documents',
                    'When PIM items are accepted' => 'Ask',
                    'Requires Authentication' => 'No',
                    'State' => 'Enabled',
                    'When other items are accepted' => 'Ask'
                }
            },
            'Hardware Settings' => {
                'Firmware Version' => '1965',
                'Product ID' => '0x8206',
                'Bluetooth Power' => 'On',
                'Address' => '00-1e-52-ed-37-e4',
                'Requires Authentication' => 'No',
                'Discoverable' => 'Yes',
                'Manufacturer' => 'Cambridge Silicon Radio',
                'Vendor ID' => '0x5ac',
                'Name' => 'lazer'
            },
            'Incoming Serial Ports' => {
                'Serial Port 1' => {
                    'Requires Authentication' => 'No',
                    'RFCOMM Channel' => '3',
                    'Name' => 'Bluetooth-PDA-Sync'
                }
            }
        },
        'Power' => {
            'Hardware Configuration' => {
                'UPS Installed' => 'No'
            },
            'System Power Settings' => {
                'AC Power' => {
                    'Display Sleep Timer (Minutes)' => '1',
                    'Disk Sleep Timer (Minutes)' => '10',
                    'Automatic Restart On Power Loss' => 'No',
                    'System Sleep Timer (Minutes)' => '10',
                    'Sleep On Power Button' => 'Yes',
                    'Current Power Source' => 'Yes',
                    'Display Sleep Uses Dim' => 'Yes',
                    'Wake On LAN' => 'No'
                }
            }
        },
        'Universal Access' => {
            'Universal Access Information' => {
                'Zoom' => 'On',
                'Display' => 'Black on White',
                'Slow Keys' => 'Off',
                'Flash Screen' => 'Off',
                'Mouse Keys' => 'Off',
                'Sticky Keys' => 'Off',
                'VoiceOver' => 'Off',
                'Cursor Magnification' => 'Off'
            }
        },
        'Volumes' => {
            'home' => {
                'Mounted From' => 'map auto_home',
                'Mount Point' => '/home',
                'Type' => 'autofs',
                'Automounted' => 'Yes'
            },
            'net' => {
                'Mounted From' => 'map -hosts',
                'Mount Point' => '/net',
                'Type' => 'autofs',
                'Automounted' => 'Yes'
            }
        },
        'Network' => {
            'Parallels Host-Only Networking Adapter' => {
                'Has IP Assigned' => 'Yes',
                'IPv6' => {
                    'Configuration Method' => 'Automatic'
                },
                'BSD Device Name' => 'en3',
                'Ethernet' => {
                    'MAC Address' => '00:1c:42:00:00:09',
                    'Media Options' => {
                        'Media Subtype' => 'Auto Select'
                    }
                },
                'Hardware' => 'Ethernet',
                'Type' => 'Ethernet',
                'IPv4 Addresses' => '192.168.1.16',
                'IPv4' => {
                    'Interface Name' => 'en3',
                    'Configuration Method' => 'Manual',
                    'Subnet Masks' => '255.255.255.0',
                    'Addresses' => '192.168.1.16'
                },
                'Proxies' => {
                    'Exclude Simple Hostnames' => {
                        'Auto Discovery Enabled' => 'No',
                        'FTP Passive Mode' => 'Yes',
                        'Service Order' => '9'
                    },
                    'Proxy Configuration Method' => 'Manual'
                }
            },
            'Parallels Shared Networking Adapter' => {
                'Has IP Assigned' => 'Yes',
                'IPv6' => {
                    'Configuration Method' => 'Automatic'
                },
                'BSD Device Name' => 'en2',
                'Ethernet' => {
                    'MAC Address' => '00:1c:42:00:00:08',
                    'Media Options' => {
                        'Media Subtype' => 'Auto Select'
                    }
                },
                'Hardware' => 'Ethernet',
                'Type' => 'Ethernet',
                'IPv4 Addresses' => '192.168.0.11',
                'IPv4' => {
                    'Interface Name' => 'en2',
                    'Configuration Method' => 'Manual',
                    'Subnet Masks' => '255.255.255.0',
                    'Addresses' => '192.168.0.11'
                },
                'Proxies' => {
                    'Exclude Simple Hostnames' => {
                        'Auto Discovery Enabled' => 'No',
                        'FTP Passive Mode' => 'Yes',
                        'Service Order' => '8'
                    },
                    'Proxy Configuration Method' => 'Manual'
                }
            },
            'FireWire' => {
                'Has IP Assigned' => 'No',
                'Type' => 'FireWire',
                'IPv6' => {
                    'Configuration Method' => 'Automatic'
                },
                'BSD Device Name' => 'fw0',
                'Ethernet' => {
                    'Media Subtype' => 'Auto Select',
                    'MAC Address' => '00:1e:52:ff:fe:67:eb:68',
                    'Media Options' => 'Full Duplex'
                },
                'IPv4' => {
                    'Configuration Method' => 'DHCP'
                },
                'Hardware' => 'FireWire',
                'Proxies' => {
                    'FTP Passive Mode' => 'Yes',
                    'Service Order' => '2',
                    'Exceptions List' => '*.local, 169.254/16'
                }
            },
            'Ethernet' => {
                'Has IP Assigned' => 'Yes',
                'IPv6' => {
                    'Configuration Method' => 'Automatic'
                },
                'BSD Device Name' => 'en0',
                'Ethernet' => {
                    'Media Subtype' => '100baseTX',
                    'MAC Address' => '00:1e:c2:0c:36:27',
                    'Media Options' => 'Full Duplex, Flow Control'
                },
                'Hardware' => 'Ethernet',
                'DNS' => {
                    'Server Addresses' => '10.0.1.1',
                    'Domain Name' => 'lan'
                },
                'Type' => 'Ethernet',
                'IPv4 Addresses' => '10.0.1.101',
                'DHCP Server Responses' => {
                    'Domain Name' => 'lan',
                    'Lease Duration (seconds)' => {
                        'Routers' => '10.0.1.1',
                        'Subnet Mask' => '255.255.255.0',
                        'Server Identifier' => '10.0.1.1',
                        'DHCP Message Type' => '0x05'
                    },
                    'Domain Name Servers' => '10.0.1.1'
                },
                'IPv4' => {
                    'Router' => '10.0.1.1',
                    'Interface Name' => 'en0',
                    'Network Signature' => 'IPv4.Router=10.0.1.1;IPv4.RouterHardwareAddress=00:1d:7e:43:96:57',
                    'Configuration Method' => 'DHCP',
                    'Subnet Masks' => '255.255.255.0',
                    'Addresses' => '10.0.1.101'
                },
                'Proxies' => {
                    'FTP Passive Mode' => 'Yes',
                    'Service Order' => '1',
                    'Exceptions List' => '*.local, 169.254/16'
                }
            },
            'Bluetooth' => {
                'Has IP Assigned' => 'No',
                'Type' => 'PPP (PPPSerial)',
                'IPv6' => {
                    'Configuration Method' => 'Automatic'
                },
                'BSD Device Name' => 'Bluetooth-Modem',
                'IPv4' => {
                    'Configuration Method' => 'PPP'
                },
                'Hardware' => 'Modem',
                'Proxies' => {
                    'FTP Passive Mode' => 'Yes'
                },
                'Service Order' => {}
            },
            'AirPort' => {
                'Has IP Assigned' => 'No',
                'Type' => 'AirPort',
                'IPv6' => {
                    'Configuration Method' => 'Automatic'
                },
                'BSD Device Name' => 'en1',
                'Ethernet' => {
                    'MAC Address' => '00:1e:c2:a7:26:6f',
                    'Media Options' => {
                        'Media Subtype' => 'Auto Select'
                    }
                },
                'IPv4' => {
                    'Configuration Method' => 'DHCP'
                },
                'Hardware' => 'AirPort',
                'Proxies' => {
                    'HTTP Proxy Server' => '195.221.21.146',
                    'HTTP Proxy Port' => '80',
                    'FTP Passive Mode' => 'Yes',
                    'HTTP Proxy Enabled' => 'No',
                    'Service Order' => '3',
                    'Exceptions List' => '*.local, 169.254/16'
                }
            }
        },
        'Ethernet Cards' => {
            'pci14e4,4328' => {
                'Slot' => 'AirPort',
                'Subsystem Vendor ID' => '0x106b',
                'Link Width' => 'x1',
                'Revision ID' => '0x0003',
                'Device ID' => '0x4328',
                'Kext name' => 'AppleAirPortBrcm4311.kext',
                'BSD name' => 'en1',
                'Version' => '423.91.27',
                'Type' => 'Other Network Controller',
                'Subsystem ID' => '0x0088',
                'Bus' => 'PCI',
                'Location' => '/System/Library/Extensions/IO80211Family.kext/Contents/PlugIns/AppleAirPortBrcm4311.kext',
                'Vendor ID' => '0x14e4'
            },
            'Marvell Yukon Gigabit Adapter 88E8055 Singleport Copper SA' => {
                'Subsystem Vendor ID' => '0x11ab',
                'Link Width' => 'x1',
                'Revision ID' => '0x0013',
                'Device ID' => '0x436a',
                'Kext name' => 'AppleYukon2.kext',
                'BSD name' => 'en0',
                'Version' => '3.1.14b1',
                'Type' => 'Ethernet Controller',
                'Subsystem ID' => '0x00ba',
                'Bus' => 'PCI',
                'Location' => '/System/Library/Extensions/IONetworkingFamily.kext/Contents/PlugIns/AppleYukon2.kext',
                'Name' => 'ethernet',
                'Vendor ID' => '0x11ab'
            }
        },
        'Hardware' => {
            'Hardware Overview' => {
                'SMC Version (system)' => '1.21f4',
                'Model Identifier' => 'iMac7,1',
                'Boot ROM Version' => 'IM71.007A.B03',
                'Processor Speed' => '2,4 GHz',
                'Hardware UUID' => '00000000-0000-1000-8000-001EC20C3627',
                'Bus Speed' => '800 MHz',
                'Total Number Of Cores' => '2',
                'Number Of Processors' => '1',
                'Processor Name' => 'Intel Core 2 Duo',
                'Model Name' => 'iMac',
                'Memory' => '2 GB',
                'Serial Number (system)' => 'W8805BRDX89',
                'L2 Cache' => '4 MB'
            }
        },
        'Diagnostics' => {
            'Power On Self-Test' => {
                'Result' => 'Passed',
                'Last Run' => '24/07/10 11:20'
            }
        },
        'Serial-ATA' => {
            'Intel ICH8-M AHCI' => {
                'WDC WD3200AAJS-40VWA0' => {
                    'Volumes' => {
                        'osx' => {
                            'Mount Point' => '/',
                            'File System' => 'Journaled HFS+',
                            'Writable' => 'Yes',
                            'BSD Name' => 'disk0s2',
                            'Capacity' => '216,53 GB (216 532 934 656 bytes)',
                            'Available' => '2,39 GB (2 389 823 488 bytes)'
                        },
                        'Sauvegardes' => {
                            'Mount Point' => '/Volumes/Sauvegardes',
                            'File System' => 'Journaled HFS+',
                            'Writable' => 'Yes',
                            'BSD Name' => 'disk0s3',
                            'Capacity' => '103,06 GB (103 061 807 104 bytes)',
                            'Available' => '1,76 GB (1 759 088 640 bytes)'
                        }
                    },
                    'Revision' => '58.01D02',
                    'Detachable Drive' => 'No',
                    'Serial Number' => '     WD-WMARW0629615',
                    'Capacity' => '320,07 GB (320 072 933 376 bytes)',
                    'Model' => 'WDC WD3200AAJS-40VWA0',
                    'Removable Media' => 'No',
                    'Medium Type' => 'Rotational',
                    'BSD Name' => 'disk0',
                    'S.M.A.R.T. status' => 'Verified',
                    'Partition Map Type' => 'GPT (GUID Partition Table)',
                    'Native Command Queuing' => 'Yes',
                    'Queue Depth' => '32'
                },
                'Link Speed' => '3 Gigabit',
                'Product' => 'ICH8-M AHCI',
                'Vendor' => 'Intel',
                'Description' => 'AHCI Version 1.10 Supported',
                'Negotiated Link Speed' => '3 Gigabit'
            }
        },
        'Firewall' => {
            'Firewall Settings' => {
                'Services' => {
                    'Remote Login (SSH)' => 'Allow all connections'
                },
                'Applications' => {
                    'org.sip-communicator' => 'Allow all connections',
                    'Firewall Logging' => 'No',
                    'com.skype.skype' => 'Allow all connections',
                    'com.Growl.GrowlHelperApp' => 'Allow all connections',
                    'com.hp.scan.app' => 'Allow all connections',
                    'com.parallels.desktop.dispatcher' => 'Allow all connections',
                    'Stealth Mode' => 'No',
                    'net.sourceforge.xmeeting.XMeeting' => 'Allow all connections',
                    'com.getdropbox.dropbox' => 'Allow all connections'
                },
                'Mode' => 'Limit incoming connections to specific services and applications'
            }
        },
        'Software' => {
            'System Software Overview' => {
                'Time since boot' => '1 day1:09',
                'Computer Name' => 'lazer',
                'Boot Volume' => 'osx',
                'Boot Mode' => 'Normal',
                'System Version' => 'Mac OS X 10.6.4 (10F569)',
                'Kernel Version' => 'Darwin 10.4.0',
                'Secure Virtual Memory' => 'Enabled',
                '64-bit Kernel and Extensions' => 'No',
                'User Name' => 'wawa (wawa)'
            }
        },
        'FireWire' => {
            'FireWire Bus' => {
                'Maximum Speed' => 'Up to 800 Mb/sec',
                '(1394 ATAPI,Rev 1.00)' => {
                    'Maximum Speed' => 'Up to 400 Mb/sec',
                    'Sub-units' => {
                        '(1394 ATAPI,Rev 1.00) Unit' => {
                            'Firmware Revision' => '0x12804',
                            'Sub-units' => {
                                '(1394 ATAPI,Rev 1.00) SBP-LUN' => {
                                    'Volumes' => {
                                        'Video' => {
                                            'Mount Point' => '/Volumes/Video',
                                            'File System' => 'Journaled HFS+',
                                            'Writable' => 'Yes',
                                            'BSD Name' => 'disk2s3',
                                            'Capacity' => '199,92 GB (199 915 397 120 bytes)',
                                            'Available' => '38,73 GB (38 726 303 744 bytes)'
                                        }
                                    },
                                    'BSD Name' => 'disk2',
                                    'S.M.A.R.T. status' => 'Not Supported',
                                    'Partition Map Type' => 'APM (Apple Partition Map)',
                                    'Capacity' => '200,05 GB (200 049 647 616 bytes)',
                                    'Removable Media' => 'Yes'
                                }
                            },
                            'Product Revision Level' => {},
                            'Unit Spec ID' => '0x609E',
                            'Unit Software Version' => '0x10483'
                        }
                    },
                    'Manufacturer' => 'Prolific PL3507 Combo Device',
                    'GUID' => '0x50770E0000043E',
                    'Model' => '0x1',
                    'Connection Speed' => 'Up to 400 Mb/sec'
                }
            }
        },
        'Memory' => {
            'Memory Slots' => {
                'ECC' => 'Disabled',
                'BANK 1/DIMM1' => {
                    'Part Number' => '0x313032343633363735305320202020202020',
                    'Type' => 'DDR2 SDRAM',
                    'Speed' => '667 MHz',
                    'Size' => '1 GB',
                    'Status' => 'OK',
                    'Serial Number' => '0x00000000',
                    'Manufacturer' => '0x0000000000000000'
                },
                'BANK 0/DIMM0' => {
                    'Part Number' => '0x3848544631323836344844592D3636374531',
                    'Type' => 'DDR2 SDRAM',
                    'Speed' => '667 MHz',
                    'Size' => '1 GB',
                    'Status' => 'OK',
                    'Serial Number' => '0xD5289015',
                    'Manufacturer' => '0x2C00000000000000'
                }
            }
        },
        'Printers' => {
            'Photosmart C4500 series [38705D]' => {
                'PPD' => 'HP Photosmart C4500 series',
                'CUPS Version' => '1.4.4 (cups-218.12)',
                'URI' => 'dnssd://Photosmart%20C4500%20series%20%5B38705D%5D._pdl-datastream._tcp.local./?bidi',
                'Default' => 'Yes',
                'Status' => 'Idle',
                'Driver Version' => '4.1',
                'Scanner UUID' => '-',
                'Print Server' => 'Local',
                'Scanning app' => '-',
                'Scanning support' => 'Yes',
                'PPD File Version' => '4.1',
                'Scanning app (bundleID path)' => '-',
                'Fax support' => 'No',
                'PostScript Version' => '(3011.104) 0'
            }
        },
        'AirPort' => {
            'Software Versions' => {
                'IO80211 Family' => '3.1.1 (311.1)',
                'AirPort Utility' => '5.5.1 (551.19)',
                'configd plug-in' => '6.2.3 (623.1)',
                'Menu Extra' => '6.2.1 (621.1)',
                'Network Preference' => '6.2.1 (621.1)',
                'System Profiler' => '6.0 (600.9)'
            },
            'Interfaces' => {
                'en1' => {
                    'Firmware Version' => 'Broadcom BCM43xx 1.0 (5.10.91.27)',
                    'Status' => 'Off',
                    'Locale' => 'ETSI',
                    'Card Type' => 'AirPort Extreme  (0x14E4, 0x88)',
                    'Supported PHY Modes' => '802.11 a/b/g/n',
                    'Supported Channels' => '1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 36, 40, 44, 48, 52, 56, 60, 64, 100, 104, 108, 112, 116, 120, 124, 128, 132, 136, 140',
                    'Wake On Wireless' => 'Supported',
                    'Country Code' => 'X3'
                }
            }
        },
        'Graphics/Displays' => {
            'ATI Radeon HD 2600 Pro' => {
                'Displays' => {
                    'Display Connector' => {
                        'Status' => 'No Display Connected'
                    },
                    'iMac' => {
                        'Resolution' => '1920 x 1200',
                        'Pixel Depth' => '32-Bit Color (ARGB8888)',
                        'Main Display' => 'Yes',
                        'Mirror' => 'Off',
                        'Built-In' => 'Yes',
                        'Online' => 'Yes'
                    }
                },
                'EFI Driver Version' => '01.00.219',
                'PCIe Lane Width' => 'x16',
                'Chipset Model' => 'ATI,RadeonHD2600',
                'Revision ID' => '0x0000',
                'Device ID' => '0x9583',
                'Vendor' => 'ATI (0x1002)',
                'Type' => 'GPU',
                'ROM Revision' => '113-B2250F-219',
                'Bus' => 'PCIe',
                'VRAM (Total)' => '256 MB'
            }
        }
    }
);

plan tests => scalar keys %tests;

my $logger = FusionInventory::Logger->new();

foreach my $test (keys %tests) {
    my $file = "resources/osx/$test.txt";
    my $result = FusionInventory::Agent::Tools::MacOS::_parseSystemProfiler(
        $logger, $file, '<'
    );
    is_deeply($result, $tests{$test}, "$test system profiler parsing");
}
