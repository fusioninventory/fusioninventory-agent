package FusionInventory::Agent::Task::Deploy;
our $VERSION = '0.0.1';

use strict;
use warnings;

use LWP;
use JSON;
use Data::Dumper;
use URI::Escape;
use FusionInventory::Logger;
use FusionInventory::Agent::Storage;
use FusionInventory::Agent::Network;
use FusionInventory::Agent::Task::Deploy::Job;
use FusionInventory::Agent::Task::Deploy::File;
use FusionInventory::Agent::Task::Deploy::Datastore;
use FusionInventory::Agent::Task::Deploy::ActionProcessor;
use FusionInventory::Agent::Task::Deploy::CheckProcessor;

sub updateStatus {
    my ($self, $params) = @_;

#    my $deviceid;
#    my $part;
#    my $uuid;
#    my $status;
#    my $message;
    #my $ua = LWP::UserAgent->new;
    my $network = $self->{network};

    my $url = $self->{backendURL}."/?a=setStatus";

    foreach (keys %$params) {
        $url .= "&$_=".uri_escape($params->{$_});
    }

    print $url."\n";


    my $cpt = 1;
    do {
        my $response = $network->get({ source => $url });
        return 1 if defined($response);

        print "FAILED TO UPDATE THE STATUS.\n";
        print "while retry in 600 seconds ($cpt/5)\n";
        sleep(600);
    } while ($cpt++ <= 5);

    return;
}

sub setLog {
    my ($self, $params) = @_;

    my $ua = LWP::UserAgent->new;

    my $url = $self->{backendURL}."/?a=setLog&d=".$params->{d}."&u=".$params->{u};

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
    my ($self, $datastore) = @_;

    my $logger = $self->{logger};
    my $network = $self->{network};

    my $ret = [];

    my $files = {};

    my $jsonText = $network->get ({
        source => $self->{backendURL}.'/?a=getJobs&ddeviceId',
        timeout => 60,
        });
    if (!defined($jsonText)) {
        $logger->debug("No answer from server for deployment job.");
        return;
    }

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
    my ( undef ) = @_;

    my $self = {};
    bless $self;

    my $storage = FusionInventory::Agent::Storage->new({
            target => {
                vardir => $ARGV[0],
            }
        });

    my $data = $storage->restore({
            module => "FusionInventory::Agent"
        });
    #my $myData = $self->{myData} = $storage->restore();

    print Dumper($data);
    my $config = $self->{config} = $data->{config};
    my $target = $self->{'target'} = $data->{'target'};
    my $logger = $self->{logger} = FusionInventory::Logger->new ({
            config => $self->{config}
        });

    return unless $target->{type} eq 'server';

    $self->{backendURL} = $target->{path};
    # In case the old URL is used.
    $self->{backendURL} =~ s#front/plugin_fusioninventory.communication.php##;
    # Debug Gonéri
    $self->{backendURL} =~ s#nana.rulezlan.org/ocsinventory#nana.rulezlan.org/ocsinventory2#;
    $self->{backendURL} .= "/deploy/";
    # DEBUG:
#    $self->{backendURL} = "http://nana.rulezlan.org/deploy/ocsinventory/deploy/";

    my $network = $self->{network} = FusionInventory::Agent::Network->new ({

            logger => $logger,
            config => $config,
            target => $target,

        });


    my $datastore = FusionInventory::Agent::Task::Deploy::Datastore->new({
            path => '/tmp',
            });
    $datastore->cleanUp();

    my $jobList = $self->getJobs($datastore);
    return unless defined($jobList);
JOB: foreach my $job (@$jobList) {

         # RECEIVED
         $self->updateStatus({ d => 'DEVICEID', p => 'job', u => $job->{uuid}, c => 'received' });

         $self->updateStatus({ d => 'DEVICEID', p => 'job', u => $job->{uuid}, c => 'checking' });
         # CHECKING
         if (ref($job->{checks}) eq 'ARRAY') {
             my $checkProcessor = FusionInventory::Agent::Task::Deploy::CheckProcessor->new();
             foreach my $checknum (0..@{$job->{checks}}) {
                 print $checknum."\n";
                 next unless $job->{checks}[$checknum];
                 if (!$checkProcessor->process($job->{checks}[$checknum])) {
                     $self->updateStatus({ d => 'DEVICEID', p => 'job', u => $job->{uuid}, c => 'checking', s => 'ko', m => 'check failed', cheknum => $checknum });
                     next JOB;
                 }
             }
         }

         # DOWNLOADING
         $self->updateStatus({ d => 'DEVICEID', p => 'job', u => $job->{uuid}, c => 'downloading' });
         my $workdir = $datastore->createWorkDir($job->{uuid});
         print "\n\n\n------------------------\n";
         foreach my $file (@{$job->{associatedFiles}}) {
             if ($file->exists()) {
                 $self->updateStatus({ d => 'DEVICEID', p => 'file', u => $file->{sha512}, s => 'ok' });
                 $workdir->addFile($file);
                 next;
             }
             $self->updateStatus({ d => 'DEVICEID', p => 'file', u => $file->{sha512}, c => 'downloading' });
             $file->download();
             if ($file->exists()) {
                 $self->updateStatus({ d => 'DEVICEID', p => 'file', u => $file->{sha512}, c => 'downloading', s => 'ok' });
                 $workdir->addFile($file);
             } else {
                 $self->updateStatus({ d => 'DEVICEID', p => 'file', u => $file->{sha512}, c => 'downloading', s => 'ko', m => 'download failed' });
                 next JOB;
             }
         }
         $self->updateStatus({ d => 'DEVICEID', p => 'job', u => $job->{uuid}, c => 'downloading', s => 'ok' });

#        # CHECKING
#         if (!$job->checkWinkey()) {
#             $self->updateStatus({ d => 'DEVICEID', p => 'job', u => $job->{uuid}, s => 'ko', m => 'rejected because of a Windows registry check' });
#             next JOB;
#         } elsif (!$job->checkFreespace()) {
#             $self->updateStatus({ d => 'DEVICEID', p => 'job', u => $job->{uuid}, s => 'ko', m => 'rejected because of harddrive free space' });
#             next JOB;
#         }

         $workdir->prepare();

        # PROCESSING
         $self->updateStatus({ d => 'DEVICEID', p => 'job', u => $job->{uuid}, c => 'processing' });
         my $actionProcessor = FusionInventory::Agent::Task::Deploy::ActionProcessor->new({ workdir => $workdir });
         my $actionnum = 0;
         while (my $action = $job->getNextToProcess()) {
             my $ret = $actionProcessor->process($action);
             if (!$ret->{status}) {
                 $self->setLog({ d => 'DEVICEID', u => $job->{uuid}, l => $ret->{log} });
                 $self->updateStatus({ d => 'DEVICEID', p => 'job', u => $job->{uuid}, c => 'processing', s => 'ko', actionnum => $actionnum, m => 'action processing failure' });
                 next JOB;
             }
             $self->updateStatus({ d => 'DEVICEID', p => 'job', u => $job->{uuid}, c => 'processing', s => 'ok', actionnum => $actionnum });
             $actionnum++;
         }
         $self->updateStatus({ d => 'DEVICEID', p => 'job', u => $job->{uuid}, c => 'processing', s => 'ok' });
         $self->updateStatus({ d => 'DEVICEID', p => 'job', u => $job->{uuid}, s => 'ok' });
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
