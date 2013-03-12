package FusionInventory::Agent::Tools;

use strict;
use warnings;
use base 'Exporter';

use Encode qw(encode);
use English qw(-no_match_vars);
use File::Basename;
use File::Spec;
use File::stat;
use File::Which;
use Memoize;
use UNIVERSAL::require;

our @EXPORT = qw(
    getDirectoryHandle
    getFileHandle
    getFormatedLocalTime
    getFormatedGMTTime
    getFormatedDate
    getCanonicalManufacturer
    getCanonicalSpeed
    getCanonicalSize
    getSanitizedString
    getFirstLine
    getFirstMatch
    getLastLine
    getAllLines
    getLinesCount
    compareVersion
    canRun
    canRead
    canLoad
    hex2char
    hex2dec
    dec2hex
    any
    all
    none
    uniq
    file2module
    module2file
    runFunction
    delay
);

my $nowhere = $OSNAME eq 'MSWin32' ? 'nul' : '/dev/null';

# this trigger some errors on Perl 5.12/Win32:
# Anonymous function called in forbidden scalar context
if ($OSNAME ne 'MSWin32') {
    memoize('canRun');
    memoize('canRead');
}

sub getFormatedLocalTime {
    my ($time) = @_;

    return unless $time;

    my ($year, $month , $day, $hour, $min, $sec) =
        (localtime ($time))[5, 4, 3, 2, 1, 0];

    return getFormatedDate(
        ($year + 1900), ($month + 1), $day, $hour, $min, $sec
    );
}

sub getFormatedGMTTime {
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
    my ($manufacturer) = @_;

    return unless $manufacturer;

    if ($manufacturer =~ /(
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
        $manufacturer = ucfirst(lc($1));
    } elsif ($manufacturer =~ /^(hp|HP|hewlett packard)/) {
        $manufacturer = "Hewlett Packard";
    } elsif ($manufacturer =~ /^(WDC|[Ww]estern)/) {
        $manufacturer = "Western Digital";
    } elsif ($manufacturer =~ /^(ST|[Ss]eagate)/) {
        $manufacturer = "Seagate";
    } elsif ($manufacturer =~ /^(HD|IC|HU)/) {
        $manufacturer = "Hitachi";
    }

    return $manufacturer;
}

sub getCanonicalSpeed {
    my ($speed) = @_;

    ## no critic (ExplicitReturnUndef)

    return undef unless $speed;

    return 400 if $speed =~ /^PC3200U/;

    return undef unless $speed =~ /^([,.\d]+) \s? (\S+)$/x;
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

    return undef unless $size =~ /^([,.\d]+) \s? (\S+)$/x;
    my $value = $1;
    my $unit = lc($2);

    return
        $unit eq 'tb' ? $value * 1000 * 1000 :
        $unit eq 'gb' ? $value * 1000        :
        $unit eq 'mb' ? $value               :
        $unit eq 'kb' ? $value * 0.001       :
                        undef                ;
}

sub compareVersion {
    my ($major, $minor, $min_major, $min_minor) = @_;

    $major = 0 unless $major;
    $minor = 0 unless $minor;
    $min_major = 0 unless $min_major;
    $min_minor = 0 unless $min_minor;

    return
        $major > $min_major
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
    if (!Encode::is_utf8($string) && $string !~ m/\A(
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

sub getDirectoryHandle {
    my (%params) = @_;

    die "no directory parameter given" unless $params{directory};

    my $handle;

    if (!opendir $handle, $params{directory}) {
        $params{logger}->error("Can't open directory $params{directory}: $ERRNO")
            if $params{logger};
        return;
    }

    return $handle;
}

sub getFileHandle {
    my (%params) = @_;

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
            # Turn off localised output for commands
            local $ENV{LC_ALL} = 'C';
            local $ENV{LANG} = 'C';
            if (!open $handle, '-|', $params{command} . " 2>$nowhere") {
                $params{logger}->error(
                    "Can't run command $params{command}: $ERRNO"
                ) if $params{logger};
                return;
            }
            last SWITCH;
        }
        if ($params{string}) {
            open $handle, "<", \$params{string} or die;
            last SWITCH;
        }
        die "neither command, file or string parameter given";
    }

    return $handle;
}

sub getFirstLine {
    my (%params) = @_;

    my $handle = getFileHandle(%params);
    return unless $handle;

    my $result = <$handle>;
    close $handle;

    chomp $result if $result;
    return $result;
}

sub getLastLine {
    my (%params) = @_;

    my $handle = getFileHandle(%params);
    return unless $handle;

    my $result;
    while (my $line = <$handle>) {
        $result = $line;
    }
    close $handle;

    chomp $result if $result;
    return $result;
}

sub getFirstMatch {
    my (%params) = @_;

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
    my (%params) = @_;

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
    my (%params) = @_;

    my $handle = getFileHandle(%params);
    return unless $handle;

    my $count = 0;
    while (my $line = <$handle>) {
        $count++;
    }
    close $handle;

    return $count;
}

sub canRun {
    my ($binary) = @_;

    return $binary =~ m{^/} ?
        -x $binary :            # full path
        scalar(which($binary)); # executable name
}

sub canRead {
    my ($file) = @_;

    return -f $file;
}

sub canLoad {
    my ($module) = @_;

    return $module->require();
}

sub hex2char {
    my ($value) = @_;

    ## no critic (ExplicitReturnUndef)
    return undef unless $value;
    return $value unless $value =~ /^0x/;

    $value =~ s/^0x//; # drop hex prefix
    $value =~ s/00$//; # drop trailing null-character
    $value =~ s/(\w{2})/chr(hex($1))/eg;

    return $value;
}

sub hex2dec {
    my ($value) = @_;

    ## no critic (ExplicitReturnUndef)
    return undef unless $value;
    return $value unless $value =~ /^0x/;

    return oct($value);
}

sub dec2hex {
    my ($value) = @_;

    ## no critic (ExplicitReturnUndef)
    return undef unless $value;
    return $value if $value =~ /^0x/;

    return sprintf("0x%x", $value);
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

sub file2module {
    my ($file) = @_;
    $file =~ s{.pm$}{};
    $file =~ s{/}{::}g;
    return $file;
}

sub module2file {
    my ($module) = @_;
    $module .= '.pm';
    $module =~ s{::}{/}g;
    return $module;
}

sub runFunction {
    my (%params) = @_;

    my $logger = $params{logger};

    # ensure module is loaded
    if ($params{load}) {
        $params{module}->require();
        if ($EVAL_ERROR) {
            $logger->debug("Failed to load $params{module}: $EVAL_ERROR")
                if $logger;
            return;
        }
    }

    my $result;
    eval {
        local $SIG{ALRM} = sub { die "alarm\n" };
        # set a timeout if needed
        alarm $params{timeout} if $params{timeout};

        no strict 'refs'; ## no critic (ProhibitNoStrict)
        $result = &{$params{module} . '::' . $params{function}}(
            ref $params{params} eq 'HASH'  ? %{$params{params}} :
            ref $params{params} eq 'ARRAY' ? @{$params{params}} :
                                               $params{params}
        );
        alarm 0;
    };

    if ($EVAL_ERROR) {
        my $message = $EVAL_ERROR eq "alarm\n" ?
            "$params{module} killed by a timeout"             :
            "unexpected error in $params{module}: $EVAL_ERROR";
        $logger->debug($message) if $logger;
    }

    return $result;
}

sub delay {
    my ($delay) = @_;

    if ($OSNAME eq 'MSWin32') {
        Win32->require();
        Win32::Sleep($delay*1000);
    }  else {
        sleep($delay);
    }
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

=head2 getFormatedGMTTime($time)

Returns a formated date from given Unix timestamp.

=head2 getFormatedDate($year, $month, $day, $hour, $min, $sec)

Returns a formated date from given date elements.

=head2 getCanonicalManufacturer($manufacturer)

Returns a normalized manufacturer value for given one.

=head2 getCanonicalSpeed($speed)

Returns a normalized speed value (in Mhz) for given one.

=head2 getCanonicalSize($size)

Returns a normalized size value (in Mb) for given one.

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

Returns an open file handle on either a command output, a file, or a string.

=over

=item logger a logger object

=item command the command to use

=item file the file to use, as an alternative to the command

=item string the string to use, as an alternative to the command

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

Returns all the lines of given command output or given file content, as a list
of strings with end of line removed in list context, as a single string
otherwise.

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

=head2 getLastLine(%params)

Returns the last line of given command output or given file content.

=over

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

=head2 canRun($binary)

Returns true if given binary can be executed.

=head2 canRead($file)

Returns true if given file can be read.

=head2 canLoad($module)

Returns true if given perl module can be loaded (and actually loads it).

=head2 hex2char($value)

Returns the value converted to a character if it starts with hexadecimal
prefix, the unconverted value otherwise. Eg. 0x41 -> A, 41 -> 41.

=head2 hex2dec($value)

Returns the value converted to a decimal if it starts with hexadecimal prefix,
the unconverted value otherwise. Eg. 0x41 -> 65, 41 -> 41.

=head2 dec2hex($value)

Returns the value converted to an hexadecimal if it doesn't start with
hexadecimal prefix, the unconverted value otherwise. Eg. 65 -> 0x41, 0x41 ->
0x41.

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

=head2 file2module($string)

Converts a perl file name to a perl module name (Foo/Bar.pm -> Foo::Bar)

=head2 module2file($string)

Converts a perl module name to a perl file name ( Foo::Bar -> Foo/Bar.pm)

=head2 runFunction(%params)

Run a function whose name is computed at runtime and return its result.

=over

=item logger a logger object

=item module the function namespace

=item function the function name

=item timeout timeout for function execution

=item load enforce module loading first

=back

=head2 delay($second)

Wait for $second. It uses sleep() or Win32::Sleep() depending
on the Operating System.
