package FusionInventory::Agent::Tools::Unix;

use strict;
use warnings;
use base 'Exporter';

use English qw(-no_match_vars);
use Memoize;
use Time::Local;

use FusionInventory::Agent::Tools;

our @EXPORT = qw(
    getDeviceCapacity
    getIpDhcp
    getFilesystemsFromDf
    getProcessesFromPs
    getControllersFromLspci
);

memoize('getControllersFromLspci');

sub getDeviceCapacity {
    my ($dev) = @_;
    my $command = `/sbin/fdisk -v` =~ '^GNU' ? 'fdisk -p -s' : 'fdisk -s';
    # requires permissions on /dev/$dev
    my $capacity;
    foreach my $line (`$command /dev/$dev 2>/dev/null`) {
        next unless $line =~ /^(\d+)/;
        $capacity = $1;
    }
    $capacity = int($capacity / 1000) if $capacity;
    return $capacity;
}

sub getIpDhcp {
    my ($logger, $if) = @_;

    my $dhcpLeaseFile = _findDhcpLeaseFile($logger);

    return unless $dhcpLeaseFile;

    _parseDhcpLeaseFile($logger, $if, $dhcpLeaseFile);
}

sub _findDhcpLeaseFile {
    my ($logger) = @_;

    my @files;

    foreach my $dir qw(
        /var/db
        /var/lib/dhcp3
        /var/lib/dhcp
    ) {
        next unless -d $dir;

        push @files,
            grep { -s $_ }
            glob("$dir/*.lease");

    }

    return unless @files;

    # sort by creation time
    @files =
        map { $_->[0] }
        sort { $a->[1]->ctime() <=> $b->[1]->ctime() }
        map { [ $_, stat($_) ] }
    @files;

    # take the last one
    return $files[-1];
}

sub _parseDhcpLeaseFile {
    my ($logger, $if, $lease_file) = @_;

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

    return unless $expiration_time;

    my $current_time = time();

    return $current_time <= $expiration_time ? $server_ip : undef;
}

sub getFilesystemsFromDf {
    my $handle = getFileHandle(@_);

    my @filesystems;
    
    # get headers line first
    my $line = <$handle>;
    chomp $line;
    my @headers = split(/\s+/, $line);

    while (my $line = <$handle>) {
        chomp $line;
        my @infos = split(/\s+/, $line);

        # depending of the number of colums, information index change
        my ($filesystem, $total, $free, $type);
        if ($headers[1] eq 'Type') {
            $filesystem = $infos[1];
            $total      = $infos[2];
            $free       = $infos[4];
            $type       = $infos[6];
        } else {
            $total = $infos[1];
            $free  = $infos[3];
            $type  = $infos[5];
        }

        # skip some virtual filesystems
        next if $total !~ /^\d+$/ || $total == 0;
        next if $free  !~ /^\d+$/ || $free  == 0;

        push @filesystems, {
            VOLUMN     => $infos[0],
            FILESYSTEM => $filesystem,
            TOTAL      => sprintf("%i", $total / 1024),
            FREE       => sprintf("%i", $free / 1024),
            TYPE       => $type
        };
    }

    close $handle;

    return @filesystems;
}

sub getProcessesFromPs {
    my $handle = getFileHandle(@_);

    # skip headers
    my $line = <$handle>;

    my %month = (
        Jan => '01',
        Feb => '02',
        Mar => '03',
        Apr => '04',
        May => '05',
        Jun => '06',
        Jul => '07',
        Aug => '08',
        Sep => '09',
        Oct => '10',
        Nov => '11',
        Dec => '12',
    );
    my ($sec, $min, $hour, $day, $mon, $year, $wday, $yday, $isdst) =
        localtime(time);
    $year = $year + 1900;
    my @processes;

    while ($line = <$handle>) {
        next unless $line =~
            /^
            (\S+) \s+
            (\S+) \s+
            (\S+) \s+
            (\S+) \s+
            (\S+) \s+
            (\S+) \s+
            (\S+) \s+
            (\S+) \s+
            (\S+) \s+
            (\S+) \s+
            (.*\S)
            /x;
        my $user = $1;
        my $pid = $2;
        my $cpu = $3;
        my $mem = $4;
        my $vsz = $5;
        my $tty = $7;
        my $started = $9;
        my $time = $10;
        my $cmd = $11;

        my $begin;
        if ($started =~ /(\w{3})(\d{2})/) {
            my $start_month = $1;
            my $start_day = $2;
            $begin = "$year-$month{$start_month}-$start_day $time"; 
        }  else {
            $begin = "$year-$mon-$day $started";
        }

        push @processes, {
            USER          => $user,
            PID           => $pid,
            CPUUSAGE      => $cpu,
            MEM           => $mem,
            VIRTUALMEMORY => $vsz,
            TTY           => $tty,
            STARTED       => $begin,
            CMD           => $cmd
        };
    }

    close $handle;

    return @processes;
}

sub getControllersFromLspci {
    my %params = (
        command => 'lspci -vvv -nn',
        @_
    );
    my $handle = getFileHandle(%params);

    my (@controllers, $controller);

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
            push(@controllers, $controller);
            undef $controller;
        } elsif ($line =~ /^\tKernel driver in use: (\w+)/) {
            $controller->{DRIVER} = $1;
        } elsif ($line =~ /^\tSubsystem: ([a-f\d]{4}:[a-f\d]{4})/) {
            $controller->{PCISUBSYSTEMID} = $1;
        }
    }

    close $handle;

    return @controllers;
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Tools::Unix - Unix-specific generic functions

=head1 DESCRIPTION

This module provides some Unix-specific generic functions.

=head1 FUNCTIONS

=head2 getDeviceCapacity($device)

Returns storage capacity of given device.

=head2 getIpDhcp

Returns an hashref of information for current DHCP lease.

=head2 getFilesystemsFromDf(%params)

Returns a list of filesystems as a list of hashref, by parsing given df command
output.

=over

=item logger a logger object

=item command the exact command to use

=item file the file to use, as an alternative to the command

=back

=head2 getProcessesFromPs(%params)

Returns a list of processes as a list of hashref, by parsing given ps command
output.

=over

=item logger a logger object

=item command the exact command to use

=item file the file to use, as an alternative to the command

=back

=head2 getControllersFromLspci(%params)

Returns a list of controllers as a list of hashref, by parsing lspci command
output.

=over

=item logger a logger object

=item command the exact command to use (default: lspci -vvv -nn)

=item file the file to use, as an alternative to the command

=back
