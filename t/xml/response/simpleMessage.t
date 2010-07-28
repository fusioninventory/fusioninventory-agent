#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use Test::Exception;
use FusionInventory::Agent::XML::Response::SimpleMessage;

plan tests => 4;

my ($message, $content, $parsed_content);
$message = FusionInventory::Agent::XML::Response::SimpleMessage->new();
ok(!defined $message->getParsedContent(), 'message without content');

$content = <<EOF;
<?xml version="1.0" encoding="UTF-8"?>
<REPLY>
  <OPTION>
    <NAME>REGISTRY</NAME>
    <PARAM NAME="blablabla" REGKEY="SOFTWARE/Mozilla" REGTREE="0">*</PARAM>
  </OPTION>
  <OPTION>
    <NAME>DOWNLOAD</NAME>
    <PARAM FRAG_LATENCY="10" PERIOD_LATENCY="1" TIMEOUT="30" ON="1" TYPE="CONF" CYCLE_LATENCY="6" PERIOD_LENGTH="10" />
  </OPTION>
  <RESPONSE>SEND</RESPONSE>
  <PROLOG_FREQ>1</PROLOG_FREQ>
</REPLY>
EOF
$parsed_content = {
    OPTION => [
        {
            NAME => 'REGISTRY',
            PARAM => [
                {
                    NAME    => 'blablabla',
                    content => '*',
                    REGTREE => '0',
                    REGKEY  => 'SOFTWARE/Mozilla'
                }
             ]
        },
        {
            NAME => 'DOWNLOAD',
            PARAM => [
                {
                     FRAG_LATENCY   => '10',
                     TIMEOUT        => '30',
                     PERIOD_LATENCY => '1',
                     ON             => '1',
                     TYPE           => 'CONF',
                     PERIOD_LENGTH  => '10',
                     CYCLE_LATENCY  => '6'
                }
            ]
        }
    ],
    RESPONSE => 'SEND',
    PROLOG_FREQ => '1'
};
$message = FusionInventory::Agent::XML::Response::SimpleMessage->new({
    content => $content
});
is_deeply(
    $message->getParsedContent(), $parsed_content, 'message with content'
);

$content = <<EOF;
<?xml version="1.0" encoding="UTF-8"?>
<REPLY>
<PROCESSNUMBER>1280265498/024</PROCESSNUMBER>
<OPTION>
<NAME>SNMPQUERY</NAME>
<PARAM CORE_QUERY="1" THREADS_QUERY="4" PID="1280265498/024"/>
<DEVICE TYPE="PRINTER" ID="72" IP="192.168.0.151" AUTHSNMP_ID="1" MODELSNMP_ID="196"/>
<AUTHENTICATION ID="1" COMMUNITY="public" VERSION="1" USERNAME="" AUTHPROTOCOL="" AUTHPASSPHRASE="" PRIVPROTOCOL="" PRIVPASSPHRASE=""/>
<AUTHENTICATION ID="2" COMMUNITY="public" VERSION="2c" USERNAME="" AUTHPROTOCOL="" AUTHPASSPHRASE="" PRIVPROTOCOL="" PRIVPASSPHRASE=""/>
<MODEL ID="196" NAME="4675719">
       <GET OBJECT="comments" OID=".1.3.6.1.2.1.1.1.0" VLAN="0" LINK="comments"/>
       <GET OBJECT="name" OID=".1.3.6.1.2.1.1.5.0" VLAN="0" LINK="name"/>
       <GET OBJECT="location" OID=".1.3.6.1.2.1.1.6.0" VLAN="0" LINK="location"/>
       <WALK OBJECT="ifIndex" OID=".1.3.6.1.2.1.2.2.1.1" VLAN="0" LINK="ifIndex"/>
       <WALK OBJECT="ifName" OID=".1.3.6.1.2.1.2.2.1.2" VLAN="0" LINK="ifName"/>
       <WALK OBJECT="ifType" OID=".1.3.6.1.2.1.2.2.1.3" VLAN="0" LINK="ifType"/>
       <WALK OBJECT="ifPhysAddress" OID=".1.3.6.1.2.1.2.2.1.6" VLAN="0" LINK="ifPhysAddress"/>
       <WALK OBJECT="ifaddr" OID=".1.3.6.1.2.1.4.20.1.2" VLAN="0" LINK="ifaddr"/>
       <GET OBJECT="informations" OID=".1.3.6.1.4.1.11.2.3.9.1.1.7.0" VLAN="0" LINK="informations"/>
    </MODEL>
 </OPTION>
</REPLY>
EOF
$parsed_content = {
    OPTION => [
        {
            AUTHENTICATION => [
                {
                    ID             => '1',
                    AUTHPROTOCOL   => '',
                    PRIVPROTOCOL   => '',
                    USERNAME       => '',
                    AUTHPASSPHRASE => '',
                    VERSION        => '1',
                    COMMUNITY      => 'public',
                    PRIVPASSPHRASE => ''
                },
                {
                    ID             => '2',
                    AUTHPROTOCOL   => '',
                    PRIVPROTOCOL   => '',
                    USERNAME       => '',
                    AUTHPASSPHRASE => '',
                    VERSION        => '2c',
                    COMMUNITY      => 'public',
                    PRIVPASSPHRASE => ''
                }
            ],
            NAME => 'SNMPQUERY',
            MODEL => {
                ID   => '196',
                NAME => '4675719',
                WALK => [
                    {
                        VLAN   => '0',
                        LINK   => 'ifIndex',
                        OBJECT => 'ifIndex',
                        OID    => '.1.3.6.1.2.1.2.2.1.1'
                    },
                    {
                        VLAN   => '0',
                        LINK   => 'ifName',
                        OBJECT => 'ifName',
                        OID    => '.1.3.6.1.2.1.2.2.1.2'
                    },
                    {
                        VLAN   => '0',
                        LINK   => 'ifType',
                        OBJECT => 'ifType',
                        OID    => '.1.3.6.1.2.1.2.2.1.3'
                    },
                    {
                        VLAN   => '0',
                        LINK   => 'ifPhysAddress',
                        OBJECT => 'ifPhysAddress',
                        OID    => '.1.3.6.1.2.1.2.2.1.6'
                    },
                    {
                        VLAN   => '0',
                        LINK   => 'ifaddr',
                        OBJECT => 'ifaddr',
                        OID    => '.1.3.6.1.2.1.4.20.1.2'
                    }
                ],
                GET => [
                    {
                        VLAN   => '0',
                        LINK   => 'comments',
                        OBJECT => 'comments',
                        OID    => '.1.3.6.1.2.1.1.1.0'
                    },
                    {
                        VLAN   => '0',
                        LINK   => 'name',
                        OBJECT => 'name',
                        OID    => '.1.3.6.1.2.1.1.5.0'
                    },
                    {
                        VLAN   => '0',
                        LINK   => 'location',
                        OBJECT => 'location',
                        OID    => '.1.3.6.1.2.1.1.6.0'
                    },
                    {
                        VLAN   => '0',
                        LINK   => 'informations',
                        OBJECT => 'informations',
                        OID    => '.1.3.6.1.4.1.11.2.3.9.1.1.7.0'
                    }
                ]
            },
            DEVICE => {
                ID           => '72',
                IP           => '192.168.0.151',
                MODELSNMP_ID => '196',
                TYPE         => 'PRINTER',
                AUTHSNMP_ID  => '1'
            },
            PARAM => [
                {
                    PID           => '1280265498/024',
                    THREADS_QUERY => '4',
                    CORE_QUERY    => '1'
                }
            ]
        }
    ],
    PROCESSNUMBER => '1280265498/024'
};
$message = FusionInventory::Agent::XML::Response::SimpleMessage->new({
    content => $content
});
is_deeply(
    $message->getParsedContent(), $parsed_content, 'message with content'
);

$content = <<EOF;
<REPLY>
 <PROCESSNUMBER>1280265592/024</PROCESSNUMBER>
 <OPTION>
    <NAME>NETDISCOVERY</NAME>
    <PARAM CORE_DISCOVERY="1" THREADS_DISCOVERY="10" PID="1280265592/024"/>
    <RANGEIP ID="1" IPSTART="192.168.0.1" IPEND="192.168.0.254" ENTITY="15"/>
    <AUTHENTICATION ID="1" COMMUNITY="public" VERSION="1" USERNAME="" AUTHPROTOCOL="" AUTHPASSPHRASE="" PRIVPROTOCOL="" PRIVPASSPHRASE=""/>
    <AUTHENTICATION ID="2" COMMUNITY="public" VERSION="2c" USERNAME="" AUTHPROTOCOL="" AUTHPASSPHRASE="" PRIVPROTOCOL="" PRIVPASSPHRASE=""/>
 </OPTION>
</REPLY>
EOF
$parsed_content = {
    OPTION => [
        {
            AUTHENTICATION => [
                {
                    ID             => '1',
                    AUTHPROTOCOL   => '',
                    PRIVPROTOCOL   => '',
                    USERNAME       => '',
                    AUTHPASSPHRASE => '',
                    VERSION        => '1',
                    COMMUNITY      => 'public',
                    PRIVPASSPHRASE => ''
                },
                {
                    ID             => '2',
                    AUTHPROTOCOL   => '',
                    PRIVPROTOCOL   => '',
                    USERNAME       => '',
                    AUTHPASSPHRASE => '',
                    VERSION        => '2c',
                    COMMUNITY      => 'public',
                    PRIVPASSPHRASE => ''
                }
            ],
            RANGEIP => {
                ID      => '1',
                ENTITY  => '15',
                IPSTART => '192.168.0.1',
                IPEND   => '192.168.0.254'
            },
            NAME => 'NETDISCOVERY',
            PARAM => [
                {
                CORE_DISCOVERY    => '1',
                PID               => '1280265592/024',
                THREADS_DISCOVERY => '10'
                }
            ]
        }
    ],
    PROCESSNUMBER => '1280265592/024'
};
$message = FusionInventory::Agent::XML::Response::SimpleMessage->new({
    content => $content
});
is_deeply(
    $message->getParsedContent(), $parsed_content, 'message with content'
);
