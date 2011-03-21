package FusionInventory::Agent::Config;

use strict;
use warnings;

use English qw(-no_match_vars);
use File::Spec;
use Getopt::Long;

my $basedir = '';
my $basevardir = '';

if ($OSNAME eq 'MSWin32') {
    $basedir = $ENV{APPDATA}.'/fusioninventory-agent';
    $basevardir = $basedir.'/var/lib/fusioninventory-agent';
} else {
    $basevardir = File::Spec->rel2abs($basedir.'/var/lib/fusioninventory-agent'),
}

my $default = {
    'ca-cert-dir'             => '',
    'ca-cert-file'            => '',
    'conf-file'               => '',
    'color'                   => 0,
    'daemon'                  => 0,
    'daemon-no-fork'          => 0,
    'debug'                   => 0,
    'devlib'                  => 0,
    'disable-perllib-envvar'  => 0,
    'force'                   => 0,
    'help'                    => 0,
    'html'                    => 0,
    'info'                    => 1,
    'lazy'                    => 0,
    'local'                   => '',
    'logger'                  => 'Stderr',
    'logfile'                 => '',
    'logfile-maxsize'         => 0,
    'logfacility'             => 'LOG_USER',
    'password'                => '',
    'proxy'                   => '',
    'realm'                   => '',
    'remotedir'               => '/ocsinventory', # deprecated
    'server'                  => '',
    'share-dir'               => '',
    'stdout'                  => 0,
    'tag'                     => '',
    'user'                    => '',
    'version'                 => 0,
    'wait'                    => '',
#   'xml'                     => 0,
    'no-ocsdeploy'            => 0,
    'no-inventory'            => 0,
    'nosoft'                  => 0, # deprecated
    'nosoftware'              => 0, # deprecated
    'no-printer'              => 0,
    'no-socket'               => 0,
    'no-software'             => 0,
    'no-software'             => 0,
    'no-wakeonlan'            => 0,
    'no-snmpquery'            => 0,
    'no-netdiscovery'         => 0,
    'no-p2p'                  => 0,
    'delaytime'               => 3600, # max delay time (seconds)
    'backend-collect-timeout' => 180,   # timeOut of process : see Backend.pm
    'no-ssl-check'            => 0,
    'scan-homedirs'           => 0,
    'rpc-ip'                  => '',
    'rpc-port'                => '62354',
    'rpc-trust-localhost'     => 0,
    # Other values that can't be changed with the
    # CLI parameters
    'basevardir'              => $basevardir,
#    'logdir'                  =>  $basedir.'/var/log/fusioninventory-agent',
#   'pidfile'                 =>  $basedir.'/var/run/ocsinventory-agent.pid',
};

sub load {
    my (undef, $params) = @_;

    my $config = $default;
    $config->{VERSION} = $FusionInventory::Agent::VERSION;

    if ($OSNAME eq 'MSWin32') {
        loadFromWinRegistry($config);
    } else {
        loadFromCfgFile($config);
    }
    loadUserParams($config);

    if (!$config->{'share-dir'}) {
        if ($config->{'devlib'}) {
                $config->{'share-dir'} = File::Spec->rel2abs('./share/');
        } else {
            eval { 
                require File::ShareDir;
                $config->{'share-dir'} = File::ShareDir::dist_dir('FusionInventory-Agent');
            };
        }
    }


    return $config;
}

sub loadFromWinRegistry {
    my $config = shift;

    eval {
        require Encode;
        Encode->import('encode');
        require Win32::TieRegistry;
        Win32::TieRegistry->import(
            Delimiter   => "/",
            ArrayValues => 0
        );
    };
    if ($EVAL_ERROR) {
        print "[error] $EVAL_ERROR";
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

    my $file;

    my $in;
    foreach (@ARGV) {
        if (!$in && /^--conf-file=(.*)/) {
            $file = $1;
            $file =~ s/'(.*)'/$1/;
            $file =~ s/"(.*)"/$1/;
        } elsif (/^--conf-file$/) {
            $in = 1;
        } elsif ($in) {
            $file = $_;
            $in = 0;
        } else {
            $in = 0;
        }
    }

    push (@{$config->{etcdir}}, '/etc/fusioninventory');
    push (@{$config->{etcdir}}, '/usr/local/etc/fusioninventory');
#  push (@{$config->{etcdir}}, $ENV{HOME}.'/.ocsinventory'); # Should I?

    if (!$file || !-f $file) {
        foreach (@{$config->{etcdir}}) {
            $file = $_.'/agent.cfg';
            last if -f $file;
        }
        return unless -f $file;
    }

    my $handle;
    if (!open $handle, '<', $file) {
        warn "Config: Failed to open $file: $ERRNO";
        return;
    }

    $config->{'conf-file'} = $file;

    while (<$handle>) {
        s/#.+//;
        if (/([\w-]+)\s*=\s*(.+)/) {
            my $key = $1;
            my $val = $2;
            # Remove the quotes
            $val =~ s/\s+$//;
            $val =~ s/^'(.*)'$/$1/;
            $val =~ s/^"(.*)"$/$1/;
            $config->{$key} = $val;
        }
    }
    close $handle;
}

sub loadUserParams {
    my $config = shift;

    Getopt::Long::Configure( "no_ignorecase" );

    GetOptions(
        $config,
        'backend-collect-timeout=s',
        'basevardir=s',
        'ca-cert-dir=s',
        'ca-cert-file=s',
        'conf-file=s',
        'color',
        'daemon|d',
        'daemon-no-fork|D',
        'debug',
        'delaytime=s',
        'devlib',
        'disable-perllib-envvar',
        'force|f',
        'help|h',
        'html',
        'info|i',
        'lazy',
        'local|l=s',
        'logger=s',
        'logfile=s',
        'logfile-maxsize=i',
        'nosoft',
        'nosoftware',
        'no-ocsdeploy',
        'no-inventory',
        'no-printer',
        'no-socket',
        'no-soft',
        'no-software',
        'no-ssl-check',
        'no-wakeonlan',
        'no-snmpquery',
        'no-netdiscovery',
        'no-p2p',
        'password|p=s',
        'proxy|P=s',
        'realm|r=s',
        'rpc-ip=s',
        'rpc-port=s',
        'rpc-trust-localhost',
        'remotedir|R=s',
        'scan-homedirs',
        'share-dir=s',
        'server|s=s',
        'stdout',
        'tag|t=s',
        'user|u=s',
        'version',
        'wait|w=s',
    ) or help($config);

    # We want only canonical path
    $config->{basevardir} = File::Spec->rel2abs($config->{basevardir}) if $config->{basevardir};
    $config->{'share-dir'} = File::Spec->rel2abs($config->{'share-dir'}) if $config->{'share-dir'};
    $config->{'conf-file'} = File::Spec->rel2abs($config->{'conf-file'}) if $config->{'conf-file'};
    $config->{'ca-cert-file'} = File::Spec->rel2abs($config->{'ca-cert-file'}) if $config->{'ca-cert-file'};
    $config->{'ca-cert-dir'} = File::Spec->rel2abs($config->{'ca-cert-dir'}) if $config->{'ca-cert-dir'};
    $config->{'logfile'} = File::Spec->rel2abs($config->{'logfile'}) if $config->{'logfile'};


    help($config) if $config->{help};
    version() if $config->{version};
}

sub help {
    my ($config, $error) = @_;
    if ($error) {
        chomp $error;
        print "ERROR: $error\n\n";
    }

    if ($config->{'conf-file'}) {
        print STDERR "Setting initialised with values retrieved from ".
        "the config found at ".$config->{'conf-file'}."\n";
    }

    print STDERR <<EOF;

Target definition options
    -s --server=URI     send tasks result to a server ($config->{server})
    -l --local=DIR      write tasks results in a directory ($config->{local})
    --stdout            write tasks result on STDOUT

Target scheduling options
    --delaytime=DURATION        maximum initial delay before first target, in seconds ($config->{delaytime})
    -w --wait=DURATION          maximum delay between each target, in seconds ($config->{wait})
    --lazy                      do not contact the target before next scheduled ime ($config->{lazy})

Task selection options
    --no-ocsdeploy      do not run packages deployment task ($config->{'no-ocsdeploy'})
    --no-inventory      do not run inventory task ($config->{'no-inventory'})
    --no-wakeonlan      do not run wake on lan task ($config->{'no-wakeonlan'})
    --no-snmpquery      do not run snmp query task ($config->{'no-snmpquery'})
    --no-netdiscovery   do not run net discovery task ($config->{'no-netdiscovery'})


Inventory task specific options
    --no-printer        do not list local printers ($config->{'no-printer'})
    --no-software       do not list installed software ($config->{'no-software'})
    --scan-homedirs     allow to scan use home directories ($config->{'scan-homedirs'})
    --html              save the inventory as HTML ($config->{html})
    -f --force          always send data to server ($config->{force})
    -t --tag=TAG        mark the machine with given tag ($config->{tag})
    --backend-collect-timeout   timeout for inventory modules execution ($config->{'backend-collect-timeout'})

Package deployment task specific options
    --no-p2p            do not use peer to peer to download files ($config->{'no-p2p'})

Network options:
    -P --proxy=PROXY    proxy address ($config->{proxy})
    -u --user=USER      user name for server authentication ($config->{user})
    -p --password=PWD   password for server authentication
    -r --realm=REALM    realm for server authentication ($config->{realm})
    --ca-cert-dir=D     path to the CA certificates directory ($config->{'ca-cert-dir'})
    --ca-cert-file=F    path to the CA certificates file ($config->{'ca-cert-file'})
    --no-ssl-check      do not check server SSL certificates ($config->{'no-ssl-check'})

Web interface options
    --no-socket                 disable embedded web server ($config->{'no-socket'})
    --rpc-ip=IP                 network interface to listen to ($config->{'rpc-ip'})
    --rpc-port=PORT             network port to listen to ($config->{'rpc-port'})
    --rpc-trust-localhost       trust local requests without authentication token ($config->{'rpc-trust-localhost'})

Logging options
    --logger                    Logger backend, either Stderr, File or Syslog ($config->{logger})
    --logfile=FILE              log file ($config->{logfile})
    --logfile-maxsize=X         maximum size of the log file in MB ($config->{'logfile-maxsize'})
    --logfacility=FACILITY      syslog facility ($config->{logfacility})
    --color                     use color in the console ($config->{color})

Agent setup options
    --basevardir=DIR            path to the writable data files ($config->{basevardir})
    --share-dir=DIR             path to the read-only data files ($config->{'share-dir'})
    --conf-file=FILE            path to an alternative config file ($config->{'conf-file'})
    --disable-perllib-envvar    do not load Perl lib from PERL5LIB and PERLIB environment variable ($config->{'disable-perllib-envvar'})
    --devlib                    search for Backend modules in ./lib only ($config->{devlib})

Execution mode options
    -d --daemon                 run the agent as a daemon ($config->{daemon})
    -D --daemon-no-fork         run the agent as a daemon but don't fork in background ($config->{'daemon-no-fork'})
    -i --info                   verbose mode ($config->{info})
    --debug                     debug mode ($config->{debug})
    --version                   print the version and exit

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
