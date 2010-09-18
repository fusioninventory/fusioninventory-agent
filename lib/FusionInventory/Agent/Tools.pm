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
    getCanonicalManufacturer
    getCanonicalSpeed
    getCanonicalSize
    getControllersFromLspci
    getInfosFromDmidecode
    getIpDhcp
    getPackagesFromCommand
    compareVersion
    cleanUnknownValues
    can_run
    can_load
);

memoize('can_run');
memoize('getCanonicalManufacturer');
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

sub getCanonicalManufacturer {
    my ($model) = @_;

    return unless $model;

    if ($model =~ /(
        maxtor    |
        sony      |
        compaq    |
        ibm       |
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
    } elsif ($model =~ /^(hp|HP|hewlett packard)/) {
        $model = "Hewlett Packard";
    } elsif ($model =~ /^(WDC|[Ww]estern)/) {
        $model = "Western Digital";
    } elsif ($model =~ /^(ST|[Ss]eagate)/) {
        $model = "Seagate";
    } elsif ($model =~ /^(HD|IC|HU)/) {
        $model = "Hitachi";
    }

    return $model;
}

sub getCanonicalSpeed {
    my ($speed) = @_;

    ## no critic (ExplicitReturnUndef)

    return undef unless $speed;

    return undef unless $speed =~ /^(\d+) \s (\S+)$/x;
    my $value = $1;
    my $unit = lc($2);

    return
        $unit eq 'ghz' ? $value * 1000 :
        $unit eq 'mhz' ? $value        :
                         undef         ;
}

sub getCanonicalSize {
    my ($size) = @_;

    ## no critic (ExplicitReturnUndef)

    return undef unless $size;

    return undef unless $size =~ /^(\d+) \s (\S+)$/x;
    my $value = $1;
    my $unit = lc($2);

    return
        $unit eq 'tb' ? $value * 1000 * 1000 :
        $unit eq 'gb' ? $value * 1000        :
        $unit eq 'mb' ? $value               :
                        undef                ;
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

sub findDhcpLeaseFile {
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
            return "$dir/dhclient.leases";
        }
    }

    return;
}

sub parseDhcpLeaseFile {
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

    my $current_time = time();

    return $current_time <= $expiration_time ? $server_ip : undef;
}

sub getIpDhcp {
    my ($logger, $if) = @_;

    my $dhcpLeaseFile = findDhcpLeaseFile($logger, $if);

    return unless $dhcpLeaseFile;
    print $dhcpLeaseFile."\n";

    parseDhcpLeaseFile($logger, $if, $dhcpLeaseFile);

}

sub getPackagesFromCommand {
     my ($logger, $file, $mode, $callback) = @_;

    my $handle;
    if (!open $handle, $mode, $file) {
        my $message = $mode eq '-|' ? 
            "Can't run command $file: $ERRNO" :
            "Can't open file $file: $ERRNO"   ;
        $logger->error($message);
        return;
    }

    my $packages;
    
    while (my $line = <$handle>) {
        chomp $line;
        my $package = $callback->($line);
        push @$packages, $package if $package;
    }

    close $handle;

    return $packages;
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
__END__

=head1 NAME

FusionInventory::Agent::Tools - OS-independant generic functions

=head1 DESCRIPTION

This module provides some OS-independant generic functions.

=head1 FUNCTIONS

=head2 getFormatedLocalTime($time)

Returns a formated date from given Unix timestamp.

=head2 getFormatedGmTime($time)

Returns a formated date from given Unix timestamp.

=head2 getFormatedDate($year, $month, $day, $hour, $min, $sec)

Returns a formated date from given date elements.

=head2 getCanonicalManufacturer($manufacturer)

Returns a normalized manufacturer value for given one.

=head2 getCanonicalSpeed($speed)

Returns a normalized speed value (in Mhz) for given one.

=head2 getCanonicalSize($size)

Returns a normalized size value (in Mb) for given one.


=head2 getControllersFromLspci

Returns a list of controllers as an arrayref of hashref, by parsing lspci
output.

=head2 getInfosFromDmidecode

Returns a structured view of dmidecode output. Each information block is turned
into an hashref, block with same DMI type are grouped into a list, and each
list is indexed by its DMI type into the resulting hashref.

$info = {
    0 => [
        { block }
    ],
    1 => [
        { block },
        { block },
    ],
    ...
}

=head2 getIpDhcp

Returns an hashref of information for current DHCP lease.

=head2 getPackagesFromCommand

Returns a list of packages as an arrayref of hashref, by parsing given command
output with given callback.

=head2 compareVersion($major, $minor, $min_major, $min_minor)

Returns true if software with given major and minor version meet minimal
version requirements.

=head2 cleanUnknownValues($hashref)

Deletes all key with undefined values from given hashref.

=head2 can_run($binary)

Returns true if given binary can be executed.

=head2 can_load($module)

Returns true if given perl module can be loaded (and actually loads it).
