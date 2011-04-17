package FusionInventory::Agent::Tools;

use strict;
use warnings;
use base 'Exporter';

use English qw(-no_match_vars);
use File::stat;
use Memoize;
use File::Spec;
use File::Basename;

our @EXPORT = qw(
    getSubnetAddress
    getSubnetAddressIPv6
    getDirectoryHandle
    getFileHandle
    getFormatedLocalTime
    getFormatedGmTime
    getFormatedDate
    getCanonicalManufacturer
    getCanonicalSpeed
    getCanonicalSize
    getInfosFromDmidecode
    getCpusFromDmidecode
    getSanitizedString
    getFirstLine
    getFirstMatch
    getAllLines
    getLinesCount
    compareVersion
    can_run
    can_read
    can_load
    any
    all
    none
    uniq
    getFusionInventoryLibdir
);

memoize('can_run');
memoize('can_read');
memoize('getCanonicalManufacturer');
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

    my $manufacturer;
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
        hitachi   |
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

    return 400 if $speed =~ /^PC3200U/;

    return undef unless $speed =~ /^(\d+) \s? (\S+)$/x;
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

    return $size if $size =~ /^\d+$/;

    return undef unless $size =~ /^(\d+) \s (\S+)$/x;
    my $value = $1;
    my $unit = lc($2);

    return
        $unit eq 'tb' ? $value * 1000 * 1000 :
        $unit eq 'gb' ? $value * 1000        :
        $unit eq 'mb' ? $value               :
                        undef                ;
}

# THIS FUNCTION HAS BEEN BACKPORTED IN 2.1.x branch
# PLEASE KEEP IT SYNCHED
sub getInfosFromDmidecode {
    my %params = (
        command => 'dmidecode',
        @_
    );

    my $handle = getFileHandle(%params);
    return unless $handle;

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

# THIS FUNCTION HAS BEEN BACKPORTED IN 2.1.x branch
# PLEASE KEEP IT SYNCHED
sub getCpusFromDmidecode {
    my $infos = getInfosFromDmidecode(@_);

    return unless $infos->{4};

    my @cpus;
    foreach my $info (@{$infos->{4}}) {
        next if $info->{Status} && $info->{Status} =~ /Unpopulated/i;

        my $proc_manufacturer = $info->{'Processor Manufacturer'};
        my $proc_version      = $info->{'Processor Version'};

        # VMware
        next if
            ($proc_manufacturer && $proc_manufacturer eq '000000000000') &&
            ($proc_version      && $proc_version eq '00000000000000000000000000000000');

        my $cpu = {
            SERIAL => $info->{'Serial Number'},
            ID     => $info->{ID},
            CORE   => $info->{'Core Count'} || $info->{'Core Enabled'},
            THREAD => $info->{'Thread Count'},
        };
        $cpu->{MANUFACTURER} = $info->{'Manufacturer'} || $info->{'Processor Manufacturer'};
        $cpu->{NAME} =
            ($cpu->{MANUFACTURER} =~ /Intel/ ? $info->{'Family'} : undef) ||
            $info->{'Version'}                                     ||
            $info->{'Processor Family'}                            ||
            $info->{'Processor Version'};

        if ($info->{Version}) {
            if ($info->{Version} =~ /([\d\.]+)MHz$/) {
                $cpu->{SPEED} = $1;
            } elsif ($info->{Version} =~ /([\d\.]+)GHz$/) {
                $cpu->{SPEED} = $1 * 1000;
            }
        }
        if (!$cpu->{SPEED}) {
            if ($info->{'Max Speed'}) {
                if ($info->{'Max Speed'} =~ /^\s*(\d+)\s*Mhz/i) {
                    $cpu->{SPEED} = $1;
                } elsif ($info->{'Max Speed'} =~ /^\s*(\d+)\s*Ghz/i) {
                    $cpu->{SPEED} = $1 * 1000;
                }
            }
        }

        if ($info->{'External Clock'}) {
            if ($info->{'External Clock'} =~ /^\s*(\d+)\s*Mhz/i) {
                $cpu->{EXTERNAL_CLOCK} = $1;
            } elsif ($info->{'External Clock'} =~ /^\s*(\d+)\s*Ghz/i) {
                $cpu->{EXTERNAL_CLOCK} = $1 * 1000;
            }
        }

        push @cpus, $cpu;
    }

    return @cpus;
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

sub getSanitizedString {
    my ($string) = @_;

    return unless defined $string;

    # clean control caracters
    $string =~ s/[[:cntrl:]]//g;

    # encode to utf-8 if needed
    if ($string !~ m/\A(
          [\x09\x0A\x0D\x20-\x7E]           # ASCII
        | [\xC2-\xDF][\x80-\xBF]            # non-overlong 2-byte
        | \xE0[\xA0-\xBF][\x80-\xBF]        # excluding overlongs
        | [\xE1-\xEC\xEE\xEF][\x80-\xBF]{2} # straight 3-byte
        | \xED[\x80-\x9F][\x80-\xBF]        # excluding surrogates
        | \xF0[\x90-\xBF][\x80-\xBF]{2}     # planes 1-3
        | [\xF1-\xF3][\x80-\xBF]{3}         # planes 4-15
        | \xF4[\x80-\x8F][\x80-\xBF]{2}     # plane 16
        )*\z/x) {
        $string = encode("UTF-8", $string);
    };

    return $string;
}

sub getSubnetAddress {
    my ($address, $mask) = @_;

    return unless $address && $mask;

    # load Net::IP conditionnaly
    return unless can_load("Net::IP");
    Net::IP->import(':PROC');

    my $binaddress = ip_iptobin($address, 4);
    my $binmask    = ip_iptobin($mask, 4);
    my $binsubnet  = $binaddress & $binmask;

    return ip_bintoip($binsubnet, 4);
}

sub getSubnetAddressIPv6 {
    my ($address, $mask) = @_;

    return unless $address && $mask;

    # load Net::IP conditionnaly
    return unless can_load("Net::IP");
    Net::IP->import(':PROC');

    my $binaddress = ip_iptobin($address, 6);
    my $binmask    = ip_iptobin($mask, 6);
    my $binsubnet  = $binaddress & $binmask;

    return ip_bintoip($binsubnet, 6);
}

sub getDirectoryHandle {
    my %params = @_;

    die "no directory parameter given" unless $params{directory};

    my $handle;

    if (!opendir $handle, $params{directory}) {
        $params{logger}->error("Can't open directory $params{directory}: $ERRNO")
            if $params{logger};
        return;
    }

    return $handle;
}

# THIS FUNCTION HAS BEEN BACKPORTED IN 2.1.x branch
# PLEASE KEEP IT SYNCHED
sub getFileHandle {
    my %params = @_;

    my $handle;

    SWITCH: {
        if ($params{file}) {
            if (!open $handle, '<', $params{file}) {
                $params{logger}->error(
                    "Can't open file $params{file}: $ERRNO"
                ) if $params{logger};
                return;
            }
            last SWITCH;
        }
        if ($params{command}) {
            if (!open $handle, '-|', $params{command} . " 2>/dev/null") {
                $params{logger}->error(
                    "Can't run command $params{command}: $ERRNO"
                ) if $params{logger};
                return;
            }
            last SWITCH;
        }
	if ($params{string}) {
	    
	    open $handle, "<", \$params{string} or die;
	}
        die "neither command nor file parameter given";
    }

    return $handle;
}

sub getFirstLine {
    my %params = @_;

    my $handle = getFileHandle(%params);
    my $result = <$handle>;
    close $handle;

    chomp $result;
    return $result;
}

sub getFirstMatch {
    my %params = @_;

    return unless $params{pattern};

    my $handle = getFileHandle(%params);
    return unless $handle;

    my @results;
    while (my $line = <$handle>) {
        @results = $line =~ $params{pattern};
        last if @results;
    }
    close $handle;

    return wantarray ? @results : $results[0];
}

sub getAllLines {
    my %params = @_;

    my $handle = getFileHandle(%params);
    return unless $handle;

    if (wantarray) {
        my @lines = map { chomp; $_ } <$handle>;
        close $handle;
        return @lines;
    } else {
        local $RS;
        my $lines = <$handle>;
        close $handle;
        return $lines;
    }
}

sub getLinesCount {
    my %params = @_;

    my $handle = getFileHandle(%params);
    return unless $handle;

    my $count = 0;
    while (my $line = <$handle>) {
        $count++;
    }
    close $handle;

    return $count;
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

sub can_read {
    my ($file) = @_;

    return -f $file;
}

sub can_load {
    my ($module) = @_;

    return $module->require();
}

# shamelessly imported from List::MoreUtils to avoid a dependency
sub any (&@) { ## no critic (SubroutinePrototypes)
    my $f = shift;
    foreach ( @_ ) {
        return 1 if $f->();
    }
    return 0;
}

sub all (&@) { ## no critic (SubroutinePrototypes)
    my $f = shift;
    foreach ( @_ ) {
        return 0 unless $f->();
    }
    return 1;
}

sub none (&@) { ## no critic (SubroutinePrototypes)
    my $f = shift;
    foreach ( @_ ) {
        return 0 if $f->();
    }
    return 1;
}

sub uniq (@) { ## no critic (SubroutinePrototypes)
    my %seen = ();
    grep { not $seen{$_}++ } @_;
}

# THIS FUNCTION HAS BEEN BACKPORTED IN 2.1.x branch
# PLEASE KEEP IT SYNCHED
# TODO: to move in FusionInventory::Agent::Task
sub getFusionInventoryLibdir {
    my ($config) = @_;

    # We started the agent from the source directory
    return ['lib'] if -d 'lib/FusionInventory/Agent';

    my $ret = [];
    # use first directory of @INC containing an installation tree
    foreach my $dir (@INC) {
    # perldoc lib
    # For each directory in LIST (called $dir here) the lib module also checks to see
    # if a directory called $dir/$archname/auto exists. If so the $dir/$archname
    # directory is assumed to be a corresponding architecture specific directory and
    # is added to @INC in front of $dir. lib.pm also checks if directories called
    # $dir/$version and $dir/$version/$archname exist and adds these directories to @INC.
        my @subdirs = (
        $dir . '/FusionInventory/Agent',
        $dir .'/'. $Config::Config{archname}.'auto/FusionInventory/Agent'
        );
        foreach (@subdirs) {
            next unless -d $_.'/FusionInventory/Agent';
            push @$ret, $_; 
        }
    }

    return $ret;

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

=head2 getCpusFromDmidecode()

Returns a list of CPUs, from dmidecode output.

=head2 getSanitizedString($string)

Returns the input stripped from any control character, properly encoded in
UTF-8.

=head2 compareVersion($major, $minor, $min_major, $min_minor)

Returns true if software with given major and minor version meet minimal
version requirements.

=head2 getDirectoryHandle(%params)

Returns an open file handle on either a command output, or a file.

=over

=item logger a logger object

=item directory the directory to use

=back

=head2 getFileHandle(%params)

Returns an open file handle on either a command output, or a file.

=over

=item logger a logger object

=item command the exact command to use

=item file the file to use, as an alternative to the command

=back

=head2 getFirstLine(%params)

Returns the first line of given command output or given file content, with end
of line removed.

=over

=item logger a logger object

=item command the exact command to use

=item file the file to use, as an alternative to the command

=back

=head2 getAllLines(%params)

Returns all the lines of given command output or given file content, with end
of line removed.

=over

=item logger a logger object

=item command the exact command to use

=item file the file to use, as an alternative to the command

=back

=head2 getFirstMatch(%params)

Returns the result of applying given pattern on the first matching line of
given command output or given file content.

=over

=item pattern a regexp

=item logger a logger object

=item command the exact command to use

=item file the file to use, as an alternative to the command

=back

=head2 getLinesCount(%params)

Returns the number of lines of given command output or given file content.

=over

=item logger a logger object

=item command the exact command to use

=item file the file to use, as an alternative to the command

=back

=head2 getSubnetAddress($address, $mask)

Returns the subnet address for IPv4.

=head2 getSubnetAddressIPv6($address, $mask)

Returns the subnet address for IPv6.

=head2 can_run($binary)

Returns true if given binary can be executed.

=head2 can_read($file)

Returns true if given file can be read.

=head2 can_load($module)

Returns true if given perl module can be loaded (and actually loads it).

=head2 any BLOCK LIST

Returns a true value if any item in LIST meets the criterion given through
BLOCK.

=head2 all BLOCK LIST

Returns a true value if all items in LIST meet the criterion given through
BLOCK.

=head2 none BLOCK LIST

Returns a true value if no item in LIST meets the criterion given through BLOCK.

=head2 uniq BLOCK LIST

Returns a new list by stripping duplicate values in LIST.

=head2 getFusionInventoryLibdir()

Return a array reference of the location of the FusionInventory/Agent library
directory on the system.

