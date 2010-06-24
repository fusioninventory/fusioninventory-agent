
use inc::Module::Install;
use English qw(-no_match_vars);

# Hack to be able to run a post install script
sub MY::postamble
{

    return if $OSNAME =~ /^MSWin/;

	my $re;

	$re = '
install :: all pure_install doc_install
	$(NOECHO) $(NOOP)';

	$re .= "\n\t[ ! -f run-postinst ] || $EXECUTABLE_NAME fusioninventory-agent-config\n";

    return $re;
}

use Config;


name 'FusionInventory-Agent';
include 'Module::AutoInstall';
abstract 'FusionInventory unified Agent for UNIX, Linux, Windows and MacOSX';
license 'gpl';
version_from 'lib/FusionInventory/Agent.pm';
perl_version '5.008';
requires 'Digest::MD5' => undef;
requires 'XML::Simple' => undef;
requires 'LWP' => undef;
requires 'File::Temp' => undef;
requires 'Net::IP' => undef;
requires 'HTTP::Status' => undef;
requires 'File::Find' => undef;
recommends 'Compress::Zlib';
recommends 'Proc::Daemon' => undef unless $OSNAME =~ /^MSWin/;
recommends 'Proc::PID::File' => undef unless $OSNAME =~ /^MSWin/;
recommends 'File::Glob' => undef;
recommends 'File::Path' => undef;
recommends 'HTTP::Daemon' => undef; # RPC
recommends 'Archive::Extract' => undef;
recommends 'Net::CUPS' => 0.60;
recommends 'MIME::Base64' => undef;
recommends 'File::ShareDir' => undef; # You'll need to use --html-dir

test_requires  'Test::More'  => undef;

install_script  'fusioninventory-agent';
install_script  'fusioninventory-agent-config';
install_script  'fusioninventory-win32-service' if $OSNAME =~ /^MSWin/;
install_share 'share';

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

if (!can_use('Crypt::SSLeay') && !can_use('IO::Socket::SSL')) {
    print "Please install Crypt::SSLeay or IO::Socket::SSL if you want to use SSL.\n";
}

if (!can_use('Net::SSLeay')) {
    print "Please install Net::SSLeay if you want to use the software deployment.\n";
}


if (!can_run('ipdiscover') && !can_run('nmap')) {
    print "Please install nmap ";
    print "or ipdiscover " if $OSNAME =~ /^linux$/i;
    print "if you want to use the network ".
    "discover feature.\n";
}

if (!can_use('Proc::Daemon') || !can_use('Proc::PID::File')) {
    print "Please install Proc::Daemon and Proc::PID::File if you ".
    "want to use the daemon mode.\n";
}


my $archname;
eval { # config_re is not available on Perl 5.6
    my @t = Config::config_re('archname');
    $archname = $t[0];
};
if ($OSNAME =~ /(linux|bsd)/i && (!$archname ||$archname =~ /(i[3456x]86|x86_64|amd64)/i)) {
    foreach (qw/dmidecode lspci/) {
        if (!can_run($_)) {
            print "\n";
            print "[WARNING] $_ is needed if you want a complete inventory on x86 and AMD64/x86_64.\n";
            print "\n";
        }
    }
}

if ($OSNAME =~ /^darwin$/ && !can_use('Mac::SysProfile')) {
    print "\n";
    print "[WARNING] Mac::SysProfile is needed on MacOS to detect most of the device information.\n";
    print "\n";
    requires 'Mac::SysProfile' => undef;
}

# memconf is needed by Solaris backend module
if ($OSNAME =~ /^solaris$/i) {
    install_script  'memconf';
}
#for i in inc/BUNDLES/* ; do rm -rf `basename $i` ;done`
#auto_install;
WriteAll;

