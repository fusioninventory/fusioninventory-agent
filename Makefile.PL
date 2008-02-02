
use inc::Module::Install;

# Hack to be able to run a post install script
sub MY::postamble
{
    return '
install :: all pure_install doc_install
	$(NOECHO) $(NOOP)
	[ ! -f run-postinst ] || perl postinst.pl
';
}

use Config qw(config_re);

name 'Ocsinventory-Agent';
include 'Module::AutoInstall';
abstract 'Ocs-Iventory unified Agent for UNIX and Linux';
license 'gpl';
version_from 'ocsinventory-agent';
perl_version '5.006';
requires 'Digest::MD5' => undef;
requires 'XML::Simple' => undef;
requires 'Net::IP' => undef;
requires 'LWP' => undef;
requires 'File::Temp' => undef;
recommends 'Compress::Zlib';
recommends 'Proc::Daemon' => undef;

install_script  'ocsinventory-agent';
bundle 'Compress::Zlib' => undef;
bundle 'Digest::MD5' => undef;
bundle 'File::Temp' => undef;
bundle 'Net::IP' => undef;
bundle 'XML::Simple' => undef;
bundle 'XML::SAX' => undef;
bundle 'XML::NamespaceSupport' => undef;
bundle 'URI' => undef;
bundle 'LWP' => undef;


if (defined ($ENV{PERL_AUTOINSTALL}) || defined ($ENV{PERL_AUTOINSTALL})) {
    unlink 'run-postinst';  
} else {
    open POSTINST, '>run-postinst' or die $!;
    close POSTINST;
}



sub wait {
    return if (defined ($ENV{PERL_AUTOINSTALL}) || defined ($ENV{PERL_AUTOINSTALL}));
    <STDIN>;
}


if (!can_use('Compress::Zlib')) {
    print "Please install Compress::Zlib if you use an OCS server prior 1.02.\n"; 
    wait();
}

if (!can_use('Crypt::SSLeay')) {
    print "Please install Crypt::SSLeay if you want to use SSL.\n"; 
}

if (!can_run('ipdiscover') && !can_run('nmap')) {
    print "Plese install nmap ";
    print "or ipdiscover " if $^O =~ /^linux$/i;
    print "if you want to use the network ".
    "discover feature.\n";
    wait();
}

my @t = config_re('archname');
if ($^O =~ /(linux|bsd)/i && $t[0] =~ /(i[3456x]86)/) {
    foreach (qw/dmidecode lspci/) {
        print "$_ is needed if you want complet inventory.\n" unless can_run($_);
        wait();
    }
}

auto_install;
WriteAll;
