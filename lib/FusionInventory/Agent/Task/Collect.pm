package FusionInventory::Agent::Task::Collect;

use strict;
use warnings;
use base 'FusionInventory::Agent::Task';

use Digest::SHA;
use English qw(-no_match_vars);
use File::Basename;
use File::Find;
use File::stat;

use FusionInventory::Agent;
use FusionInventory::Agent::Logger;
use FusionInventory::Agent::Tools;

our $VERSION = $FusionInventory::Agent::VERSION;

my %functions = (
    getFromRegistry => \&_getFromRegistry,
    findFile        => \&_findFile,
# As decided by the FusInv-Agent developers, the runCommand function
# is disabled for the moment.
#    runCommand      => \&_runCommand,
    getFromWMI      => \&_getFromWMI
);

# How to validate JSON for retreived jobs
sub _OPTIONAL  { 0 }
sub _MANDATORY { 1 }
sub _OPTIONAL_EXCLUSIVE { 2 }
my %json_validation = (
    getFromRegistry => {
        path   => _MANDATORY
    },
    findFile => {
        dir       => _MANDATORY,
        limit     => _MANDATORY,
        recursive => _MANDATORY,
        filter    => {
            regex          => _OPTIONAL,
            sizeEquals     => _OPTIONAL,
            sizeGreater    => _OPTIONAL,
            sizeLower      => _OPTIONAL,
            checkSumSHA512 => _OPTIONAL,
            checkSumSHA2   => _OPTIONAL,
            name           => _OPTIONAL,
            iname          => _OPTIONAL,
            is_file        => _MANDATORY,
            is_dir         => _MANDATORY
        }
    },
    getFromWMI => {
        class      => _MANDATORY,
        properties => _MANDATORY
    }
);

sub isEnabled {
    my ($self) = @_;

    if (!$self->{target}->isa('FusionInventory::Agent::Target::Server')) {
        $self->{logger}->debug("ESX task not compatible with local target");
        return;
    }

    return 1;
}

sub _validateSpec {
    my ($self, $base, $key, $spec) = @_;

    if (ref($spec) eq 'HASH') {
        if (!exists($base->{$key})) {
            $self->{logger}->debug("$key mandatory values are missing in job");
            return 0;
        }
        $self->{logger}->debug("$key mandatory values are present in job");
        foreach my $attribute (keys(%{$spec})) {
            return 0 unless $self->_validateSpec($base->{$key}, $attribute, $spec->{$attribute});
        }
        return 1;
    }

    if ($spec == _MANDATORY) {
        if (!exists($base->{$key})) {
            $self->{logger}->debug("$key mandatory value is missing in job");
            return 0;
        }
        $self->{logger}->debug("$key mandatory value is present in job with value '".$base->{$key}."'");
        return 1;
    }

    if ($spec == _OPTIONAL && exists($base->{$key})) {
        $self->{logger}->debug("$key optional value is present in job with value '".$base->{$key}."'");
    }

    1;
}

sub _validateAnswer {
    my ($self, $msgRef, $answer) = @_;

    $$msgRef = "";

    if (!defined($answer)) {
        $$msgRef = "No answer from server.";
        return;
    }

    if (ref($answer) ne 'HASH') {
        $$msgRef = "Bad answer from server. Not a hash reference.";
        return;
    }

    if (!defined($answer->{jobs})) {
        $$msgRef = "missing jobs key";
        return;
    }

    foreach my $job (@{$answer->{jobs}}) {

        foreach (qw/uuid function/) {
            if (!defined($job->{$_})) {
                $$msgRef = "Missing key '$_' in job";
                return;
            }
        }

        my $function = $job->{function};
        if (!exists($functions{$function})) {
            $$msgRef = "not supported 'function' key value in job";
            return;
        }

        if (!exists($json_validation{$function})) {
            $$msgRef = "can't validate job";
            return;
        }

        foreach my $attribute (keys(%{$json_validation{$function}})) {
            if (!$self->_validateSpec( $job, $attribute, $json_validation{$function}->{$attribute} )) {
                $$msgRef = "'$function' job JSON format is not valid";
                return;
            }
        }
    }

    return 1;
}

sub getConfiguration {
    my ($self, %params) = @_;

    my $config = $params{spec}->{config};

    return (
        jobs => $config->{jobs}
    );
}

sub run {
    my ($self, %params) = @_;

    $self->{client} = FusionInventory::Agent::HTTP::Client::Fusion->new(
        logger       => $self->{logger},
        user         => $params{user},
        password     => $params{password},
        proxy        => $params{proxy},
        ca_cert_file => $params{ca_cert_file},
        ca_cert_dir  => $params{ca_cert_dir},
        no_ssl_check => $params{no_ssl_check},
        debug        => $self->{debug}
    );

    my $globalRemoteConfig = $self->{client}->send(
        url  => $self->{target}->{url},
        args => {
            action    => "getConfig",
            machineid => $self->{deviceid},
            task      => { Collect => $VERSION },
        }
    );

    return unless $globalRemoteConfig->{schedule};
    return unless ref( $globalRemoteConfig->{schedule} ) eq 'ARRAY';

    foreach my $job ( @{ $globalRemoteConfig->{schedule} } ) {
        next unless $job->{task} eq "Collect";
        $self->processRemote($job->{remote});
    }

    return 1;
}

sub processRemote {
    my ($self, $remoteUrl) = @_;

    if ( !$remoteUrl ) {
        return;
    }

    my $answer = $self->{client}->send(
        url  => $remoteUrl,
        args => {
            action    => "getJobs",
            machineid => $self->{deviceid},
        }
    );

    if (ref($answer) eq 'HASH' && !keys %$answer) {
        $self->{logger}->debug("Nothing to do");
        return;
    }

    my $msg;
    if (!$self->_validateAnswer(\$msg, $answer)) {
        $self->{logger}->debug("bad JSON: ".$msg);
        return;
    }

    my @jobs = @{$answer->{jobs}}
        or die "no jobs provided, aborting";

    foreach my $job (@jobs) {
        if ( !$job->{uuid} ) {
            $self->{logger}->error("UUID key missing");
            next;
        }

        if ( !$job->{function} ) {
            $self->{logger}->error("function key missing");
            next;
        }

        if ( !defined( $functions{ $job->{function} } ) ) {
            $self->{logger}->error("Bad function '$job->{function}'");
            next;
        }

        my @results = &{ $functions{ $job->{function} } }(%$job);

        my $count = int(@results);
        foreach my $result (@results) {
            next unless ref($result) eq 'HASH';
            next unless keys %$result;
            $result->{uuid}   = $job->{uuid};
            $result->{action} = "setAnswer";
            $result->{_cpt}   = $count;
            $self->{client}->send(
               url      => $remoteUrl,
               filename => sprintf('collect_%s_%s.js', $job->{uuid}, $count),
               args     => $result
            );
            $count--;
        }
    }

    return $self;
}

sub _getFromRegistry {
    my %params = @_;

    return unless FusionInventory::Agent::Tools::Win32->require();

    my $values = FusionInventory::Agent::Tools::Win32::getRegistryValues(path => $params{path});

    return unless $values;

    my $result;
    if (ref($values) eq 'HASH') { # I don't like that. We should always get href
        foreach my $k (keys %$values) {
            my $v = FusionInventory::Agent::Tools::Win32::encodeFromRegistry($values->{$k});
            $result->{$k}=$v;
        }
    }

    return ($result);
}

sub _findFile {
    my %params = (
        dir => '/',
        limit => 50
        , @_);

    return unless -d $params{dir};

    my @results;

    File::Find::find(
        {
            wanted => sub {
                if (!$params{recursive} && $File::Find::name ne $params{dir}) {
                    $File::Find::prune = 1  # Don't recurse.
                }


                if (   $params{filter}{is_dir}
                    && !$params{filter}{checkSumSHA512}
                    && !$params{filter}{checkSumSHA2} )
                {
                    return unless -d $File::Find::name;
                }

                if ( $params{filter}{is_file} ) {
                    return unless -f $File::Find::name;
                }

                my $filename = basename($File::Find::name);

                if ( $params{filter}{name} ) {
                    return if $filename ne $params{filter}{name};
                }

                if ( $params{filter}{iname} ) {
                    return if lc($filename) ne lc( $params{filter}{iname} );
                }

                if ( $params{filter}{regex} ) {
                    my $re = qr($params{filter}{regex});
                    return unless $File::Find::name =~ $re;
                }

                my $st   = stat($File::Find::name);
                my $size = $st->size;
                if ( $params{filter}{sizeEquals} ) {
                    return unless $size == $params{filter}{sizeEquals};
                }

                if ( $params{filter}{sizeGreater} ) {
                    return if $size < $params{filter}{sizeGreater};
                }

                if ( $params{filter}{sizeLower} ) {
                    return if $size > $params{filter}{sizeLower};
                }

                if ( $params{filter}{checkSumSHA512} ) {
                    my $sha = Digest::SHA->new('512');
                    $sha->addfile( $File::Find::name, 'b' );
                    return
                        if $sha->hexdigest ne $params{filter}{checkSumSHA512};
                }

                if ( $params{filter}{checkSumSHA2} ) {
                    my $sha = Digest::SHA->new('2');
                    $sha->addfile( $File::Find::name, 'b' );
                    return
                        if $sha->hexdigest ne $params{filter}{checkSumSHA2};
                }

                push @results, {
                    size => $size,
                    path => $File::Find::name
                };
                goto DONE if @results >= $params{limit};
            },
            no_chdir => 1

        },
        $params{dir}
    );
    DONE:

    return @results;
}

sub _runCommand {
    my %params = @_;

    my $line;

    if ( $params{filter}{firstMatch} ) {
        $line = getFirstMatch(
            command => $params{command},
            pattern => $params{filter}{firstMatch}
        );
    }
    elsif ( $params{filter}{firstLine} ) {
        $line = getFirstLine( command => $params{command} );

    }
    elsif ( $params{filter}{lineCount} ) {
        $line = getLinesCount( command => $params{command} );
    }
    else {
        $line = getAllLines( command => $params{command} );

    }

    return ( { output => $line } );
}

sub _getFromWMI {
    my %params = @_;

    return unless FusionInventory::Agent::Tools::Win32->require();

    return unless $params{properties};
    return unless $params{class};

    my @results;

    my @objects = FusionInventory::Agent::Tools::Win32::getWMIObjects(%params);
    foreach my $object (@objects) {
        push @results, $object;
    }

    return @results;
}

1;
