package FusionInventory::Agent::Task::Inventory::MacOS::Softwares;

use strict;
use warnings;
use Time::Piece;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::MacOS;

sub isEnabled {
    my (%params) = @_;

    return
        !$params{no_category}->{software} &&
        canRun('/usr/sbin/system_profiler');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    my $softwares = _getSoftwaresList(logger => $params{logger}, format => 'xml');
    return unless $softwares;

    foreach my $software (@$softwares) {
        $inventory->addEntry(
            section => 'SOFTWARES',
            entry   => $software
        );
    }
}

sub _getSoftwaresList {
    my (%params) = @_;
    my $logger = $params{logger};

    my $infos;
    my $datesAlreadyFormatted = 1;
    # when format used is 'text', dates are not formatted
    # they have to be formatted so we use this variable to format dates if needed
    if (!$params{format} || $params{format} eq 'text') {
        $datesAlreadyFormatted = 0;
    }
    my $localTimeOffset = FusionInventory::Agent::Tools::MacOS::detectLocalTimeOffset();
    $infos = FusionInventory::Agent::Tools::MacOS::getSystemProfilerInfos(
        %params,
        type            => 'SPApplicationsDataType',
        localTimeOffset => $localTimeOffset
    );

    my $info = $infos->{Applications};

    my @softwares;
    for my $name (keys %$info) {
        my $app = $info->{$name};

        # Windows application found by Parallels (issue #716)
        next if
            $app->{'Get Info String'} &&
            $app->{'Get Info String'} =~ /^\S+, [A-Z]:\\/;

        my $formattedDate = $app->{'Last Modified'};
        if (!$datesAlreadyFormatted) {
            $formattedDate = _formatDate($formattedDate, $logger)
        }

        my ($category, $userName) = _extractSoftwareSystemCategoryAndUserName($app->{'Location'});
        push @softwares, {
            NAME      => $name,
            VERSION   => $app->{'Version'},
            COMMENTS  => $app->{'Kind'} ? '[' . $app->{'Kind'} . ']' : undef,
            PUBLISHER => $app->{'Get Info String'},
            # extract date's data and format these data
            INSTALLDATE => $formattedDate,
            SYSTEM_CATEGORY => $category,
            USERNAME => $userName
        };
    }

    return \@softwares;
}

sub _extractSoftwareSystemCategoryAndUserName {
    my ($str) = @_;

    my $category = '';
    my $userName = '';
    return ($category, $userName) unless $str;

    if ($str =~ /^\/Users\/([^\/]+)\/([^\/]+\/[^\/]+)\//
        || $str =~ /^\/Users\/([^\/]+)\/([^\/]+)\//) {
        $userName = $1;
        $category = $2 if $2 !~ /^Downloads|^Desktop/;
    } elsif ($str =~ /^\/Volumes\/[^\/]+\/([^\/]+\/[^\/]+)\//
        || $str =~ /^\/Volumes\/[^\/]+\/([^\/]+)\//
        || $str =~ /^\/([^\/]+\/[^\/]+)\//
        || $str =~ /^\/([^\/]+)\//) {
        $category = $1;
    }

    return ($category, $userName);
}

sub _formatDate {
    my ($dateStr, $logger) = @_;

    my $formattedDate = '';

    my $extractionPatternWithAmOrPm = "%m/%d/%y %l:%M %p";
    my $extractionPattern = "%m/%d/%y %H:%M";
    my $extractionPatternUsed = '';

    my $outputFormat = "%d/%m/%Y";

    # trim
    $dateStr =~ s/^\s+|\s+$//g;
    # AM or PM detection in end of string
    if ($dateStr =~ /(?:AM|PM)$/) {
        $extractionPatternUsed = $extractionPatternWithAmOrPm;
    } else {
        $extractionPatternUsed = $extractionPattern;
    }

    my $func = sub {
        if (defined $logger) {
            $logger->error("FusionInventory::Agent::Task::Inventory::MacOS::Softwares::_formatDate() : can't parse string '$dateStr', returns empty string.\n");
        }
    };
    eval {
        my $extracted = Time::Piece->strptime(
            $dateStr,
            $extractionPatternUsed
        );
        $formattedDate = $extracted->strftime(
            $outputFormat
        );
    };
    &$func if $@;

    return $formattedDate;
}

1;
