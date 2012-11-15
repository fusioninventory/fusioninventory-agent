package FusionInventory::Agent::Task::Inventory::Input::MacOS::License;

use strict;
use warnings;

use File::Glob;
use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Generic::License;

sub isEnabled {
    return 1;
}

sub _getTransmitLicenses {
    my (%params) = @_;

    my $handle = getFileHandle(%params);

    my %val;
    my $in;
    foreach my $line (<$handle>) {
        if ($in) {
            $val{$in} = $1 if $line =~ /<string>([\d\w\.-]+)<\/string>/;
            $in = undef;
        } elsif ($line =~ /<key>SerialNumber2/) {
            $in = "KEY";
        } elsif ($line =~ /<key>PreferencesVersion<\/key>/) {
            $in = "VERSION";
        }
    }

    return unless $val{KEY};

    return {
        NAME => "Transmit",
        FULLNAME => "Panic's Transmit",
                KEY => $val{KEY}
    };
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    # Adobe
    my @found = getAdobeLicenses(command => 'sqlite3 -separator " <> " "/Library/Application Support/Adobe/Adobe PCD/cache/cache.db" "SELECT * FROM domain_data"');

    # Transmit
    my @transmitFiles = File::Glob::bsd_glob('/System/Library/User Template/*.lproj/Library/Preferences/com.panic.Transmit.plist');
    if ($params{scan_homedirs}) {
        push (@transmitFiles, File::Glob::bsd_glob('/Users/*/Library/Preferences/com.panic.Transmit.plist'));
    }

    foreach my $transmitFile (@transmitFiles) {
        my $info = _getTransmitLicenses( command => "plutil -convert xml1 -o - '$transmitFile'" );
        next unless $info;
        push @found, $info;
        last; # One installation per machine
    }

    # VMware
    my @vmwareFiles = File::Glob::bsd_glob('/Library/Application Support/VMware Fusion/license-*');
    foreach my $vmwareFile (@vmwareFiles) {
        my %info;
        # e.g:
        # LicenseType = "Site"
        my $handle = getFileHandle(file => $vmwareFile);
        foreach (<$handle>) {
            next unless /^(\S+)\s=\s"(.*)"/;
            $info{$1} = $2;
        }
        next unless $info{Serial};

        my $date;
        if ($info{LastModified} =~ /(^2\d{3})-(\d{1,2})-(\d{1,2}) @ (\d{1,2}):(\d{1,2})/) {
            $date = getFormatedDate($1, $2, $3, $4, $5, 0);
        }

        push @found, {
            NAME            => $info{ProductID},
            FULLNAME        => $info{ProductID}." (".$info{LicenseVersion}.")",
            KEY             => $info{Serial},
            ACTIVATION_DATE => $date
        }
    }

    foreach my $license (@found) {
        $inventory->addEntry(section => 'LICENSEINFOS', entry => $license);
    }
}

1;
