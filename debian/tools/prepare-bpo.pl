#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use Dpkg::Control::Info;
use Dpkg::Changelog::Debian;

$ENV{'DEBFULLNAME'} = 'Debian Perl Group';
$ENV{'EMAIL'}       = 'pkg-perl-maintainers@lists.alioth.debian.org';

my %newDeps = (
    #'Depends' => {
    #    'libfusioninventory-agent-task-esx-perl' => [ 'libio-socket-ssl-perl' ],
    #},
    #'Build-Depends' => {
    #    'libfusioninventory-agent-task-esx-perl' => [ 'libio-socket-ssl-perl' ]
    #}
);

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
            #next if $_ eq "libhttp-daemon-perl";
            #next if $_ eq "libhttp-server-simple-authen-perl";
            #next if $_ eq "libhttp-cookies-perl";
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

my @pList = $c->get_packages();
foreach my $p (@pList) {
    bpDeps($p);
}

open my $f, ">debian/control" or die "Can't open control file: $!\n";
$c->output($f);
close($f);

my $changelog = Dpkg::Changelog::Debian->new();
$changelog->load('debian/changelog');
if ( $changelog->[0]->get_distributions() ne 'squeeze-backports' ) {
    system("dch --bpo");
}

my $lastVersion = $changelog->[ @$changelog - 1 ]->get_version();
if ( `rmadison $s->{Source} -s squeeze-backports` =~ /^[^\|]*\|\s(\S+)~bpo6/ ) {
    $lastVersion = "-v$1";
}
print "lastVersion: $lastVersion\n";
system( "dpkg-buildpackage", "-i", "-sa", "-v$lastVersion" );
