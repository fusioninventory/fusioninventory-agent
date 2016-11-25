package FusionInventory::Agent::Tools::MacOS;

use strict;
use warnings;
use base 'Exporter';

use English qw(-no_match_vars);
use Memoize;
use POSIX 'strftime';
use Time::Local;
use XML::TreePP;
use UNIVERSAL::require;

use FusionInventory::Agent::Tools;

our @EXPORT = qw(
    getSystemProfilerInfos
    getIODevices
    getBootTime
);

memoize('getSystemProfilerInfos');

use constant {
    KEY_ELEMENT_NAME   => 'key',
    VALUE_ELEMENT_NAME => 'string',
    DATE_ELEMENT_NAME  => 'date'
};

sub _getSystemProfilerInfosXML {
    my (%params) = @_;

    my $command = $params{type} ?
        "/usr/sbin/system_profiler -xml $params{type}" : "/usr/sbin/system_profiler -xml";
    my $xmlStr = getAllLines(command => $command, %params);
    return unless $xmlStr;

    # As we don't want to use a module platform dependent, we use the XML::TreePP module
    # with an option to keep XML's elements order
    #    my $xmlStr = join '', @xml;
    my $info = {};
    if ($params{type} eq 'SPApplicationsDataType') {
        $info = _extractDataFromXmlString($xmlStr, $params{logger}, $params{localTimeOffset});
    } else {
        # not implemented for every data types
    }

    return $info;
}

sub _extractDataFromXmlString {
    my ($xmlStr, $logger, $localTimeOffset) = @_;

    my $xmlHash = _parseXmlStringKeepingOrder($xmlStr, $logger);

    my $softwaresXmlHash = _extractInterestingPartOfHash($xmlHash);

    my $softwareHash;
    for my $hash (@$softwaresXmlHash) {
        my $soft = _pairKeyValueFromXml($hash);
        next unless $soft->{'_name'};
        $soft = _applySpecialRulesOnApplicationData($soft);
        my $convertedDate = _convertDateFromApplicationDataXml($soft->{lastModified}, $localTimeOffset);
        if (defined $convertedDate) {
            $soft->{lastModified} = $convertedDate;
        } else {
            if (defined $logger) {
                $logger->error("can't parse retrieved dates in 'lastModified' field in XML file");
            }
        }
        my $mappedHash = _mapApplicationDataKeys($soft);
        $softwareHash = _mergeHashes($softwareHash, $mappedHash);
    }

    return {
        'Applications' => $softwareHash
    };
}

sub _extractInterestingPartOfHash {
    my ($xmlHash) = @_;

    return _findElementAndReturnParentArray(undef, $xmlHash, 'key', '_name');
}

sub _findElementAndReturnParentArray {
    my ($parentArray, $struct, $elementName, $elementValue) = @_;

    my $foundArray;
    if ((ref $struct) eq 'HASH') {
        if ($parentArray && $struct->{$elementName}) {
            if (ref($struct->{$elementName}) eq ''
                && $struct->{$elementName} eq $elementValue) {
                $foundArray = $parentArray;
            } else {
                my %hash = map { $_ => 1 } @{$struct->{$elementName}};
                if ($hash{$elementValue}) {
                    $foundArray = $parentArray;
                }
            }
        } else {
            for my $key (keys %$struct) {
                my $ref = ref $struct->{$key};
                if ($ref ne '') {
                    $foundArray = _findElementAndReturnParentArray(undef, $struct->{$key}, $elementName, $elementValue);
                }
                last if $foundArray;
            }
        }
    } elsif ((ref $struct) eq 'ARRAY') {
        for my $subStruct (@$struct) {
            my $ref = ref $subStruct;
            if ($ref ne '') {
                $foundArray = _findElementAndReturnParentArray($struct, $subStruct, $elementName, $elementValue);
                last if $foundArray;
            }
        }
    }
    return $foundArray;
}

sub _pairKeyValueFromXml {
    my ($hashFromXml) = @_;

    my $names = $$hashFromXml{KEY_ELEMENT_NAME()};
    my $values = $$hashFromXml{VALUE_ELEMENT_NAME()};
    my $date = $$hashFromXml{DATE_ELEMENT_NAME()};

    my $soft = {};
    my $index = 0;
    for my $key (@$names) {
        my $value;
        if ($key eq 'lastModified') {
            $value = $date;
        } else {
            $value = $values->[$index];
            $index++;
        }
        $soft->{$key} = $value;
    }

    return $soft;
}

sub _parseXmlStringKeepingOrder {
    my ($xmlStr, $logger) = @_;

    # this module is required and cannot be imported by default
    # because it's for Mac OS X only
    Tie::IxHash->require();
    if ($EVAL_ERROR) {
        $logger->debug(
            'Tie::IxHash unavailable, unable launching _parseXmlStringKeepingOrder to retrieve softwares'
        ) if $logger;
        return 0;
    }

    my $tpp = XML::TreePP->new( use_ixhash => 1 );
    my $tree = $tpp->parse( $xmlStr );

    return $tree;
}

sub cmpVersionNumbers {
    my ($str1, $str2) = @_;

    my @list1 = reverse split(/\./, $str1);
    my @list2 = reverse split(/\./, $str2);

    my $cmp = 0;
    my $int1;
    while (
        $cmp == 0 && ($int1 = pop @list1)
    ) {
        $int1 = int($int1);
        my $int2 = pop @list2;
        if (defined $int2) {
            $int2 = int($int2);
            $cmp = $int1 <=> $int2;
        } else {
            $cmp = 1;
        }
    }
    # if $cmp is still 0 and list2 still contains values,
    # so $str2 is greater
    if ($cmp == 0 && (@list2) > 0) {
        $cmp = -1;
    }

    return $cmp;
}

sub _convertDateFromApplicationDataXml {
    my ($dateStrFromDataXml, $localtimeOffset) = @_;

    my $date;
    if ($dateStrFromDataXml =~ /^(\d{4})[^0-9](\d{2})[^0-9](\d{2})[^0-9](\d{2}):(\d{2}):(\d{2})[^0-9]$/) {
        $date = _convertDateToLocalDate($6, $5, $4, $3, $2 - 1, $1, $localtimeOffset);
    }

    return $date;
}

sub _convertDateToLocalDate {
    my ($sec,$min,$hour,$mday,$mon,$year, $localtimeOffset) = @_;

    my $epoch = timegm ($sec, $min, $hour, $mday, $mon, $year);

    my $newEpoch = $epoch + $localtimeOffset;

    return strftime("%d/%m/%Y", gmtime($newEpoch));
}

sub detectLocalTimeOffset {
    my @gmTime = localtime;
    return -(timelocal(@gmTime) - timegm(@gmTime));
}

sub _applySpecialRulesOnApplicationData {
    my ($hash) = @_;

    if (defined($hash->{has64BitIntelCode})) {
        $hash->{has64BitIntelCode} = ucfirst $hash->{has64BitIntelCode};
    }
    if (defined($hash->{runtime_environment})) {
        if ($hash->{runtime_environment} eq 'arch_x86') {
            $hash->{runtime_environment} = 'Intel';
        }
        $hash->{runtime_environment} = ucfirst $hash->{runtime_environment};
    }

    return $hash;
}

sub _mergeHashes {
    my ($hash1, $hash2) = @_;

    for my $key (keys %$hash2) {
        my $newKey = $key;
        if (defined($hash1->{$key})) {
            my $i = 0;
            $newKey = $key . '_' . $i;
            while (defined($hash1->{$newKey})) {
                $newKey = $key . '_' . $i++;
            }
        }
        $hash1->{$newKey} = $hash2->{$key};
    }

    return $hash1;
}

sub _extractApplicationDataFromXmlStringElement {
    my ($xmlString) = @_;

    my $hash = {};
    while ($xmlString =~ /<key>([^<]+)<\/key><(?:string|date)>([^<]+)<\/(?:string|date)>/g) {
        $hash->{$1} = $2;
    }

    return $hash;
}

sub _mapApplicationDataKeys {
    my ($hash) = @_;

    my $mapping = {
        'version' => 'Version',
        'has64BitIntelCode' => '64-Bit (Intel)',
        'lastModified' => 'Last Modified',
        'path' => 'Location',
        'runtime_environment' => 'Kind',
        'info' => 'Get Info String'
    };
    my %hashMapped = map { ($mapping->{$_} || 'unMapped') => $hash->{$_} } keys %$hash;
    delete $hashMapped{unMapped};

    # to merge two hashes
    # @hash1{keys %hash2} = values %hash2

    return { $hash->{'_name'} => \%hashMapped };
}

sub getSystemProfilerInfos {
    my (%params) = @_;

    my $info;
    if ($params{format} && $params{format} eq 'xml') {
        $info = _getSystemProfilerInfosXML(%params);
    } else {
        $info = _getSystemProfilerInfosText(%params);
    }

    return $info;
}

sub _getSystemProfilerInfosText {
    my (%params) = @_;

    my $command = $params{type} ?
        "/usr/sbin/system_profiler $params{type}" : "/usr/sbin/system_profiler";
    my $handle = getFileHandle(command => $command, %params);

    my $info = {};

    my @parents = (
        [ $info, -1 ]
    );
    while (my $line = <$handle>) {
        chomp $line;

        next unless $line =~ /^(\s*)(\S[^:]*):(?: (.*\S))?/;
        my $level = defined $1 ? length($1) : 0;
        my $key = $2;
        my $value = $3;

        my $parent = $parents[-1];
        my $parent_level = $parent->[1];
        my $parent_node  = $parent->[0];

        if (defined $value) {
            # check indentation level against parent node
            if ($level <= $parent_level) {

                if (keys %$parent_node == 0) {
                    # discard just created node, and fix its parent
                    my $parent_key = $parent->[2];
                    $parents[-2]->[0]->{$parent_key} = undef;
                }

                # unstack nodes until a suitable parent is found
                while ($level <= $parents[-1]->[1]) {
                    pop @parents;
                }
                $parent_node = $parents[-1]->[0];
            }

            # add the value to the current node
            $parent_node->{$key} = $value;
        } else {
            # compare level with parent
            if ($level > $parent_level) {
                # down the tree: no change
            } elsif ($level < $parent_level) {
                # up the tree: unstack nodes until a suitable parent is found
                while ($level <= $parents[-1]->[1]) {
                    pop @parents;
                }
            } else {
                # same level: unstack last node
                pop @parents;
            }

            # create a new node, and push it to the stack
            my $parent_node = $parents[-1]->[0];

            my $i;
            my $keyL = $key;
            while (defined($parent_node->{$key})) {
                $key = $keyL . '_' . $i++;
            }

            $parent_node->{$key} = {};
            push (@parents, [ $parent_node->{$key}, $level, $key ]);
        }
    }
    close $handle;

    return $info;
}

sub getIODevices {
    my (%params) = @_;

    # passing expected class to the command ensure only instance of this class
    # are present in the output, reducing the size of the content to be parsed,
    # but still requires some manual filtering to avoid subclasses instances
    my $command = $params{class} ? "ioreg -c $params{class}" : "ioreg -l";
    my $filter = $params{class} || '[^,]+';

    my $handle = getFileHandle(command => $command, %params);
    return unless $handle;

    my @devices;
    my $device;


    while (my $line = <$handle>) {
        if ($line =~ /<class $filter,/) {
            # new device block
            $device = {};
            next;
        }

        next unless $device;

        if ($line =~ /\| }/) {
            # end of device block
            push @devices, $device;
            undef $device;
            next;
        }

        if ($line =~ /"([^"]+)" \s = \s <? (?: "([^"]+)" | (\d+)) >?/x) {
            # string or numeric property
            $device->{$1} = $2 || $3;
            next;
        }

    }
    close $handle;

    return @devices;
}

sub getBootTime {
    my (%params) = @_;
    if (!$params{string} && !$params{command}) {
        $params{command} = 'sysctl -n kern.boottime';
    }
    my $boottime = getFirstMatch(
        pattern => qr/(?: sec = (\d+)|(\d+)$)/,
        %params
    );

    return $boottime;
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Tools::MacOS - MacOS generic functions

=head1 DESCRIPTION

This module provides some generic functions for MacOS.

=head1 FUNCTIONS

=head2 getSystemProfilerInfos(%params)

Returns a structured view of system_profiler output. Each information block is
turned into a hashref, hierarchically organised.

$info = {
    'Hardware' => {
        'Hardware Overview' => {
            'SMC Version (system)' => '1.21f4',
            'Model Identifier' => 'iMac7,1',
            ...
        }
    }
}

=over

=item logger a logger object

=item command the exact command to use (default: /usr/sbin/system_profiler)

=item file the file to use, as an alternative to the command

=back

=head2 getIODevices(%params)

Returns a flat list of devices as a list of hashref, by parsing ioreg output.
Relationships are not extracted.

=over

=item logger a logger object

=item class the class of devices wanted

=item file the file to use, as an alternative to the command

=back
