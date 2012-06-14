#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use FusionInventory::Agent::Tools::MacOS;

my %system_profiler_tests = (
    '10.4-powerpc' => {
        'Network' => {
            'Ethernet intégré 2' => {
                'Has IP Assigned' => 'No',
                'IPv6' => {
                    'Configuration Method' => 'Automatic'
                },
                'BSD Device Name' => 'en1',
                'Ethernet' => {
                    'MAC Address' => '00:14:51:61:ef:09',
                    'Media Options' => undef,
                    'Media Subtype' => 'autoselect'
                },
                'Hardware' => 'Ethernet',
                'Type' => 'Ethernet',
                'IPv4' => {
                    'Configuration Method' => 'DHCP'
                },
                'Proxies' => {
                    'Proxy Configuration Method' => 'Manual',
                    'ExcludeSimpleHostnames' => 0,
                    'Auto Discovery Enabled' => 'No',
                    'FTP Passive Mode' => 'Yes'
                }
            },
            'Modem interne' => {
                'Has IP Assigned' => 'No',
                'Type' => 'PPP (PPPSerial)',
                'IPv6' => {
                    'Configuration Method' => 'Automatic'
                },
                'BSD Device Name' => 'modem',
                'IPv4' => {
                    'Configuration Method' => 'PPP'
                },
                'Hardware' => 'Modem',
                'Proxies' => {
                    'Proxy Configuration Method' => 'Manual',
                    'ExcludeSimpleHostnames' => 0,
                    'Auto Discovery Enabled' => 'No',
                    'FTP Passive Mode' => 'Yes'
                }
            },
            'Ethernet intégré' => {
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
                'Hardware' => 'Ethernet',
                'DNS' => {
                    'Server Addresses' => '10.0.1.1',
                    'Domain Name' => 'lan'
                },
                'Type' => 'Ethernet',
                'IPv4 Addresses' => '10.0.1.110',
                'DHCP Server Responses' => {
                    'Domain Name' => 'lan',
                    'Lease Duration (seconds)' => 0,
                    'Routers' => '10.0.1.1',
                    'Subnet Mask' => '255.255.255.0',
                    'Server Identifier' => '10.0.1.1',
                    'DHCP Message Type' => '0x05',
                    'Domain Name Servers' => '10.0.1.1'
                },
                'IPv4' => {
                    'Router' => '10.0.1.1',
                    'Interface Name' => 'en0',
                    'Configuration Method' => 'DHCP',
                    'Subnet Masks' => '255.255.255.0',
                    'Addresses' => '10.0.1.110'
                },
                'Proxies' => {
                    'SOCKS Proxy Enabled' => 'No',
                    'HTTPS Proxy Enabled' => 'No',
                    'FTP Proxy Enabled' => 'No',
                    'Gopher Proxy Enabled' => 'No',
                    'FTP Passive Mode' => 'Yes',
                    'HTTP Proxy Enabled' => 'No',
                    'RTSP Proxy Enabled' => 'No'
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
                    'Proxy Configuration Method' => 'Manual',
                    'ExcludeSimpleHostnames' => 0,
                    'Auto Discovery Enabled' => 'No',
                    'FTP Passive Mode' => 'Yes'
                }
            },
            'FireWire intégré' => {
                'Has IP Assigned' => 'No',
                'IPv6' => {
                    'Configuration Method' => 'Automatic'
                },
                'BSD Device Name' => 'fw1',
                'Ethernet' => {
                    'Media Subtype' => 'autoselect',
                    'MAC Address' => '00:14:51:ff:fe:1a:c8:e2',
                    'Media Options' => 'Full Duplex'
                },
                'Hardware' => 'FireWire',
                'Type' => 'FireWire',
                'IPv4' => {
                    'Configuration Method' => 'DHCP'
                },
                'Proxies' => {
                    'Proxy Configuration Method' => 'Manual',
                    'ExcludeSimpleHostnames' => 0,
                    'Auto Discovery Enabled' => 'No',
                    'FTP Passive Mode' => 'Yes'
                }
            }
        },
        'Locations' => {
            'Automatic' => {
                'Services' => {
                    'Ethernet intégré 2' => {
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
                            'Auto Discovery Enabled' => 0,
                            'Proxy Configuration Method' => '2',
                            'ExcludeSimpleHostnames' => 0,
                            'FTP Passive Mode' => '1'
                        },
                        'Hardware (MAC) Address' => '00:14:51:61:ef:09'
                    },
                    'Modem interne' => {
                        'Type' => 'PPP',
                        'IPv6' => {
                            'Configuration Method' => 'Automatic'
                        },
                        'IPv4' => {
                            'Configuration Method' => 'PPP'
                        },
                        'Proxies' => {
                            'Auto Discovery Enabled' => 0,
                            'Proxy Configuration Method' => '2',
                            'ExcludeSimpleHostnames' => 0,
                            'FTP Passive Mode' => '1'
                        },
                        'PPP' => {
                            'ACSP Enabled' => 0,
                            'Idle Reminder' => 0,
                            'IPCP Compression VJ' => '1',
                            'LCP Echo Interval' => '10',
                            'LCP Echo Enabled' => '1',
                            'Log File' => '/var/log/ppp.log',
                            'Idle Reminder Time' => '1800',
                            'LCP Echo Failure' => '4',
                            'Verbose Logging' => 0,
                            'Dial On Demand' => 0,
                            'Disconnect On Logout' => '1',
                            'Disconnect On Idle Timer' => '600',
                            'Disconnect On Idle' => '1',
                            'Disconnect On Fast User Switch' => '1',
                            'Disconnect On Sleep' => '1',
                            'Display Terminal Window' => 0,
                            'Redial Enabled' => '1',
                            'Redial Count' => '1',
                            'Redial Interval' => '5',
                            'Use Terminal Script' => 0,
                        }
                    },
                    'Ethernet intégré' => {
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
                            'SOCKS Proxy Enabled' => 0,
                            'HTTPS Proxy Enabled' => 0,
                            'FTP Proxy Enabled' => 0,
                            'FTP Passive Mode' => '1',
                            'Gopher Proxy Enabled' => 0,
                            'HTTP Proxy Enabled' => 0,
                            'RTSP Proxy Enabled' => 0,
                        },
                        'Hardware (MAC) Address' => '00:14:51:61:ef:08'
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
                            'Auto Discovery Enabled' => 0,
                            'Proxy Configuration Method' => '2',
                            'ExcludeSimpleHostnames' => 0,
                            'FTP Passive Mode' => '1'
                        },
                        'PPP' => {
                            'ACSP Enabled' => 0,
                            'Idle Reminder' => 0,
                            'IPCP Compression VJ' => '1',
                            'Idle Reminder Time' => '1800',
                            'Verbose Logging' => 0,
                            'LCP Echo Enabled' => 0,
                            'LCP Echo Interval' => '10',
                            'Log File' => '/var/log/ppp.log',
                            'LCP Echo Failure' => '4',
                            'Dial On Demand' => 0,
                            'Disconnect On Logout' => '1',
                            'Disconnect On Idle Timer' => '600',
                            'Disconnect On Idle' => '1',
                            'Disconnect On Fast User Switch' => '1',
                            'Disconnect On Sleep' => '1',
                            'Display Terminal Window' => 0,
                            'Redial Enabled' => '1',
                            'Redial Count' => '1',
                            'Redial Interval' => '5',
                            'Use Terminal Script' => 0,
                        }
                    },
                    'FireWire intégré' => {
                        'Type' => 'FireWire',
                        'IPv6' => {
                            'Configuration Method' => 'Automatic'
                        },
                        'BSD Device Name' => 'fw1',
                        'AppleTalk' => {
                            'Configuration Method' => 'Node'
                        },
                        'IPv4' => {
                            'Configuration Method' => 'DHCP'
                        },
                        'Proxies' => {
                            'Auto Discovery Enabled' => 0,
                            'Proxy Configuration Method' => '2',
                            'ExcludeSimpleHostnames' => 0,
                            'FTP Passive Mode' => '1'
                        },
                        'Hardware (MAC) Address' => '00:14:51:ff:fe:1a:c8:e2'
                    }
                },
                'Active Location' => 'Yes'
            }
        },
        'Hardware' => {
            'Hardware Overview' => {
                'Boot ROM Version' => '5.2.7f1',
                'Machine Name' => 'Power Mac G5',
                'Serial Number' => 'CK54202SR6V',
                'Bus Speed' => '1.15 GHz',
                'Machine Model' => 'PowerMac11,2',
                'Number Of CPUs' => '2',
                'Memory' => '2 GB',
                'CPU Type' => 'PowerPC G5 (1.1)',
                'L2 Cache (per CPU)' => '1 MB',
                'CPU Speed' => '2.3 GHz'
            }
        },
        'Diagnostics' => {
            'Power On Self-Test' => {
                'Result' => 'Passed',
                'Last Run' => '27/07/10 17:27'
            }
        },
        'Serial-ATA' => {
            'Serial-ATA Bus' => {
                'Maxtor 6B250S0' => {
                    'Volumes' => {
                        'disk0s5' => {
                            'File System' => 'Journaled HFS+',
                            'Writable' => 'Yes',
                            'Capacity' => '212.09 GB',
                            'Available' => '203.48 GB'
                        },
                        'disk0s3' => {
                            'File System' => 'Journaled HFS+',
                            'Writable' => 'Yes',
                            'Capacity' => '21.42 GB',
                            'Available' => '6.87 GB'
                        }
                    },
                    'Revision' => 'BANC1E50',
                    'Detachable Drive' => 'No',
                    'Serial Number' => 'B623KFXH',
                    'Capacity' => '233.76 GB',
                    'Model' => 'Maxtor 6B250S0',
                    'Removable Media' => 'No',
                    'BSD Name' => 'disk0',
                    'Protocol' => 'ata',
                    'Unit Number' => 0,
                    'OS9 Drivers' => 'No',
                    'Socket Type' => 'Serial-ATA',
                    'S.M.A.R.T. status' => 'Verified',
                    'Bay Name' => '"A (upper)"'
                }
            }
        },
        'PCI Cards' => {
            'bcom5714' => {
                'Slot' => 'GIGE',
                'Subsystem Vendor ID' => '0x106b',
                'Revision ID' => '0x0003',
                'Device ID' => '0x166a',
                'Type' => 'network',
                'Subsystem ID' => '0x0085',
                'Bus' => 'PCI',
                'Vendor ID' => '0x14e4'
            },
            'GeForce 6600' => {
                'Slot' => 'SLOT-1',
                'Subsystem Vendor ID' => '0x10de',
                'Revision ID' => '0x00a4',
                'Device ID' => '0x0141',
                'Type' => 'display',
                'Subsystem ID' => '0x0010',
                'ROM Revision' => '2149',
                'Bus' => 'PCI',
                'Name' => 'NVDA,Display-B',
                'Vendor ID' => '0x10de'
            }
        },
        'USB' => {
            'USB Bus' => {
                'Host Controller Driver' => 'AppleUSBOHCI',
                'PCI Device ID' => '0x0035',
                'Host Controller Location' => 'Built In USB',
                'Bus Number' => '0x2b',
                'PCI Vendor ID' => '0x1033',
                'PCI Revision ID' => '0x0043'
            },
            'USB High-Speed Bus' => {
                'Host Controller Driver' => 'AppleUSBEHCI',
                'PCI Device ID' => '0x00e0',
                'Host Controller Location' => 'Built In USB',
                'Bus Number' => '0x4b',
                'PCI Vendor ID' => '0x1033',
                'PCI Revision ID' => '0x0004'
            }
        },
        'ATA' => {
            'ATA Bus' => {
                'HL-DT-ST DVD-RW GWA-4165B' => {
                    'Revision' => 'C006',
                    'Detachable Drive' => 'No',
                    'Serial Number' => 'B6FD7234EC63',
                    'Protocol' => 'ATAPI',
                    'Unit Number' => 0,
                    'Socket Type' => 'Internal',
                    'Model' => 'HL-DT-ST DVD-RW GWA-4165B'
                }
            }
        },
        'Audio (Built In)' => {
            'Built In Sound Card' => {
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
        'Memory' => {
            'DIMM5/J7200' => {
                'Type' => 'Empty',
                'Speed' => 'Empty',
                'Size' => 'Empty',
                'Status' => 'Empty'
            },
            'DIMM3/J7000' => {
                'Type' => 'Empty',
                'Speed' => 'Empty',
                'Size' => 'Empty',
                'Status' => 'Empty'
            },
            'DIMM2/J6900' => {
                'Type' => 'Empty',
                'Speed' => 'Empty',
                'Size' => 'Empty',
                'Status' => 'Empty'
            },
            'DIMM0/J6700' => {
                'Type' => 'DDR2 SDRAM',
                'Speed' => 'PC2-4200U-444',
                'Size' => '1 GB',
                'Status' => 'OK'
            },
            'DIMM6/J7300' => {
                'Type' => 'Empty',
                'Speed' => 'Empty',
                'Size' => 'Empty',
                'Status' => 'Empty'
            },
            'DIMM1/J6800' => {
                'Type' => 'DDR2 SDRAM',
                'Speed' => 'PC2-4200U-444',
                'Size' => '1 GB',
                'Status' => 'OK'
            },
            'DIMM4/J7100' => {
                'Type' => 'Empty',
                'Speed' => 'Empty',
                'Size' => 'Empty',
                'Status' => 'Empty'
            },
            'DIMM7/J7400' => {
                'Type' => 'Empty',
                'Speed' => 'Empty',
                'Size' => 'Empty',
                'Status' => 'Empty'
            }
        },
        'Software' => {
            'System Software Overview' => {
                'Boot Volume' => 'fwosx104',
                'System Version' => 'Mac OS X 10.4.11 (8S165)',
                'Kernel Version' => 'Darwin 8.11.0',
                'User Name' => 'wawa (wawa)',
                'Computer Name' => 'g5'
            }
        },
        'Disc Burning' => {
            'HL-DT-ST DVD-RW GWA-4165B' => {
                'Burn Underrun Protection DVD' => 'Yes',
                'Reads DVD' => 'Yes',
                'Cache' => '2048 KB',
                'Write Strategies' => 'CD-TAO, CD-SAO, CD-Raw, DVD-DAO',
                'Media' => 'No',
                'Burn Underrun Protection CD' => 'Yes',
                'Interconnect' => 'ATAPI',
                'DVD-Write' => '-R, -RW, +R, +RW, +R DL',
                'Burn Support' => 'Yes (Apple Shipped/Supported)',
                'CD-Write' => '-R, -RW',
                'Firmware Revision' => 'C006'
            }
        },
        'FireWire' => {
            'FireWire Bus' => {
                'Maximum Speed' => 'Up to 800 Mb/sec',
                'Unknown Device' => {
                    'Maximum Speed' => 'Up to 400 Mb/sec',
                    'Manufacturer' => 'Unknown',
                    'Model' => 'Unknown Device',
                    'Connection Speed' => 'Up to 400 Mb/sec'
                }
            }
        },
        'Graphics/Displays' => {
            'NVIDIA GeForce 6600' => {
                'Displays' => {
                    'Display' => {
                        'Status' => 'No display connected'
                    },
                    'ASUS VH222' => {
                        'Quartz Extreme' => 'Supported',
                        'Core Image' => 'Supported',
                        'Display Asleep' => 'Yes',
                        'Main Display' => 'Yes',
                        'Resolution' => '1360 x 768 @ 60 Hz',
                        'Depth' => '32-bit Color',
                        'Mirror' => 'Off',
                        'Online' => 'Yes'
                    }
                },
                'Slot' => 'SLOT-1',
                'Chipset Model' => 'GeForce 6600',
                'Revision ID' => '0x00a4',
                'Device ID' => '0x0141',
                'Vendor' => 'nVIDIA (0x10de)',
                'Type' => 'Display',
                'ROM Revision' => '2149',
                'Bus' => 'PCI',
                'VRAM (Total)' => '256 MB'
            }
        },
        'Power' => {
            'System Power Settings' => {
                'AC Power' => {
                    'System Sleep Timer (Minutes)' => 0,
                    'Reduce Processor Speed' => 'No',
                    'Dynamic Power Step' => 'Yes',
                    'Display Sleep Timer (Minutes)' => '10',
                    'Disk Sleep Timer (Minutes)' => '10',
                    'Automatic Restart On Power Loss' => 'No',
                    'Sleep On Power Button' => 'Yes',
                    'Wake On AC Change' => 'No',
                    'Wake On Modem Ring' => 'Yes',
                    'Wake On LAN' => 'Yes'
                }
            }
        }
    },
    '10.5-powerpc' => {
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
                    'Unit Number' => 0,
                    'Low Power Polling' => 'No',
                    'Socket Type' => 'Internal',
                    'Power Off' => 'No',
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
                    'System Sleep Timer (Minutes)' => 0,
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
                    'Lease Duration (seconds)' => 0,
                    'Routers' => '10.0.1.1',
                    'Subnet Mask' => '255.255.255.0',
                    'Server Identifier' => '10.0.1.1',
                    'DHCP Message Type' => '0x05',
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
                    'Media Options' => undef,
                    'Media Subtype' => 'Auto Select'
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
                    'Unit Number' => 0,
                    'Mac OS 9 Drivers' => 'No',
                    'Socket Type' => 'Serial-ATA',
                    'S.M.A.R.T. status' => 'Verified',
                    'Partition Map Type' => 'APM (Apple Partition Map)',
                    'Bay Name' => '"B (lower)"'
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
    '10.6-intel' => {
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
                            'PowerEnabled' => 0,
                            'PreferredNetworks' => {
                                'Unique Network ID' => '905AE8BA-BD26-48F3-9486-AE5BC72FE642',
                                'SecurityType' => 'WPA2 Personal',
                                'Unique Password ID' => '907EDC44-8C27-44A0-B5F5-2D04E1A5942A',
                                'SSID_STR' => 'freewa'
                            },
                            'RememberRecentNetworks' => '1',
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
                    'Current Required (mA)' => 0,
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
                    'Unit Number' => 0,
                    'Low Power Polling' => 'Yes',
                    'Socket Type' => 'Internal',
                    'Power Off' => 'No',
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
                    'Address' => undef,
                    'Name' => 'Bluetooth-Modem',
                    'RFCOMM Channel' => 0,
                    'Requires Authentication' => 'No'
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
                    'Media Options' => undef,
                    'Media Subtype' => 'Auto Select'
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
                    'Exclude Simple Hostnames' => 0,
                    'Auto Discovery Enabled' => 'No',
                    'FTP Passive Mode' => 'Yes',
                    'Proxy Configuration Method' => 'Manual'
                },
                'Service Order' => '9',
            },
            'Parallels Shared Networking Adapter' => {
                'Has IP Assigned' => 'Yes',
                'IPv6' => {
                    'Configuration Method' => 'Automatic'
                },
                'BSD Device Name' => 'en2',
                'Ethernet' => {
                    'MAC Address' => '00:1c:42:00:00:08',
                    'Media Options' => undef,
                    'Media Subtype' => 'Auto Select'
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
                    'Exclude Simple Hostnames' => 0,
                    'Auto Discovery Enabled' => 'No',
                    'FTP Passive Mode' => 'Yes',
                    'Proxy Configuration Method' => 'Manual'
                },
                'Service Order' => '8',
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
                    'Exceptions List' => '*.local, 169.254/16'
                },
                'Service Order' => '2',
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
                    'Lease Duration (seconds)' => 0,
                    'Routers' => '10.0.1.1',
                    'Subnet Mask' => '255.255.255.0',
                    'Server Identifier' => '10.0.1.1',
                    'DHCP Message Type' => '0x05',
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
                    'Exceptions List' => '*.local, 169.254/16'
                },
                'Service Order' => '1',
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
                'Service Order' => 0,
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
                    'Media Options' => undef,
                    'Media Subtype' => 'Auto Select'
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
                    'Exceptions List' => '*.local, 169.254/16'
                },
                'Service Order' => '3',
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
                    'com.skype.skype' => 'Allow all connections',
                    'com.Growl.GrowlHelperApp' => 'Allow all connections',
                    'com.hp.scan.app' => 'Allow all connections',
                    'com.parallels.desktop.dispatcher' => 'Allow all connections',
                    'net.sourceforge.xmeeting.XMeeting' => 'Allow all connections',
                    'com.getdropbox.dropbox' => 'Allow all connections'
                },
                'Mode' => 'Limit incoming connections to specific services and applications',
                'Firewall Logging' => 'No',
                'Stealth Mode' => 'No',
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
    },
    '10.6.6-intel' => {
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
                        'Hardware (MAC) Address' => '00:1d:4f:ff:fe:66:f3:58'
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
                        'Hardware (MAC) Address' => '00:1b:63:36:1e:c3'
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
                            'FTP Passive Mode' => 'Yes',
                            'Exceptions List' => '*.local, 169.254/16'
                        },
                        'Hardware (MAC) Address' => '00:1c:b3:c0:56:85',
                        'IEEE80211' => {
                            'Disconnect on Logout' => 'Yes',
                            'Join Mode' => 'Automatic',
                            'JoinModeFallback' => 'Prompt',
                            'PowerEnabled' => '1',
                            'PreferredNetworks' => {
                                'Unique Network ID' => 'A628B3F5-DB6B-48A6-A3A4-17D33697041B',
                                'SecurityType' => 'Open',
                                'SSID_STR' => 'univ-paris1.fr'
                            },
                            'RememberRecentNetworks' => 0,
                            'RequireAdmin' => 0,
                        }
                    }
                },
                'Active Location' => 'No'
            },
            'universite-paris1' => {
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
                        'Hardware (MAC) Address' => '00:1d:4f:ff:fe:66:f3:58'
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
                        'Hardware (MAC) Address' => '00:1b:63:36:1e:c3'
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
                            'FTP Passive Mode' => 'Yes',
                            'Exceptions List' => '*.local, 169.254/16'
                        },
                        'Hardware (MAC) Address' => '00:1c:b3:c0:56:85',
                        'IEEE80211' => {
                            'Join Mode' => 'Automatic',
                            'Disconnect on Logout' => 'Yes',
                            'PowerEnabled' => '1',
                            'RememberRecentNetworks' => 0,
                            'RequireAdmin' => 0,
                            'PreferredNetworks' => {
                                 'Unique Network ID' => '963478B4-1AC3-4B35-A4BB-3510FEA2FEF2',
                                 'SecurityType' => 'WPA2 Enterprise',
                                 'SSID_STR' => 'eduroam'
                            },
                            'JoinModeFallback' => 'Prompt'
                        }
                    }
                },
                'Active Location' => 'No'
            },
            'eduroam' => {
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
                        'Hardware (MAC) Address' => '00:1d:4f:ff:fe:66:f3:58'
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
                        'Hardware (MAC) Address' => '00:1b:63:36:1e:c3'
                    },
                    'AirPort' => {
                        'Type' => 'IEEE80211',
                        'BSD Device Name' => 'en1',
                        'AppleTalk' => {
                            'Configuration Method' => 'Node',
                            'Node' => 'Node'
                        },
                        'IPv4' => {
                            'Configuration Method' => 'DHCP'
                        },
                        'Proxies' => {
                            'FTP Passive Mode' => 'Yes',
                            'Exceptions List' => '*.local, 169.254/16'
                        },
                        'Hardware (MAC) Address' => '00:1c:b3:c0:56:85',
                        'IEEE80211' => {
                            'Join Mode' => 'Automatic',
                            'Disconnect on Logout' => 'Yes',
                            'PowerEnabled' => 0,
                            'RememberRecentNetworks' => 0,
                            'PreferredNetworks' => {
                                'Unique Network ID' => '46A33A68-7109-48AD-9255-900F0134903E',
                                'SecurityType' => 'WPA Personal',
                                'Unique Password ID' => '2C0ADC06-C220-4F00-809E-C34A6085305F',
                                'SSID_STR' => 'undercover'
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
                'PCI Device ID' => '0x27c9',
                'Host Controller Location' => 'Built-in USB',
                'Bus Number' => '0x3d',
                'PCI Vendor ID' => '0x8086',
                'PCI Revision ID' => '0x0002'
            },
            'USB High-Speed Bus' => {
                'Host Controller Driver' => 'AppleUSBEHCI',
                'PCI Device ID' => '0x27cc',
                'Host Controller Location' => 'Built-in USB',
                'Built-in iSight' => {
                    'Location ID' => '0xfd400000',
                    'Version' => ' 1.89',
                    'Current Available (mA)' => '500',
                    'Speed' => 'Up to 480 Mb/sec',
                    'Product ID' => '0x8501',
                    'Current Required (mA)' => '100',
                    'Manufacturer' => 'Micron',
                    'Vendor ID' => '0x05ac  (Apple Inc.)'
                },
                'iPhone' => {
                    'Location ID' => '0xfd300000',
                    'Product ID' => '0x1297',
                    'Current Required (mA)' => '500',
                    'Serial Number' => 'ad21f6125218200927797eb473d3e7eeae31e5ae',
                    'Version' => ' 0.01',
                    'Speed' => 'Up to 480 Mb/sec',
                    'Current Available (mA)' => '500',
                    'Manufacturer' => 'Apple Inc.',
                    'Vendor ID' => '0x05ac  (Apple Inc.)'
                },
                'Bus Number' => '0xfd',
                'PCI Revision ID' => '0x0002',
                'PCI Vendor ID' => '0x8086'
            }
        },
        'ATA' => {
            'ATA Bus' => {
                'MATSHITACD-RW  CW-8221' => {
                    'Revision' => 'GA0J',
                    'Serial Number' => undef,
                    'Detachable Drive' => 'No',
                    'Protocol' => 'ATAPI',
                    'Unit Number' => 0,
                    'Low Power Polling' => 'Yes',
                    'Socket Type' => 'Internal',
                    'Power Off' => 'Yes',
                    'Model' => 'MATSHITACD-RW  CW-8221'
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
                'Audio ID' => '34',
                'S/PDIF Optical Digital Audio Output' => {
                    'Connection' => 'Combination Output'
                }
            }
        },
        'Disc Burning' => {
            'MATSHITA CD-RW  CW-8221' => {
                'Reads DVD' => 'Yes',
                'Cache' => '2048 KB',
                'Write Strategies' => 'CD-TAO, CD-SAO, CD-Raw',
                'Media' => 'To show the available burn speeds, insert a disc and choose View > Refresh',
                'Interconnect' => 'ATAPI',
                'Burn Support' => 'Yes (Apple Shipping Drive)',
                'CD-Write' => '-R, -RW',
                'Firmware Revision' => 'GA0J'
            }
        },
        'Bluetooth' => {
            'Apple Bluetooth Software Version' => '2.3.8f7',
            'Outgoing Serial Ports' => {
                'Serial Port 1' => {
                    'Address' => undef,
                    'Name' => 'Bluetooth-Modem',
                    'RFCOMM Channel' => 0,
                    'Requires Authentication' => 'No'
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
                    'Folder for accepted items' => '~/Downloads',
                    'When PIM items are accepted' => 'Ask',
                    'Requires Authentication' => 'No',
                    'State' => 'Enabled',
                    'When other items are accepted' => 'Ask'
                }
            },
            'Hardware Settings' => {
                'Firmware Version' => '1965',
                'Product ID' => '0x8205',
                'Bluetooth Power' => 'On',
                'Address' => '00-1d-4f-8f-13-b1',
                'Requires Authentication' => 'No',
                'Discoverable' => 'Yes',
                'Manufacturer' => 'Cambridge Silicon Radio',
                'Vendor ID' => '0x5ac',
                'Name' => 'MacBookdeSAP'
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
            'Battery Information' => {
                'Charge Information' => {
                    'Full charge capacity (mAh)' => 0,
                    'Charge remaining (mAh)' => 0,
                    'Fully charged' => 'No',
                    'Charging' => 'No'
                },
                'Health Information' => {
                    'Cycle count' => '5',
                    'Condition' => 'Replace Now',
                },
                'Voltage (mV)' => '3908',
                'Battery Installed' => 'Yes',
                'Amperage (mA)' => '74',
                'Model Information' => {
                    'PCB Lot Code' => '0000',
                    'Firmware Version' => '102a',
                    'Device name' => 'ASMB016',
                    'Hardware Revision' => '0500',
                    'Cell Revision' => '0102',
                    'Manufacturer' => 'DP',
                    'Pack Lot Code' => '0002'
                }
            },
            'System Power Settings' => {
                'AC Power' => {
                    'System Sleep Timer (Minutes)' => 0,
                    'Display Sleep Timer (Minutes)' => '10',
                    'Disk Sleep Timer (Minutes)' => '10',
                    'Automatic Restart On Power Loss' => 'No',
                    'Wake On AC Change' => 'No',
                    'Current Power Source' => 'Yes',
                    'Wake On Clamshell Open' => 'Yes',
                    'Display Sleep Uses Dim' => 'Yes',
                    'Wake On LAN' => 'Yes'
                },
                'Battery Power' => {
                    'Reduce Brightness' => 'Yes',
                    'Display Sleep Timer (Minutes)' => '5',
                    'Disk Sleep Timer (Minutes)' => '5',
                    'System Sleep Timer (Minutes)' => '5',
                    'Wake On AC Change' => 'No',
                    'Wake On Clamshell Open' => 'Yes',
                    'Display Sleep Uses Dim' => 'Yes'
                }
            },
            'AC Charger Information' => {
                'ID' => '0x0100',
                'Charging' => 'No',
                'Revision' => '0x0000',
                'Connected' => 'Yes',
                'Serial Number' => '0x005a4e88',
                'Family' => '0x00ba',
                'Wattage (W)' => '60'
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
                    'MAC Address' => '00:1d:4f:ff:fe:66:f3:58',
                    'Media Options' => 'Full Duplex'
                },
                'IPv4' => {
                    'Configuration Method' => 'DHCP'
                },
                'Hardware' => 'FireWire',
                'Proxies' => {
                    'FTP Passive Mode' => 'Yes',
                    'Exceptions List' => '*.local, 169.254/16'
                },
                'Service Order' => '2',
            },
            'Ethernet' => {
                'Has IP Assigned' => 'Yes',
                'IPv6' => {
                    'Router' => 'fe80:0000:0000:0000:020b:60ff:feb0:b01b',
                    'Prefix Length' => '64',
                    'Interface Name' => 'en0',
                    'Flags' => '32832',
                    'Configuration Method' => 'Automatic',
                    'Addresses' => '2001:0660:3305:0100:021b:63ff:fe36:1ec3'
                },
                'BSD Device Name' => 'en0',
                'Ethernet' => {
                    'Media Subtype' => '100baseTX',
                    'MAC Address' => '00:1b:63:36:1e:c3',
                    'Media Options' => 'Full Duplex, Flow Control'
                },
                'Hardware' => 'Ethernet',
                'DNS' => {
                    'Server Addresses' => '193.55.96.84, 193.55.99.70, 194.214.33.181',
                    'Domain Name' => 'univ-paris1.fr'
                },
                'Type' => 'Ethernet',
                'IPv4 Addresses' => '172.20.10.171',
                'DHCP Server Responses' => {
                    'Domain Name' => 'univ-paris1.fr',
                    'Lease Duration (seconds)' => 0,
                    'Routers' => '172.20.10.72',
                    'Subnet Mask' => '255.255.254.0',
                    'Server Identifier' => '172.20.0.2',
                    'DHCP Message Type' => '0x05',
                    'Domain Name Servers' => '193.55.96.84,193.55.99.70,194.214.33.181'
                },
                'IPv4' => {
                    'Router' => '172.20.10.72',
                    'Interface Name' => 'en0',
                    'Network Signature' => 'IPv4.Router=172.20.10.72;IPv4.RouterHardwareAddress=00:0b:60:b0:b0:1b',
                    'Configuration Method' => 'DHCP',
                    'Subnet Masks' => '255.255.254.0',
                    'Addresses' => '172.20.10.171'
                },
                'Proxies' => {
                    'FTP Passive Mode' => 'Yes',
                    'Exceptions List' => '*.local, 169.254/16'
                },
                'Sleep Proxies' => {
                    'MacBook de SAP ' => {
                        'Portability' => '37',
                        'Type' => '50',
                        'Metric' => '503771',
                        'Marginal Power' => '71',
                        'Total Power' => '72'
                    }
                },
                'IPv6 Address' => '2001:0660:3305:0100:021b:63ff:fe36:1ec3',
                'Service Order' => '1',
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
                'Service Order' => 0,
            },
            'AirPort' => {
                'Has IP Assigned' => 'No',
                'Type' => 'AirPort',
                'BSD Device Name' => 'en1',
                'Ethernet' => {
                    'MAC Address' => '00:1c:b3:c0:56:85',
                    'Media Options' => undef,
                    'Media Subtype' => 'Auto Select'
                },
                'IPv4' => {
                    'Configuration Method' => 'DHCP'
                },
                'Hardware' => 'AirPort',
                'Proxies' => {
                    'FTP Passive Mode' => 'Yes',
                    'Exceptions List' => '*.local, 169.254/16'
                },
                'Service Order' => '3',
            }
        },
        'Ethernet Cards' => {
            'Marvell Yukon Gigabit Adapter 88E8053 Singleport Copper SA' => {
                'Subsystem Vendor ID' => '0x11ab',
                'Link Width' => 'x1',
                'Revision ID' => '0x0022',
                'Device ID' => '0x4362',
                'Kext name' => 'AppleYukon2.kext',
                'BSD name' => 'en0',
                'Version' => '3.2.1b1',
                'Type' => 'Ethernet Controller',
                'Subsystem ID' => '0x5321',
                'Bus' => 'PCI',
                'Location' => '/System/Library/Extensions/IONetworkingFamily.kext/Contents/PlugIns/AppleYukon2.kext',
                'Name' => 'ethernet',
                'Vendor ID' => '0x11ab'
            }
        },
        'Hardware' => {
            'Hardware Overview' => {
                'SMC Version (system)' => '1.17f0',
                'Model Identifier' => 'MacBook2,1',
                'Boot ROM Version' => 'MB21.00A5.B07',
                'Processor Speed' => '2 GHz',
                'Hardware UUID' => '00000000-0000-1000-8000-001B66661EC3',
                'Sudden Motion Sensor' => {
                    'State' => 'Enabled'
                },
                'Bus Speed' => '667 MHz',
                'Total Number Of Cores' => '2',
                'Number Of Processors' => '1',
                'Processor Name' => 'Intel Core 2 Duo',
                'Model Name' => 'MacBook',
                'Memory' => '1 GB',
                'Serial Number (system)' => 'W8737DR1Z5V',
                'L2 Cache' => '4 MB'
            }
        },
        'Diagnostics' => {
            'Power On Self-Test' => {
                'Result' => 'Passed',
                'Last Run' => '1/13/11 9:43 AM'
            }
        },
        'Serial-ATA' => {
            'Intel ICH7-M AHCI' => {
                'FUJITSU MHW2080BHPL' => {
                    'Volumes' => {
                        'Writable' => 'Yes',
                        'Macintosh HD' => {
                            'Mount Point' => '/',
                            'File System' => 'Journaled HFS+',
                            'Writable' => 'Yes',
                            'BSD Name' => 'disk0s2',
                            'Capacity' => '79.68 GB (79,682,387,968 bytes)',
                            'Available' => '45.62 GB (45,623,767,040 bytes)'
                        },
                        'BSD Name' => 'disk0s1',
                        'Capacity' => '209.7 MB (209,715,200 bytes)'
                    },
                    'Revision' => '0081001C',
                    'Detachable Drive' => 'No',
                    'Serial Number' => '        K10RT792D51G',
                    'Capacity' => '80.03 GB (80,026,361,856 bytes)',
                    'Model' => 'FUJITSU MHW2080BHPL',
                    'Removable Media' => 'No',
                    'Medium Type' => 'Rotational',
                    'BSD Name' => 'disk0',
                    'S.M.A.R.T. status' => 'Verified',
                    'Partition Map Type' => 'GPT (GUID Partition Table)',
                    'Native Command Queuing' => 'Yes',
                    'Queue Depth' => '32'
                },
                'Link Speed' => '1.5 Gigabit',
                'Product' => 'ICH7-M AHCI',
                'Vendor' => 'Intel',
                'Description' => 'AHCI Version 1.10 Supported',
                'Negotiated Link Speed' => '1.5 Gigabit'
            }
        },
        'Firewall' => {
            'Firewall Settings' => {
                'Mode' => 'Allow all incoming connections',
                'Stealth Mode' => 'No',
                'Firewall Logging' => 'No'
            }
        },
        'Software' => {
            'System Software Overview' => {
                'Time since boot' => '2:37',
                'Computer Name' => 'MacBook de SAP',
                'Boot Volume' => 'Macintosh HD',
                'Boot Mode' => 'Normal',
                'System Version' => 'Mac OS X 10.6.6 (10J567)',
                'Kernel Version' => 'Darwin 10.6.0',
                'Secure Virtual Memory' => 'Enabled',
                '64-bit Kernel and Extensions' => 'No',
                'User Name' => 'System Administrator (root)'
            }
        },
        'FireWire' => {
            'FireWire Bus' => {
                'Maximum Speed' => 'Up to 400 Mb/sec'
            }
        },
        'Memory' => {
            'Memory Slots' => {
                'ECC' => 'Disabled',
                'BANK 1/DIMM1' => {
                    'Part Number' => '0x48594D503536345336344350362D59352020',
                    'Type' => 'DDR2 SDRAM',
                    'Speed' => '667 MHz',
                    'Size' => '512 MB',
                    'Status' => 'OK',
                    'Serial Number' => '0x00006021',
                    'Manufacturer' => '0xAD00000000000000'
                },
                'BANK 0/DIMM0' => {
                    'Part Number' => '0x48594D503536345336344350362D59352020',
                    'Type' => 'DDR2 SDRAM',
                    'Speed' => '667 MHz',
                    'Size' => '512 MB',
                    'Status' => 'OK',
                    'Serial Number' => '0x00003026',
                    'Manufacturer' => '0xAD00000000000000'
                }
            }
        },
        'Printers' => {
            '192.168.5.97' => {
                'PPD' => 'HP LaserJet 2200',
                'CUPS Version' => '1.4.6 (cups-218.28)',
                'URI' => 'socket://192.168.5.97/?bidi',
                'Default' => 'No',
                'Status' => 'Idle',
                'Driver Version' => '10.4',
                'Scanner UUID' => '-',
                'Print Server' => 'Local',
                'Scanning app' => '-',
                'Scanning support' => 'No',
                'PPD File Version' => '17.3',
                'Scanning app (bundleID path)' => '-',
                'Fax support' => 'No',
                'PostScript Version' => '(2014.116) 0'
            },
            '192.168.5.63' => {
                'PPD' => 'Generic PostScript Printer',
                'CUPS Version' => '1.4.6 (cups-218.28)',
                'URI' => 'lpd://192.168.5.63/',
                'Default' => 'No',
                'Status' => 'Idle',
                'Driver Version' => '10.4',
                'Scanner UUID' => '-',
                'Print Server' => 'Local',
                'Scanning app' => '-',
                'Scanning support' => 'No',
                'PPD File Version' => '1.4',
                'Scanning app (bundleID path)' => '-',
                'Fax support' => 'No',
                'PostScript Version' => '(2016.0) 0'
            }
        },
        'AirPort' => {
            'Software Versions' => {
                'IO80211 Family' => '3.1.2 (312)',
                'AirPort Utility' => '5.5.2 (552.11)',
                'configd plug-in' => '6.2.3 (623.2)',
                'Menu Extra' => '6.2.1 (621.1)',
                'Network Preference' => '6.2.1 (621.1)',
                'System Profiler' => '6.0 (600.9)'
            },
            'Interfaces' => {
                'en1' => {
                    'Firmware Version' => 'Atheros 5416: 2.1.14.5',
                    'Locale' => 'ETSI',
                    'Card Type' => 'AirPort Extreme  (0x168C, 0x87)',
                    'Country Code' => undef,
                    'Supported PHY Modes' => '802.11 a/b/g/n',
                    'Status' => 'Off',
                    'Supported Channels' => '1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 36, 40, 44, 48, 52, 56, 60, 64, 100, 104, 108, 112, 116, 120, 124, 128, 132, 136, 140'
                }
            }
        },
        'Graphics/Displays' => {
            'Intel GMA 950' => {
                'Type' => 'GPU',
                'Displays' => {
                    'Display Connector' => {
                        'Status' => 'No Display Connected'
                    },
                    'Color LCD' => {
                        'Resolution' => '1280 x 800',
                        'Pixel Depth' => '32-Bit Color (ARGB8888)',
                        'Main Display' => 'Yes',
                        'Mirror' => 'Off',
                        'Built-In' => 'Yes',
                        'Online' => 'Yes'
                    }
                },
                'Chipset Model' => 'GMA 950',
                'Bus' => 'Built-In',
                'Revision ID' => '0x0003',
                'Device ID' => '0x27a2',
                'Vendor' => 'Intel (0x8086)',
                'VRAM (Total)' => '64 MB of Shared System Memory'
            }
        }
    },
    'sample1.SPApplicationsDataType' => {
        'Applications' => {
            'Exposé' => {
                'Version' => '1.1',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Applications/Utilities/Expose.app',
                'Get Info String' => '1.1, Copyright 2007-2008 Apple Inc.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'ARM Help' => {
                'Version' => '4.7.3',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Library/Application Support/Shark/Helpers/ARM Help.app',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Intel'
            },
            'MiniTerm' => {
                'Version' => '1.5',
                'Last Modified' => '04/09/11 22:43',
                'Location' => '/usr/libexec/MiniTerm.app',
                'Get Info String' => 'Terminal window application for PPP',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'SystemUIServer' => {
                'Version' => '1.6',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/CoreServices/SystemUIServer.app',
                'Get Info String' => 'SystemUIServer version 1.6, Copyright 2000-2009 Apple Computer, Inc.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'HPScanner' => {
                'Version' => '1.1.52',
                'Last Modified' => '24/07/09 10:03',
                'Location' => '/Library/Image Capture/Devices/HPScanner.app',
                'Get Info String' => '1.1.52, Copyright 2009 Hewlett-Packard Company',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'PowerPC Help' => {
                'Version' => '4.7.3',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Library/Application Support/Shark/Helpers/PowerPC Help.app',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Intel'
            },
            'Spotlight' => {
                'Version' => '2.0',
                'Last Modified' => '24/07/09 04:18',
                'Location' => '/System/Library/Services/Spotlight.service',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Utilitaire AppleScript' => {
                'Version' => '1.1.1',
                'Last Modified' => '19/05/09 07:34',
                'Location' => '/System/Library/CoreServices/AppleScript Utility.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'KoreanIM' => {
                'Version' => '6.1',
                'Last Modified' => '05/05/09 18:41',
                'Location' => '/System/Library/Input Methods/KoreanIM.app',
                'Get Info String' => '6.0, Copyright © 1997-2006 Apple Computer Inc., All Rights Reserved',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'Java Web Start' => {
                'Version' => '13.6.0',
                'Last Modified' => '17/02/12 12:35',
                'Location' => '/System/Library/CoreServices/Java Web Start.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'SleepX' => {
                'Version' => '2.7',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Developer/Applications/Utilities/SleepX.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Canon IJ Printer Utility' => {
                'Version' => '7.17.10',
                'Last Modified' => '15/06/09 09:22',
                'Location' => '/Library/Printers/Canon/BJPrinter/Utilities/BJPrinterUtility2.app',
                'Get Info String' => 'Canon IJ Printer Utility version 7.17.10, Copyright CANON INC. 2001-2009 All Rights Reserved.',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Intel'
            },
            'TextEdit' => {
                'Version' => '1.6',
                'Last Modified' => '27/06/09 08:06',
                'Location' => '/Applications/TextEdit.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'SpeechSynthesisServer' => {
                'Version' => '3.10.35',
                'Last Modified' => '12/07/09 07:23',
                'Location' => '/System/Library/Frameworks/ApplicationServices.framework/Versions/A/Frameworks/SpeechSynthesis.framework/Versions/A/Resources/SpeechSynthesisServer.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'KeyboardViewer' => {
                'Version' => '2.0',
                'Last Modified' => '11/06/09 08:11',
                'Location' => '/System/Library/Input Methods/KeyboardViewer.app',
                'Get Info String' => '2.0, Copyright © 2004-2009 Apple Inc., All Rights Reserved',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'Spin Control' => {
                'Version' => '0.9',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Developer/Applications/Performance Tools/Spin Control.app',
                'Get Info String' => 'Spin Control',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Python Launcher' => {
                'Version' => '2.6.1',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/Frameworks/Python.framework/Versions/2.6/Resources/Python Launcher.app',
                'Get Info String' => '2.6.1, © 001-2006 Python Software Foundation',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'AddressBookManager' => {
                'Version' => '2.0.4',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/Frameworks/AddressBook.framework/Versions/A/Resources/AddressBookManager.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Chess' => {
                'Version' => '2.4.2',
                'Last Modified' => '19/05/09 08:09',
                'Location' => '/Applications/Chess.app',
                'Get Info String' => '2.4.2, Copyright 2003-2009 Apple Inc.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'EM64T Help' => {
                'Version' => '4.7.3',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Library/Application Support/Shark/Helpers/EM64T Help.app',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Intel'
            },
            'Big Bang Reversi' => {
                'Version' => '2.51',
                'Last Modified' => '05/04/07 16:09',
                'Location' => '/Applications/Big Bang Board Games/Big Bang Reversi.app',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Universal'
            },
            'CCacheServer' => {
                'Version' => '6.5.11',
                'Last Modified' => '04/09/11 22:43',
                'Location' => '/System/Library/CoreServices/CCacheServer.app',
                'Get Info String' => '6.5 Copyright © 2008 Massachusetts Institute of Technology',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'hpdot4d' => {
                'Version' => '3.5.0',
                'Last Modified' => '02/05/10 22:37',
                'Location' => '/Library/Printers/hp/Frameworks/HPDeviceModel.framework/Versions/3.0/Runtime/hpdot4d.app',
                'Get Info String' => 'hpdot4d 3.5.0, (c) Copyright 2005-2010 Hewlett-Packard Development Company, L.P.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Type5Camera' => {
                'Version' => '6.1',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/Image Capture/Devices/Type5Camera.app',
                'Get Info String' => '6.1, © Copyright 2001-2011 Apple Inc., all rights reserved.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'Front Row' => {
                'Version' => '1.1',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Applications/Front Row.app',
                'Get Info String' => '1.1, Copyright 2007-2008 Apple Inc.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'SyncDiagnostics' => {
                'Version' => '5.2',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/Frameworks/SyncServices.framework/Versions/A/Resources/SyncDiagnostics.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'eaptlstrust' => {
                'Version' => '10.0',
                'Last Modified' => '19/05/09 07:34',
                'Location' => '/System/Library/PrivateFrameworks/EAP8021X.framework/Support/eaptlstrust.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'Accessibility Verifier' => {
                'Version' => '1.2',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Developer/Applications/Utilities/Accessibility Tools/Accessibility Verifier.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'PreferenceSyncClient' => {
                'Version' => '2.0',
                'Last Modified' => '02/07/09 08:17',
                'Location' => '/System/Library/CoreServices/PreferenceSyncClient.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'Big Bang Checkers' => {
                'Version' => '2.51',
                'Last Modified' => '05/04/07 16:09',
                'Location' => '/Applications/Big Bang Board Games/Big Bang Checkers.app',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Universal'
            },
            'Utilitaire RAID' => {
                'Version' => '1.2',
                'Last Modified' => '04/09/11 22:43',
                'Location' => '/Applications/Utilities/RAID Utility.app',
                'Get Info String' => 'RAID Utility 1.0 (121), Copyright © 2007-2009 Apple Inc.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Big Bang Mancala' => {
                'Version' => '2.51',
                'Last Modified' => '05/04/07 16:09',
                'Location' => '/Applications/Big Bang Board Games/Big Bang Mancala.app',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Universal'
            },
            'pdftopdf2' => {
                'Version' => '8.02',
                'Last Modified' => '09/07/09 06:55',
                'Location' => '/Library/Printers/EPSON/InkjetPrinter2/Filter/pdftopdf2.app',
                'Get Info String' => 'pdftopdf2 version 8.02, Copyright (C) SEIKO EPSON CORPORATION 2001-2009. All rights reserved.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'ChineseTextConverterService' => {
                'Version' => '1.2',
                'Last Modified' => '19/05/09 04:18',
                'Location' => '/System/Library/Services/ChineseTextConverterService.app',
                'Get Info String' => 'Chinese Text Converter 1.1',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'BluetoothAudioAgent' => {
                'Version' => '2.4.5',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/CoreServices/BluetoothAudioAgent.app',
                'Get Info String' => '2.4.5, Copyright (c) 2011 Apple Inc. All rights reserved.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'Type2Camera' => {
                'Version' => '6.0',
                'Last Modified' => '04/09/11 22:43',
                'Location' => '/System/Library/Image Capture/Devices/Type2Camera.app',
                'Get Info String' => '6.0, © Copyright 2000-2009 Apple Inc., all rights reserved.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'Set Info' => {
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Library/Scripts/ColorSync/Set Info.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'Utilitaire de l\'imprimante Lexmark' => {
                'Version' => '1.2.10',
                'Last Modified' => '01/07/09 07:28',
                'Location' => '/Library/Printers/Lexmark/Drivers/Lexmark Printer Utility.app',
                'Get Info String' => '1.0, Copyright 2008 Lexmark International, Inc. All rights reserved.',
                '64-Bit (Intel)' => 'Yes',
            'Kind' => 'Intel'
            },
                'Outil d’étalonnage du moniteur' => {
                'Version' => '4.6',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/ColorSync/Calibrators/Display Calibrator.app',
                'Get Info String' => '4.6, Copyright 2008 Apple Computer, Inc.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Inkjet8' => {
                'Version' => '2.1',
                'Last Modified' => '16/06/09 11:59',
                'Location' => '/Library/Printers/hp/cups/Inkjet8.driver',
                'Get Info String' => 'HP Inkjet 8 Driver 2.1, Copyright (c) 1994-2009 Hewlett-Packard Development Company, L.P.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Canon IJScanner1' => {
                'Version' => '1.0.0',
                'Last Modified' => '15/06/09 08:19',
                'Location' => '/Library/Image Capture/Devices/Canon IJScanner1.app',
                'Get Info String' => '1.0.0, Copyright CANON INC. 2009 All Rights Reserved',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'SRLanguageModeler' => {
                'Version' => '1.9',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Developer/Applications/Utilities/Speech/SRLanguageModeler.app',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Intel'
            },
            'OBEXAgent' => {
                'Version' => '2.4.5',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/CoreServices/OBEXAgent.app',
                'Get Info String' => '2.4.5, Copyright (c) 2011 Apple Inc. All rights reserved.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'AutoImporter' => {
                'Version' => '6.0.1',
                'Last Modified' => '04/09/11 22:43',
                'Location' => '/System/Library/Image Capture/Support/Application/AutoImporter.app',
                'Get Info String' => '6.0, © Copyright 2000-2009 Apple Inc., all rights reserved.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Photo Booth' => {
                'Version' => '3.0.3',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Applications/Photo Booth.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Inkjet4' => {
                'Version' => '2.2',
                'Last Modified' => '16/06/09 15:17',
                'Location' => '/Library/Printers/hp/cups/Inkjet4.driver',
                'Get Info String' => 'HP Inkjet 4 Driver 2.2, Copyright (c) 1994-2009 Hewlett-Packard Development Company, L.P.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'DiskImageMounter' => {
                'Version' => '10.6.8',
                'Last Modified' => '04/09/11 22:43',
                'Location' => '/System/Library/CoreServices/DiskImageMounter.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Yahoo! Sync' => {
                'Version' => '1.3',
                'Last Modified' => '19/05/09 08:56',
                'Location' => '/System/Library/PrivateFrameworks/YahooSync.framework/Versions/A/Resources/Yahoo! Sync.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'Mise à jour de logiciels' => {
                'Version' => '4.0.6',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/CoreServices/Software Update.app',
                'Get Info String' => 'Software Update version 4.0, Copyright © 2000-2009, Apple Inc. All rights reserved.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'DiskImages UI Agent' => {
                'Version' => '289.1',
                'Last Modified' => '04/09/11 22:43',
                'Location' => '/System/Library/PrivateFrameworks/DiskImages.framework/Versions/A/Resources/DiskImages UI Agent.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Quartz Composer Visualizer' => {
                'Version' => '1.2',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Developer/Applications/Graphics Tools/Quartz Composer Visualizer.app',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Intel'
            },
            'Grapher' => {
                'Version' => '2.1',
                'Last Modified' => '07/04/09 02:42',
                'Location' => '/Applications/Utilities/Grapher.app',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Intel'
            },
            'CIJScannerRegister' => {
                'Version' => '1.0.0',
                'Last Modified' => '15/06/09 08:19',
                'Location' => '/Library/Image Capture/Support/LegacyDeviceDiscoveryHelpers/CIJScannerRegister.app',
                'Get Info String' => 'CIJScannerRegister version 1.0.0, Copyright CANON INC. 2009 All Rights Reserved.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Embed' => {
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Library/Scripts/ColorSync/Embed.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'VPNClient' => {
                'Version' => '4.9.01.0180',
                'Last Modified' => '14/10/09 17:14',
                'Location' => '/Applications/VPNClient.app',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Universal'
            },
            'Assistant réglages Bluetooth' => {
                'Version' => '2.4.5',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/CoreServices/Bluetooth Setup Assistant.app',
                'Get Info String' => '2.4.5, Copyright (c) 2011 Apple Inc. All rights reserved.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'SecurityFixer' => {
                'Version' => '10.6',
                'Last Modified' => '19/05/09 04:17',
                'Location' => '/System/Library/CoreServices/SecurityFixer.app',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Intel'
            },
            'Type1Camera' => {
                'Version' => '6.0',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/Image Capture/Devices/Type1Camera.app',
                'Get Info String' => '6.0, © Copyright 2000-2009 Apple Inc., all rights reserved.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'dotmacfx' => {
                'Version' => '3.0',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/Frameworks/SecurityFoundation.framework/Versions/A/dotmacfx.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'LexmarkCUPSDriver' => {
                'Version' => '1.1.26',
                'Last Modified' => '01/07/09 07:26',
                'Location' => '/Library/Printers/Lexmark/Drivers/LexmarkCUPSDriver.app',
                'Get Info String' => '0.0.0 (v27), Copyright 2008 Lexmark International, Inc. All rights reserved.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'IA32 Help' => {
                'Version' => '4.7.3',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Library/Application Support/Shark/Helpers/IA32 Help.app',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Intel'
            },
            'Type6Camera' => {
                'Version' => '6.0',
                'Last Modified' => '04/09/11 22:43',
                'Location' => '/System/Library/Image Capture/Devices/Type6Camera.app',
                'Get Info String' => '6.0, © Copyright 2002-2009 Apple Inc., all rights reserved.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'BluetoothUIServer' => {
                'Version' => '2.4.5',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/CoreServices/BluetoothUIServer.app',
                'Get Info String' => '2.4.5, Copyright (c) 2011 Apple Inc. All rights reserved.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'Database Events' => {
                'Version' => '1.0.4',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/CoreServices/Database Events.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'FontRegistryUIAgent' => {
                'Version' => '33.12',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/Frameworks/ApplicationServices.framework/Versions/A/Frameworks/ATS.framework/Versions/A/Support/FontRegistryUIAgent.app',
                'Get Info String' => 'Copyright © 2011 Apple Inc.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Bluetooth Explorer' => {
                'Version' => '2.3.6',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Developer/Applications/Utilities/Bluetooth/Bluetooth Explorer.app',
                'Get Info String' => '2.3.6, Copyright (c) 2010 Apple Inc. All rights reserved.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'WebProcess' => {
                'Version' => '6534.52',
                'Last Modified' => '17/02/12 12:35',
                'Location' => '/System/Library/PrivateFrameworks/WebKit2.framework/WebProcess.app',
                'Get Info String' => '6534.52.7, Copyright 2003-2011 Apple Inc.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'SpeakableItems' => {
                'Version' => '3.7.8',
                'Last Modified' => '19/05/09 10:45',
                'Location' => '/System/Library/Speech/Recognizers/AppleSpeakableItems.SpeechRecognizer/Contents/Resources/SpeakableItems.app',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Intel'
            },
            'Microsoft PowerPoint' => {
                'Version' => '11.2.0',
                'Last Modified' => '12/12/05 13:00',
                'Location' => '/Applications/Office 2004 for Mac Test Drive/Microsoft PowerPoint',
                'Get Info String' => '11.2.0 (051115TD), © 2004 Microsoft Corporation.  All rights reserved.',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'PowerPC'
            },
            'Inkjet1' => {
                'Version' => '2.1.2',
                'Last Modified' => '16/06/09 15:54',
                'Location' => '/Library/Printers/hp/cups/Inkjet1.driver',
                'Get Info String' => 'HP Inkjet 1 Driver 2.1.2, Copyright (c) 1994-2009 Hewlett-Packard Development Company, L.P.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Moniteur d’activité' => {
                'Version' => '10.6',
                'Last Modified' => '31/07/09 09:18',
                'Location' => '/Applications/Utilities/Activity Monitor.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'TamilIM' => {
                'Version' => '1.3',
                'Last Modified' => '19/05/09 07:36',
                'Location' => '/System/Library/Input Methods/TamilIM.app',
                'Get Info String' => 'Tamil Input Method 1.2',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'CoreServicesUIAgent' => {
                'Version' => '41.5',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/CoreServices/CoreServicesUIAgent.app',
                'Get Info String' => 'Copyright © 2009 Apple Inc.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Syncrospector' => {
                'Version' => '5.2',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Developer/Applications/Utilities/Syncrospector.app',
                'Get Info String' => 'Syncrospector 3.0, © 2004 Apple Computer, Inc., All rights reserved.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'Trousseau d’accès' => {
                'Version' => '4.1.1',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Applications/Utilities/Keychain Access.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'UserNotificationCenter' => {
                'Version' => '3.1.0',
                'Last Modified' => '19/05/09 04:13',
                'Location' => '/System/Library/CoreServices/UserNotificationCenter.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'SecurityAgent' => {
                'Version' => '5.2',
                'Last Modified' => '04/09/11 22:43',
                'Location' => '/System/Library/CoreServices/SecurityAgent.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'PhotosmartPro' => {
                'Version' => '3.0',
                'Last Modified' => '16/06/09 11:32',
                'Location' => '/Library/Printers/hp/cups/PhotosmartPro.driver',
                'Get Info String' => 'HP Photosmart Pro Driver 3.0, Copyright (c) 1994-2009 Hewlett-Packard Development Company, L.P.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Éditeur d\'équations' => {
                'Version' => '11.0.0',
                'Last Modified' => '12/12/05 13:00',
                'Location' => '/Applications/Office 2004 for Mac Test Drive/Office/Éditeur d\'équations',
                'Get Info String' => '11.0.0 (040108), ©2004 Microsoft Corporation.  All rights reserved.',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'PowerPC'
            },
            'ScreenReaderUIServer' => {
                'Version' => '3.5.0',
                'Last Modified' => '04/09/11 22:43',
                'Location' => '/System/Library/PrivateFrameworks/ScreenReader.framework/Versions/A/Resources/ScreenReaderUIServer.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'Éditeur AppleScript' => {
                'Version' => '2.3',
                'Last Modified' => '24/04/09 15:41',
                'Location' => '/Applications/Utilities/AppleScript Editor.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'TWAINBridge' => {
                'Version' => '6.0.1',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/Image Capture/Devices/TWAINBridge.app',
                'Get Info String' => '6.0.1, © Copyright 2000-2010 Apple Inc., all rights reserved.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'AppleMobileDeviceHelper' => {
                'Version' => '5.0',
                'Last Modified' => '17/02/12 12:35',
                'Location' => '/System/Library/PrivateFrameworks/MobileDevice.framework/Versions/A/AppleMobileDeviceHelper.app',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Universal'
            },
            'Lanceur d’applets' => {
                'Version' => '13.6.0',
                'Last Modified' => '17/02/12 12:35',
                'Location' => '/usr/share/java/Tools/Applet Launcher.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'SpindownHD' => {
                'Version' => '4.7.3',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Developer/Applications/Performance Tools/CHUD/Hardware Tools/SpindownHD.app',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Intel'
            },
            'FileMerge' => {
                'Version' => '2.5',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Developer/Applications/Utilities/FileMerge.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Git Gui' => {
                'Version' => '0.13.0',
                'Last Modified' => '22/10/10 16:54',
                'Location' => '/usr/local/git/share/git-gui/lib/Git Gui.app',
                'Get Info String' => 'Git Gui 0.13.0 © 2006-2007 Shawn Pearce, et. al.',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Universal'
            },
            'Jar Bundler' => {
                'Version' => '13.6.0',
                'Last Modified' => '17/02/12 12:35',
                'Location' => '/usr/share/java/Tools/Jar Bundler.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'Python' => {
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Developer/SDKs/MacOSX10.5.sdk/System/Library/Frameworks/Python.framework/Versions/2.5/Resources/Python.app',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Universal'
            },
            'Type8Camera' => {
                'Version' => '6.1',
                'Last Modified' => '04/09/11 22:43',
                'Location' => '/System/Library/Image Capture/Devices/Type8Camera.app',
                'Get Info String' => '6.1, © Copyright 2002-2011 Apple Inc., all rights reserved.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'NetAuthAgent' => {
                'Version' => '2.1',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/CoreServices/NetAuthAgent.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'commandtoescp' => {
                'Version' => '8.02',
                'Last Modified' => '09/07/09 06:55',
                'Location' => '/Library/Printers/EPSON/InkjetPrinter2/Filter/commandtoescp.app',
                'Get Info String' => 'commandtoescp Copyright (C) SEIKO EPSON CORPORATION 2001-2009. All rights reserved.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Microsoft Word' => {
                'Version' => '11.2.0',
                'Last Modified' => '12/12/05 13:00',
                'Location' => '/Applications/Office 2004 for Mac Test Drive/Microsoft Word',
                'Get Info String' => '11.2.0 (051115TD), © 2004 Microsoft Corporation.  All rights reserved.',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'PowerPC'
            },
            'Application Loader' => {
                'Version' => '1.4.1',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Developer/Applications/Utilities/Application Loader.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Guide de l’utilisateur de Keynote' => {
                'Version' => '1.0.2',
                'Last Modified' => '17/02/09 17:24',
                'Location' => '/Library/Documentation/Applications/iWork \'06/Keynote User Guide.app',
                'Get Info String' => 'Keynote User Guide',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Universal'
            },
            'Instruments' => {
                'Version' => '2.7',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Developer/Applications/Instruments.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'SpeechService' => {
                'Version' => '3.10.35',
                'Last Modified' => '12/07/09 07:23',
                'Location' => '/System/Library/Services/SpeechService.service',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'Lecteur DVD' => {
                'Version' => '5.4',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Applications/DVD Player.app',
                'Get Info String' => '5.4, Copyright © 2001-2010 by Apple Inc.  All Rights Reserved.',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Intel'
            },
            'Keychain Scripting' => {
                'Version' => '4.0.2',
                'Last Modified' => '04/09/11 22:43',
                'Location' => '/System/Library/ScriptingAdditions/Keychain Scripting.app',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Universal'
            },
            'AppleGraphicsWarning' => {
                'Version' => '2.0.3',
                'Last Modified' => '19/05/09 07:27',
                'Location' => '/System/Library/CoreServices/AppleGraphicsWarning.app',
                'Get Info String' => 'Version 2.0.3, Copyright Apple Inc., 2008',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Jar Launcher' => {
                'Version' => '13.6.0',
                'Last Modified' => '17/02/12 12:35',
                'Location' => '/System/Library/CoreServices/Jar Launcher.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'Image Capture Extension' => {
                'Version' => '6.1',
                'Last Modified' => '04/09/11 22:43',
                'Location' => '/System/Library/Image Capture/Support/Image Capture Extension.app',
                'Get Info String' => '6.1, © Copyright 2000-2011 Apple Inc. All rights reserved.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'Configuration audio et MIDI' => {
                'Version' => '3.0.3',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Applications/Utilities/Audio MIDI Setup.app',
                'Get Info String' => '3.0.3, Copyright 2002-2010 Apple, Inc.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Match' => {
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Library/Scripts/ColorSync/Match.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'Installation à distance de Mac OS X' => {
                'Version' => '1.1.1',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Applications/Utilities/Remote Install Mac OS X.app',
                'Get Info String' => 'Remote Install Mac OS X 1.1.1, Copyright © 2007-2009 Apple Inc. All rights reserved',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'rastertoescpII' => {
                'Version' => '8.02',
                'Last Modified' => '09/07/09 06:55',
                'Location' => '/Library/Printers/EPSON/InkjetPrinter2/Filter/rastertoescpII.app',
                'Get Info String' => 'rastertoescpII Copyright (C) SEIKO EPSON CORPORATION 2001-2009. All rights reserved.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'System Events' => {
                'Version' => '1.3.4',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/CoreServices/System Events.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'IncompatibleAppDisplay' => {
                'Version' => '305',
                'Last Modified' => '04/09/11 22:43',
                'Location' => '/System/Library/PrivateFrameworks/SystemMigration.framework/Versions/A/Resources/IncompatibleAppDisplay.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'TCIM' => {
                'Version' => '6.3',
                'Last Modified' => '04/09/11 22:43',
                'Location' => '/System/Library/Input Methods/TCIM.app',
                'Get Info String' => '6.2, Copyright © 1997-2006 Apple Computer Inc., All Rights Reserved',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'Utilitaire de réseau' => {
                'Version' => '1.4.6',
                'Last Modified' => '25/06/09 04:25',
                'Location' => '/Applications/Utilities/Network Utility.app',
                'Get Info String' => 'Version 1.4.6, Copyright © 2000-2009 Apple Inc. All rights reserved.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'iChatAgent' => {
                'Version' => '5.0.3',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/Frameworks/IMCore.framework/iChatAgent.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'iCal Helper' => {
                'Version' => '4.0.4',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/Frameworks/CalendarStore.framework/Versions/A/Resources/iCal Helper.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'Microsoft Clip Gallery' => {
                'Version' => '11.2.0',
                'Last Modified' => '12/12/05 13:00',
                'Location' => '/Applications/Office 2004 for Mac Test Drive/Office/Microsoft Clip Gallery',
                'Get Info String' => '11.2.0 (050718), © 2004 Microsoft Corporation.  All rights reserved.',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'PowerPC'
            },
            'Console' => {
                'Version' => '10.6.3',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Applications/Utilities/Console.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'TeX Live Utility' => {
                'Version' => '0.65',
                'Last Modified' => '06/10/09 09:58',
                'Location' => '/Applications/TeX/TeX Live Utility.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'GarageBand' => {
                'Version' => '3.0.5',
                'Last Modified' => '15/10/09 13:14',
                'Location' => '/Applications/GarageBand.app',
                'Get Info String' => 'GarageBand 3.0.5 (104.10), Copyright © 2005-2007 by Apple Inc.',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Universal'
            },
            'Capture' => {
                'Version' => '1.5',
                'Last Modified' => '19/05/09 04:12',
                'Location' => '/Applications/Utilities/Grab.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'File Sync' => {
                'Version' => '5.0.3',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/CoreServices/File Sync.app',
                'Get Info String' => '© Copyright 2009 Apple Inc., all rights reserved.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Résolution des conflits' => {
                'Version' => '5.2',
                'Last Modified' => '04/09/11 22:43',
                'Location' => '/System/Library/PrivateFrameworks/SyncServicesUI.framework/Versions/A/Resources/Conflict Resolver.app',
                'Get Info String' => '1.0, Copyright Apple Computer Inc. 2004',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'Inkjet5' => {
                'Version' => '2.1',
                'Last Modified' => '16/06/09 14:00',
                'Location' => '/Library/Printers/hp/cups/Inkjet5.driver',
                'Get Info String' => 'HP Inkjet 5 Driver 2.1, Copyright (c) 1994-2009 Hewlett-Packard Development Company, L.P.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'OmniOutliner' => {
                'Version' => '3.5',
                'Last Modified' => '15/03/06 02:55',
                'Location' => '/Applications/OmniOutliner.app',
                'Get Info String' => 'OmniOutliner 3.5, version 134.3, Copyright 2000-2005 The Omni Group',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Universal'
            },
            'Keynote' => {
                'Version' => '3.0.2',
                'Last Modified' => '17/02/09 18:05',
                'Location' => '/Applications/iWork \'06/Keynote.app',
                'Get Info String' => '3.0.2, Copyright 2006 Apple Computer, Inc.',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Universal'
            },
            'Microsoft Cert Manager' => {
                'Version' => '050929',
                'Last Modified' => '22/12/05 23:28',
                'Location' => '/Applications/Office 2004 for Mac Test Drive/Office/Microsoft Cert Manager.app',
                'Get Info String' => '1.0.1 (050929), ©2004 Microsoft Corporation.  All rights reserved.',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'PowerPC'
            },
            'InkServer' => {
                'Version' => '1.0',
                'Last Modified' => '19/05/09 04:18',
                'Location' => '/System/Library/Input Methods/InkServer.app',
                'Get Info String' => '1.0, Copyright 2008 Apple Inc.',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Intel'
            },
            'Création de page Web' => {
                'Version' => '6.0',
                'Last Modified' => '04/09/11 22:43',
                'Location' => '/System/Library/Image Capture/Automatic Tasks/Build Web Page.app',
                'Get Info String' => '6.0, © Copyright 2003-2009 Apple  Inc., all rights reserved.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'HP Printer Utility' => {
                'Version' => '8.1.0',
                'Last Modified' => '23/06/09 16:22',
                'Location' => '/Library/Printers/hp/Utilities/HP Printer Utility.app',
                'Get Info String' => 'HP Printer Utility version 8.1.0, Copyright (c) 2005-2010 Hewlett-Packard Development Company, L.P.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Utilitaire AirPort' => {
                'Version' => '5.5.3',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Applications/Utilities/AirPort Utility.app',
                'Get Info String' => '5.5.3, Copyright 2001-2011 Apple Inc.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'Wish' => {
                'Version' => '8.5.7',
                'Last Modified' => '23/07/09 05:45',
                'Location' => '/System/Library/Frameworks/Tk.framework/Versions/8.5/Resources/Wish.app',
                'Get Info String' => 'Wish Shell 8.5.7,',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Utilitaire ColorSync' => {
                'Version' => '4.6.2',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Applications/Utilities/ColorSync Utility.app',
                'Get Info String' => '4.6.2, © Copyright 2009 Apple Inc.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'CrashReporterPrefs' => {
                'Version' => '10.6.3',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Developer/Applications/Utilities/CrashReporterPrefs.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'KeyboardSetupAssistant' => {
                'Version' => '10.5.0',
                'Last Modified' => '19/05/09 07:45',
                'Location' => '/System/Library/CoreServices/KeyboardSetupAssistant.app',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Intel'
            },
            'Property List Editor' => {
                'Version' => '5.3',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Developer/Applications/Utilities/Property List Editor.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'Microsoft Entourage' => {
                'Version' => '11.2.1',
                'Last Modified' => '12/12/05 13:00',
                'Location' => '/Applications/Office 2004 for Mac Test Drive/Microsoft Entourage',
                'Get Info String' => '11.2.1 (051115TD), © 2004 Microsoft Corporation.  All rights reserved.',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'PowerPC'
            },
            'Folder Actions Dispatcher' => {
                'Version' => '1.0.2',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/CoreServices/Folder Actions Dispatcher.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Reggie SE' => {
                'Version' => '4.7.3',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Developer/Applications/Performance Tools/CHUD/Hardware Tools/Reggie SE.app',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Intel'
            },
            'Mail' => {
                'Version' => '4.5',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Applications/Mail.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Quartz Debug' => {
                'Version' => '4.1',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Developer/Applications/Performance Tools/Quartz Debug.app',
                'Get Info String' => 'Quartz Debug 4.1',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Apple80211Agent' => {
                'Version' => '6.2.2',
                'Last Modified' => '04/09/11 22:43',
                'Location' => '/System/Library/CoreServices/Apple80211Agent.app',
                'Get Info String' => '6.2.2, Copyright © 2000–2009 Apple Inc. All rights reserved.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'Microsoft Query' => {
                'Version' => '10.0.0',
                'Last Modified' => '12/12/05 13:00',
                'Location' => '/Applications/Office 2004 for Mac Test Drive/Office/Microsoft Query',
                'Get Info String' => '10.0.0 (1204)  Copyright 1995-2002 Microsoft Corporation.  All rights reserved.',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'PowerPC'
            },
            'check_afp' => {
                'Version' => '2.1',
                'Last Modified' => '04/09/11 22:43',
                'Location' => '/System/Library/Filesystems/AppleShare/check_afp.app',
                'Get Info String' => 'AFP Client Session Monitor, Copyright © 2000 - 2010, Apple Inc.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'Microsoft Graph' => {
                'Version' => '11.2.0',
                'Last Modified' => '12/12/05 13:00',
                'Location' => '/Applications/Office 2004 for Mac Test Drive/Office/Microsoft Graph',
                'Get Info String' => '11.2.0 (050718), © 2004 Microsoft Corporation.  All rights reserved.',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'PowerPC'
            },
            'Raster2CanonIJ' => {
                'Last Modified' => '15/06/09 08:18',
                'Location' => '/Library/Printers/Canon/BJPrinter/Filters/Raster2CanonIJ/Raster2CanonIJ.bundle'
            },
            'Premiers contacts avec iMovie' => {
                'Version' => '1.0.2',
                'Last Modified' => '17/02/09 17:24',
                'Location' => '/Library/Documentation/Applications/iMovie/iMovie Getting Started.app',
                'Get Info String' => 'iMovie Getting Started',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Universal'
            },
            'Dictionnaire' => {
                'Version' => '2.1.3',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Applications/Dictionary.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Dock' => {
                'Version' => '1.7',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/CoreServices/Dock.app',
                'Get Info String' => 'Dock 1.7',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'ImageCaptureService' => {
                'Version' => '6.0.1',
                'Last Modified' => '04/09/11 22:43',
                'Location' => '/System/Library/Services/ImageCaptureService.app',
                'Get Info String' => '6.0, © Copyright 2003-2009 Apple Inc., all rights reserved.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Microsoft Error Reporting' => {
                'Version' => '050811',
                'Last Modified' => '12/12/05 13:00',
                'Location' => '/Applications/Office 2004 for Mac Test Drive/Office/Microsoft Error Reporting.app',
                'Get Info String' => '1.0.1 (050811), ©2004 Microsoft Corporation.  All rights reserved.',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'PowerPC'
            },
            'Préférences Java' => {
                'Version' => '13.6.0',
                'Last Modified' => '17/02/12 12:35',
                'Location' => '/Applications/Utilities/Java Preferences.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'Bluetooth Diagnostics Utility' => {
                'Version' => '2.3.6',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Developer/Applications/Utilities/Bluetooth/Bluetooth Diagnostics Utility.app',
                'Get Info String' => '2.3.6, Copyright (c) 2010 Apple Inc. All rights reserved.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'Inkjet' => {
                'Version' => '3.0',
                'Last Modified' => '16/06/09 12:48',
                'Location' => '/Library/Printers/hp/cups/Inkjet.driver',
                'Get Info String' => 'HP Inkjet Driver 3.0, Copyright (c) 1994-2009 Hewlett-Packard Development Company, L.P.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Automator' => {
                'Version' => '2.1.1',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Applications/Automator.app',
                'Get Info String' => '2.1.1, Copyright © 2004-2009 Apple Inc. All rights reserved.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'store_helper' => {
                'Version' => '1.0',
                'Last Modified' => '04/09/11 22:43',
                'Location' => '/System/Library/PrivateFrameworks/CommerceKit.framework/Versions/A/Resources/store_helper.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'TeXShop' => {
                'Version' => '2.26',
                'Last Modified' => '06/10/09 09:58',
                'Location' => '/Applications/TeX/TeXShop.app',
                'Get Info String' => '2.26, Copyright 2001-2007, Richard Koch',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Universal'
            },
            'License' => {
                'Version' => '11',
                'Last Modified' => '25/07/09 07:43',
                'Location' => '/Library/Documentation/License.app',
                'Get Info String' => 'License',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Universal'
            },
            'Colorimètre numérique' => {
                'Version' => '3.7.2',
                'Last Modified' => '28/05/09 07:06',
                'Location' => '/Applications/Utilities/DigitalColor Meter.app',
                'Get Info String' => '3.7.2, Copyright 2001-2008 Apple Inc. All Rights Reserved.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            '50onPaletteServer' => {
                'Version' => '1.0.3',
                'Last Modified' => '30/06/09 07:29',
                'Location' => '/System/Library/Input Methods/50onPaletteServer.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'URL Access Scripting' => {
                'Version' => '1.1.1',
                'Last Modified' => '19/05/09 07:34',
                'Location' => '/System/Library/ScriptingAdditions/URL Access Scripting.app',
                'Get Info String' => 'URL Access Scripting 1.1, Copyright © 2002-2004 Apple Computer, Inc.',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Universal'
            },
            'Saturn' => {
                'Version' => '4.7.3',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Developer/Applications/Performance Tools/CHUD/Saturn.app',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Intel'
            },
            'PubSubAgent' => {
                'Version' => '1.0.5',
                'Last Modified' => '17/02/12 12:35',
                'Location' => '/System/Library/Frameworks/PubSub.framework/Versions/A/Resources/PubSubAgent.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'VietnameseIM' => {
                'Version' => '1.1.1',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/Input Methods/VietnameseIM.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'kcSync' => {
                'Version' => '3.0.1',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/Frameworks/SecurityFoundation.framework/Versions/A/kcSync.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'App Store' => {
                'Version' => '1.0.2',
                'Last Modified' => '17/02/12 12:35',
                'Location' => '/Applications/App Store.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Premiers contacts avec iWeb' => {
                'Version' => '1.0.2',
                'Last Modified' => '17/02/09 17:24',
                'Location' => '/Library/Documentation/Applications/iWeb/iWeb Getting Started.app',
                'Get Info String' => 'iWeb Getting Started',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Universal'
            },
            'Aperçu' => {
                'Version' => '5.0.3',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Applications/Preview.app',
                'Get Info String' => '5.0.1, Copyright 2002-2009 Apple Inc.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Build Applet' => {
                'Version' => '2.6.0',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Developer/Applications/Utilities/Python 2.6/Build Applet.app',
                'Get Info String' => '2.6.0a0, (c) 2004 Python Software Foundation.',
                '64-Bit (Intel)' => 'No'
            },
            'Diagnostic réseau' => {
                'Version' => '1.1.3',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/CoreServices/Network Diagnostics.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'Big Bang Backgammon' => {
                'Version' => '2.51',
                'Last Modified' => '05/04/07 16:09',
                'Location' => '/Applications/Big Bang Board Games/Big Bang Backgammon.app',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Universal'
            },
            'CoreLocationAgent' => {
                'Version' => '12.3',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/CoreServices/CoreLocationAgent.app',
                'Get Info String' => 'Copyright © 2009 Apple Inc.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'Show Info' => {
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Library/Scripts/ColorSync/Show Info.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'Préférences Système' => {
                'Version' => '7.0',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Applications/System Preferences.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'Java VisualVM' => {
                'Version' => '13.6.0',
                'Last Modified' => '17/02/12 12:35',
                'Location' => '/usr/share/java/Tools/Java VisualVM.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'Inkjet6' => {
                'Version' => '1.0',
                'Last Modified' => '16/06/09 10:36',
                'Location' => '/Library/Printers/hp/cups/Inkjet6.driver',
                'Get Info String' => 'HP Inkjet 6 Driver 1.0, Copyright (c) 1994-2009 Hewlett-Packard Development Company, L.P.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'HALLab' => {
                'Version' => '1.6',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Developer/Applications/Audio/HALLab.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'CHUD Remover' => {
                'Version' => '4.7.3',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Developer/Applications/Performance Tools/CHUD/CHUD Remover.app',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Intel'
            },
            'Accessibility Inspector' => {
                'Version' => '2.0',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Developer/Applications/Utilities/Accessibility Tools/Accessibility Inspector.app',
                'Get Info String' => 'Accessibility Inspector 2.0, Copyright 2002-2009 Apple Inc.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'CharacterPalette' => {
                'Version' => '1.0.4',
                'Last Modified' => '02/07/09 09:49',
                'Location' => '/System/Library/Input Methods/CharacterPalette.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'Utilitaire VoiceOver' => {
                'Version' => '3.5.0',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Applications/Utilities/VoiceOver Utility.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'EPIJAutoSetupTool2' => {
                'Version' => '8.02',
                'Last Modified' => '09/07/09 06:55',
                'Location' => '/Library/Printers/EPSON/InkjetPrinter2/AutoSetupTool/EPIJAutoSetupTool2.app',
                'Get Info String' => 'EPIJAutoSetupTool2 Copyright (C) SEIKO EPSON CORPORATION 2001-2009. All rights reserved.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'VoiceOver' => {
                'Version' => '3.5.0',
                'Last Modified' => '04/09/11 22:43',
                'Location' => '/System/Library/CoreServices/VoiceOver.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'Lexmark Scanner' => {
                'Version' => '3.2.45',
                'Last Modified' => '01/07/09 07:26',
                'Location' => '/Library/Image Capture/Devices/Lexmark Scanner.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'AddPrinter' => {
                'Version' => '6.6',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/CoreServices/AddPrinter.app',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Intel'
            },
            'Automator Runner' => {
                'Version' => '1.1',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/CoreServices/Automator Runner.app',
                'Get Info String' => '1.1, Copyright © 2006-2009 Apple Inc. All rights reserved.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'MallocDebug' => {
                'Version' => '1.7.1',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Developer/Applications/Performance Tools/MallocDebug.app',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Universal'
            },
            'SpeechFeedbackWindow' => {
                'Version' => '3.8.1',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/Frameworks/Carbon.framework/Versions/A/Frameworks/SpeechRecognition.framework/Versions/A/Resources/SpeechFeedbackWindow.app',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Intel'
            },
            'CIJAutoSetupTool' => {
                'Version' => '1.7.1',
                'Last Modified' => '15/06/09 08:18',
                'Location' => '/Library/Printers/Canon/BJPrinter/Utilities/CIJAutoSetupTool.app',
                'Get Info String' => 'CIJAutoSetupTool.app version 1.7.0, Copyright CANON INC. 2007-2008 All Rights Reserved.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Alerts Daemon' => {
                'Version' => '040322',
                'Last Modified' => '12/12/05 13:00',
                'Location' => '/Applications/Office 2004 for Mac Test Drive/Office/Alerts Daemon.app',
                'Get Info String' => '11.0.0 (040322), ©2004 Microsoft Corporation.  All rights reserved.',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'PowerPC'
            },
            'HPFaxBackend' => {
                'Version' => '3.1.0',
                'Last Modified' => '25/07/09 08:52',
                'Location' => '/Library/Printers/hp/Fax/HPFaxBackend.app',
                'Get Info String' => '1.0, Copyright © 2009 Hewlett-Packard Development Company, L.P.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'Proof' => {
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Library/Scripts/ColorSync/Proof.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'HelpViewer' => {
                'Version' => '5.0.4',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/CoreServices/HelpViewer.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Premiers contacts avec iPhoto' => {
                'Version' => '1.0.2',
                'Last Modified' => '17/02/09 18:05',
                'Location' => '/Library/Documentation/Applications/iPhoto/iPhoto Getting Started.app',
                'Get Info String' => 'iPhoto Getting Started',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Universal'
            },
            'Big Bang 4-In-A-Row' => {
                'Version' => '2.51',
                'Last Modified' => '05/04/07 16:09',
                'Location' => '/Applications/Big Bang Board Games/Big Bang 4-In-A-Row.app',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Universal'
            },
            'ServerJoiner' => {
                'Version' => '10.6.3',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/CoreServices/ServerJoiner.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Configuration actions de dossier' => {
                'Version' => '1.1.4',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/CoreServices/Folder Actions Setup.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'AU Lab' => {
                'Version' => '2.2',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Developer/Applications/Audio/AU Lab.app',
                'Get Info String' => '2.2 ©2010, Apple, Inc',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Pixie' => {
                'Version' => '2.3',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Developer/Applications/Graphics Tools/Pixie.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Utilitaire d’emplacement de mémoire' => {
                'Version' => '1.4.1',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/CoreServices/Memory Slot Utility.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'AppleScript Runner' => {
                'Version' => '1.0.2',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/CoreServices/AppleScript Runner.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'wxPerl' => {
                'Version' => '1.0',
                'Last Modified' => '19/05/09 08:31',
                'Location' => '/System/Library/Perl/Extras/5.8.9/darwin-thread-multi-2level/auto/Wx/wxPerl.app',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Universal'
            },
            'Microsoft Office Notifications' => {
                'Version' => '11.2.0',
                'Last Modified' => '12/12/05 13:00',
                'Location' => '/Applications/Office 2004 for Mac Test Drive/Office/Microsoft Office Notifications',
                'Get Info String' => '11.2.0 (050825), © 2004 Microsoft Corporation.  All rights reserved.',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'PowerPC'
            },
            'Pages' => {
                'Version' => '2.0.2',
                'Last Modified' => '17/02/09 18:05',
                'Location' => '/Applications/iWork \'06/Pages.app',
                'Get Info String' => '2.0.2, Copyright 2006 Apple Computer Inc.',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Universal'
            },
            'Problem Reporter' => {
                'Version' => '10.6.7',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/CoreServices/Problem Reporter.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'Échange de fichiers Bluetooth' => {
                'Version' => '2.4.5',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Applications/Utilities/Bluetooth File Exchange.app',
                'Get Info String' => '2.4.5, Copyright (c) 2011 Apple Inc. All rights reserved.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'IORegistryExplorer' => {
                'Version' => '2.1',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Developer/Applications/Utilities/IORegistryExplorer.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'UnmountAssistantAgent' => {
                'Version' => '1.0',
                'Last Modified' => '03/07/09 03:00',
                'Location' => '/System/Library/CoreServices/UnmountAssistantAgent.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'MassStorageCamera' => {
                'Version' => '6.1',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/Image Capture/Devices/MassStorageCamera.app',
                'Get Info String' => '6.1, © Copyright 2000-2011 Apple Inc. All rights reserved.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'SpeechRecognitionServer' => {
                'Version' => '3.11.1',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/Frameworks/Carbon.framework/Versions/A/Frameworks/SpeechRecognition.framework/Versions/A/Resources/SpeechRecognitionServer.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'X11' => {
                'Version' => '2.3.6',
                'Last Modified' => '04/09/11 22:43',
                'Location' => '/Applications/Utilities/X11.app',
                'Get Info String' => 'org.x.X11',
                '64-Bit (Intel)' => 'No'
            },
            'quicklookd32' => {
                'Version' => '2.3',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/Frameworks/QuickLook.framework/Versions/A/Resources/quicklookd32.app',
                'Get Info String' => '1.0, Copyright Apple Inc. 2007',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Intel'
            },
            'iSync Plug-in Maker' => {
                'Version' => '3.1',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Developer/Applications/Utilities/iSync Plug-in Maker.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'Repeat After Me' => {
                'Version' => '1.3',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Developer/Applications/Utilities/Speech/Repeat After Me.app',
                'Get Info String' => '1.3, Copyright © 2002-2005 Apple Computer, Inc.',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Intel'
            },
            'HP Utility' => {
                'Version' => '4.6.1',
                'Last Modified' => '23/06/09 16:22',
                'Location' => '/Library/Printers/hp/Utilities/HP Utility.app',
                'Get Info String' => 'HP Utility version 4.6.1, Copyright (c) 2005-2010 Hewlett-Packard Development Company, L.P.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Livre des polices' => {
                'Version' => '2.2.2',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Applications/Font Book.app',
                'Get Info String' => '2.2.2, Copyright © 2003-2010 Apple Inc.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'rcd' => {
                'Version' => '2.6',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/CoreServices/rcd.app',
                'Get Info String' => '2.6',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Automator Launcher' => {
                'Version' => '1.2',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/CoreServices/Automator Launcher.app',
                'Get Info String' => '1.2, Copyright © 2004-2009 Apple Inc. All rights reserved.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Laserjet' => {
                'Version' => '1.0',
                'Last Modified' => '22/06/09 14:27',
                'Location' => '/Library/Printers/hp/cups/Laserjet.driver',
                'Get Info String' => 'HP Laserjet Driver 1.0, Copyright (c) 1994-2009 Hewlett-Packard Development Company, L.P.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Deskjet' => {
                'Version' => '3.0',
                'Last Modified' => '18/06/09 13:21',
                'Location' => '/Library/Printers/hp/cups/Deskjet.driver',
                'Get Info String' => 'HP Deskjet Driver 3.0, Copyright (c) 1994-2009 Hewlett-Packard Development Company, L.P.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'PrinterProxy' => {
                'Version' => '6.6',
                'Last Modified' => '04/09/11 22:43',
                'Location' => '/System/Library/Frameworks/Carbon.framework/Versions/A/Frameworks/Print.framework/Versions/A/Plugins/PrinterProxy.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'OpenGL Driver Monitor' => {
                'Version' => '1.5',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Developer/Applications/Graphics Tools/OpenGL Driver Monitor.app',
                'Get Info String' => '1.5, Copyright © 2009 Apple Inc.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Core Image Fun House' => {
                'Version' => '2.1.43',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Developer/Applications/Graphics Tools/Core Image Fun House.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'USB Prober' => {
                'Version' => '4.0.0',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Developer/Applications/Utilities/USB Prober.app',
                'Get Info String' => '4.0.0, Copyright © 2002-2010 Apple Inc. All Rights Reserved.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'BigTop' => {
                'Version' => '4.7.3',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Developer/Applications/Performance Tools/BigTop.app',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Intel'
            },
            'FontSyncScripting' => {
                'Version' => '2.0.6',
                'Last Modified' => '19/05/09 04:17',
                'Location' => '/System/Library/ScriptingAdditions/FontSyncScripting.app',
                'Get Info String' => 'FontSync Scripting 2.0. Copyright © 2000-2008 Apple Inc.',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Universal'
            },
            'Big Bang Chess' => {
                'Version' => '2.51',
                'Last Modified' => '05/04/07 16:09',
                'Location' => '/Applications/Big Bang Board Games/Big Bang Chess.app',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Universal'
            },
            'iDVD' => {
                'Version' => '6.0.4',
                'Last Modified' => '17/02/09 18:05',
                'Location' => '/Applications/iDVD.app',
                'Get Info String' => 'iDVD 6.0.4, Copyright � 2001-2006 Apple Inc.',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Universal'
            },
            'quicklookd' => {
                'Version' => '2.3',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/Frameworks/QuickLook.framework/Versions/A/Resources/quicklookd.app',
                'Get Info String' => '1.0, Copyright Apple Inc. 2007',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Spaces' => {
                'Version' => '1.1',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Applications/Utilities/Spaces.app',
                'Get Info String' => '1.1, Copyright 2007-2008 Apple Inc.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'Microsoft Excel' => {
                'Version' => '11.2.0',
                'Last Modified' => '12/12/05 13:00',
                'Location' => '/Applications/Office 2004 for Mac Test Drive/Microsoft Excel',
                'Get Info String' => '11.2.0 (051115TD), © 2004 Microsoft Corporation.  All rights reserved.',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'PowerPC'
            },
            'iSync' => {
                'Version' => '3.1.2',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Applications/iSync.app',
                'Get Info String' => '3.1.2, Copyright © 2003-2010 Apple Inc.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Remove' => {
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Library/Scripts/ColorSync/Remove.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'KerberosAgent' => {
                'Version' => '6.5.11',
                'Last Modified' => '04/09/11 22:43',
                'Location' => '/System/Library/CoreServices/KerberosAgent.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'Printer Setup Utility' => {
                'Version' => '6.6',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/CoreServices/Printer Setup Utility.app',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Universal'
            },
            'Type4Camera' => {
                'Version' => '6.1',
                'Last Modified' => '04/09/11 22:43',
                'Location' => '/System/Library/Image Capture/Devices/Type4Camera.app',
                'Get Info String' => '6.1, © Copyright 2001-2011 Apple Inc. All rights reserved.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'EPSON Scanner' => {
                'Version' => '5.0',
                'Last Modified' => '09/07/09 06:57',
                'Location' => '/Library/Image Capture/Devices/EPSON Scanner.app',
                'Get Info String' => '5.0, Copyright 2003 EPSON',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'PacketLogger' => {
                'Version' => '2.3.6',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Developer/Applications/Utilities/Bluetooth/PacketLogger.app',
                'Get Info String' => '2.3.6, Copyright (c) 2010 Apple Inc. All rights reserved.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'BluetoothCamera' => {
                'Version' => '6.0.1',
                'Last Modified' => '04/09/11 22:43',
                'Location' => '/System/Library/Image Capture/Devices/BluetoothCamera.app',
                'Get Info String' => '6.0.1, © Copyright 2004-2011 Apple Inc., all rights reserved.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'PluginIM' => {
                'Version' => '1.1',
                'Last Modified' => '19/05/09 07:36',
                'Location' => '/System/Library/Input Methods/PluginIM.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'Transfert d’images' => {
                'Version' => '6.0.1',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Applications/Image Capture.app',
                'Get Info String' => '6.0, © Copyright 2000-2009 Apple Inc., all rights reserved.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'AppleMobileSync' => {
                'Version' => '5.0',
                'Last Modified' => '17/02/12 12:35',
                'Location' => '/System/Library/PrivateFrameworks/MobileDevice.framework/Versions/A/AppleMobileSync.app',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Universal'
            },
            'Calculette' => {
                'Version' => '4.5.3',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Applications/Calculator.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Utilitaire d’emplacement d’extension' => {
                'Version' => '1.4.1',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/CoreServices/Expansion Slot Utility.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Dashcode' => {
                'Version' => '3.0.2',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Developer/Applications/Dashcode.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'hprastertojpeg' => {
                'Version' => '1.0.1',
                'Last Modified' => '30/03/09 12:51',
                'Location' => '/Library/Printers/hp/filter/hprastertojpeg.driver',
                'Get Info String' => 'HP Photosmart Compact Photo Printer driver 1.0.1, Copyright (c) 2007-2009 Hewlett-Packard Development Company, L.P.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Aide-mémoire' => {
                'Version' => '7.0',
                'Last Modified' => '19/05/09 07:28',
                'Location' => '/Applications/Stickies.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'VoiceOver Quickstart' => {
                'Version' => '3.5.0',
                'Last Modified' => '04/09/11 22:43',
                'Location' => '/System/Library/PrivateFrameworks/ScreenReader.framework/Versions/A/Resources/VoiceOver Quickstart.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'Utilitaire d’archive' => {
                'Version' => '10.6',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/CoreServices/Archive Utility.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'OpenGL Profiler' => {
                'Version' => '4.2',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Developer/Applications/Graphics Tools/OpenGL Profiler.app',
                'Get Info String' => '4.2, Copyright 2003-2009 Apple, Inc.',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Universal'
            },
            'Utilitaire de disque' => {
                'Version' => '11.5.2',
                'Last Modified' => '04/09/11 22:43',
                'Location' => '/Applications/Utilities/Disk Utility.app',
                'Get Info String' => 'Version 11.5.2, Copyright © 1999-2010 Apple Inc. All rights reserved.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Image Events' => {
                'Version' => '1.1.4',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/CoreServices/Image Events.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'PackageMaker' => {
                'Version' => '3.0.4',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Developer/Applications/Utilities/PackageMaker.app',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Intel'
            },
            'Assistant migration' => {
                'Version' => '3.0.4',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Applications/Utilities/Migration Assistant.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Samsung Scanner' => {
                'Version' => '2.00.29',
                'Last Modified' => '01/07/09 07:26',
                'Location' => '/Library/Image Capture/Devices/Samsung Scanner.app',
                'Get Info String' => 'Copyright (C) 2004-2009 Samsung Electronics Co., Ltd.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Assistant réglages de réseau' => {
                'Version' => '1.6',
                'Last Modified' => '19/05/09 11:15',
                'Location' => '/System/Library/CoreServices/Network Setup Assistant.app',
                'Get Info String' => '1.6',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Epson Printer Utility Lite' => {
                'Version' => '8.02',
                'Last Modified' => '09/07/09 06:55',
                'Location' => '/Library/Printers/EPSON/InkjetPrinter2/Utility/UTL/Epson Printer Utility Lite.app',
                'Get Info String' => 'Epson Printer Utility Lite version 8.02',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'MacVim' => {
                'Version' => '7.3',
                'Last Modified' => '15/08/10 22:04',
                'Location' => '/Applications/MacVim.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'TrueCrypt' => {
                'Version' => '7.1',
                'Last Modified' => '28/09/11 17:05',
                'Location' => '/Applications/TrueCrypt.app',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Universal'
            },
            'Extract' => {
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Library/Scripts/ColorSync/Extract.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'Partage d’écran' => {
                'Version' => '1.1.1',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/CoreServices/Screen Sharing.app',
                'Get Info String' => '1.1.1, Copyright © 2007-2009 Apple Inc., All Rights Reserved.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'Utilitaire de base de données' => {
                'Version' => '11.2.0',
                'Last Modified' => '12/12/05 13:00',
                'Location' => '/Applications/Office 2004 for Mac Test Drive/Office/Utilitaire de base de données',
                'Get Info String' => '11.2.0 (050929), © 2004 Microsoft Corporation.  All rights reserved.',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'PowerPC'
            },
            'Language Chooser' => {
                'Version' => '20',
                'Last Modified' => '17/02/12 12:35',
                'Location' => '/System/Library/CoreServices/Language Chooser.app',
                'Get Info String' => 'System Language Initializer',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'iCal' => {
                'Version' => '4.0.4',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Applications/iCal.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'iTunes' => {
                'Version' => '10.5.3',
                'Last Modified' => '17/02/12 12:35',
                'Location' => '/Applications/iTunes.app',
                'Get Info String' => 'iTunes 10.5.3, © 2000-2012 Apple Inc. All rights reserved.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'Finder' => {
                'Version' => '10.6.8',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/CoreServices/Finder.app',
                'Get Info String' => 'Mac OS X Finder 10.6.8',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'AppleFileServer' => {
                'Last Modified' => '17/02/12 12:35',
                'Location' => '/System/Library/CoreServices/AppleFileServer.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Dashboard' => {
                'Version' => '1.7',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Applications/Dashboard.app',
                'Get Info String' => '1.7, Copyright 2006-2008 Apple Inc.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'Agent de la borne d’accès AirPort' => {
                'Version' => '1.5.5',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/CoreServices/AirPort Base Station Agent.app',
                'Get Info String' => '1.5.5 (155.2), Copyright © 2006-2009 Apple Inc. All Rights Reserved.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'Speech Startup' => {
                'Version' => '3.8.1',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/Frameworks/Carbon.framework/Versions/A/Frameworks/SpeechRecognition.framework/Versions/A/Resources/Speech Startup.app',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Intel'
            },
            'ParentalControls' => {
                'Version' => '2.0',
                'Last Modified' => '04/09/11 22:43',
                'Location' => '/System/Library/PrivateFrameworks/FamilyControls.framework/Versions/A/Resources/ParentalControls.app',
                'Get Info String' => '2.0, Copyright Apple Inc. 2007-2009',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'Icon Composer' => {
                'Version' => '2.1.1',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Developer/Applications/Utilities/Icon Composer.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'ChineseHandwriting' => {
                'Version' => '1.0.1',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/Input Methods/ChineseHandwriting.app',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Intel'
            },
            'Assistant Boot Camp' => {
                'Version' => '3.0.4',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Applications/Utilities/Boot Camp Assistant.app',
                'Get Info String' => 'Boot Camp Assistant 3.0.4, Copyright © 2010 Apple Inc. All rights reserved',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Guide de l’utilisateur de Pages' => {
                'Version' => '1.0.2',
                'Last Modified' => '17/02/09 17:24',
                'Location' => '/Library/Documentation/Applications/iWork \'06/Pages User Guide.app',
                'Get Info String' => 'Pages User Guide',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Universal'
            },
            'Big Bang Tic-Tac-Toe' => {
                'Version' => '2.51',
                'Last Modified' => '05/04/07 16:10',
                'Location' => '/Applications/Big Bang Board Games/Big Bang Tic-Tac-Toe.app',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Universal'
            },
            'ScreenSaverEngine' => {
                'Version' => '3.0.3',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/Frameworks/ScreenSaver.framework/Versions/A/Resources/ScreenSaverEngine.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'Aquamacs Emacs' => {
                'Version' => '22',
                'Last Modified' => '30/09/09 03:34',
                'Location' => '/Applications/Aquamacs Emacs.app',
                'Get Info String' => 'Aquamacs Emacs 22',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Universal'
            },
            'SCIM' => {
                'Version' => '4.3',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/Input Methods/SCIM.app',
                'Get Info String' => '4.0, Copyright © 1997-2009 Apple Inc., All Rights Reserved',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'webdav_cert_ui' => {
                'Version' => '1.8.3',
                'Last Modified' => '17/02/12 12:35',
                'Location' => '/System/Library/Filesystems/webdav.fs/Support/webdav_cert_ui.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'iMovie HD' => {
                'Version' => '6.0.3',
                'Last Modified' => '17/02/09 17:24',
                'Location' => '/Applications/iMovie HD.app',
                'Get Info String' => '6.0.3, © Apple Computer, Inc., 1999–2006',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Universal'
            },
            'Xcode' => {
                'Version' => '3.2.6',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Developer/Applications/Xcode.app',
                'Get Info String' => 'Xcode version 3.2.6',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'i-Installer' => {
                'Version' => '2.94',
                'Last Modified' => '06/10/09 09:58',
                'Location' => '/Applications/Utilities/i-Installer.app',
                'Get Info String' => 'i-Installer v2, Copyright Gerben Wierda 2002 -- 2006',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Universal'
            },
            'BibDesk' => {
                'Version' => '1.3.20',
                'Last Modified' => '06/10/09 09:58',
                'Location' => '/Applications/TeX/BibDesk.app',
                'Get Info String' => 'BibDesk 1.3.20 (v1412), Copyright 2001-09 Michael O. McCracken.',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Universal'
            },
            'ManagedClient' => {
                'Version' => '2.5',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/CoreServices/ManagedClient.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'Informations Système' => {
                'Version' => '10.6.0',
                'Last Modified' => '04/09/11 22:43',
                'Location' => '/Applications/Utilities/System Profiler.app',
                'Get Info String' => '10.6.0, Copyright 1997-2009 Apple, Inc.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'Type7Camera' => {
                'Version' => '6.0',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/Image Capture/Devices/Type7Camera.app',
                'Get Info String' => '6.0, © Copyright 2002-2009 Apple Inc., all rights reserved.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'CPUPalette' => {
                'Version' => '4.7.3',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Library/Application Support/HWPrefs/CPUPalette.app',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Intel'
            },
            'Kotoeri' => {
                'Version' => '4.2.1',
                'Last Modified' => '04/09/11 22:43',
                'Location' => '/System/Library/Input Methods/Kotoeri.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'FileSyncAgent' => {
                'Version' => '5.0.3',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/CoreServices/FileSyncAgent.app',
                'Get Info String' => '© Copyright 2009 Apple Inc., all rights reserved.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Image Capture Web Server' => {
                'Version' => '6.0',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/Image Capture/Support/Image Capture Web Server.app',
                'Get Info String' => '6.0, © Copyright 2003-2009 Apple Inc., all rights reserved.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'Excalibur' => {
                'Version' => '4.0.7',
                'Last Modified' => '06/10/09 09:58',
                'Location' => '/Applications/TeX/Excalibur-4.0.7/Excalibur.app',
                'Get Info String' => '4.0.7',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Universal'
            },
            'About Xcode' => {
                'Version' => '169',
                'Last Modified' => '23/10/10 17:35',
                'Location' => '/Developer/About Xcode.app',
                'Get Info String' => 'About Xcode',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Universal'
            },
            'Safari' => {
                'Version' => '5.1.2',
                'Last Modified' => '17/02/12 12:35',
                'Location' => '/Applications/Safari.app',
                'Get Info String' => '5.1.2, Copyright © 2003-2011 Apple Inc.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Carnet d’adresses' => {
                'Version' => '5.0.3',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Applications/Address Book.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Brother Contrôleur d\'état' => {
                'Version' => '3.00',
                'Last Modified' => '19/05/09 03:15',
                'Location' => '/Library/Printers/Brother/Utilities/BrStatusMonitor.app',
                'Get Info String' => 'ver3.00, ©2005-2009 Brother Industries, Ltd. All Rights Reserved.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'iWeb' => {
                'Version' => '1.1.2',
                'Last Modified' => '17/02/09 17:24',
                'Location' => '/Applications/iWeb.app',
                'Get Info String' => '1.1.2, Copyright 2006 Apple Computer, Inc.',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Universal'
            },
            'Interface Builder' => {
                'Version' => '3.2.6',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Developer/Applications/Interface Builder.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Assistant de certification' => {
                'Version' => '3.0',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/CoreServices/Certificate Assistant.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'MakePDF' => {
                'Version' => '6.0',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/Image Capture/Automatic Tasks/MakePDF.app',
                'Get Info String' => '6.0, © Copyright 2003-2009 Apple Inc., all rights reserved.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'Terminal' => {
                'Version' => '2.1.2',
                'Last Modified' => '04/09/11 22:43',
                'Location' => '/Applications/Utilities/Terminal.app',
                'Get Info String' => '2.1.2, © 1995-2010 Apple Inc. All Rights Reserved.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'iPhoto' => {
                'Version' => '6.0.6',
                'Last Modified' => '17/02/09 18:05',
                'Location' => '/Applications/iPhoto.app',
                'Get Info String' => 'iPhoto 6.0.6, Copyright © 2002-2007 Apple Inc.',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Universal'
            },
            'Canon IJScanner2' => {
                'Version' => '1.0.0',
                'Last Modified' => '15/06/09 08:18',
                'Location' => '/Library/Image Capture/Devices/Canon IJScanner2.app',
                'Get Info String' => '1.0.0, Copyright CANON INC. 2009 All Rights Reserved',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Assistant réglages' => {
                'Version' => '10.6',
                'Last Modified' => '31/07/09 09:25',
                'Location' => '/System/Library/CoreServices/Setup Assistant.app',
                'Get Info String' => '10.6',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'Programme d’installation' => {
                'Version' => '4.0',
                'Last Modified' => '27/06/09 08:18',
                'Location' => '/System/Library/CoreServices/Installer.app',
                'Get Info String' => '3.0, Copyright © 2000-2006 Apple Computer Inc., All Rights Reserved',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'Service de résumé' => {
                'Version' => '2.0',
                'Last Modified' => '19/05/09 07:27',
                'Location' => '/System/Library/Services/SummaryService.app',
                'Get Info String' => 'Summary Service Version  2',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'commandtohp' => {
                'Version' => '1.9.2',
                'Last Modified' => '15/06/09 14:48',
                'Location' => '/Library/Printers/hp/cups/filters/commandtohp.filter',
                'Get Info String' => 'HP Command File Filter 1.9.2, Copyright (c) 2006-2010 Hewlett-Packard Development Company, L.P.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Bienvenue sur Tiger' => {
                'Version' => '1.0.2',
                'Last Modified' => '13/12/06 19:30',
                'Location' => '/Library/Documentation/User Guides and Information.localized/Welcome to Tiger.app',
                'Get Info String' => 'Welcome to Tiger',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'PowerPC'
            },
            'AddressBookSync' => {
                'Version' => '2.0.4',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/Frameworks/AddressBook.framework/Versions/A/Resources/AddressBookSync.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Inkjet3' => {
                'Version' => '2.0',
                'Last Modified' => '16/06/09 15:21',
                'Location' => '/Library/Printers/hp/cups/Inkjet3.driver',
                'Get Info String' => 'HP Inkjet 3 Driver 2.0, Copyright (c) 1994-2009 Hewlett-Packard Development Company, L.P.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Ticket Viewer' => {
                'Version' => '1.0',
                'Last Modified' => '19/05/09 07:28',
                'Location' => '/System/Library/CoreServices/Ticket Viewer.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Supprimer Office' => {
                'Version' => '11.2.0',
                'Last Modified' => '12/12/05 13:00',
                'Location' => '/Applications/Office 2004 for Mac Test Drive/Supprimer Office',
                'Get Info String' => '11.2.0 (050714), © 2004 Microsoft Corporation.  All rights reserved.',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'PowerPC'
            },
            'LaTeXiT' => {
                'Version' => '1.16.1',
                'Last Modified' => '06/10/09 09:58',
                'Location' => '/Applications/TeX/LaTeXiT.app',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Universal'
            },
            'WebKitPluginHost' => {
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Developer/SDKs/MacOSX10.6.sdk/System/Library/Frameworks/WebKit.framework/WebKitPluginHost.app',
                '64-Bit (Intel)' => 'No'
            },
            'Utilitaire d’annuaire' => {
                'Version' => '2.2',
                'Last Modified' => '19/05/09 11:08',
                'Location' => '/System/Library/CoreServices/Directory Utility.app',
                'Get Info String' => '2.2, Copyright © 2001–2008 Apple Inc.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'pdftopdf' => {
                'Version' => '1.3',
                'Last Modified' => '16/04/09 17:20',
                'Location' => '/Library/Printers/hp/cups/filters/pdftopdf.filter',
                'Get Info String' => 'HP PDF Filter 1.3, Copyright (c) 2001-2009 Hewlett-Packard Development Company, L.P.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'AVRCPAgent' => {
                'Version' => '2.4.5',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/CoreServices/AVRCPAgent.app',
                'Get Info String' => '2.4.5, Copyright (c) 2011 Apple Inc. All rights reserved.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'syncuid' => {
                'Version' => '5.2',
                'Last Modified' => '04/09/11 22:43',
                'Location' => '/System/Library/PrivateFrameworks/SyncServicesUI.framework/Versions/A/Resources/syncuid.app',
                'Get Info String' => '4.0, Copyright Apple Computer Inc. 2004',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'Brother Scanner' => {
                'Version' => '2.0.2',
                'Last Modified' => '29/06/09 02:52',
                'Location' => '/Library/Image Capture/Devices/Brother Scanner.app',
                'Get Info String' => '2.0.2, Copyright 2009 Brother Industries, LTD.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Transfert de podcast' => {
                'Version' => '2.0.2',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Applications/Utilities/Podcast Capture.app',
                'Get Info String' => '2.0.1, Copyright © 2007-2009 Apple Inc.',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Intel'
            },
            'ODSAgent' => {
                'Version' => '1.4.1',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/CoreServices/ODSAgent.app',
                'Get Info String' => '1.4.1 (141.6), Copyright © 2007-2009 Apple Inc. All Rights Reserved.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'iChat' => {
                'Version' => '5.0.3',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Applications/iChat.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Project Gallery Launcher' => {
                'Version' => '11.2.0',
                'Last Modified' => '12/12/05 13:00',
                'Location' => '/Applications/Office 2004 for Mac Test Drive/Office/Project Gallery Launcher',
                'Get Info String' => '11.2.0 (050714), © 2004 Microsoft Corporation.  All rights reserved.',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'PowerPC'
            },
            'Premiers contacts avec GarageBand' => {
                'Version' => '1.0.2',
                'Last Modified' => '15/10/09 13:14',
                'Location' => '/Library/Documentation/Applications/GarageBand/GarageBand Getting Started.app',
                'Get Info String' => 'GarageBand Getting Started',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Universal'
            },
            'Rename' => {
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Library/Scripts/ColorSync/Rename.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'Comic Life' => {
                'Version' => '1.2.4 (v554)',
                'Last Modified' => '15/03/06 02:55',
                'Location' => '/Applications/Comic Life.app',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Universal'
            },
            'PluginProcess' => {
                'Version' => '6534.52',
                'Last Modified' => '17/02/12 12:35',
                'Location' => '/System/Library/PrivateFrameworks/WebKit2.framework/PluginProcess.app',
                'Get Info String' => '6534.52.7, Copyright 2003-2011 Apple Inc.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Shark' => {
                'Version' => '4.7.3',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Developer/Applications/Performance Tools/Shark.app',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Intel'
            },
            'QuickTime Player' => {
                'Version' => '10.0',
                'Last Modified' => '17/02/12 12:35',
                'Location' => '/Applications/QuickTime Player.app',
                'Get Info String' => '10.0, Copyright © 2010-2011 Apple Inc. All Rights Reserved.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'ARDAgent' => {
                'Version' => '3.5.2',
                'Last Modified' => '17/02/12 12:35',
                'Location' => '/System/Library/CoreServices/RemoteManagement/ARDAgent.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Quartz Composer' => {
                'Version' => '4.0',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Developer/Applications/Quartz Composer.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'SyncServer' => {
                'Version' => '5.2',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/Frameworks/SyncServices.framework/Versions/A/Resources/SyncServer.app',
                'Get Info String' => '© 2002-2003 Apple',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'SecurityProxy' => {
                'Version' => '1.0',
                'Last Modified' => '21/05/09 04:37',
                'Location' => '/System/Library/CoreServices/SecurityProxy.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'Premiers contacts avec iDVD' => {
                'Version' => '1.0.2',
                'Last Modified' => '17/02/09 17:24',
                'Location' => '/Library/Documentation/Applications/iDVD/iDVD Getting Started.app',
                'Get Info String' => 'iDVD Getting Started',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Universal'
            },
            'Help Indexer' => {
                'Version' => '4.0',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Developer/Applications/Utilities/Help Indexer.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Time Machine' => {
                'Version' => '1.1',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Applications/Time Machine.app',
                'Get Info String' => '1.1, Copyright 2007-2008 Apple Inc.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'Type3Camera' => {
                'Version' => '6.0',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/Image Capture/Devices/Type3Camera.app',
                'Get Info String' => '6.0, © Copyright 2001-2009 Apple Inc., all rights reserved.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'loginwindow' => {
                'Version' => '6.1.1',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/CoreServices/loginwindow.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'Visite guidée d’iWork' => {
                'Version' => '1.0.2',
                'Last Modified' => '17/02/09 17:24',
                'Location' => '/Library/Application Support/iWork \'06/iWork Tour.app',
                'Get Info String' => 'iWork Tour',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'Universal'
            },
            'Organization Chart' => {
                'Version' => '11.0.0',
                'Last Modified' => '12/12/05 13:00',
                'Location' => '/Applications/Office 2004 for Mac Test Drive/Office/Organization Chart',
                'Get Info String' => '11.0.0 (040322), © 2004 Microsoft Corporation.  All rights reserved.',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'PowerPC'
            },
            'OpenGL Shader Builder' => {
                'Version' => '2.1',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/Developer/Applications/Graphics Tools/OpenGL Shader Builder.app',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Photosmart' => {
                'Version' => '4.0',
                'Last Modified' => '16/06/09 12:03',
                'Location' => '/Library/Printers/hp/cups/Photosmart.driver',
                'Get Info String' => 'HP Photosmart Driver 4.0, Copyright (c) 1994-2009 Hewlett-Packard Development Company, L.P.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            },
            'Microsoft Database Daemon' => {
                'Version' => '11.2.0',
                'Last Modified' => '12/12/05 13:00',
                'Location' => '/Applications/Office 2004 for Mac Test Drive/Office/Microsoft Database Daemon',
                'Get Info String' => '11.2.0 (050825), © 2004 Microsoft Corporation.  All rights reserved.',
                '64-Bit (Intel)' => 'No',
                'Kind' => 'PowerPC'
            },
            'PTPCamera' => {
                'Version' => '6.1',
                'Last Modified' => '04/09/11 22:42',
                'Location' => '/System/Library/Image Capture/Devices/PTPCamera.app',
                'Get Info String' => '6.1, © Copyright 2004-2011 Apple Inc., all rights reserved.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Universal'
            },
            'Officejet' => {
                'Version' => '3.0',
                'Last Modified' => '16/06/09 14:48',
                'Location' => '/Library/Printers/hp/cups/Officejet.driver',
                'Get Info String' => 'HP Officejet Driver 3.0, Copyright (c) 1994-2009 Hewlett-Packard Development Company, L.P.',
                '64-Bit (Intel)' => 'Yes',
                'Kind' => 'Intel'
            }
        }
    }
);

my @ioreg_tests = (
    {
        file    => 'IOUSBDevice1',
        class   => 'IOUSBDevice',
        results => [
            {
                'IOGeneralInterest' => 'IOCommand is not serializable',
                'USB Address' => '2',
                'Requested Power' => '20',
                'idProduct' => '539',
                'bMaxPacketSize0' => '8',
                'USB Vendor Name' => 'Apple Computer',
                'sessionID' => '922879256',
                'bNumConfigurations' => '1',
                'bDeviceProtocol' => '0',
                'Bus Power Available' => '250',
                'Device Speed' => '1',
                'USB Product Name' => 'Apple Internal Keyboard / Trackpad',
                'iProduct' => '2',
                'IOUserClientClass' => 'IOUSBDeviceUserClientV2',
                'non-removable' => 'yes',
                'bDeviceClass' => '0',
                'bDeviceSubClass' => '0',
                'PortNum' => '2',
                'bcdDevice' => '24',
                'locationID' => '488636416',
                'iManufacturer' => '1',
                'iSerialNumber' => '0',
                'idVendor' => '1452'
            },
            {
                'IOGeneralInterest' => 'IOCommand is not serializable',
                'USB Address' => '2',
                'Requested Power' => '50',
                'idProduct' => '33344',
                'bMaxPacketSize0' => '8',
                'USB Vendor Name' => 'Apple Computer, Inc.',
                'sessionID' => '944991920',
                'bNumConfigurations' => '1',
                'bDeviceProtocol' => '0',
                'Bus Power Available' => '250',
                'Device Speed' => '1',
                'USB Product Name' => 'IR Receiver',
                'iProduct' => '2',
                'IOUserClientClass' => 'IOUSBDeviceUserClientV2',
                'non-removable' => 'yes',
                'bDeviceClass' => '0',
                'bDeviceSubClass' => '0',
                'PortNum' => '2',
                'bcdDevice' => '272',
                'locationID' => '1562378240',
                'iManufacturer' => '1',
                'iSerialNumber' => '0',
                'idVendor' => '1452'
            },
            {
                'IOGeneralInterest' => 'IOCommand is not serializable',
                'USB Address' => '2',
                'Requested Power' => '0',
                'idProduct' => '33285',
                'bMaxPacketSize0' => '64',
                'USB Vendor Name' => 'Apple Inc.',
                'sessionID' => '3290864968',
                'bNumConfigurations' => '1',
                'bDeviceProtocol' => '1',
                'Bus Power Available' => '250',
                'Device Speed' => '1',
                'iProduct' => '0',
                'IOUserClientClass' => 'IOUSBDeviceUserClientV2',
                'USB Product Name' => 'Bluetooth USB Host Controller',
                'PortNum' => '1',
                'bDeviceClass' => '224',
                'bDeviceSubClass' => '1',
                'non-removable' => 'yes',
                'bcdDevice' => '6501',
                'locationID' => '2098200576',
                'iManufacturer' => '0',
                'iSerialNumber' => '0',
                'idVendor' => '1452'
            },
            {
                'IOGeneralInterest' => 'IOCommand is not serializable',
                'USB Address' => '2',
                'Requested Power' => '50',
                'idProduct' => '34049',
                'bMaxPacketSize0' => '64',
                'USB Vendor Name' => 'Micron',
                'sessionID' => '2717373407',
                'bNumConfigurations' => '1',
                'bDeviceProtocol' => '255',
                'Bus Power Available' => '250',
                'Device Speed' => '2',
                'USB Product Name' => 'Built-in iSight',
                'iProduct' => '2',
                'IOUserClientClass' => 'IOUSBDeviceUserClientV2',
                'non-removable' => 'yes',
                'bDeviceClass' => '255',
                'bDeviceSubClass' => '255',
                'PortNum' => '4',
                'bcdDevice' => '393',
                'locationID' => '18446744073663414272',
                'iManufacturer' => '1',
                'iSerialNumber' => '0',
                'idVendor' => '1452'
            },
            {
                'IOGeneralInterest' => 'IOCommand is not serializable',
                'USB Address' => '3',
                'Requested Power' => '50',
                'idProduct' => '24613',
                'bMaxPacketSize0' => '64',
                'USB Vendor Name' => 'CBM',
                'sessionID' => '3995793432240',
                'bNumConfigurations' => '1',
                'bDeviceProtocol' => '0',
                'Bus Power Available' => '250',
                'uid' => 'USB:197660250078C5C90000',
                'Device Speed' => '2',
                'USB Product Name' => 'Flash Disk',
                'iProduct' => '2',
                'IOUserClientClass' => 'IOUSBDeviceUserClientV2',
                'bDeviceClass' => '0',
                'bDeviceSubClass' => '0',
                'PortNum' => '3',
                'bcdDevice' => '256',
                'locationID' => '18446744073662365696',
                'iManufacturer' => '1',
                'iSerialNumber' => '3',
                'idVendor' => '6518',
                'USB Serial Number' => '16270078C5C90000'
            }
        ],
    },
    {
        file    => 'IOUSBDevice2',
        class   => 'IOUSBDevice',
        results => [
            {
                'IOGeneralInterest' => 'IOCommand is not serializable',
                'USB Address' => '3',
                'Requested Power' => '50',
                'idProduct' => '54',
                'bMaxPacketSize0' => '8',
                'USB Vendor Name' => 'Genius',
                'sessionID' => '1035836159',
                'bNumConfigurations' => '1',
                'bDeviceProtocol' => '0',
                'Bus Power Available' => '250',
                'Device Speed' => '0',
                'USB Product Name' => 'NetScroll + Mini Traveler',
                'iProduct' => '1',
                'IOUserClientClass' => 'IOUSBDeviceUserClientV2',
                'bDeviceClass' => '0',
                'bDeviceSubClass' => '0',
                'PortNum' => '2',
                'bcdDevice' => '272',
                'locationID' => '438304768',
                'iManufacturer' => '2',
                'iSerialNumber' => '0',
                'idVendor' => '1112'
            },
            {
                'IOGeneralInterest' => 'IOCommand is not serializable',
                'USB Address' => '2',
                'Requested Power' => '0',
                'idProduct' => '33286',
                'bMaxPacketSize0' => '64',
                'USB Vendor Name' => 'Apple Inc.',
                'sessionID' => '3009829809',
                'bNumConfigurations' => '1',
                'bDeviceProtocol' => '1',
                'Bus Power Available' => '250',
                'Device Speed' => '1',
                'iProduct' => '0',
                'IOUserClientClass' => 'IOUSBDeviceUserClientV2',
                'USB Product Name' => 'Bluetooth USB Host Controller',
                'PortNum' => '1',
                'bDeviceClass' => '224',
                'bDeviceSubClass' => '1',
                'non-removable' => 'yes',
                'bcdDevice' => '6501',
                'locationID' => '437256192',
                'iManufacturer' => '0',
                'iSerialNumber' => '0',
                'idVendor' => '1452'
            },
            {
                'IOGeneralInterest' => 'IOCommand is not serializable',
                'USB Address' => '3',
                'Requested Power' => '10',
                'idProduct' => '545',
                'bMaxPacketSize0' => '8',
                'USB Vendor Name' => 'Apple, Inc',
                'sessionID' => '1018522533',
                'bNumConfigurations' => '1',
                'bDeviceProtocol' => '0',
                'Bus Power Available' => '50',
                'Device Speed' => '0',
                'USB Product Name' => 'Apple Keyboard',
                'iProduct' => '2',
                'IOUserClientClass' => 'IOUSBDeviceUserClientV2',
                'non-removable' => 'yes',
                'bDeviceClass' => '0',
                'bDeviceSubClass' => '0',
                'PortNum' => '2',
                'bcdDevice' => '105',
                'locationID' => '18446744073613213696',
                'iManufacturer' => '1',
                'iSerialNumber' => '0',
                'idVendor' => '1452'
            },
            {
                'IOGeneralInterest' => 'IOCommand is not serializable',
                'USB Address' => '2',
                'Requested Power' => '50',
                'idProduct' => '33346',
                'bMaxPacketSize0' => '8',
                'USB Vendor Name' => 'Apple Computer, Inc.',
                'sessionID' => '1116620200',
                'bNumConfigurations' => '1',
                'bDeviceProtocol' => '0',
                'Bus Power Available' => '250',
                'Device Speed' => '0',
                'USB Product Name' => 'IR Receiver',
                'iProduct' => '2',
                'IOUserClientClass' => 'IOUSBDeviceUserClientV2',
                'non-removable' => 'yes',
                'bDeviceClass' => '0',
                'bDeviceSubClass' => '0',
                'PortNum' => '1',
                'bcdDevice' => '22',
                'locationID' => '1561329664',
                'iManufacturer' => '1',
                'iSerialNumber' => '0',
                'idVendor' => '1452'
            },
            {
                'IOGeneralInterest' => 'IOCommand is not serializable',
                'USB Address' => '2',
                'Requested Power' => '1',
                'idProduct' => '4138',
                'bMaxPacketSize0' => '64',
                'USB Vendor Name' => 'LaCie',
                'sessionID' => '637721320',
                'bNumConfigurations' => '1',
                'bDeviceProtocol' => '0',
                'Bus Power Available' => '250',
                'uid' => 'USB:059F102A6E7A5FFFFFFF',
                'Device Speed' => '2',
                'USB Product Name' => 'LaCie Device',
                'iProduct' => '11',
                'IOUserClientClass' => 'IOUSBDeviceUserClientV2',
                'bDeviceClass' => '0',
                'bDeviceSubClass' => '0',
                'PortNum' => '1',
                'bcdDevice' => '256',
                'locationID' => '18446744073660268544',
                'iManufacturer' => '10',
                'iSerialNumber' => '5',
                'idVendor' => '1439',
                'USB Serial Number' => '6E7A5FFFFFFF'
            },
            {
                'IOGeneralInterest' => 'IOCommand is not serializable',
                'USB Address' => '3',
                'Requested Power' => '250',
                'idProduct' => '34050',
                'bMaxPacketSize0' => '64',
                'USB Vendor Name' => 'Apple Inc.',
                'sessionID' => '791376929',
                'bNumConfigurations' => '1',
                'bDeviceProtocol' => '1',
                'Bus Power Available' => '250',
                'Device Speed' => '2',
                'USB Product Name' => 'Built-in iSight',
                'iProduct' => '2',
                'IOUserClientClass' => 'IOUSBDeviceUserClientV2',
                'non-removable' => 'yes',
                'bDeviceClass' => '239',
                'bDeviceSubClass' => '2',
                'PortNum' => '4',
                'bcdDevice' => '341',
                'locationID' => '18446744073663414272',
                'iManufacturer' => '1',
                'iSerialNumber' => '3',
                'idVendor' => '1452',
                'USB Serial Number' => '6067E773DA9722F4 (03.01)'
            }
        ]
    },
    {
        file   => 'IOPlatformExpertDevice',
        class  => 'IOPlatformExpertDevice',
        results => [
            {
                'IOPlatformUUID' => '00000000-0000-1000-8000-001B633026B1',
                'IOBusyInterest' => 'IOCommand is not serializable',
                'IOPlatformSerialNumber' => 'W87305UMYA8',
                'IOPolledInterface' => 'SMCPolledInterface is not serializable',
                'compatible' => 'MacBook2,1',
                'model' => 'MacBook2,1',
                'serial-number' => '59413800000000000000000000573837333035554',
                'version' => '1.0',
                'name' => '/',
                'board-id' => 'Mac-F4208CAA',
                'clock-frequency' => '00',
                'system-type' => '02',
                'manufacturer' => 'Apple Inc.',
                'product-name' => 'MacBook2,1',
                'IOPlatformArgs' => '0030'
            }
        ],
    }
);

plan tests => 
    scalar (keys %system_profiler_tests) + 
    scalar @ioreg_tests;

foreach my $test (keys %system_profiler_tests) {
    my $file = "resources/macos/system_profiler/$test";
    my $infos = getSystemProfilerInfos(file => $file);
    is_deeply($infos, $system_profiler_tests{$test}, "$test system profiler parsing");
}

foreach my $test (@ioreg_tests) {
    my $file = "resources/macos/ioreg/$test->{file}";
    my @devices = getIODevices(file => $file, class => $test->{class});
    is_deeply(\@devices, $test->{results}, "$test->{file} ioreg parsing");
}
