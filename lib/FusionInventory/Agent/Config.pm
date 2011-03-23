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

sub new {
    my ($class, $params) = @_;

    my $self = {
        VERSION => $FusionInventory::Agent::VERSION
    };
    bless $self, $class;
    $self->loadDefaults();

    if ($OSNAME eq 'MSWin32') {
        $self->loadFromWinRegistry();
    } else {
        $self->loadFromCfgFile();
    }
    $self->loadUserParams();

    if (!$self->{'share-dir'}) {
        if ($self->{'devlib'}) {
                $self->{'share-dir'} = File::Spec->rel2abs('./share/');
        } else {
            eval { 
                require File::ShareDir;
                $self->{'share-dir'} = File::ShareDir::dist_dir('FusionInventory-Agent');
            };
        }
    }


    return $self;
}

sub loadDefaults {
    my ($self) = @_;

    foreach my $key (keys %$default) {
        $self->{$key} = $default->{$key};
    }
}

sub loadFromWinRegistry {
    my ($self) = @_;

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
        $self->{lc($key)} = $val;
    }
}

sub loadFromCfgFile {
    my ($self) = @_;

    $self->{etcdir} = [];

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

    push (@{$self->{etcdir}}, '/etc/fusioninventory');
    push (@{$self->{etcdir}}, '/usr/local/etc/fusioninventory');
#  push (@{$self->{etcdir}}, $ENV{HOME}.'/.ocsinventory'); # Should I?

    if (!$file || !-f $file) {
        foreach (@{$self->{etcdir}}) {
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

    $self->{'conf-file'} = $file;

    while (<$handle>) {
        s/#.+//;
        if (/([\w-]+)\s*=\s*(.+)/) {
            my $key = $1;
            my $val = $2;
            # Remove the quotes
            $val =~ s/\s+$//;
            $val =~ s/^'(.*)'$/$1/;
            $val =~ s/^"(.*)"$/$1/;
            $self->{$key} = $val;
        }
    }
    close $handle;
}

sub loadUserParams {
    my ($self) = @_;

    Getopt::Long::Configure( "no_ignorecase" );

    GetOptions(
        $self,
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
    ) or $self->help();

    # We want only canonical path
    $self->{basevardir} = File::Spec->rel2abs($self->{basevardir}) if $self->{basevardir};
    $self->{'share-dir'} = File::Spec->rel2abs($self->{'share-dir'}) if $self->{'share-dir'};
    $self->{'conf-file'} = File::Spec->rel2abs($self->{'conf-file'}) if $self->{'conf-file'};
    $self->{'ca-cert-file'} = File::Spec->rel2abs($self->{'ca-cert-file'}) if $self->{'ca-cert-file'};
    $self->{'ca-cert-dir'} = File::Spec->rel2abs($self->{'ca-cert-dir'}) if $self->{'ca-cert-dir'};
    $self->{'logfile'} = File::Spec->rel2abs($self->{'logfile'}) if $self->{'logfile'};


    $self->help() if $self->{help};
    $self->version() if $self->{version};
}

sub help {
    my ($self, $error) = @_;
    if ($error) {
        chomp $error;
        print "ERROR: $error\n\n";
    }

    if ($self->{'conf-file'}) {
        print STDERR "Setting initialised with values retrieved from ".
        "the config found at ".$self->{'conf-file'}."\n";
    }

    print STDERR <<EOF;

Target definition options
    -s --server=URI     send tasks result to a server ($self->{server})
    -l --local=DIR      write tasks results in a directory ($self->{local})
    --stdout            write tasks result on STDOUT

Target scheduling options
    --delaytime=DURATION        maximum initial delay before first target, in seconds ($self->{delaytime})
    -w --wait=DURATION          maximum delay between each target, in seconds ($self->{wait})
    --lazy                      do not contact the target before next scheduled ime ($self->{lazy})

Task selection options
    --no-ocsdeploy      do not run packages deployment task ($self->{'no-ocsdeploy'})
    --no-inventory      do not run inventory task ($self->{'no-inventory'})
    --no-wakeonlan      do not run wake on lan task ($self->{'no-wakeonlan'})
    --no-snmpquery      do not run snmp query task ($self->{'no-snmpquery'})
    --no-netdiscovery   do not run net discovery task ($self->{'no-netdiscovery'})

Inventory task specific options
    --no-printer        do not list local printers ($self->{'no-printer'})
    --no-software       do not list installed software ($self->{'no-software'})
    --scan-homedirs     allow to scan use home directories ($self->{'scan-homedirs'})
    --html              save the inventory as HTML ($self->{html})
    -f --force          always send data to server ($self->{force})
    -t --tag=TAG        mark the machine with given tag ($self->{tag})
    --backend-collect-timeout   timeout for inventory modules execution ($self->{'backend-collect-timeout'})

Package deployment task specific options
    --no-p2p            do not use peer to peer to download files ($self->{'no-p2p'})

Network options:
    -P --proxy=PROXY    proxy address ($self->{proxy})
    -u --user=USER      user name for server authentication ($self->{user})
    -p --password=PWD   password for server authentication
    -r --realm=REALM    realm for server authentication ($self->{realm})
    --ca-cert-dir=D     path to the CA certificates directory ($self->{'ca-cert-dir'})
    --ca-cert-file=F    path to the CA certificates file ($self->{'ca-cert-file'})
    --no-ssl-check      do not check server SSL certificates ($self->{'no-ssl-check'})

Web interface options
    --no-socket                 disable embedded web server ($self->{'no-socket'})
    --rpc-ip=IP                 network interface to listen to ($self->{'rpc-ip'})
    --rpc-port=PORT             network port to listen to ($self->{'rpc-port'})
    --rpc-trust-localhost       trust local requests without authentication token ($self->{'rpc-trust-localhost'})

Logging options
    --logger                    Logger backend, either Stderr, File or Syslog ($self->{logger})
    --logfile=FILE              log file ($self->{logfile})
    --logfile-maxsize=X         maximum size of the log file in MB ($self->{'logfile-maxsize'})
    --logfacility=FACILITY      syslog facility ($self->{logfacility})
    --color                     use color in the console ($self->{color})

Agent setup options
    --basevardir=DIR            path to the writable data files ($self->{basevardir})
    --share-dir=DIR             path to the read-only data files ($self->{'share-dir'})
    --conf-file=FILE            path to an alternative config file ($self->{'conf-file'})
    --disable-perllib-envvar    do not load Perl lib from PERL5LIB and PERLIB environment variable ($self->{'disable-perllib-envvar'})
    --devlib                    search for Backend modules in ./lib only ($self->{devlib})

Execution mode options
    -d --daemon                 run the agent as a daemon ($self->{daemon})
    -D --daemon-no-fork         run the agent as a daemon but don't fork in background ($self->{'daemon-no-fork'})
    -i --info                   verbose mode ($self->{info})
    --debug                     debug mode ($self->{debug})
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
