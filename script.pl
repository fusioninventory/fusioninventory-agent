#!/usr/bin/perl -w

use strict;
use warnings;

use lib '/home/goneri/fusioninventory/agent/lib';
use lib 'lib';
use LWP;
use JSON;
use LWP::Simple;
use Data::Dumper;
use FusionInventory::Agent::Task::Deploy::Job;
use FusionInventory::Agent::Task::Deploy::File;
use FusionInventory::Agent::Task::Deploy::Datastore;

my $baseUrl = "http://deploy/ocsinventory/deploy";

sub updateStatus {
    my ($deviceid, $part, $uuid, $status, $message) = @_;

    my $ua = LWP::UserAgent->new;

    my $url = $baseUrl."?a=setStatus&d=$deviceid&part=$part&u=$uuid&s=$status&m=".($message||'');

    print $url."\n";

    my $response = $ua->get();
return;
    if (!$response->is_success) {
        print "FAILED TO UPDATE THE STATUS\n";
        sleep(600);
        $response = $ua->get($url);
    }
}

sub getJobs {

    my $ret = [];

    my $files = {};

    my $json_text = get ($baseUrl.'?a=getJobs&ddeviceId');
    print $json_text."\n";

    my $perl_scalar = from_json( $json_text, { utf8  => 1 } );
#    print to_json( $perl_scalar, { ascii => 1, pretty => 1 } );

    my $datastore = FusionInventory::Agent::Task::Deploy::Datastore->new({
            path => '/tmp',
            });
    foreach my $sha512 (keys %{$perl_scalar->{files}}) {
        $files->{$sha512} = FusionInventory::Agent::Task::Deploy::File->new({
                sha512 => $sha512,
                data => $perl_scalar->{files}{$sha512},
                datastore => $datastore
                });
    }

    foreach (@{$perl_scalar->{jobs}}) {
        push @$ret, FusionInventory::Agent::Task::Deploy::Job->new({
                data => $_,
                files => $files
                });
    }

    $ret;
}


my $jobList = getJobs();
JOB: foreach my $job (@$jobList) {
         updateStatus('DEVICEID', 'job', $job->{uuid}, 'received');
         foreach my $file (@{$job->{files}}) {
             if ($file->exists()) {
                 updateStatus('DEVICEID', 'file', $file->{sha512}, 'ok');
                 next;
             }
             updateStatus('DEVICEID', 'file', $file->{sha512}, 'downloading');
             $file->download();
             if ($file->exists()) {
                 updateStatus('DEVICEID', 'file', $file->{sha512}, 'ok');
             } else {
                 updateStatus('DEVICEID', 'file', $file->{sha512}, 'ko', 'download failed');
                 next JOB;
             }
         }

         if (!$job->checkWinkey()) {
             updateStatus('DEVICEID', 'job', $job->{uuid}, 'ko', 'rejected because of a Windows registry check');
             next JOB;
         } elsif (!$job->checkFreespace()) {
             updateStatus('DEVICEID', 'job', $job->{uuid}, 'ko', 'rejected because of harddrive free space');
             next JOB;
         }

     }
