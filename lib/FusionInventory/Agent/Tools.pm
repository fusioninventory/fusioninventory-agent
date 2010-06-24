package FusionInventory::Agent::Tools;

use strict;
use warnings;
use base 'Exporter';

use English qw(-no_match_vars);
use File::stat;
use Time::Local;

our @EXPORT = qw(
    getFormatedLocalTime
    getFormatedGmTime
    getFormatedDate
    getManufacturer
    getIpDhcp
    compareVersion
    can_run
    can_load
    can_read
    runcmd
);

sub getFormatedLocalTime {
    my ($time) = @_;

    my ($year, $month , $day, $hour, $min, $sec) =
        (localtime ($time))[5, 4, 3, 2, 1, 0];

    return getFormatedDate(
        ($year + 1900), ($month + 1), $day, $hour, $min, $sec
    );
}

sub getFormatedGmTime {
    my ($time) = @_;

    my ($year, $month , $day, $hour, $min, $sec) =
        (gmtime ($time))[5, 4, 3, 2, 1, 0];

    return getFormatedDate(
        ($year - 70), $month, ($day - 1), $hour, $min, $sec
    );
}

sub getFormatedDate {
    my ($year, $month, $day, $hour, $min, $sec) = @_;

    return sprintf
        "%02d-%02d-%02d %02d:%02d:%02d",
        $year, $month, $day, $hour, $min, $sec;
}

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
            $expiration_time = timelocal($6, $5, $4, $3, $2, $1);
        }
    }
    close $handle;

    my $current_time = time();

    return $current_time <= $expiration_time ? $server_ip : undef;
}

sub compareVersion {
    my ($major, $minor, $min_major, $min_minor) = @_;

    return
        $major > $minor
        ||
        (
            $major == $min_major
            &&
            $minor >= $min_minor
        );
}

sub can_run {
    my ($binary) = @_;

    my $ret;
    if ($OSNAME eq 'MSWin32') {
        MAIN: foreach (split/$Config::Config{path_sep}/, $ENV{PATH}) {
            foreach my $ext (qw/.exe .bat/) {
                if (-f $_.'/'.$binary.$ext) {
                    $ret = 1;
                    last MAIN;
                }
            }
        }
    } else {
        chomp(my $binpath=`which $binary 2>/dev/null`);
        $ret = -x $binpath;
    }

    return $ret;
}

sub can_load {
    my ($module) = @_;

    return $module->require();
}

sub can_read {
    my ($file) = @_;
    return unless -r $file;
    1;
}

sub runcmd {
    my ($cmd) = @_;
    return unless $cmd;

    # $self->{logger}->debug(" - run $cmd");

    return `$cmd`;
}


1;
