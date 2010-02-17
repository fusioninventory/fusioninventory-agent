
use inc::Module::Install;

# Hack to be able to run a post install script
sub MY::postamble
{

	my $re;

	$re = '
install :: all pure_install doc_install
	$(NOECHO) $(NOOP)';

	$re .= "\n\t[ ! -f run-postinst ] || $^X fusioninventory-agent-config\n";

    return $re;
}

require 'lib/FusionInventory/Agent/Config.pm';
use Config;

my $version = $FusionInventory::Agent::Config::VERSION;
if (-d '.bzr') {
    chomp( my $bzrRev = `bzr revno`);
    $version .= "~bzr".$bzrRev;
}

name 'FusionInventory-Agent';
include 'Module::AutoInstall';
abstract 'FusionInventory unified Agent for UNIX, Linux and MacOSX';
license 'gpl';
version $version;
perl_version '5.006';
requires 'Digest::MD5' => undef;
requires 'XML::Simple' => undef;
requires 'LWP' => undef;
requires 'File::Temp' => undef;
recommends 'Net::IP' => undef;
recommends 'Compress::Zlib';
recommends 'Proc::Daemon' => undef;
recommends 'Proc::PID::File' => undef;

# For the software deployment
recommends 'XML::Simple' => undef;
recommends 'File::Copy' => undef;
recommends 'File::Glob' => undef;
recommends 'LWP::Simple' => undef;
recommends 'File::Path' => undef;
recommends 'Archive::Extract' => undef;
recommends 'File::Copy::Recursive' => undef;
recommends 'Net::SSLGlue::LWP' => undef;
recommends 'Digest::MD5' => undef;
recommends 'HTTP::Daemon' => undef; # RPC

use Data::Dumper;
use Cwd;


install_script  'fusioninventory-agent';
install_script  'fusioninventory-agent-config';


# We want a release bundled with the needed dependency to be able to
# prepare a standalone binary with PAR::Packer 
if ($ENV{FusionInventory_BUNDLE_RELEASE}) {
  foreach my $module (qw/Archive::Zip HTML::Parser LWP URI XML::NamespaceSupport Net::IP HTML::Tagset Proc::Daemon Module::ScanDeps PAR::Packer AutoLoader PAR PAR::Dist File::Remove YAML::Tiny Getopt::ArgvFile ExtUtils::Install ExtUtils::ParseXS XML::SAX XML::Simple/) {
    bundle $module;
    requires $module;
  }
}



if (defined ($ENV{PERL_AUTOINSTALL}) || defined ($ENV{PERL_AUTOINSTALL})) {
    unlink 'run-postinst';
} else {
    open POSTINST, '>run-postinst' or die $!;
    close POSTINST;
}


if (!can_use('Compress::Zlib')) {
    print "Please install Compress::Zlib if you use an OCS server prior 1.02.\n";
}

if (!can_use('Crypt::SSLeay')) {
    print "Please install Crypt::SSLeay if you want to use SSL.\n";
}

if (!can_use('Net::SSLeay')) {
    print "Please install Net::SSLeay if you want to use the software deployment.\n";
}


if (!can_run('ipdiscover') && !can_run('nmap')) {
    print "Please install nmap ";
    print "or ipdiscover " if $^O =~ /^linux$/i;
    print "if you want to use the network ".
    "discover feature.\n";
}

if (!can_use('Net::IP')) {
    print "Net::IP is strongly recommended since it's required to retrieve "
    ."network information\n";
}

if (!can_use('Proc::Daemon') || !can_use('Proc::PID::File')) {
    print "Please install Proc::Daemon and Proc::PID::File if you ".
    "want to use the daemon mode.\n";
}

if (!can_use('Net::Wake')) {
    print "Please install Net::Wake if you ".
    "want to use the wakeonlan mode.\n";
}


my $archname;
eval { # config_re is not available on Perl 5.6
    my @t = Config::config_re('archname');
    $archname = $t[0];
};
if ($^O =~ /(linux|bsd)/i && (!$archname ||$archname =~ /(i[3456x]86|x86_64|amd64)/i)) {
    foreach (qw/dmidecode lspci/) {
        if (!can_run($_)) {
            print "\n";
            print "[WARNING] $_ is needed if you want a complete inventory on x86 and AMD64/x86_64.\n";
            print "\n";
        }
    }
}

if ($^O =~ /^darwin$/ && !can_use('Mac::SysProfile')) {
    print "\n";
    print "[WARNING] Mac::SysProfile is needed on MacOS to detect most of the device information.\n";
    print "\n";
    requires 'Mac::SysProfile' => undef;
}

# memconf is needed by Solaris backend module
if ($^O =~ /^solaris$/i) {
    install_script  'memconf';
}
#for i in inc/BUNDLES/* ; do rm -rf `basename $i` ;done`
#auto_install;
WriteAll;

