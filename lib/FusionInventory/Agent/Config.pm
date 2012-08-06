package FusionInventory::Agent::Config;

use strict;
use warnings;

use English qw(-no_match_vars);
use File::Spec;
use Getopt::Long;
use UNIVERSAL::require;

my $default = {
    'logger'                  => 'Stderr',
    'logfacility'             => 'LOG_USER',
    'delaytime'               => 3600,
    'backend-collect-timeout' => 30,
    'httpd-port'              => 62354,
    'timeout'                 => 180,
    'no-task'                 => [],
    'no-category'             => []
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
        message => 'use --httpd-trust 127.0.0.1 option instead',
        new     => { 'httpd-trust' => '127.0.0.1' }
    },
    'daemon-no-fork' => {
        message => 'use --daemon and --no-fork options instead',
        new     => [ 'daemon', 'no-fork' ]
    },
    'D' => {
        message => 'use --daemon and --no-fork options instead',
        new     => [ 'daemon', 'no-fork' ]
    },
    'no-inventory' => {
        message => 'use --no-task inventory option instead',
        new     => { 'no-task' => 'inventory' }
    },
    'no-wakeonlan' => {
        message => 'use --no-task wakeonlan option instead',
        new     => { 'no-task' => 'wakeonlan' }
    },
    'no-netdiscovery' => {
        message => 'use --no-task netdiscovery option instead',
        new     => { 'no-task' => 'netdiscovery' }
    },
    'no-snmpquery' => {
        message => 'use --no-task snmpquery option instead',
        new     => { 'no-task' => 'snmpquery' }
    },
    'no-ocsdeploy' => {
        message => 'use --no-task ocsdeploy option instead',
        new     => { 'no-task' => 'ocsdeploy' }
    },
    'no-printer' => {
        message => 'use --no-category printer option instead',
        new     => { 'no-category' => 'printer' }
    },
    'no-software' => {
        message => 'use --no-category software option instead',
        new     => { 'no-category' => 'software' }
    },
};

sub new {
    my ($class, %params) = @_;

    my $self = {};
    bless $self, $class;
    $self->_loadDefaults();

    my $backend =
        $params{options}->{'conf-file'} ? 'file'                     :
        $params{options}->{config}      ? $params{options}->{config} :
        $OSNAME eq 'MSWin32'            ? 'registry'                 :
                                          'file';

    SWITCH: {
        if ($backend eq 'registry') {
            die "Unavailable configuration backend\n"
                unless $OSNAME eq 'MSWin32';
            $self->_loadFromRegistry();
            last SWITCH;
        }

        if ($backend eq 'file') {
            $self->_loadFromFile({
                file      => $params{options}->{'conf-file'},
                directory => $params{confdir},
            });
            last SWITCH;
        }

        if ($backend eq 'none') {
            last SWITCH;
        }

        die "Unknown configuration backend '$backend'\n";
    }

    $self->_loadUserParams($params{options});

    $self->_checkContent();

    return $self;
}

sub _loadDefaults {
    my ($self) = @_;

    foreach my $key (keys %$default) {
        $self->{$key} = $default->{$key};
    }
}

sub _loadFromRegistry {
    my ($self) = @_;

    my $Registry;
    Win32::TieRegistry->require();
    Win32::TieRegistry->import(
        Delimiter   => '/',
        ArrayValues => 0,
        TiedRef     => \$Registry
    );

    my $machKey = $Registry->Open('LMachine', {
        Access => Win32::TieRegistry::KEY_READ()
    }) or die "Can't open HKEY_LOCAL_MACHINE key: $EXTENDED_OS_ERROR";

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

sub _loadFromFile {
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

    while (my $line = <$handle>) {
        $line =~ s/#.+//;
        if ($line =~ /([\w-]+)\s*=\s*(.+)/) {
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
    my ($self, $params) = @_;

    foreach my $key (keys %$params) {
        $self->{$key} = $params->{$key};
    }
}

sub _checkContent {
    my ($self) = @_;

    # check for deprecated options
    foreach my $old (keys %$deprecated) {
        next unless defined $self->{$old};

        my $handler = $deprecated->{$old};

        # notify user of deprecation
        print STDERR "the '$old' option is deprecated, $handler->{message}\n";

        # transfer the value to the new option, if possible
        if ($handler->{new}) {
            if (ref $handler->{new} eq 'HASH') {
                # list of new options with new values
                foreach my $key (keys %{$handler->{new}}) {
                    $self->{$key} = $self->{$key} ?
                        $self->{$key} . ',' . $handler->{new}->{$key} :
                        $handler->{new}->{$key};
                }
            } elsif (ref $handler->{new} eq 'ARRAY') {
                # list of new options, with same value
                foreach my $new (@{$handler->{new}}) {
                    $self->{$new} = $self->{$old};
                }
            } else {
                # new option, with same value
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
    $self->{'no-task'} = [ split(/,/, $self->{'no-task'}) ];
    $self->{'no-category'} = [ split(/,/, $self->{'no-category'}) ];

    # files location
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

=head2 new(%params)

The constructor. The following parameters are allowed, as keys of the %params
hash:

=over

=item I<confdir>

the configuration directory.

=item I<options>

additional options override.
