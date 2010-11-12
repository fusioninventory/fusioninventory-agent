package FusionInventory::Agent::Config;

use strict;
use warnings;

use English qw(-no_match_vars);
use File::Spec;
use Getopt::Long;
use Pod::Usage;

use POE;

my $default = {
    'backend-collect-timeout' => 180,   # timeOut of process : see Backend.pm
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
    'server'                  => undef,
    'service'                 => 0,
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
    my ($class, $confdir) = @_;

    my $self = $default;
    bless $self, $class;

    $self->_loadDefaults();

    if ($OSNAME eq 'MSWin32') {
        $self->_loadFromWinRegistry();
    } else {
        $self->_loadFromCfgFile($confdir);
    }

    $self->_loadUserParams();

    $self->_checkContent();


    return $self;
}

sub createSession {
    my ($self) = @_;


    POE::Session->create(
        inline_states => {
            _start        => sub {
                $_[KERNEL]->alias_set('config');
            },
            get => sub {
                my ($kernel, $heap, $args) = @_[KERNEL, HEAP, ARG0, ARG1];
                my $key = $args->[0];
                my $rsvp = $args->[1];
#print "p: $p\n";
#print "v: ".$self->{$p}."\n";
                $kernel->call(IKC => post => $rsvp, $self->{$key});

            },
        }
    );

}

sub _loadDefaults {
    my ($self) = @_;

    foreach my $key (keys %$default) {
        $self->{$key} = $default->{$key};
    }
}

sub _loadFromWinRegistry {
    my ($self) = @_;

    my $Registry;
    eval {
        require Encode;
        Encode->import('encode');
        require Win32::TieRegistry;
        Win32::TieRegistry->import(
            Delimiter   => "/",
            ArrayValues => 0,
            TiedRef     => \$Registry
        );
    };
    if ($EVAL_ERROR) {
        print "[error] $EVAL_ERROR";
        return;
    }

    my $machKey;
    {
        # Win32-specifics constants can not be loaded on non-Windows OS
        no strict 'subs'; ## no critics
        $machKey = $Registry->Open('LMachine', {
            Access => Win32::TieRegistry::KEY_READ
        } ) or die "Can't open HKEY_LOCAL_MACHINE key: $EXTENDED_OS_ERROR";
    }

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
    my ($self, $confdir) = @_;

    my $file;

    foreach my $arg (@ARGV) {
        if ($arg =~ /^--conf-file=(.+)$/) {
            $file = $1;
        } elsif ($arg =~ /^--conf-file$/) {
            $file = shift @ARGV;
        }
    }

    if ($file) {
        die "non-existing file $file" unless -f $file;
        die "non-readable file $file" unless -r $file;
    } else {
        # default configuration file
        $file = $confdir . '/agent.cfg';
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
        'server|s=s',
        'service',
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

    if ($self->{'no-socket'}) {
        print STDERR
            "the parameter --no-socket is deprecated, use --no-www instead\n";
        $self->{'no-www'} = $self->{'no-socket'};
    }

    if ($self->{'rpc-ip'}) {
        print STDERR
            "the parameter --rpc-ip is deprecated, use --www-ip instead\n";
        $self->{'www-ip'} = $self->{'rpc-ip'};
    }

    if ($self->{'rpc-trust-localhost'}) {
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
