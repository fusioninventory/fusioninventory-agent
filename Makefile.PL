use inc::Module::Install;

name 'FusionInventory-Agent-Task-NetDiscovery';
include 'Module::AutoInstall';
abstract 'Network discovery support for FusionInventory Agent';
version_from 'lib/FusionInventory/Agent/Task/NetDiscovery.pm';
license 'gpl';
perl_version '5.008';

# mandatory dependencies
requires 'FusionInventory::Agent' => '2.2';
requires 'Net::IP'                => undef;
requires 'threads'                => undef;
requires 'XML::TreePP'            => undef;

# optional dependencies
requires 'Net::NBName'            => undef;
requires 'Net::SNMP'              => undef;

WriteAll;

