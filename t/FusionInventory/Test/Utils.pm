package FusionInventory::Test::Utils;

use strict;
use warnings;
use base 'Exporter';

use English qw(-no_match_vars);
use Socket;

our @EXPORT = qw(
    test_port
    mockGetWmiObjects
);

sub test_port {
    my ($port) = @_;

    my $iaddr = inet_aton('localhost');
    my $paddr = sockaddr_in($port, $iaddr);
    my $proto = getprotobyname('tcp');
    if (socket(my $socket, PF_INET, SOCK_STREAM, $proto)) {
        if (connect($socket, $paddr)) {
            close $socket;
            return 1;
        } 
    }

    return 0;
}

sub mockGetWmiObjects {
    my ($test) = @_;

    return sub {
        my (%params) = @_;

        my $file = "resources/win32/wmi/$test-$params{class}.wmi";
        open (my $handle, '<', $file) or die "can't open $file: $ERRNO";

        # this is a windows file
        binmode $handle, ':encoding(UTF-16LE)';
        local $INPUT_RECORD_SEPARATOR="\r\n";

        # build a list of desired properties indexes
        my %properties = map { $_ => 1 } @{$params{properties}};

        my @objects;
        my $object;
        while (my $line = <$handle>) {
            chomp $line;

            if ($line =~ /^ (\w+) = (.+) $/x) {
                my $key = $1;
                my $value = $2;
                next unless $properties{$key};
                $value =~ s/&amp;/&/g;
                $object->{$key} = $value;
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
    };
}
