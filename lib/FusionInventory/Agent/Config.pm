package FusionInventory::Agent::Config;

use strict;
use Getopt::Long;
use English qw(-no_match_vars);

my $basedir = '';

if ($OSNAME =~ /^MSWin/) {
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
  'disable-perllib-envvar' => 0,
  'force'     =>  0,
  'help'      =>  0,
  'html-dir'  =>  '',
  'info'      =>  1,
  'lazy'      =>  0,
  'local'     =>  '',
  #'logger'    =>  'Syslog,File,Stderr',
  'logger'    =>  'Stderr',
  'logfile'   =>  '',
  'logfacility' =>  'LOG_USER',
  'password'  =>  '',
  'proxy'     =>  '',
  'realm'     =>  '',
  'remotedir' =>  '/ocsinventory', # deprecated, give a complet URL to
                                   # --server instead
  'server'    =>  '',
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
  'no-printer'=>  0,
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

    if ($OSNAME =~ /^MSWin/) {
        loadFromWinRegistry($config);
    } else {
        loadFromCfgFile($config);
    }

    loadUserParams($config);
	return $config;
}

sub loadFromWinRegistry {
  my $config = shift;

  if (!eval ("
    use Encode qw(encode);
    use Win32::TieRegistry ( Delimiter=>\"/\", ArrayValues=>0 );
    1
  ")) {
    print "[error] $@";
    return;
  }

  my $machKey = $Win32::TieRegistry::Registry->Open( "LMachine", {Access=>Win32::TieRegistry::KEY_READ(),Delimiter=>"/"} );
  my $settings = $machKey->{"SOFTWARE/FusionInventory-Agent"};

  foreach my $rawKey (keys %$settings) {
    next unless $rawKey =~ /^\/(\S+)/;
    my $key = $1;
    my $val = $settings->{$rawKey};
    # Remove the quotes
    $val =~ s/\s+$//;
    $val =~ s/^'(.*)'$/$1/;
    $val =~ s/^"(.*)"$/$1/;
    $config->{lc($key)} = $val;
  }
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
        "disable-perllib-envvar" => \$config->{'disable-perllib-envvar'},
		"f|force"         =>   \$config->{force},
		"h|help"          =>   \$config->{help},
		"html-dir=s"      =>   \$config->{'html-dir'},
		"i|info"          =>   \$config->{info},
		"lazy"            =>   \$config->{lazy},
		"l|local=s"       =>   \$config->{'local'},
		"logfile=s"       =>   \$config->{logfile},
		"no-ocsdeploy"    =>   \$config->{'no-ocsdeploy'},
		"no-inventory"    =>   \$config->{'no-inventory'},
		"no-soft"         =>   \$config->{'no-soft'},
		"no-printer"     =>   \$config->{'no-printer'},
		"no-software"     =>   \$config->{'no-software'},
		"no-wakeonlan"    =>   \$config->{'no-wakeonlan'},
		"no-snmpquery"    =>   \$config->{'no-snmpquery'},
		"no-netdiscovery" =>   \$config->{'no-netdiscovery'},
		"p|password=s"    =>   \$config->{password},
		"P|proxy=s"       =>   \$config->{proxy},
		"r|realm=s"       =>   \$config->{realm},
		"rpc-ip=s"        =>   \$config->{'rpc-ip'},
		"rpc-trust-localhost" =>   \$config->{'rpc-trust-localhost'},
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
		"no-socket"       =>   \$config->{'no-socket'},
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

  print STDERR <<EOF;

Usage:
    --backend-collect-timeout set a max delay time of one inventory data collect job ($config->{'backend-collect-timeout'})
    --basevardir=/path  indicate the directory where should the agent store its files ($config->{basevardir})
    --ca-cert-dir=D  SSL certificat directory ($config->{'ca-cert-dir'})
    --ca-cert-file=F SSL certificat file ($config->{'ca-cert-file'})
    --color         use color in the console ($config->{color})
    -d --daemon        detach the agent in background ($config->{daemon})
    -D --daemon-no-fork daemon but don't fork in background ($config->{'daemon-no-fork'})
    --debug         debug mode ($config->{debug})
    --delaytime     set a max delay time (in second) if no PROLOG_FREQ is set ($config->{delaytime})
    --devlib        search for Backend mod in ./lib only ($config->{devlib})
    --disable-perllib-envvar    do not load Perl lib from PERL5LIB and PERLIB environment variable ($config->{'disable-perllib-envvar'})
    -f --force          always send data to server (Don't ask before) ($config->{force})
    --html-dir       alternative directory where the static HTML are stored
    -i  --info           verbose mode ($config->{info})
    --no-socket      don't allow remote connexion ($config->{'no-socket'})
    --lazy           do not contact the server more than one time during the PROLOG_FREQ ($config->{lazy})
-l --local=DIR      do not contact server but write inventory in DIR directory in XML ($config->{local})
    --logfile=FILE   log message in FILE ($config->{logfile})
    --no-ocsdeploy   Do not deploy packages or run command ($config->{noocsdeploy})
    --no-inventory   Do not generate inventory ($config->{'no-inventory'})
    --no-ssl-check   do not check the SSL connexion with the server ($config->{'no-ssl-check'})
    --no-printer     do not return printer list in inventory $config->{'no-printer'})
    --no-software    do not return installed software list ($config->{'no-software'})
    --no-wakeonlan   do not use wakeonlan function ($config->{'no-wakeonlan'})

    -p --password=PWD   password for server auth
    -P --proxy=PROXY    proxy address. e.g: http://user:pass\@proxy:port ($config->{proxy})
    -r --realm=REALM    realm for server auth. e.g: 'Restricted Area' ($config->{realm})
    --rpc-ip=IP      ip of the interface to use for peer to peer exchange
    --rpc-trust-localhost      allow local users to http://127.0.0.1:62354/now to force an inventory
    --scan-homedirs  permit to scan home user directories ($config->{'scan-homedirs'})
    -s --server=uri     server uri ($config->{server})
    --stdout         do not write or post the inventory but print it on STDOUT
    -t --tag=TAG        use TAG as tag ($config->{tag}) Will be ignored by server if a value already exists.
    --version        print the version
    -w --wait=DURATION  wait during a random periode between 0 and DURATION seconds before contacting server ($config->{wait})

Manpage:
    See man fusioninventory-agent

FusionInventory-Agent is released under GNU GPL 2 license
EOF

  exit 1;
}


sub version {
  print "FusionInventory Agent (".$FusionInventory::Agent::VERSION.")\n";
  exit 0;
}


1;
