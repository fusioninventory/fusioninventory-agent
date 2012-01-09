
use inc::Module::Install;
use English qw(-no_match_vars);

name 'FusionInventory-Agent-Task-Deploy';
include 'Module::AutoInstall';
abstract 'Software deployment support';
license 'gpl';
version_from 'lib/FusionInventory/Agent/Task/Deploy.pm';
perl_version '5.008';

# mandatory dependencies
requires 'FusionInventory::Agent' => 2.2.0;
requires 'Archive::Extract'       => undef;
requires 'Digest::SHA'            => undef;
requires 'File::Copy::Recursive'  => undef;
requires 'JSON'                   => undef;
requires 'URI::Escape'            => undef;


WriteAll;
