package FusionInventory::Agent::Tools;

use strict;
use warnings;
use base 'Exporter';

use English qw(-no_match_vars);
use File::stat;
use Memoize;
use Sys::Hostname;
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
    getHostname
    compareVersion
    can_run
    can_read
    can_load
    any
    all
    none
    uniq
    getVersionFromTaskModuleFile
    getFusionInventoryLibdir
    getFusionInventoryTaskList
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

    if ($OSNAME eq 'MSWin32') {
        my @osver;
        eval "use Win32; (@osver) = Win32::GetOSVersion();";
        my $isWin2003 = ($osver[4] == 2 && $osver[1] == 5 && $osver[2] == 2);
# We get some strange breakage on Win2003. For the moment
# we don't use dmidecode on this OS.
        return if $isWin2003;
    }

    my $handle = getFileHandle(%params);

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
    my ($logger, $file) = @_;

    my $infos = getInfosFromDmidecode(logger => $logger, file => $file);

    return unless $infos->{4};

    my @cpus;
    foreach (@{$infos->{4}}) {
        next if $_->{Status} && $_->{Status} =~ /Unpopulated/i;

        # VMware
        if (
                ($_->{'Processor Manufacturer'} && ($_->{'Processor Manufacturer'} eq '000000000000'))
                &&
                ($_->{'Processor Version'} && ($_->{'Processor Version'} eq '00000000000000000000000000000000'))
           ) {
            next;
        }

        my $manufacturer = $_->{'Manufacturer'} || $_->{'Processor Manufacturer'};
        my $name = (($manufacturer =~ /Intel/ && $_->{'Family'}) || ($_->{'Version'} || $_->{'Processor Family'})) || $_->{'Processor Version'};

        my $speed;
        if ($_->{Version} && $_->{Version} =~ /([\d\.]+)GHz$/) {
            $speed = $1*1000;
        } elsif ($_->{Version} && $_->{Version} =~ /([\d\.]+)MHz$/) {
            $speed = $1;
        } elsif ($_->{'Max Speed'}) {
            if ($_->{'Max Speed'} =~ /^\s*(\d+)\s*Mhz/i) {
                $speed = $1;
            } elsif ($_->{'Max Speed'} =~ /^\s*(\d+)\s*Ghz/i) {
                $speed = $1*1000;
            }
        }


        my $externalClock;
        if ($_->{'External Clock'}) {
            if ($_->{'External Clock'} =~ /^\s*(\d+)\s*Mhz/i) {
                $externalClock = $1;
            } elsif ($_->{'External Clock'} =~ /^\s*(\d+)\s*Ghz/i) {
                $externalClock = $1*1000;
            }
        }

        push @cpus, {
            SERIAL => $_->{'Serial Number'},
            SPEED => $speed,
            ID => $_->{ID},
            MANUFACTURER => $manufacturer,
            NAME =>  $name,
            CORE => $_->{'Core Count'} || $_->{'Core Enabled'},
            THREAD => $_->{'Thread Count'},
            EXTERNAL_CLOCK => $externalClock
        }

    }

    return \@cpus;
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

    my $binaddress = ip_iptobin($address, 6);
    my $binmask    = ip_iptobin($mask, 6);
    my $binsubnet  = $binaddress & $binmask;

    return ip_bintoip($binsubnet, 6);
}

sub getSubnetAddressIPv6 {
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

sub getHostname {

    # use hostname directly under Unix
    return hostname() if $OSNAME ne 'MSWin32';

    # otherwise, use Win32 API
    eval {
        require Encode;
        require Win32::API;
        Encode->import();

        my $getComputerName = Win32::API->new(
            "kernel32", "GetComputerNameExW", ["I", "P", "P"], "N"
        );
        my $lpBuffer = "\x00" x 1024;
        my $N = 1024; #pack ("c4", 160,0,0,0);

        $getComputerName->Call(3, $lpBuffer, $N);

        # GetComputerNameExW returns the string in UTF16, we have to change
        # it to UTF8
        return encode(
            "UTF-8", substr(decode("UCS-2le", $lpBuffer), 0, ord $N)
        );
    };
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
sub getVersionFromTaskModuleFile {
    my ($file) = @_;

    my $version;
    open my $fh, "<$file" or return;
    foreach (<$fh>) {
        if (/^# VERSION FROM Agent.pm/) {
            if (!$FusionInventory::Agent::VERSION) {
                eval { use FusionInventory::Agent; 1 };
            }
            $version = $FusionInventory::Agent::VERSION;
            last;
        } elsif (/^our\ *\$VERSION\ *=\ *(\S+);/) {
            $version = $1;
            last;
        } elsif (/^use strict;/) {
            last;
        }
    }
    close $fh;

    if ($version) {
        $version =~ s/^'(.*)'$/$1/;
        $version =~ s/^"(.*)"$/$1/;
    }

    return $version;
}

# THIS FUNCTION HAS BEEN BACKPORTED IN 2.1.x branch
# PLEASE KEEP IT SYNCHED
sub getFusionInventoryLibdir {
    my ($config) = @_;

    # We started the agent from the source directory
    return 'lib' if -d 'lib/FusionInventory/Agent';

    # use first directory of @INC containing an installation tree
    my $dirToScan;
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
            $dirToScan = $_;
            last;
        }
    }

    return $dirToScan;

}

# THIS FUNCTION HAS BEEN BACKPORTED IN 2.1.x branch
# PLEASE KEEP IT SYNCHED
sub getFusionInventoryTaskList {
    my ($config) = @_;

    my $libdir = getFusionInventoryLibdir($config);

    my @tasks = glob($libdir.'/FusionInventory/Agent/Task/*.pm');

    my @ret;
    foreach (@tasks) {
        next unless basename($_) =~ /(.*)\.pm/;
        my $module = $1;

        next if $module eq 'Base';

        push @ret, {
            path => $_,
            version => getVersionFromTaskModuleFile($_),
            module => $module,
        }
    }

    return \@ret;
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

Returns a clean array with the CPU list.

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

=head2 getHostname()

Returns host name, using hostname() under Unix, Win32::API under Windows.

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

=head2 getVersionFromTaskModuleFile($taskModuleFile)

Parse a task module file to get the $VERSION. The VERSION must be
a line between the begining of the file and the 'use strict;' line.
The line must by either:

 our $VERSION = 'XXXX';

In case the .pm file is from the core distribution, the follow line 
must be present instead:

 # VERSION FROM Agent.pm/

=head2 getFusionInventoryLibdir()

Return the location of the FusionInventory/Agent library directory
on the system.
