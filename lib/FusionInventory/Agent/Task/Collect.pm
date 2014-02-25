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
use FusionInventory::Agent::HTTP::Client::Fusion;
use FusionInventory::Agent::Logger;
use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Recipient::Stdout;

our $VERSION = $FusionInventory::Agent::VERSION;

my %functions = (
    getFromRegistry => \&_getFromRegistry,
    findFile        => \&_findFile,
# As decided by the FusInv-Agent developers, the runCommand function
# is disabled for the moment.
#    runCommand      => \&_runCommand,
    getFromWMI      => \&_getFromWMI
);

sub getConfiguration {
    my ($self, %params) = @_;

    my $response = $params{response};
    if (!$response) {
        $self->{logger}->debug("Task not compatible with a local controller");
        return;
    }

    my $client = FusionInventory::Agent::HTTP::Client::Fusion->new(
        logger       => $self->{logger},
        user         => $params{user},
        password     => $params{password},
        proxy        => $params{proxy},
        ca_cert_file => $params{ca_cert_file},
        ca_cert_dir  => $params{ca_cert_dir},
        no_ssl_check => $params{no_ssl_check},
    );

    my $remoteConfig = $client->send(
        url  => $params{controller}->getUrl(),
        args => {
            action    => "getConfig",
            machineid => $params{deviceid},
            task      => { Collect => $VERSION },
        }
    );

    my $schedule = $remoteConfig->{schedule};
    return unless $schedule;
    return unless ref $schedule eq 'ARRAY';

    my @remotes =
        grep { $_ }
        map  { $_->{remote} }
        grep { $_->{task} eq "Collect" }
        @{$schedule};

    if (!@remotes) {
        $self->{logger}->debug("Task not scheduled");
        return;
    }

    my $jobs = $client->send(
        url  => $remotes[-1],
        args => {
            action    => "getJobs",
            machineid => $params{deviceid}
        }
    );

    if (!$jobs) {
        $self->{logger}->error("No host in the server request");
        return;
    }

    if (ref $jobs->{jobs} ne 'ARRAY') {
        $self->{logger}->error("Invalid server request format");
        return;
    }

    return (
        url  => $remotes[-1],
        jobs => $jobs->{jobs}
    );
}

sub run {
    my ($self, %params) = @_;

    $self->{logger}->info("Running Collect task");

    my @jobs = @{$self->{config}->{jobs}};
    if (!@jobs) {
        $self->{logger}->error("no VMware host(s) given, aborting");
        return;
    }
    $self->{logger}->debug(
        "got " . scalar @jobs . " collect order(s)"
    );

    my $recipient =
        $params{recipient} ||
        FusionInventory::Agent::Recipient::Stdout->new();

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
            $self->{logger}->error("Bad function `$job->{function}'");
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
            $recipient->send(
                url      => $self->{config}->{url},
                filename => sprintf('collect_%s_%s.js', $job->{uuid}, $count),
                message  => $result
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
