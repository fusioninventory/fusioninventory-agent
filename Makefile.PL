use inc::Module::Install;

name 'FusionInventory-Agent-Task-SNMPQuery';
include 'Module::AutoInstall';
abstract 'Network discovery support for FusionInventory Agent';
version_from 'lib/FusionInventory/Agent/Task/SNMPQuery.pm';
license 'gpl';
perl_version '5.006';
requires 'FusionInventory::Agent' => '2.0';
requires 'threads' => undef;
requires 'XML::Simple' => undef;
requires 'Net::IP' => undef;
requires 'File::stat' => undef;
requires 'Net::SNMP' => undef;
requires 'Parallel::ForkManager' => undef;

WriteAll;

