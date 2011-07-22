use inc::Module::Install;

name 'FusionInventory-Agent-Task-SNMPQuery';
include 'Module::AutoInstall';
abstract 'SNMP query support for FusionInventory Agent';
version_from 'lib/FusionInventory/Agent/Task/SNMPQuery.pm';
license 'gpl';
perl_version '5.008';

# mandatory dependencies
requires 'FusionInventory::Agent' => '2.2';
requires 'Net::SNMP'              => undef;
requires 'threads'                => undef;

WriteAll;

