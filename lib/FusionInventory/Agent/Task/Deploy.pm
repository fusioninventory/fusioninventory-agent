package FusionInventory::Agent::Task::Deploy;
our $VERSION = '0.0.1';

use strict;
use warnings;

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
    my ($params) = @_;

#    my $deviceid;
#    my $part;
#    my $uuid;
#    my $status;
#    my $message;
    my $ua = LWP::UserAgent->new;

    my $url = $baseUrl."?a=setStatus";

    foreach (keys %$params) {
        $url .= "&$_=".uri_escape($params->{$_});
    }

    print $url."\n";


    my $cpt = 1;
    do {
        my $response = $ua->get($url);
        return if $response->is_success;

        print "FAILED TO UPDATE THE STATUS.\n";
        print "while retry in 600 seconds ($cpt/5)\n";
        sleep(600);
    } while ($cpt++ <= 5);
}

sub setLog {
    my ($params) = @_;

    my $ua = LWP::UserAgent->new;

    my $url = $baseUrl."?a=setLog&d=".$params->{d}."&u=".$params->{u};

    print $url."\n";

    my $fh;
    my $content;
    foreach (@{$params->{l}}) {
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

sub main {

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
         updateStatus({ d => 'DEVICEID', p => 'job', u => $job->{uuid}, s => 'received' });
         foreach my $file (@{$job->{associatedFiles}}) {
             if ($file->exists()) {
                 updateStatus({ d => 'DEVICEID', p => 'file', u => $file->{sha512}, s => 'ok' });
                 $workdir->addFile($file);
                 next;
             }
             updateStatus({ d => 'DEVICEID', p => 'file', u => $file->{sha512}, s => 'downloading' });
             $file->download();
             if ($file->exists()) {
                 updateStatus({ d => 'DEVICEID', p => 'file', u => $file->{sha512}, s => 'ok' });
                 $workdir->addFile($file);
             } else {
                 updateStatus({ d => 'DEVICEID', p => 'file', u => $file->{sha512}, s => 'ko', m => 'download failed' });
                 next JOB;
             }
         }


         if (!$job->checkWinkey()) {
             updateStatus({ d => 'DEVICEID', p => 'job', u => $job->{uuid}, s => 'ko', m => 'rejected because of a Windows registry check' });
             next JOB;
         } elsif (!$job->checkFreespace()) {
             updateStatus({ d => 'DEVICEID', p => 'job', u => $job->{uuid}, s => 'ko', m => 'rejected because of harddrive free space' });
             next JOB;
         }

         $workdir->prepare();

         my $actionProcessor = FusionInventory::Agent::Task::Deploy::ActionProcessor->new({ workdir => $workdir });
         updateStatus({ d => 'DEVICEID', p => 'job', u => $job->{uuid}, s => 'processing' });
         while (my $action = $job->getNextToProcess()) {
             my $ret = $actionProcessor->process($action);
             if (!$ret->{status}) {
                 setLog({ d => 'DEVICEID', u => $job->{uuid}, l => $ret->{log} });
                 updateStatus({ d => 'DEVICEID', p => 'job', u => $job->{uuid}, s => 'ko', m => 'action processing failure' });
                 next JOB;
             }
         }
         updateStatus({ d => 'DEVICEID', p => 'job', u => $job->{uuid}, s => 'ok' });

     }


#$datastore->cleanUp();
}


__END__

=head1 NAME

FusionInventory::Agent::Task::OcsDeploy - OCS Inventory Software deployment support for FusionInvnetory Agent

=head1 DESCRIPTION

With this module, F<FusionInventory> can accept software deployment
request from an OCS Inventory server.

OCS Inventory uses SSL certificat to authentificat the server. You may have
to point F<--ca-cert-file> or F<--ca-cert-dir> to your public certificat.

If the P2P option is turned on, the agent will looks for peer in its network. The network size will be limited at 255 machines.

=cut
