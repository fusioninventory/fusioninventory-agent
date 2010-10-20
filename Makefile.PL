
use inc::Module::Install;
use English qw(-no_match_vars);

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
recommends 'Crypt::SSLeay'    => undef;
recommends 'HTTP::Daemon'     => undef;
recommends 'Net::CUPS'        => 0.60;

if ($OSNAME ne 'MSWin32') {
    recommends 'Proc::Daemon'     => undef;
    recommends 'Proc::PID::File'  => undef;
} else {
    requires 'Win32::OLE' => undef;
    requires 'Win32::TieRegistry' => undef;
}

# test dependencies
test_requires  'Test::More'  => undef;
test_requires  'XML::TreePP'  => undef;

install_script  'fusioninventory-agent';
install_script  'fusioninventory-agent-config';
install_script  'fusioninventory-win32-service' if $OSNAME eq 'MSWin32';
install_script  'fusioninventory-injector';
install_share; # No parameter, si http://www.glpi-project.org/forum/viewtopic.php?pid=107979#p107979

# We want a release bundled with the needed dependency to be able to
# prepare a standalone binary with PAR::Packer 
if ($ENV{FusionInventory_BUNDLE_RELEASE}) {
    foreach my $module (qw/Archive::Zip HTML::Parser LWP URI XML::NamespaceSupport Net::IP HTML::Tagset Proc::Daemon Module::ScanDeps PAR::Packer AutoLoader PAR PAR::Dist File::Remove YAML::Tiny Getopt::ArgvFile ExtUtils::Install ExtUtils::ParseXS XML::SAX XML::Simple/) {
        bundle $module;
        requires $module;
    }
}

# memconf is needed by Solaris backend module
if ($OSNAME eq 'solaris') {
    install_script  'memconf';
}

WriteAll;

package MY;

use English qw(-no_match_vars);

# allow user to define installation directories
sub post_constants {
    my ($self) = @_;
    my $confdir =
        $self->{ARGS}->{CONFDIR} || '$(PREFIX)/etc/fusioninventory';
    my $datadir =
        $self->{ARGS}->{DATADIR} || '$(PREFIX)/share/fusioninventory';
    my $vardir =
        $self->{ARGS}->{VARDIR} || '$(PREFIX)/var/fusioninventory';
    return <<EOF;
CONFDIR = $confdir
DATADIR = $datadir
VARDIR  = $vardir

EOF
}

# ensure configuration and data get installed too
sub install {
    my ($self) = @_;
    my $install = $self->SUPER::install(@_);
    $install =~ s/install :: pure_install doc_install/install :: pure_install doc_install config_install data_install/;

    $install .= <<'EOF';

config_install :
	install -d -m 755 $(DESTDIR)$(CONFDIR)
	install -m 644 etc/fusioninventory/agent.cfg $(DESTDIR)$(CONFDIR)

data_install :
	install -d -m 755 $(DESTDIR)$(DATADIR)
	install -m 644 share/pci.ids $(DESTDIR)$(DATADIR)/
	install -d -m 755 $(DESTDIR)$(DATADIR)/html
	install -m 644 share/html/* $(DESTDIR)$(DATADIR)/html
EOF
    return $install;
}

# ensure binaries get modified to use configured directories (on Unix only)
sub installbin {
    my ($self) = @_;
    my $installbin = $self->SUPER::installbin(@_);

    return $installbin if $OSNAME eq 'MSWin32';

    $installbin =~ s|\t\$\(FIXIN\) (.*)\n|\t\$(FIXIN) $1\n\t\$(FINALIZE) $1\n|g;

    $installbin .= <<'EOF';
FINALIZE = $(ABSPERLRUN) -pi \
    -e 's|use lib .*||;' \
    -e 's|confdir => .*|confdir => "$(CONFDIR)",|;' \
    -e 's|datadir => .*|datadir => "$(DATADIR)",|;' \
    -e 's|vardir  => .*|vardir  => "$(VARDIR)",|' \
    --
EOF
    return $installbin;
}

sub manifypods {
    my ($self) = @_;
    my $manifypods = $self->SUPER::manifypods(@_);
    $manifypods =~ s/manifypods : pure_all/manifypods : pure_all fusioninventory-agent.1.html/;
    $manifypods .= <<'EOF';
fusioninventory-agent.1.html: fusioninventory-agent
	pod2html --infile=$< --outfile=$@

EOF
    return $manifypods;
}
