#!/usr/bin/perl

use strict;
use warnings;

use Test::Deep;
use Test::More;

use FusionInventory::Agent::Tools::Generic::License;

my %adobe_tests = (
    'sample1' => [
        {
            'KEY' => '0054-9254-6385-5325-8335',
            'NAME' => 'InCopy-CS5.5-Mac-GM',
            'COMPONENTS' => 'InCopy-CS5.5-Mac-GM',
            'FULLNAME' => 'Adobe InCopy CS5.5'
        },
        {
            'KEY' => '0054-9254-6813-4374-8223',
            'NAME' => 'DesignSuitePremium-CS5.5-Mac-GM',
            'COMPONENTS' => 'Photoshop-CS5.5-Mac-GM/AcrobatPro-AS1-Mac-GM/Dreamweaver-CS5.5-Mac-GM/Fireworks-CS5.5-Mac-GM/FlashCatalyst-CS5.5-Mac-GM/FlashPro-CS5.5-Mac-GM/Illustrator-CS5.5-Mac-GM/InDesign-CS5.5-Mac-GM',
            'FULLNAME' => 'Creative Suite 5.5 Design Premium'
        }
    ]
);

plan tests => scalar keys %adobe_tests;

foreach my $test (keys %adobe_tests) {
    my $file = "resources/generic/license/adobe/cache.db-$test";
    my @licenses = FusionInventory::Agent::Tools::Generic::License::getAdobeLicenses(file => $file);
    cmp_deeply(\@licenses, $adobe_tests{$test}, $test);
}

1;
