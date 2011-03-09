#!/usr/bin/perl -w

use strict;
use warnings;

use lib 'lib';
use LWP;
use JSON;
use LWP::Simple;
use Data::Dumper;
use URI::Escape;
use FusionInventory::Agent::Task::Deploy::Job;
use FusionInventory::Agent::Task::Deploy::File;
use FusionInventory::Agent::Task::Deploy::Datastore;
use FusionInventory::Agent::Task::Deploy::ActionProcessor;
use FusionInventory::Agent::Task::Deploy::CheckProcessor;

my $baseUrl = "http://nana.rulezlan.org/deploy/ocsinventory/deploy/";


sub updateStatus {
    my ($deviceid, $part, $uuid, $status, $message) = @_;

    my $ua = LWP::UserAgent->new;

    my $url = $baseUrl."?a=setStatus&d=$deviceid&part=$part&u=$uuid&s=$status&m=".(uri_escape($message)||'');

    print $url."\n";

    my $response = $ua->get($url);
    if (!$response->is_success) {
        print "FAILED TO UPDATE THE STATUS\n";
        sleep(600);
        $response = $ua->get($url);
    }
}

sub setLog {
    my ($deviceid, $uuid, $log) = @_;

    my $ua = LWP::UserAgent->new;

    my $url = $baseUrl."?a=setLog&d=$deviceid&u=$uuid";

    print $url."\n";

    my $fh;
    my $content;
    foreach (@$log) {
        $content .= $_."\n";
    }

    my $response = $ua->post($url, { log => $content });
    if (!$response->is_success) {
        print "FAILED TO SEND THE LOG\n";
        sleep(600);
        $response = $ua->post($url, {log => $content});
    }
}

sub getJobs {
    my ($datastore) = @_;

    my $ret = [];

    my $files = {};

    my $jsonText = get ($baseUrl.'?a=getJobs&ddeviceId');
#    print $jsonText."\n";
    my $jsonHash = from_json( $jsonText, { utf8  => 1 } );
    print to_json( $jsonHash, { ascii => 1, pretty => 1 } );

    foreach my $sha512 (keys %{$jsonHash->{associatedFiles}}) {
        $files->{$sha512} = FusionInventory::Agent::Task::Deploy::File->new({
                sha512 => $sha512,
                data => $jsonHash->{associatedFiles}{$sha512},
                datastore => $datastore
                });
    }

    foreach (@{$jsonHash->{jobs}}) {
        my $associatedFiles = [];
        if ($_->{associatedFiles}) {
            foreach my $uuid (@{$_->{associatedFiles}}) {
                if (!$files->{$uuid}) {
                    die "unknow file: `".$uuid."'. Not found in YSON answer!";
                }
                push @$associatedFiles, $files->{$uuid};
            }
        }
        push @$ret, FusionInventory::Agent::Task::Deploy::Job->new({
                data => $_,
                associatedFiles => $associatedFiles
                });
    }

    $ret;
}

my $datastore = FusionInventory::Agent::Task::Deploy::Datastore->new({
        path => '/tmp',
        });
$datastore->cleanUp();

my $jobList = getJobs($datastore);
JOB: foreach my $job (@$jobList) {
         updateStatus({ d => 'DEVICEID', p => 'job', u => $job->{uuid}, s => 'received' });
        if (ref($job->{checks}) eq 'ARRAY') {
            my $checkProcessor = FusionInventory::Agent::Task::Deploy::CheckProcessor->new();
            foreach my $checknum (0..@{$job->{checks}}) {
print $checknum."\n";
                next unless $job->{checks}[$checknum];
                if (!$checkProcessor->process($job->{checks}[$checknum])) {
                    updateStatus({ d => 'DEVICEID', p => 'job', u => $job->{uuid}, s => 'ko', m => 'check failed', cheknum => $checknum });
                    next JOB;
                }
            }
        }



         my $workdir = $datastore->createWorkDir($job->{uuid});
         print "\n\n\n------------------------\n";
         updateStatus('DEVICEID', 'job', $job->{uuid}, 'received');
         foreach my $file (@{$job->{associatedFiles}}) {
             if ($file->exists()) {
                 updateStatus('DEVICEID', 'file', $file->{sha512}, 'ok');
                 $workdir->addFile($file);
                 next;
             }
             updateStatus('DEVICEID', 'file', $file->{sha512}, 'downloading');
             $file->download();
             if ($file->exists()) {
                 updateStatus('DEVICEID', 'file', $file->{sha512}, 'ok');
                 $workdir->addFile($file);
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

         $workdir->prepare();

         my $actionProcessor = FusionInventory::Agent::Task::Deploy::ActionProcessor->new({ workdir => $workdir });
         updateStatus('DEVICEID', 'job', $job->{uuid}, 'processing');
         while (my $action = $job->getNextToProcess()) {
             my $ret = $actionProcessor->process($action);
             if (!$ret->{status}) {
                 setLog('DEVICEID', $job->{uuid}, $ret->{log});
                 print Dumper($ret->{log});
                 updateStatus('DEVICEID', 'job', $job->{uuid}, 'ko', 'action processing failure');
                 next JOB;
             }
         }
         updateStatus('DEVICEID', 'job', $job->{uuid}, 'ok');

     }

#$datastore->cleanUp();
