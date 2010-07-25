
use inc::Module::Install;
use English qw(-no_match_vars);

# Hack to be able to run a post install script
sub MY::postamble {

    return if $OSNAME eq 'MSWin32';

    my $re = <<'EOF';

install :: all pure_install doc_install
	$(NOECHO) $(NOOP)
	[ ! -f run-postinst ] || $(EXECUTABLE_NAME) fusioninventory-agent-config
EOF

    return $re;
}

name 'FusionInventory-Agent';
include 'Module::AutoInstall';
abstract 'FusionInventory unified Agent for UNIX, Linux, Windows and MacOSX';
license 'gpl';
version_from 'lib/FusionInventory/Agent.pm';
perl_version '5.008';

# mandatory dependencies
requires 'Digest::MD5'        => undef;
requires 'LWP'                => undef;
requires 'Net::IP'            => undef;
requires 'UNIVERSAL::require' => undef;
requires 'XML::Simple'        => undef;

if ($OSNAME eq 'darwin') {
    requires 'Mac::SysProfile' => undef;
}

# optional dependencies
recommends 'Compress::Zlib'   => undef;
recommends 'File::ShareDir'   => undef; # You'll need to use --share-dir
recommends 'HTTP::Daemon'     => undef; # RPC
recommends 'Net::CUPS'        => 0.60;

if ($OSNAME ne 'MSWin32') {
    recommends 'Proc::Daemon'     => undef;
    recommends 'Proc::PID::File'  => undef;
}

# test dependencies
test_requires  'Test::More'  => undef;

install_script  'fusioninventory-agent';
install_script  'fusioninventory-agent-config';
install_script  'fusioninventory-win32-service' if $OSNAME eq 'MSWin32';
install_share; # No parameter, si http://www.glpi-project.org/forum/viewtopic.php?pid=107979#p107979

# We want a release bundled with the needed dependency to be able to
# prepare a standalone binary with PAR::Packer 
if ($ENV{FusionInventory_BUNDLE_RELEASE}) {
    foreach my $module (qw/Archive::Zip HTML::Parser LWP URI XML::NamespaceSupport Net::IP HTML::Tagset Proc::Daemon Module::ScanDeps PAR::Packer AutoLoader PAR PAR::Dist File::Remove YAML::Tiny Getopt::ArgvFile ExtUtils::Install ExtUtils::ParseXS XML::SAX XML::Simple/) {
        bundle $module;
        requires $module;
    }
}

if ($ENV{PERL_AUTOINSTALL}) {
    unlink 'run-postinst';
} else {
    open POSTINST, '>run-postinst' or die $!;
    close POSTINST;
}

# memconf is needed by Solaris backend module
if ($OSNAME eq 'solaris') {
    install_script  'memconf';
}
#for i in inc/BUNDLES/* ; do rm -rf `basename $i` ;done`
#auto_install;
makemaker_args(
    test => { TESTS => join ' ', map { glob } qw(t/*.t t/*/*.t t/*/*/*.t) },
);
WriteAll;
