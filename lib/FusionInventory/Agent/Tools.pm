package FusionInventory::Agent::Tools;

use strict;
use warnings;
use base 'Exporter';

use File::stat;

our @EXPORT = qw(getManufacturer getIpDhcp);

sub getManufacturer {
    my ($model) = @_;

    if ($model =~ /(
        maxtor    |
        western   |
        sony      |
        compaq    |
        ibm       |
        seagate   |
        toshiba   |
        fujitsu   |
        lg        |
        samsung   |
        nec       |
        transcend |
        matshita  |
        pioneer
    )/xi) {
        $model = ucfirst(lc($1));
    } elsif ($model =~ /^(HP|hewlett packard)/) {
        $model = "Hewlett Packard";
    } elsif ($model =~ /^WDC/) {
        $model = "Western Digital";
    } elsif ($model =~ /^ST/) {
        $model = "Seagate";
    } elsif ($model =~ /^(HD|IC|HU)/) {
        $model = "Hitachi";
    }

    return $model;
}

sub getIpDhcp {
    my $if = shift;

    my $lease_file;
    foreach my $dir qw(
        /var/db
        /var/lib/dhcp3
        /var/lib/dhcp
    ) {
        next unless -d $dir;

        my @files =
            grep { -s $_ }
            glob("$dir/*$if.lease");

        if (@files) {
            # sort by creation time 
            @files =
                map { $_->[0] } 
                sort { $a->[1]->ctime() <=> $b->[1]->ctime() }
                map { [ $_, stat($_) ] }
                @files;

            # take the last one
            $lease_file = $files[-1];
            last;
        }

        if (-f "$dir/dhclient.leases") {
            $lease_file = "$dir/dhclient.leases";
            last;
        }
    }

    return unless $lease_file;

    my ($server_ip, $expiration_time);

    my $handle;
    if (!open $handle, '<', $lease_file) {
        warn "Can't open $lease_file\n";
        return;
    }

    my ($lease, $dhcp);

    # find the last lease for the interface with its expire date
    while (my $line = <$handle>) {
        if ($line=~ /^lease/i) {
            $lease = 1;
            next;
        }
        if ($line=~ /^}/) {
            $lease = 0;
            next;
        }

        next unless $lease;

        # inside a lease section
        if ($line =~ /interface\s+"([^"]+)"/){
            $dhcp = ($1 eq $if);
            next;
        }

        next unless $dhcp;

        if (
            $line =~ 
            /option \s+ dhcp-server-identifier \s+ (\d{1,3}(?:\.\d{1,3}){3})/x
        ) {
            # server IP
            $server_ip = $1;
        } elsif (
            $line =~
            /expire \s+ \d \s+ (\d+)\/(\d+)\/(\d+) \s+ (\d+):(\d+):(\d+)/x
        ) {
            $expiration_time =
                sprintf "%04d%02d%02d%02d%02d%02d", $1, $2, $3, $4, $5, $6;
        }
    }
    close $handle;

    my $current_time = `date +"%Y%m%d%H%M%S"`;
    chomp $current_time;

    return $current_time <= $expiration_time ? $server_ip : undef;
}

1;
