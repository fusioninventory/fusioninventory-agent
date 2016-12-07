#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use Dpkg::Control::Info;
use Dpkg::Changelog::Debian;

$ENV{'DEBFULLNAME'} = 'Gonéri Le Bouder';
$ENV{'EMAIL'}       = 'goneri@rulezlan.org';

my %dropTest = (
    'fusioninventory-agent' => [
        't/components/client/ocs/response.t', 't/xml/response.t',
        't/components/logger.t',              't/components/client/ssl.t',
        't/components/client/connection.t',   't/01compile.t',
        't/apps/agent.t',
    ],
    'libfusioninventory-agent-task-deploy-perl' => [ 't/server.t', ]

);

my %newDeps = (
    'Depends' => {
        'libfusioninventory-agent-task-esx-perl' => [ 'libio-socket-ssl-perl' ],
    },
    'Build-Depends' => {
        'libfusioninventory-agent-task-esx-perl' => [ 'libio-socket-ssl-perl' ]

      }

);

open RULES, "<debian/rules";
my @origin_rules = <RULES>;
close RULES;
open RULES, ">debian/rules";
foreach (@origin_rules) {
    s/BACKPORT = no/BACKPORT = yes/;
    print RULES;
}
close RULES;

sub bpDeps {
    my ($pkg) = @_;

    my $name = $pkg->{Package} || $pkg->{Source};
    foreach my $section (qw/Build-Depends Build-Depends-Indep Depends/) {
        next unless $pkg->{$section};
        $pkg->{$section} =~ s/\s*\n//g;
        my @list = split( /,/, $pkg->{$section} );

        my @listFinal;
        foreach (@list) {
            s/^\s*//;
            next if $_ eq "libhttp-daemon-perl";
            next if $_ eq "libhttp-server-simple-authen-perl";
            next if $_ eq "libhttp-cookies-perl";
            push @listFinal, $_;
        }
        if ( $newDeps{$section}->{$name} ) {
            push @listFinal, $_ foreach ( @{ $newDeps{$section}->{$name} } );
        }
        $pkg->{$section} = join( ",\n", @listFinal );
    }

}

my $c = Dpkg::Control::Info->new("debian/control");

my $s = $c->get_source();
bpDeps($s);
use Data::Dumper;

my @pList = $c->get_packages();
foreach my $p (@pList) {
    bpDeps($p);
}

open my $f, ">debian/control";
$c->output($f);

foreach ( @{ $dropTest{ $s->{Source} } } ) {
    unlink($_);
}

my $changelog = Dpkg::Changelog::Debian->new();
$changelog->load('debian/changelog');
use Data::Dumper;
if ( $changelog->[0]->get_distributions() ne 'squeeze-backports' ) {
    system("dch --bpo");
}

my $lastVersion = $changelog->[ @$changelog - 1 ]->get_version();
if ( `rmadison $s->{Source} -s squeeze-backports` =~ /^[^\|]*\|\s(\S+)~bpo6/ ) {
    $lastVersion = "-v$1";
}
print "lastVersion: $lastVersion\n";
system( "dpkg-buildpackage", "-i", "-sa", "-v$lastVersion" );
