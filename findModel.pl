#!/usr/bin/perl

use File::Glob;
use XML::TreePP;
use Data::Dumper;
use FusionInventory::Agent::SNMP::Mock;
use UNIVERSAL::require;

my $file = shift;

my $snmp = FusionInventory::Agent::SNMP::Mock->new(
    file => $file
);

my $sysdescr = $snmp->get('.1.3.6.1.2.1.1.1.0');
$sysdescr =~ s/\n//g;
$sysdescr =~ s/\r//g;

my $model_dir = "/home/goneri/public_html/glpi/plugins/fusinvsnmp/models";

foreach my $file (glob("$model_dir/*.xml")) {
    my $tpp = XML::TreePP->new( force_array => [qw( sysdescr )] );
    my $tree = $tpp->parsefile( $file );
    next unless $sysdescr;
    my $associatedSysdescrs = $tree->{model}{devices}{sysdescr};
    next unless $associatedSysdescrs;

    foreach my $m (@$associatedSysdescrs) {
        $m =~ s{\\\\}{}g;
        if ($sysdescr eq $m) {
            print "Model found: $file\n";
        }
    }

}
