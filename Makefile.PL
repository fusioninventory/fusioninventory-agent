
use inc::Module::Install;
use English qw(-no_match_vars);

name 'FusionInventory-Agent-Task-ESX';
include 'Module::AutoInstall';
abstract 'ESX and ESXi inventory';
license 'gpl';
version_from 'lib/FusionInventory/Agent/Task/ESX.pm';
perl_version '5.008';

# mandatory dependencies
requires 'FusionInventory::Agent'        => 2.1.8;
requires 'Getopt::Long'                  => undef;

install_script  'fusioninventory-esx';

WriteAll;
