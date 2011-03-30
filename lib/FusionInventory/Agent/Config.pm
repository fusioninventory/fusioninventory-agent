package FusionInventory::Agent::Config;

use strict;
use warnings;

use English qw(-no_match_vars);
use File::Spec;
use Getopt::Long;

my $default = {
    'logger'                  => 'Stderr',
    'logfacility'             => 'LOG_USER',
    'delaytime'               => 3600,
    'backend-collect-timeout' => 180,
    'rpc-port'                => 62354,
};

my $deprecated = {
    'info' => {
        message => 'it was useless anyway'
    },
    'realm' => {
        message => 'it is now useless'
    },
    'no-socket' => {
        message => 'use --no-httpd option instead',
        new     => 'no-httpd'
    },
    'rpc-ip' => {
        message => 'use --httpd-ip option instead',
        new     => 'httpd-ip'
    },
    'rpc-port' => {
        message => 'use --httpd-port option instead',
        new     => 'httpd-port'
    },
    'rpc-trust-localhost' => {
        message => 'use --httpd-trust-localhost option instead',
        new     => 'httpd-trust-localhost'
    },
    'daemon-no-fork' => {
        message => 'use --daemon and --no-fork options instead',
        new     => [ 'daemon', 'no-fork' ]
    },
};

sub new {
    my ($class, $params) = @_;

    my $self = {};
    bless $self, $class;
    $self->loadDefaults();

    if ($OSNAME eq 'MSWin32') {
        $self->loadFromWinRegistry();
    } else {
        $self->loadFromCfgFile({
            file      => $params->{options}->{'conf-file'},
            directory => $params->{confdir},
        });
    }
    $self->loadUserParams($params->{options});

    $self->checkContent();


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
    my ($self, $params) = @_;

    my $file = $params->{file} ?
        $params->{file} : $params->{directory} . '/agent.cfg';

    if ($file) {
        die "non-existing file $file" unless -f $file;
        die "non-readable file $file" unless -r $file;
    } else {
        die "no configuration file";
    }

    my $handle;
    if (!open $handle, '<', $file) {
        warn "Config: Failed to open $file: $ERRNO";
        return;
    }

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
    my ($self, $params) = @_;

    foreach my $key (keys %$params) {
        $self->{$key} = $params->{$key};
    }
}

sub checkContent {
    my ($self) = @_;

    # check for deprecated options
    foreach my $old (keys %$deprecated) {
        next unless defined $self->{$old};

        my $handler = $deprecated->{$old};

        # notify user of deprecation
        print STDERR "the --$old option is deprecated, $handler->{message}\n";

        # transfer the value to the new option, if possible
        if ($handler->{new}) {
            if (ref $handler->{new} eq 'ARRAY') {
                foreach my $new (@{$handler->{new}}) {
                    $self->{$new} = $self->{$old};
                }
            } else {
                $self->{$handler->{new}} = $self->{$old};
            }
        }

        # avoid cluttering configuration
        delete $self->{$old};
    }

    # a logfile options implies a file logger backend
    if ($self->{logfile}) {
        $self->{logger} .= ',File';
    }

    # multi-values options
    $self->{logger} = [ split(/,/, $self->{logger}) ] if $self->{logger};
    $self->{server} = [ split(/,/, $self->{server}) ] if $self->{server};

    # files location
    $self->{'ca-cert-file'} =
        File::Spec->rel2abs($self->{'ca-cert-file'}) if $self->{'ca-cert-file'};
    $self->{'ca-cert-dir'} =
        File::Spec->rel2abs($self->{'ca-cert-dir'}) if $self->{'ca-cert-dir'};
    $self->{'logfile'} =
        File::Spec->rel2abs($self->{'logfile'}) if $self->{'logfile'};
}


1;
