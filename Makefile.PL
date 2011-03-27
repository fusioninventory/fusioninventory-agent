use inc::Module::Install;

name 'FusionInventory-Agent-Task-NetDiscovery';
include 'Module::AutoInstall';
abstract 'Network discovery support for FusionInventory Agent';
version_from 'lib/FusionInventory/Agent/Task/NetDiscovery.pm';
license 'gpl';
perl_version '5.006';
requires 'FusionInventory::Agent' => '2.0';
requires 'threads' => undef;
requires 'XML::Simple' => undef;
requires 'Net::IP' => undef;
requires 'Parallel::ForkManager' => undef;
requires 'Net::SNMP' => undef;
requires 'Net::NBName' => undef;
requires 'XML::TreePP' => undef;
WriteAll;

