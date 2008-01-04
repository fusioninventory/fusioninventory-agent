use inc::Module::Install;
use Config qw(config_re);

name 'Ocsinventory-Agent';
abstract 'Ocs-Iventory unified Agent for UNIX and Linux';
license 'gpl';
perl_version '5.006';
requires 'Digest::MD5' => undef;
requires 'XML::Simple' => undef;
requires 'Net::IP' => undef;
requires 'Proc::Daemon' => undef;
requires 'LWP' => undef;
requires 'File::Temp' => undef;
requires 'Compress::Zlib';

install_script  'ocsinventory-agent';

if (!can_use('Crypt::SSLeay')) {
    print "Please install Crypt::SSLeay if you want to use SSL.\n"; 
}

if (!can_run('ipdiscover') && !can_run('nmap')) {
    print "Plese install nmap ";
    print "or ipdiscover " if $^O =~ /^linux$/i;
    print "if you want to use the network ".
    "discover feature.\n";
}

my @t = config_re('archname');
if ($^O =~ /(linux|bsd)/i && $t[0] =~ /(i[3456x]86)/) {
    foreach (qw/dmidecode lspci/) {
        print "$_ is needed if you want a complet inventory.\n" unless can_run($_);
    }
}

