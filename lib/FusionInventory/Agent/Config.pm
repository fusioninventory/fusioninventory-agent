package FusionInventory::Agent::Config;

use strict;
use warnings;

use English qw(-no_match_vars);
use File::Spec;

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
    'force'                   => 0,
    'help'                    => 0,
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
    my ($class, %params) = @_;

    my $self = $default;
    bless $self, $class;

    $self->_loadDefaults();

    if ($OSNAME eq 'MSWin32') {
        $self->_loadFromWinRegistry();
    } else {
        $self->_loadFromCfgFile(%params);
    }

    $self->_checkContent();

    return $self;
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
    my ($self, %params) = @_;

    my $file = $params{file} || $params{directory} . '/agent.cfg';

    die "non-existing file $file" unless -f $file;
    die "non-readable file $file" unless -r $file;

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

sub _checkContent {
    my ($self) = @_;

    # if a logfile is defined, add file logger
    if ($self->{logfile}) {
        $self->{logger} .= ',File'
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
