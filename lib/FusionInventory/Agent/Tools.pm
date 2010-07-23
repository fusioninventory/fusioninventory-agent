package FusionInventory::Agent::Tools;

use strict;
use warnings;
use base 'Exporter';

use English qw(-no_match_vars);
use File::stat;
use Memoize;
use Time::Local;

our @EXPORT = qw(
    getFormatedLocalTime
    getFormatedGmTime
    getFormatedDate
    getManufacturer
    getControllersFromLspci
    getInfosFromDmidecode
    getIpDhcp
    compareVersion
    cleanUnknownValues
    can_run
    can_load
);

memoize('can_run');
memoize('getManufacturer');
memoize('getControllersFromLspci');
memoize('getInfosFromDmidecode');

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

sub getControllersFromLspci {
    my ($logger, $file) = @_;

    return $file ?
        _parseLspci($logger, $file, '<')            :
        _parseLspci($logger, 'lspci -vvv -nn', '-|');
}

sub _parseLspci {
    my ($logger, $file, $mode) = @_;

    my $handle;
    if (!open $handle, $mode, $file) {
        $logger->error("Can't open $file: $ERRNO");
        return;
    }

    my ($controllers, $controller);

    while (my $line = <$handle>) {
        chomp $line;

        if ($line =~ /^
                (\S+) \s                     # slot
                ([^[]+) \s                   # name
                \[([a-f\d]+)\]: \s           # class
                ([^[]+) \s                   # manufacturer
                \[([a-f\d]+:[a-f\d]+)\]      # id
                (?:\s \(rev \s (\d+)\))?     # optional version
                (?:\s \(prog-if \s [^)]+\))? # optional detail
                /x) {

            $controller = {
                PCISLOT      => $1,
                NAME         => $2,
                PCICLASS     => $3,
                MANUFACTURER => $4,
                PCIID        => $5,
                VERSION      => $6
            };
            next;
        }

        next unless defined $controller;

         if ($line =~ /^$/) {
            push(@$controllers, $controller);
            undef $controller;
        } elsif ($line =~ /^\tKernel driver in use: (\w+)/) {
            $controller->{DRIVER} = $1;
        } elsif ($line =~ /^\tSubsystem: ([a-f\d]{4}:[a-f\d]{4})/) {
            $controller->{PCISUBSYSTEMID} = $1;
        }
    }

    close $handle;

    return $controllers;
}

sub getInfosFromDmidecode {
    my ($logger, $file) = @_;

    return $file ?
        _parseDmidecode($logger, $file, '<')       :
        _parseDmidecode($logger, 'dmidecode', '-|');
}

sub _parseDmidecode {
    my ($logger, $file, $mode) = @_;

    my $handle;
    if (!open $handle, $mode, $file) {
        $logger->error("Can't open $file: $ERRNO");
        return;
    }

    my ($info, $block, $type);

    while (my $line = <$handle>) {
        chomp $line;

        if ($line =~ /DMI type (\d+)/) {
            # start of block

            # push previous block in list
            if ($block) {
                push(@{$info->{$type}}, $block);
                undef $block;
            }

            # switch type
            $type = $1;

            next;
        }

        next unless defined $type;

        next unless $line =~ /^\s+ ([^:]+) : \s (.*\S)/x;

        next if
            $2 eq 'N/A'           ||
            $2 eq 'Not Specified' ||
            $2 eq 'Not Present'   ;

        $block->{$1} = $2;
    }
    close $handle;

    return $info;
}

sub getIpDhcp {
    my ($logger, $if) = @_;

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
        $logger->error("Can't open $lease_file");
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

sub cleanUnknownValues {
    my ($hash) = @_;

    foreach my $key (keys %$hash) {
       delete $hash->{$key} if !defined $hash->{$key};
    }
}

sub can_run {
    my ($binary) = @_;

    if ($OSNAME eq 'MSWin32') {
        foreach my $dir (split/$Config::Config{path_sep}/, $ENV{PATH}) {
            foreach my $ext (qw/.exe .bat/) {
                return 1 if -f $dir . '/' . $binary . $ext;
            }
        }
        return 0;
    } else {
        return 
            system("which $binary >/dev/null 2>&1") == 0;
    }

}

sub can_load {
    my ($module) = @_;

    return $module->require();
}

1;
