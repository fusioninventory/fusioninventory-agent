package FusionInventory::Agent::Task::Inventory::Input::MacOS::License;

use strict;
use warnings;

use MIME::Base64;
use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Generic;
use FusionInventory::Agent::Tools::Generic::License;

sub isEnabled { 1 }


sub doInventory {
    my (%params) = @_;


    my $adobeDB = "/Library/Application Support/Adobe/Adobe PCD/cache/cache.db";

    if ($adobeDB) {
        my @found = getAdobeLicenses( command => "sqlite3 -separator \" <> \" \"$adobeDB\" \"SELECT * FROM domain_data\"");


        foreach my $license (@found) {
            $params{inventory}->addEntry(section => 'LICENSEINFOS', entry => $license);
        }
    }

    my $office2008File = "/Applications/Microsoft Office 2008/Office/OfficePID.plist";

    if (-f $office2008File) {
        # http://www.perlmonks.org/?node_id=861663
        my $fh = getFileHandle ('command' => "plutil -convert xml1 -o - $office2008File");
        my $flag = 0;
        my $section = 0;
        my $string;
        foreach(<$fh>) {
            $flag = 1 if (m/<key>2000<\/key>/);
            $section++ if ($section == 1);
            $section = 1 if (m/<data>/ && $flag==1);
            if (m/<\/data>/) {
                $flag = 0;
                $section = 0;
            }
            if ($section == 2) {
                $string .= $_;
            }
        }
        close($fh);
        $string =~ s/\s//g;
        my $hex = uc(unpack("H*", decode_base64($string)));
        $hex =~ s/(..)/$1,/g;
        chop($hex);
        $params{inventory}->addEntry(section => 'LICENSEINFOS', entry => {
            NAME => 'Microsoft Office 2008',
            KEY => decodeWinKey($hex)
        });
    }

    my $office2011File = "/Library/Preferences/com.microsoft.office.licensing.plist";

    if (-f $office2011File) {
        my $fh = getFileHandle ('command' => "plutil -convert xml1 -o - $office2011File");
        my $string;
        foreach my $line (<$fh>) {
                last if $string && $line =~ /^\s+</;
                next if $line =~ /^\s+</;
                $string .= $1 if $line =~ /^\s+(\S+)/;
        }
        close $fh;
        my $hex = uc(unpack("H*", decode_base64($string)));
        $hex =~ s/(..)/$1,/g;
        chop($hex);

        $params{inventory}->addEntry(section => 'LICENSEINFOS', entry => {
            NAME => 'Microsoft Office 2011',
            KEY => decodeWinKey($hex)
        });
    }


}

1;
