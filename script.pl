#!/usr/bin/perl -w

use strict;
use warnings;

use LWP;
use JSON;
use LWP::Simple;
use Data::Dumper;
use FusionInventory::Agent::Task::Deploy::Job;
use FusionInventory::Agent::Task::Deploy::File;
use FusionInventory::Agent::Task::Deploy::Datastore;

my @jobs;
my %files;

my $baseUrl = "http://deploy/ocsinventory/deploy";

sub getJobs {
    
    my $json_text = get ($baseUrl.'/?a=getJobs&ddeviceId');

    my $perl_scalar = from_json( $json_text, { utf8  => 1 } );
#    print Dumper($perl_scalar);

    foreach (@{$perl_scalar->{jobs}}) {
        push @jobs, FusionInventory::Agent::Task::Deploy::Job->new($_);
    }

    foreach my $sha512 (keys %{$perl_scalar->{files}}) {
        $files{$sha512} = FusionInventory::Agent::Task::Deploy::File->new($sha512, $perl_scalar->{files}{$sha512});
    }
}


getJobs();

my $datastore = FusionInventory::Agent::Task::Deploy::Datastore->new({ location => '/tmp' });

print Dumper(\@jobs);
print Dumper(\%files);

