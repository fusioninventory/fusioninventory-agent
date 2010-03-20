
use inc::Module::Install;

my $version = $FusionInventory::Agent::Task::OcsDeploy;

name 'FusionInventory-Agent-Task-OcsDeploy';
include 'Module::AutoInstall';
abstract 'OCS Software deployment support for FusionInventory Agent';
license 'gpl';
version $version;
perl_version '5.006';
requires 'FusionInventory::Agent' => '2.0';
requires 'Digest::MD5' => undef;
requires 'XML::Simple' => undef;
requires 'LWP' => undef;
requires 'File::Temp' => undef;
requires 'Net::IP' => undef;
requires 'HTTP::Status' => undef;
recommends 'Compress::Zlib';
recommends 'Proc::Daemon' => undef;
recommends 'Proc::PID::File' => undef;

# For the software deployment
recommends 'XML::Simple' => undef;
recommends 'File::Copy' => undef;
recommends 'File::Glob' => undef;
recommends 'File::Path' => undef;
recommends 'File::Copy::Recursive' => undef;
recommends 'Digest::MD5' => undef;
recommends 'HTTP::Daemon' => undef; # RPC
recommends 'Archive::Extract' => undef; # RPC

use Data::Dumper;
use Cwd;


if (!can_use('Crypt::SSLeay') && !can_use('IO::Socket::SSL')) {
    print "Please install Crypt::SSLeay or IO::Socket::SSL if you want to use SSL.\n";
}

if (!can_use('Net::SSLeay')) {
    print "Please install Net::SSLeay if you want to use the software deployment.\n";
}

WriteAll;

