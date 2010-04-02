package FusionInventory::Agent::Config;

use strict;
use Getopt::Long;

my $basedir = '';

if ($^O =~ /^MSWin/) {
    $basedir = $ENV{APPDATA}.'/fusioninventory-agent';
}

my $default = {
  'ca-cert-dir' =>  '',
  'ca-cert-file'=>  '', 
  'color'     =>  0,
  'daemon'    =>  0,
  'daemon-no-fork'    =>  0,
  'debug'     =>  0,
  'devlib'    =>  0,
  'force'     =>  0,
  'help'      =>  0,
  'info'      =>  1,
  'lazy'      =>  0,
  'local'     =>  '',
  #'logger'    =>  'Syslog,File,Stderr',
  'logger'    =>  'Stderr',
  'logfile'   =>  '',
  'password'  =>  '',
  'proxy'     =>  '',
  'realm'     =>  '',
  'remotedir' =>  '/ocsinventory', # deprecated, give a complet URL to
                                   # --server instead
  'server'    =>  'http://ocsinventory-ng/ocsinventory',
  'stdout'    =>  0,
  'tag'       =>  '',
  'user'      =>  '',
  'version'   =>  0,
  'wait'      =>  '',
#  'xml'       =>  0,
  'no-ocsdeploy'  =>  0,
  'no-inventory'
              =>  0,
  'nosoft'    =>  0, # DEPRECATED!
  'no-software'=>  0,
  'no-wakeonlan'=> 0,
  'no-snmpquery'=> 0,
  'no-netdiscovery' => 0,
  'delaytime' =>  '3600', # max delay time (seconds)
  'backend-collect-timeout'   => '180',   # timeOut of process : see Backend.pm
  'no-ssl-check' => 0,
  'scan-homedirs' => 0,

  # Other values that can't be changed with the
  # CLI parameters
  'basevardir'=>  $basedir.'/var/lib/fusioninventory-agent',
  'logdir'    =>  $basedir.'/var/log/fusioninventory-agent',
#  'pidfile'   =>  $basedir.'/var/run/ocsinventory-agent.pid',
};

sub load {
	my (undef, $params) = @_;


	my $config = $default;
    $config->{VERSION} = $FusionInventory::Agent::VERSION;

    loadFromCfgFile($config);
    loadUserParams($config);

	return $config;
}

sub loadFromCfgFile {
  my $config = shift;

  $config->{etcdir} = [];

  push (@{$config->{etcdir}}, '/etc/fusioninventory');
  push (@{$config->{etcdir}}, '/usr/local/etc/fusioninventory');
#  push (@{$config->{etcdir}}, $ENV{HOME}.'/.ocsinventory'); # Should I?

  my $file;
if (!$file || !-f $file) {
    foreach (@{$config->{etcdir}}) {
      $file = $_.'/agent.cfg';
      last if -f $file;
    }
    return $config unless -f $file;
  }

  if (!open (CONFIG, "<".$file)) {
    print(STDERR "Config: Failed to open $file: $!\n");
	return $config;
  }
  
  $config->{configFile} = $file;

  foreach (<CONFIG>) {
    s/#.+//;
    if (/(\w+)\s*=\s*(.+)/) {
      my $key = $1;
      my $val = $2;
      # Remove the quotes
      $val =~ s/\s+$//;
      $val =~ s/^'(.*)'$/$1/;
      $val =~ s/^"(.*)"$/$1/;
      $config->{$key} = $val;
    }
  }
  close CONFIG;
}

sub loadUserParams {
	my $config = shift;


	my %options = (
		"backend-collect-timeout=s"  => \$config->{'backend-collect-timeout'},
		"basevardir=s"    =>   \$config->{basevardir},
        "ca-cert-dir=s"   =>   \$config->{'ca-cert-dir'},
        "ca-cert-file=s"  =>   \$config->{'ca-cert-file'},
		"color"           =>   \$config->{color},
		"d|daemon"        =>   \$config->{daemon},
		"D|daemon-no-fork"=>   \$config->{'daemon-no-fork'},
		"debug"           =>   \$config->{debug},
		"devlib"          =>   \$config->{devlib},
		"f|force"         =>   \$config->{force},
		"h|help"          =>   \$config->{help},
		"i|info"          =>   \$config->{info},
		"lazy"            =>   \$config->{lazy},
		"l|local=s"       =>   \$config->{'local'},
		"logfile=s"       =>   \$config->{logfile},
		"no-ocsdeploy"    =>   \$config->{'no-ocsdeploy'},
		"no-inventory"    =>   \$config->{'no-inventory'},
		"no-soft"         =>   \$config->{'no-soft'},
		"no-software"     =>   \$config->{'no-software'},
		"no-wakeonlan"    =>   \$config->{'no-wakeonlan'},
		"no-snmpquery"    =>   \$config->{'no-snmpquery'},
		"no-netdiscovery" =>   \$config->{'no-netdiscovery'},
		"p|password=s"    =>   \$config->{password},
		"P|proxy=s"       =>   \$config->{proxy},
		"r|realm=s"       =>   \$config->{realm},
		"rpc-ip=s"        =>   \$config->{'rpc-ip'},
		"R|remotedir=s"   =>   \$config->{remotedir},
		"s|server=s"      =>   \$config->{server},
		"stdout"          =>   \$config->{stdout},
		"t|tag=s"         =>   \$config->{tag},
        "no-ssl-check"    =>   \$config->{'no-ssl-check'},
		"u|user=s"        =>   \$config->{user},
		"version"         =>   \$config->{version},
		"w|wait=s"        =>   \$config->{'wait'},
#  "x|xml"          =>   \$config->{xml},
		"delaytime=s"     =>   \$config->{delaytime},
		"scan-homedirs"   =>   \$config->{'scan-homedirs'},
		"no-socket"       =>   \$config->{noSocket},
	);

    Getopt::Long::Configure( "no_ignorecase" );
	help($config) if (!GetOptions(%options) || $config->{help});
	version() if $config->{version};

}


sub help {
  my ($config, $error) = @_;
  if ($error) {
    chomp $error;
    print "ERROR: $error\n\n";
  }

  if ($config->{configFile}) {
      print STDERR "Setting initialised with values retrieved from ".
      "the config found at ".$config->{configFile}."\n";
  }

  print STDERR "\n";
  print STDERR "Usage:\n";
  print STDERR "\t    --backend-collect-timeout set a max delay time of one ".
  "inventory data collect job (".$config->{'backend-collect-timeout'}.")\n";
  print STDERR "\t    --basevardir=/path  indicate the directory where ".
  "should the agent store its files (".$config->{basevardir}.")\n";
  print STDERR "\t    --ca-cert-dir=D  SSL certificat directory ".
  "(".$config->{'ca-cert-dir'}.")\n";
  print STDERR "\t    --ca-cert-file=F SSL certificat file ".
  "(".$config->{'ca-cert-file'}.")\n";
  print STDERR "\t    --color         use color in the console ".
  "(".$config->{color}.")\n";
  print STDERR "\t-d  --daemon        detach the agent in background ".
  "(".$config->{daemon}.")\n";
  print STDERR "\t-D  --daemon-no-fork daemon but don't fork in background".
  " (".$config->{'daemon-no-fork'}.")\n";
  print STDERR "\t    --debug         debug mode (".$config->{debug}.")\n";
  print STDERR "\t    --delaytime     set a max delay time (in second) if".
  " no PROLOG_FREQ is set (".$config->{delaytime}.")\n";
  print STDERR "\t    --devlib        search for Backend mod in ./lib only (".$config->{devlib}.")\n";
  print STDERR "\t-f --force          always send data to server (Don't ask before) (".$config->{force}.")\n";
  print STDERR "\t-i --info           verbose mode (".$config->{info}.")\n";
  print STDERR "\t   --no-socket      allow remote connexion (".$config->{noSocket}.")\n";
  print STDERR "\t   --lazy           do not contact the server more than ".
  "one time during the PROLOG_FREQ (".$config->{lazy}.")\n";
  print STDERR "\t-l --local=DIR      do not contact server but write ".
  "inventory in DIR directory in XML (".$config->{local}.")\n";
  print STDERR "\t   --logfile=FILE   log message in FILE (".$config->{logfile}.")\n";
  print STDERR "\t   --no-ocsdeploy   Do not deploy packages or run command".
  "(".$config->{noocsdeploy}.")\n";
  print STDERR "\t   --no-inventory   Do not generate inventory".
  " (".$config->{'no-inventory'}.")\n";
  print STDERR "\t   --no-software    do not return installed ".
  "software list (".$config->{'no-software'}.")\n";
  print STDERR "\t   --no-wakeonlan   do not use wakeonlan function".
  " (".$config->{'no-wakeonlan'}.")\n";

  print STDERR "\t-p --password=PWD   password for server auth\n";
  print STDERR "\t-P --proxy=PROXY    proxy address. e.g: http://user:pass\@proxy:port (".$config->{proxy}.")\n";
  print STDERR "\t-r --realm=REALM    realm for server auth. e.g: 'Restricted Area' (".$config->{realm}.")\n";
  print STDERR "\t-r --realm=REALM    realm for server auth. e.g: 'Restricted Area' (".$config->{realm}.")\n";
  print STDERR "\t   --rpc-ip=IP      ip of the interface to use for peer ".
  "to peer exchange\n";
  print STDERR "\t   --scan-homedirs  permit to scan home user directories".
  " (".$config->{'scan-homedirs'}.")\n" ;
  print STDERR "\t-s --server=uri     server uri (".$config->{server}.")\n";
  print STDERR "\t   --stdout         do not write or post the inventory".
  " but print it on STDOUT\n";
  print STDERR "\t-t --tag=TAG        use TAG as tag (".$config->{tag}."). ".
  "Will be ignored by server if a value already exists.\n";
  print STDERR "\t   --no-ssl-check   do not check the ".
  "SSL connexion with the server (".$config->{'no-ssl-check'}.")\n";
  print STDERR "\t-u --user=USER      user for server auth (".$config->{user}.")\n";
  print STDERR "\t   --version        print the version\n";
  print STDERR "\t-w --wait=seconds   wait during a random periode before".
  "  contacting server like --daemon do (".$config->{wait}.")\n";
#  print STDERR "\t-x --xml            write output in a xml file ($config->{xml})\n";

  print STDERR "\n";
  print STDERR "Manpage:\n";
  print STDERR "\tSee man fusioninventory-agent\n";

  print STDERR "\n";
  print STDERR "FusionInventory-Agent is released under GNU GPL 2 license\n";
  exit 1;
}


sub version {
  print "FusionInventory Agent (".$FusionInventory::Agent::VERSION.")\n";
  exit 0;
}


1;
