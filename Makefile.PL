use inc::Module::Install;

name 'FusionInventory-Agent-Tasks-Net';
include 'Module::AutoInstall';
abstract 'FusionInventory Agent network tasks';
version '1.0';
license 'gpl';
perl_version '5.008';

# mandatory dependencies
requires 'FusionInventory::Agent' => '2.2';
requires 'Net::IP'                => undef;
requires 'threads'                => undef;
requires 'XML::TreePP'            => '0.26';

# optional dependencies
requires 'Net::NBName'            => undef;
requires 'Net::SNMP'              => undef;

WriteAll;

