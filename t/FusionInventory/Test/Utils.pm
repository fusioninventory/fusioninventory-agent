package FusionInventory::Test::Utils;

use strict;
use warnings;
use base 'Exporter';

use English qw(-no_match_vars);
use Socket;

use FusionInventory::Agent::Tools;

our @EXPORT = qw(
    test_port
    test_localhost
    mockGetWMIObjects
    mockGetRegistryKey
);

sub test_port {
    my ($port) = @_;

    my $iaddr = inet_aton('localhost');
    my $paddr = sockaddr_in($port, $iaddr);
    my $proto = getprotobyname('tcp');
    if (socket(my $socket, PF_INET, SOCK_STREAM, $proto)) {
        if (connect($socket, $paddr)) {
            close $socket;
            return 0;
        } 
    }

    return 1;
}

sub test_localhost {

    return inet_aton('localhost');
}

sub mockGetWMIObjects {
    my ($test) = @_;

    return sub {
        my (%params) = @_;

        my $file = "resources/win32/wmi/$test-$params{class}.wmi";
        return loadWMIDump($file, $params{properties});
    };
}

sub loadWMIDump {
    my ($file, $properties) = @_;

    open (my $handle, '<', $file) or die "can't open $file: $ERRNO";

    # this is a windows file
    binmode $handle, ':encoding(UTF-16LE)';
    local $INPUT_RECORD_SEPARATOR="\r\n";

    # build a list of desired properties indexes
    my %properties = map { $_ => 1 } @{$properties};

    my @objects;
    my $object;
    while (my $line = <$handle>) {
        chomp $line;

        if ($line =~ /^ (\w+) = (.+) $/x) {
            my $key = $1;
            my $value = $2;
            next unless $properties{$key};
            if ($value =~ /{(".*")}/) {
                # values list
                my @values =
                    map { /"([^"]+)"/ }
                    split(/,/, $1);
                $object->{$key} = \@values;
            } else {
                $value =~ s/&amp;/&/g;
                $object->{$key} = $value;
            }
            next;
        }

        if ($line =~ /^$/) {
            push @objects, $object if $object;
            undef $object;
            next;
        }
    }
    close $handle;

    return @objects;
}

sub mockGetRegistryKey {
    my ($test) = @_;

    return sub {
        my (%params) = @_;

        my $last_elt = (split(/\//, $params{path}))[-1];
        my $file = "resources/win32/registry/$test-$last_elt.reg";
        return loadRegistryDump($file);
    };
}

sub loadRegistryDump {
    my ($file) = @_;

    my $root_offset;
    my $root_key = {};
    my $current_key = $root_key;

    open (my $handle, '<', $file) or die "can't open $file: $ERRNO";

    # this is a windows file
    binmode $handle, ':encoding(UTF-16LE)';
    local $INPUT_RECORD_SEPARATOR="\r\n";

    while (my $line = <$handle>) {
        chomp $line;

        if ($line =~ /^ \[ ([^]]+) \] $/x) {
            my $path = $1;
            my @path = split(/\\/, $path);

            if ($root_offset) {
                splice @path, 0, $root_offset;
                $current_key = $root_key;
                foreach my $element (@path) {
                    my $key_path = $element . '/';

                    if (!defined $current_key->{$key_path}) {
                        my $new_key = {};
                        $current_key->{$key_path} = $new_key;
                    }

                    $current_key = $current_key->{$key_path};
                }
            } else {
                $root_offset = scalar @path;
            }
            next;
        }

        if ($line =~ /^ " ([^"]+) " = dword:(\d+)/x) {
            $current_key->{'/' . $1} = "0x$2";
            next;
        }

        if ($line =~ /^ " ([^"]+) " = " ([^"]+) "/x) {
            $current_key->{'/' . $1} = $2;
            next;
        }

    }
    close $handle;

    return $root_key;
}
