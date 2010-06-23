package FusionInventory::Agent::Config;

use strict;
use warnings;

use Getopt::Long;
use English qw(-no_match_vars);

my $basedir = '';

if ($OSNAME eq 'MSWin32') {
    $basedir = $ENV{APPDATA}.'/fusioninventory-agent';
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
    'force'                   => 0,
    'help'                    => 0,
    'html-dir'                => '',
    'info'                    => 1,
    'lazy'                    => 0,
    'local'                   => '',
#   'logger'                  => 'Syslog,File,Stderr',
    'logger'                  => 'Stderr',
    'logfile'                 => '',
    'logfacility'             => 'LOG_USER',
    'password'                => '',
    'proxy'                   => '',
    'realm'                   => '',
    'remotedir'               => '/ocsinventory', # deprecated
    'server'                  => '',
    'stdout'                  => 0,
    'tag'                     => '',
    'user'                    => '',
    'version'                 => 0,
    'wait'                    => '',
#   'xml'                     => 0,
    'no-ocsdeploy'            => 0,
    'no-inventory'            => 0,
    'nosoft'                  => 0, # deprecated
    'no-printer'              => 0,
    'no-software'             => 0,
    'no-wakeonlan'            => 0,
    'no-snmpquery'            => 0,
    'no-netdiscovery'         => 0,
    'delaytime'               => 3600, # max delay time (seconds)
    'backend-collect-timeout' => 180,   # timeOut of process : see Backend.pm
    'no-ssl-check'            => 0,
    'scan-homedirs'           => 0,
    # Other values that can't be changed with the
    # CLI parameters
    'basevardir'              =>  $basedir.'/var/lib/fusioninventory-agent',
    'logdir'                  =>  $basedir.'/var/log/fusioninventory-agent',
#   'pidfile'                 =>  $basedir.'/var/run/ocsinventory-agent.pid',
};

sub new {
    my ($class) = @_;

    my $self = $default;
    bless $self, $class;

    $self->loadDefaults();

    if ($OSNAME eq 'MSWin32') {
        $self->loadFromWinRegistry();
    } else {
        $self->loadFromCfgFile();
    }

    $self->loadUserParams();

    return $self;
}

sub loadDefaults {
    my ($self) = @_;

    foreach my $key (keys %$default) {
        $self->{$key} = $default->{$key};
    }

    $self->{VERSION} = $FusionInventory::Agent::VERSION;
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

    my $machKey = $Win32::TieRegistry::Registry->Open(
        "LMachine", {
            Access    => Win32::TieRegistry::KEY_READ(),
            Delimiter => "/"
        }
    );
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
        'devlib',
        'force|f',
        'help|h',
        'html-dir=s',
        'info|i',
        'lazy',
        'local|l=s',
        'logfile=s',
        'no-ocsdeploy',
        'no-inventory',
        'no-soft',
        'no-printer',
        'no-software',
        'no-wakeonlan',
        'no-snmpquery',
        'no-netdiscovery',
        'password|p=s',
        'perl-bin-dir-in-path',
        'proxy|P=s',
        'realm|r=s',
        'rpc-ip=s',
        'rpc-trust-localhost',
        'remotedir|R=s',
        'server|s=s',
        'stdout',
        'tag|t=s',
        'no-ssl-check',
        'user|u=s',
        'version',
        'wait|w=s',
        'delaytime=s',
        'scan-homedirs',
        'no-socket'
    ) or $self->help();

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
        "the config found at $self->{'conf-file'}\n";
    }

    print STDERR <<EOF;

Usage:
    --backend-collect-timeout set a max delay time of one inventory data collect job ($self->{'backend-collect-timeout'})
    --basevardir=/path  indicate the directory where should the agent store its files ($self->{basevardir})
    --ca-cert-dir=D  SSL certificat directory ($self->{'ca-cert-dir'})
    --ca-cert-file=F SSL certificat file ($self->{'ca-cert-file'})
    --color         use color in the console ($self->{color})
    -d --daemon        detach the agent in background ($self->{daemon})
    -D --daemon-no-fork daemon but don't fork in background ($self->{'daemon-no-fork'})
    --debug         debug mode ($self->{debug})
    --delaytime     set a max delay time (in second) if no PROLOG_FREQ is set ($self->{delaytime})
    --devlib        search for Backend mod in ./lib only ($self->{devlib})
    -f --force          always send data to server (Don't ask before) ($self->{force})
    --html-dir       alternative directory where the static HTML are stored
    -i  --info           verbose mode ($self->{info})
    --no-socket      don't allow remote connexion ($self->{'no-socket'})
    --lazy           do not contact the server more than one time during the PROLOG_FREQ ($self->{lazy})
-l --local=DIR      do not contact server but write inventory in DIR directory in XML ($self->{local})
    --logfile=FILE   log message in FILE ($self->{logfile})
    --no-ocsdeploy   Do not deploy packages or run command ($self->{noocsdeploy})
    --no-inventory   Do not generate inventory ($self->{'no-inventory'})
    --no-ssl-check   do not check the SSL connexion with the server ($self->{'no-ssl-check'})
    --no-printer     do not return printer list in inventory $self->{'no-printer'})
    --no-software    do not return installed software list ($self->{'no-software'})
    --no-wakeonlan   do not use wakeonlan function ($self->{'no-wakeonlan'})

    -p --password=PWD   password for server auth
    -P --proxy=PROXY    proxy address. e.g: http://user:pass\@proxy:port ($self->{proxy})
    -r --realm=REALM    realm for server auth. e.g: 'Restricted Area' ($self->{realm})
    --rpc-ip=IP      ip of the interface to use for peer to peer exchange
    --rpc-trust-localhost      allow local users to http://127.0.0.1:62354/now to force an inventory
    --scan-homedirs  permit to scan home user directories ($self->{'scan-homedirs'})
    -s --server=uri     server uri ($self->{server})
    --stdout         do not write or post the inventory but print it on STDOUT
    -t --tag=TAG        use TAG as tag ($self->{tag}) Will be ignored by server if a value already exists.
    --version        print the version
    -w --wait=DURATION  wait during a random periode between 0 and DURATION seconds before contacting server ($self->{wait})

Manpage:
    See man fusioninventory-agent

FusionInventory-Agent is released under GNU GPL 2 license
EOF

    exit 1;
}

sub version {
    my ($self) = @_;

    print "FusionInventory Agent (".$FusionInventory::Agent::VERSION.")\n";
    exit 0;
}

1;
