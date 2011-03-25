package FusionInventory::Agent::Config;

use strict;
use warnings;

use Getopt::Long;
use File::Spec;
use English qw(-no_match_vars);

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
    'no-deploy'               => 0,
    'no-esx'                  => 0,
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
        return $config unless -f $file;
    }

    my $handle;
    if (!open $handle, '<', $file) {
        warn "Config: Failed to open $file: $ERRNO";
        return $config;
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
        'no-deploy',
        'no-esx',
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
        'rpc-trust-localhost=s',
        'remotedir|R=s',
        'scan-homedirs=s',
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

Common options:
    --debug             debug mode ($config->{debug})
    --html              save the inventory requested by --local in HTML ($config->{html})
    -l --local=DIR      do not contact server but write inventory in XML to DIR directory ($config->{local})
    --logfile=FILE      log message in FILE ($config->{logfile})
    --version           print the version


Network options:
    -p --password=PWD   password for server authentication
    -P --proxy=PROXY    proxy address. e.g: http://user:pass\@proxy:port ($config->{proxy})
    -r --realm=REALM    realm for server HTTP authentication. e.g: 'Restricted Area' ($config->{realm})
    -s --server=uri     server uri, e.g: http://server/ocsinventory ($config->{server})
    -u --user           user name to use for server authentication

SSL options:
    --ca-cert-dir=D     SSL certificate directory ($config->{'ca-cert-dir'})
    --ca-cert-file=F    SSL certificate file ($config->{'ca-cert-file'})

Disable options:
    --no-deploy         do not deploy packages or run command with the new deploy task ($config->{'no-deploy'})
    --no-esx            do not use the ESX inventory module ($config->{'no-esx'})
    --no-ocsdeploy      do not deploy packages or run command ($config->{'no-ocsdeploy'})
    --no-inventory      do not generate inventory ($config->{'no-inventory'})
    --no-printer        do not return printer list in inventory $config->{'no-printer'})
    --no-socket         do not allow remote connection ($config->{'no-socket'})
    --no-software       do not return software list in inventory ($config->{'no-software'})
    --no-ssl-check      do not check the SSL connection with the server ($config->{'no-ssl-check'})
    --no-wakeonlan      do not use wakeonlan function ($config->{'no-wakeonlan'})
    --no-snmpquery      do not use snmpquery function ($config->{'no-snmpquery'})
    --no-netdiscovery   do not use netdiscovery function ($config->{'no-netdiscovery'})
    --no-p2p            do not use P2P feature for OCS software deployment ($config->{'no-p2p'})

Extra options:
    --backend-collect-timeout   set a maximum delay time of one inventory data collect job ($config->{'backend-collect-timeout'})
    --basevardir=/path          indicate the directory where the agent should store its files ($config->{basevardir})
    --color                     use color in the console ($config->{color})
    -d --daemon                 detach the agent in background ($config->{daemon})
    -D --daemon-no-fork         put the agent in daemon mode but don't fork in background ($config->{'daemon-no-fork'})
    --delaytime                 set a maximum delay time (in second) if no PROLOG_FREQ is set ($config->{delaytime})
    --devlib                    search for Backend modules in ./lib only ($config->{devlib})
    --disable-perllib-envvar    do not load Perl lib from PERL5LIB and PERLIB environment variable ($config->{'disable-perllib-envvar'})
    -f --force                  always send data to server (Don't ask before) ($config->{force})
    -i --info                   verbose mode ($config->{info})
    --lazy                      do not contact the server more than one time during the PROLOG_FREQ ($config->{lazy})
    --logfile-maxsize=X         maximum size of the log file in MB ($config->{'logfile-maxsize'})
    --logger                    Logger you want to use, can be Stderr,File or Syslog ($config->{logger})
    --rpc-ip=IP                 ip of the interface to use for peer to peer exchange ($config->{'rpc-ip'})
    --rpc-port=PORT     port use for RPC
    --rpc-trust-localhost=X     allow local users to force an inventory from http://127.0.0.1:62354/now (0/1) ($config->{'rpc-trust-localhost'})
    --scan-homedirs=X           permit to scan home user directories (0/1) ($config->{'scan-homedirs'})
    --share-dir=DIR             path to the directory where the shared files are stored ($config->{'share-dir'})
    --stdout                    do not write or post the inventory but print it on STDOUT
    -t --tag=TAG                use TAG as tag ($config->{tag}) Will be ignored by server if a value already exists.
    -w --wait=DURATION          wait a random period between 0 and DURATION seconds before contacting server ($config->{wait})

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
