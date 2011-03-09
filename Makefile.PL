
use inc::Module::Install;
use English qw(-no_match_vars);

name 'FusionInventory-Agent-Task-Deploy';
include 'Module::AutoInstall';
abstract 'Software deployment support';
license 'gpl';
version_from 'lib/FusionInventory/Agent/Task/Deploy.pm';
perl_version '5.008';

# mandatory dependencies
requires 'FusionInventory::Agent'        => 2.1.8;

test_requires 'Archive::Extract'               => undef;
test_requires 'Digest::SHA'               => undef;


WriteAll;
