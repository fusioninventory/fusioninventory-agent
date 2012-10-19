package FusionInventory::Agent::Task::Inventory::Input::MacOS::License;

use strict;
use warnings;

use File::Glob;
use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Generic::License;

sub isEnabled {
    return unless -f "/Library/Application Support/Adobe/Adobe PCD/cache/cache.db";
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

    my $inventory    = $params{inventory};
    my $scanhomedirs = $params{scan_homedirs};


    my @found = getAdobeLicenses( command => 'sqlite3 -separator " <> " "/Library/Application Support/Adobe/Adobe PCD/cache/cache.db" "SELECT * FROM domain_data"');


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

    foreach my $license (@found) {
        $inventory->addEntry(section => 'LICENSEINFOS', entry => $license);
    }
}

1;
