package FusionInventory::Agent::Task::Collect;

use strict;
use warnings;
use base 'FusionInventory::Agent::Task';

use FusionInventory::Agent::HTTP::Client::Fusion;
use FusionInventory::Agent::Logger;
use FusionInventory::Agent::Tools;

use English qw(-no_match_vars);
use File::Find;
use File::stat;
use File::Basename;
use Digest::SHA;

our $VERSION = "0.0.1";

sub isEnabled {
    my ($self) = @_;

    return $self->{target}->isa('FusionInventory::Agent::Target::Server');
}

sub _getFromRegistry {
    my %params = @_;

    return unless $OSNAME eq 'MSWin32';

    FusionInventory::Agent::Tools::Win32->require();

    my $values = FusionInventory::Agent::Tools::Win32::getRegistryValues(path => $params{path});

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
    my %params = @_;

    my $dir   = $params{dir}   || '/';
    my $limit = $params{limit} || 50;

    return unless -d $dir;

    my @result;

    my $dirCpt;
    File::Find::find(
        {
            preprocess => sub {
                if (!$params{recursive}) {
                  $dirCpt++;
                  return if $dirCpt > 1;
               }
               return @_;
            },
            wanted => sub {
#                    print $File::Find::name."\n";
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
#                print "name: $File::Find::name\n";
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
                    return if $sha->hexdigest ne $params{filter}{checkSumSHA2};
                }

                push @result,
                  {
                    size => $size,
                    path => $File::Find::name
                  };
                goto DONE if @result >= $limit;
            },
            no_chdir => 1

        },
        $dir
    );
  DONE:

    return @result;
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

    FusionInventory::Agent::Tools::Win32->require();

    return unless $params{properties};
    return unless $params{class};

    my @return;

    my @objs = FusionInventory::Agent::Tools::Win32::getWmiObjects(%params);

    foreach my $obj (@objs) {
        push @return, $obj; 
    }

    return @return;
}


my %functions = (
    getFromRegistry => \&_getFromRegistry,
    findFile        => \&_findFile,
    runCommand      => \&_runCommand,
    getFromWMI      => \&_getFromWMI
);

sub run {
    my ( $self, %params ) = @_;

    $self->{logger}->debug("FusionInventory Collect task $VERSION");

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
    die unless $self->{client};

    my $globalRemoteConfig = $self->{client}->send(
        "url" => $self->{target}->{url},
        args  => {
            action    => "getConfig",
            machineid => $self->{deviceid},
            task      => { Collect => $VERSION },
        }
    );

    return unless $globalRemoteConfig->{schedule};
    return unless ref( $globalRemoteConfig->{schedule} ) eq 'ARRAY';

    foreach my $job ( @{ $globalRemoteConfig->{schedule} } ) {
        next unless $job->{task} eq "Collect";
        $self->{collectRemote} = $job->{remote};
    }
    if ( !$self->{collectRemote} ) {
        $self->{logger}->info("Collect support disabled server side.");
        return;
    }

    my $jobs = $self->{client}->send(
        "url" => $self->{collectRemote},
        args  => {
            action    => "getJobs",
            machineid => $self->{deviceid}
        }
    );

#    $jobs = [ 
#{
#      "function" => "getFromWMI",
#      "class" => "Win32_Keyboard",
#      "properties" => [ "Name", "Caption", "Manufacturer", "Description", "Layout" ],
#      "uuid" => "xxxx3"
#},
#        {
#            "function" => "runCommand",
#            "dir"      => "/",                # Where to run the command
#            "command"  => "ipconfig",
#            "uuid"     => "xxxx3",
#            "filter" => { "firstMatch" => '(Windows.*)' }
#        },
#        {
#            "recursive" => 0,
#            "function"  => "getFromRegistry",
#            "64bit"     => 0,
#            "path" =>
#"HKEY_LOCAL_MACHINE/SOFTWARE/FusionInventory-Agent/*",
#            "uuid" => "xxxx1"
#        },
#        {
#            "function" => "findFile",
#            "dir"      => "/windows",       # Default is, every where
#            "limit"     => 5,    # Number of entry to look for, default is 50
#            "recursive" => 0,
#            "filter" =>          # filter and its content is optional
#              {
#                regex => 'fs',    # regex done on the full path
#
#                #                    sizeEquals     => 445635,
#                sizeGreater => 3,
#                sizeLower   => 12454545656,
#                checkSumSHA512 =>
#'558d4e78bff78241c25bc3cb45b700ae9a29552a1439f9b07420ba54313f03e1f5883b099984a94955adbc3c21bcbd7c8194d70c494cfcd5d83e21adc3e58ab9',
#                name  => 'fstab',
#                iname => 'FStab'    # case insensitive
#              },
#            "uuid" => "xxxx3"
#
#        }

#    ];

    return unless $jobs;
    return unless ref($jobs) eq 'ARRAY';

    $self->{logger}->info( "Got " . int( @{$jobs} ) . " collect order(s)." );

    foreach my $job (@$jobs) {
        if ( !$job->{uuid} ) {
            $self->{logger}->error("UUID key missing");
            next;
        }

        if ( !defined( $functions{ $job->{function} } ) ) {
            $self->{logger}->error("Bad function `$job->{function}'");
            next;
        }

        my @result = &{ $functions{ $job->{function} } }(%$job);

        next unless @result;

        foreach my $r (@result) {
            next unless ref($r) eq 'HASH';
            next unless keys %$r;
            $r->{uuid}   = $job->{uuid};
            $r->{action} = "setAnswer";
            $self->{client}->send(
                url  => $self->{collectRemote},
                args => $r
            );

        }

    }

    return $self;
}

1;
