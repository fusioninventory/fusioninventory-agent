package FusionInventory::Agent::Task::Inventory::MacOS::License;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::License;

sub isEnabled {
    my (%params) = @_;
    return 0 if $params{no_category}->{licenseinfo};
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    # Adobe
    my @found = getAdobeLicenses(
        command => 'sqlite3 -separator " <> " "/Library/Application Support/Adobe/Adobe PCD/cache/cache.db" "SELECT * FROM domain_data"'
    );

    # Transmit
    my @transmitFiles = glob('"/System/Library/User Template/*.lproj/Library/Preferences/com.panic.Transmit.plist"');

    if ($params{scan_homedirs}) {
        push @transmitFiles, glob('/Users/*/Library/Preferences/com.panic.Transmit.plist');
    } else {
        $logger->info(
            "'scan-homedirs' configuration parameters disabled, " .
            "ignoring transmit installations in user directories"
        );
    }

    foreach my $transmitFile (@transmitFiles) {
        my $info = _getTransmitLicenses(
            command => "plutil -convert xml1 -o - '$transmitFile'"
        );
        next unless $info;
        push @found, $info;
        last; # One installation per machine
    }

    # VMware
    my @vmwareFiles = glob('"/Library/Application Support/VMware Fusion/license-*"');
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
        NAME     => "Transmit",
        FULLNAME => "Panic's Transmit",
        KEY      => $val{KEY}
    };
}

1;
