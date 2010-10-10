package FusionInventory::Agent::Config;

use strict;
use warnings;

use Getopt::Long;
use English qw(-no_match_vars);
use File::Spec;
use Pod::Usage;

my $basedir = $OSNAME eq 'MSWin32' ?
    $ENV{APPDATA}.'/fusioninventory-agent' : '';

my $default = {
    'backend-collect-timeout' => 180,   # timeOut of process : see Backend.pm
    'basevardir'              => $basedir . '/var/lib/fusioninventory-agent',
    'ca-cert-dir'             => '',
    'ca-cert-file'            => '',
    'conf-file'               => '',
    'color'                   => 0,
    'daemon'                  => 0,
    'no-fork'                 => 0,
    'delaytime'               => 3600, # max delay time (seconds)
    'debug'                   => 0,
    'devlib'                  => 0,
    'force'                   => 0,
    'help'                    => 0,
    'html'                    => 0,
    'format'                  => 'xml',
    'info'                    => 1,
    'lazy'                    => 0,
    'local'                   => '',
    'logger'                  => undef,
    'logfile'                 => '',
    'logfile-maxsize'         => 0,
    'logfacility'             => 'LOG_USER',
    'no-ocsdeploy'            => 0,
    'no-inventory'            => 0,
    'no-printer'              => 0,
    'no-www'                  => 0,
    'no-software'             => 0,
    'no-wakeonlan'            => 0,
    'no-snmpquery'            => 0,
    'no-netdiscovery'         => 0,
    'no-ssl-check'            => 0,
    'password'                => '',
    'proxy'                   => '',
    'realm'                   => '',
    'share-dir'               => 0,
    'server'                  => undef,
    'stdout'                  => 0,
    'tag'                     => '',
    'user'                    => '',
    'version'                 => 0,
    'wait'                    => '',
    'scan-homedirs'           => 0,
    'www-ip'                  => undef,
    'www-port'                => '62354',
    'www-trust-localhost'     => 1
};

sub new {
    my ($class, $params) = @_;

    my $self = $default;
    bless $self, $class;

    $self->_loadDefaults();

    if ($OSNAME eq 'MSWin32') {
        $self->_loadFromWinRegistry();
    } else {
        $self->_loadFromCfgFile();
    }

    $self->_loadUserParams();
    $self->_loadCallerParams($params) if $params;

    $self->_checkContent();

    return $self;
}

sub _loadDefaults {
    my ($self) = @_;

    foreach my $key (keys %$default) {
        $self->{$key} = $default->{$key};
    }
}

sub _loadCallerParams {
    my ($self, $params) = @_;

    foreach my $key (keys %$params) {
        $self->{$key} = $params->{$key};
    }
}

sub _loadFromWinRegistry {
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

sub _loadFromCfgFile {
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

sub _loadUserParams {
    my ($self) = @_;

    Getopt::Long::Configure( "no_ignorecase" );

    my @options = (
        'backend-collect-timeout=s',
        'basevardir=s',
        'ca-cert-dir=s',
        'ca-cert-file=s',
        'conf-file=s',
        'daemon|d',
        'daemon-no-fork|D',
        'no-fork',
        'debug',
        'delaytime=s',
        'devlib',
        'force|f',
        'format=s',
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
        'no-www',
        'no-soft',
        'no-software',
        'no-ssl-check',
        'no-wakeonlan',
        'no-snmpquery',
        'no-netdiscovery',
        'password|p=s',
        'proxy|P=s',
        'realm|r=s',
        'rpc-ip=s',
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
        'www-ip=s',
        'www-port=s',
        'www-trust-localhost',
    );

    push(@options, 'color') if $OSNAME ne 'MSWin32';

    GetOptions(
        $self,
        @options
    ) or pod2usage(-verbose => 0);

}

sub _checkContent {
    my ($self) = @_;

    # if a logfile is defined, add file logger
    if ($self->{logfile}) {
        $self->{logger} .= ',File'
    }

    if ($self->{realm}) {
        print STDERR
            "the parameter --realm is deprecated, and will be ignored\n";
    }

    if (defined $self->{'no-socket'}) {
        print STDERR
            "the parameter --no-socket is deprecated, use --no-www instead\n";
        $self->{'no-www'} = $self->{'no-socket'};
    }

    if (defined $self->{'rpc-ip'}) {
        print STDERR
            "the parameter --rpc-ip is deprecated, use --www-ip instead\n";
        $self->{'www-ip'} = $self->{'rpc-ip'};
    }

    if (defined $self->{'rpc-trust-localhost'}) {
        print STDERR
            "the parameter --rpc-trust-localhost is deprecated, use --www-trust-localhost instead\n";
        $self->{'www-trust-localhost'} = $self->{'rpc-trust-localhost'};
    }

    if ($self->{'daemon-no-fork'}) {
        print STDERR
            "the parameter --daemon-no-fork is deprecated, use --daemon --no-fork instead\n";
        $self->{daemon} = 1;
        $self->{'no-fork'} = 1;
    }

    if ($self->{html}) {
        print STDERR
            "the parameter --html is deprecated, use --format html instead\n";
        $self->{format} = 'html';
    }

    # multi-valued attributes
    if ($self->{server}) {
        $self->{server} = [
            split(/\s*,\s*/, $self->{server})
        ];
    }

    if ($self->{logger}) {
        my %seen;
        $self->{logger} = [
            grep { !$seen{$_}++ }
            split(/\s*,\s*/, $self->{logger})
        ];
    }

    if ($self->{'share-dir'}) {
        $self->{'share-dir'} = File::Spec->rel2abs($self->{'share-dir'});
    } else {
        if ($self->{devlib}) {
            $self->{'share-dir'} = File::Spec->rel2abs('./share/');
        } else {
            eval { 
                require File::ShareDir;
                $self->{'share-dir'} =
                    File::ShareDir::dist_dir('FusionInventory-Agent');
            };
        }
    }

    # We want only canonical path
    $self->{basevardir} =
        File::Spec->rel2abs($self->{basevardir}) if $self->{basevardir};
    $self->{'conf-file'} =
        File::Spec->rel2abs($self->{'conf-file'}) if $self->{'conf-file'};
    $self->{'ca-cert-file'} =
        File::Spec->rel2abs($self->{'ca-cert-file'}) if $self->{'ca-cert-file'};
    $self->{'ca-cert-dir'} =
        File::Spec->rel2abs($self->{'ca-cert-dir'}) if $self->{'ca-cert-dir'};
    $self->{'logfile'} =
        File::Spec->rel2abs($self->{'logfile'}) if $self->{'logfile'};
}

1;

__END__

=head1 NAME

FusionInventory::Agent::Config - Agent configuration

=head1 DESCRIPTION

This is the object used by the agent to store its configuration.

=head1 METHODS

=head2 new($params)

The constructor. All configuration parameters can be passed.
