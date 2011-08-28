package FusionInventory::Agent::Task::Deploy;
our $VERSION = '0.0.1';

# Full protocol documentation available here:
#  http://forge.fusioninventory.org/projects/fusioninventory-agent/wiki/API-REST-deploy

use strict;
use warnings;
use base 'FusionInventory::Agent::Task';

use LWP;
use JSON;
use Data::Dumper;
use URI::Escape;
use FusionInventory::Agent::Storage;

#use FusionInventory::Agent::Network;
#use FusionInventory::Agent::REST;
use FusionInventory::Agent::HTTP::Client::Fusion;

use FusionInventory::Agent::Task::Deploy::Job;
use FusionInventory::Agent::Task::Deploy::File;
use FusionInventory::Agent::Task::Deploy::Datastore;
use FusionInventory::Agent::Task::Deploy::ActionProcessor;
use FusionInventory::Agent::Task::Deploy::CheckProcessor;

sub new {
    my ($class, %params) = @_;

    my $self = $class->SUPER::new(%params);

    $self->{fusionClient} = FusionInventory::Agent::HTTP::Client::Fusion->new(debug => $params{debug});

    return $self;
}

#sub setStatus {
#    my ($self, $params) = @_;
#
##    my $deviceid;
##    my $part;
##    my $uuid;
##    my $status;
##    my $message;
#    #my $ua = LWP::UserAgent->new;
#    my $network = $self->{network};
#
#    my $url = $self->{backendURL}."/?a=setStatus";
#
#    foreach (keys %$params) {
#        $url .= "&$_=".uri_escape($params->{$_});
#    }
#
#    print $url."\n";
#
#
#    my $cpt = 1;
#    do {
#        my $response = $network->get({ source => $url });
#        return 1 if defined($response);
#
#        print "FAILED TO UPDATE THE STATUS.\n";
#        print "while retry in 600 seconds ($cpt/5)\n";
#        sleep(600);
#    } while ($cpt++ <= 5);
#
#    return;
#}

sub _validateAnswer {
    my ($msgRef, $answer) = @_;

    $$msgRef = "";

    if (!defined($answer)) {
        $$msgRef = "No answer from server.";
        return;
    }

    if (ref($answer) ne 'HASH') {
        $$msgRef = "Bad answer from server. Not a hash reference.";
        return;
    }

    if (!defined($answer->{associatedFiles})) {
        $$msgRef = "missing associatedFiles key";
        return;
    }

    if (ref($answer->{associatedFiles}) ne 'HASH') {
    print Dumper($answer);
        $$msgRef = "associatedFiles should be an hash";
        return;
    }
    foreach my $k (keys %{$answer->{associatedFiles}}) {
        foreach (qw/mirrors multiparts name/) {
            if (!defined($answer->{associatedFiles}->{$k}->{$_})) {
                $$msgRef = "Missing key `$_' in associatedFiles";
                return;
            }
        }
    }
    foreach my $job (@{$answer->{jobs}}) {
        foreach (qw/uuid associatedFiles actions checks/) {
            if (!defined($job->{$_})) {
                $$msgRef = "Missing key `$_' in jobs";
                return;
            }

            if (ref($job->{actions}) ne 'ARRAY') {
                $$msgRef = "jobs/actions must be an array";
                return;
            }
        }
    }

    return 1;
}

sub processRemote {
    my ($self, $remoteUrl) = @_;

    if ( !$remoteUrl ) {
        return;
    }

    my $datastore = FusionInventory::Agent::Task::Deploy::Datastore->new(
        { path => $self->{target}{storage}{directory}.'/deploy', } );
#    $datastore->cleanUp();

    my $ret = {};
    my $jobList = [];
    my $files;

    my $answer = $self->{fusionClient}->send(
        "url" => $remoteUrl,
        args  => {
            action    => "getJobs",
            machineid => $self->{deviceid},
        }
    );

    if (ref($answer) eq 'HASH' && !keys %$answer) {
        $self->{logger}->debug("Nothing to do");
        return;
    }

    my $msg;
    if (!_validateAnswer(\$msg, $answer)) {
        $self->{logger}->debug("bad JSON: ".$msg);
        return;
    }

    foreach my $sha512 ( keys %{ $answer->{associatedFiles} } ) {
        $files->{$sha512} = FusionInventory::Agent::Task::Deploy::File->new(
            {
                sha512    => $sha512,
                data      => $answer->{associatedFiles}{$sha512},
                datastore => $datastore
            }
        );
    }

    foreach ( @{ $answer->{jobs} } ) {
        my $associatedFiles = [];
        if ( $_->{associatedFiles} ) {
            foreach my $uuid ( @{ $_->{associatedFiles} } ) {
                if ( !$files->{$uuid} ) {
                    die "unknow file: `" . $uuid
                      . "'. Not found in YSON answer!";
                }
                push @$associatedFiles, $files->{$uuid};
            }
        }
        push @$jobList,
          FusionInventory::Agent::Task::Deploy::Job->new(
            {
                data            => $_,
                associatedFiles => $associatedFiles
            }
          );
    }

  JOB: foreach my $job (@$jobList) {

        # RECEIVED
        $self->{fusionClient}->send(
            "url" => $remoteUrl,
            args  => {
                action      => "setStatus",
                machineid   => $self->{deviceid},
                part        => 'job',
                uuid        => $job->{uuid},
                currentStep => 'checking'
            }
        );

        # CHECKING
        if ( ref( $job->{checks} ) eq 'ARRAY' ) {
            my $checkProcessor =
              FusionInventory::Agent::Task::Deploy::CheckProcessor->new();
            foreach my $checknum ( 0 .. @{ $job->{checks} } ) {
                next unless $job->{checks}[$checknum];
                if ( !$checkProcessor->process( $job->{checks}[$checknum] ) ) {

                    $self->{fusionClient}->send(
                        "url" => $remoteUrl,
                        args  => {
                            action      => "setStatus",
                            machineid   => $self->{deviceid},
                            part        => 'job',
                            uuid        => $job->{uuid},
                            currentStep => 'checking',
                            status      => 'ko',
                            msg         => 'check failed',
                            cheknum     => $checknum
                        }
                    );

                    next JOB;
                }
            }
        }

        # DOWNLOADING

        $self->{fusionClient}->send(
            "url" => $remoteUrl,
            args  => {
                action      => "setStatus",
                machineid   => $self->{deviceid},
                part        => 'job',
                uuid        => $job->{uuid},
                currentStep => 'downloading'
            }
        );

        my $workdir = $datastore->createWorkDir( $job->{uuid} );
        foreach my $file ( @{ $job->{associatedFiles} } ) {
            if ( $file->exists() ) {
                $self->{fusionClient}->send(
                    "url" => $remoteUrl,
                    args  => {
                        action    => "setStatus",
                        machineid   => $self->{deviceid},
                        part      => 'file',
                        uuid        => $job->{uuid},
                        sha512      => $file->{sha512},
                        status    => 'ok'
                    }
                );

                $workdir->addFile($file);
                next;
            }
            $self->{fusionClient}->send(
                "url" => $remoteUrl,
                args  => {
                    action      => "setStatus",
                    machineid   => $self->{deviceid},
                    part        => 'file',
                    uuid        => $job->{uuid},
                    sha512      => $file->{sha512},
                    currentStep => 'downloading'
                }
            );

            $file->download();
            if ( $file->exists() ) {

                $self->{fusionClient}->send(
                    "url" => $remoteUrl,
                    args  => {
                        action      => "setStatus",
                        machineid   => $self->{deviceid},
                        part        => 'file',
                        uuid        => $job->{uuid},
                        sha512        => $file->{sha512},
                        currentStep => 'downloading',
                        status      => 'ok'
                    }
                );

                $workdir->addFile($file);
            }
            else {

                $self->{fusionClient}->send(
                    "url" => $remoteUrl,
                    args  => {
                        action      => "setStatus",
                        machineid   => $self->{deviceid},
                        part        => 'file',
                        uuid        => $job->{uuid},
                        sha512      => $file->{sha512},
                        currentStep => 'downloading',
                        status      => 'ko',
                        msg         => 'download failed'
                    }
                );
                next JOB;
            }
        }
        $self->{fusionClient}->send(
            "url" => $remoteUrl,
            args  => {
                action      => "setStatus",
                machineid   => $self->{deviceid},
                part        => 'job',
                uuid        => $job->{uuid},
                currentStep => 'downloading',
                status      => 'ok'
            }
        );

#        # CHECKING
#         if (!$job->checkWinkey()) {
#             $self->setStatus({ machineid => 'DEVICEID', part => 'job', uuid => $job->{uuid}, status => 'ko', msg => 'rejected because of a Windows registry check' });
#             next JOB;
#         } elsif (!$job->checkFreespace()) {
#             $self->setStatus({ machineid => 'DEVICEID', part => 'job', uuid => $job->{uuid}, status => 'ko', msg => 'rejected because of harddrive free space' });
#             next JOB;
#         }

        $workdir->prepare();

        # PROCESSING
#        $self->{fusionClient}->send(
#            "url" => $remoteUrl,
#            args  => {
#                action      => "setStatus",
#                machineid   => 'DEVICEID',
#                part        => 'job',
#                uuid        => $job->{uuid},
#                currentStep => 'processing'
#            }
#        );
        my $actionProcessor =
          FusionInventory::Agent::Task::Deploy::ActionProcessor->new(
            { workdir => $workdir } );
        my $actionnum = 0;
        ACTION: while ( my $action = $job->getNextToProcess() ) {
        my ($actionName, $params) = %$action;
        print Dumper($params);
            if ( $params && (ref( $params->{checks} ) eq 'ARRAY') ) {
                my $checkProcessor =
                    FusionInventory::Agent::Task::Deploy::CheckProcessor->new();
                foreach my $checknum ( 0 .. @{ $params->{checks} } ) {
                    next unless $job->{checks}[$checknum];
                    my $checkStatus = $checkProcessor->process( $params->{checks}[$checknum] );
                    if ( $checkStatus ne 'ok') {

                        $self->{fusionClient}->send(
                                "url" => $remoteUrl,
                                args  => {
                                action      => "setStatus",
                                machineid   => $self->{deviceid},
                                part        => 'job',
                                uuid        => $job->{uuid},
                                currentStep => 'checking',
                                status      => $checkStatus,
                                msg         => 'check failed',
                                actionnum   => $actionnum,
                                cheknum     => $checknum
                                }
                                );

                        next ACTION;
                    }
                }
            }


            my $ret = $actionProcessor->process($actionName, $params);
            if ( !$ret->{status} ) {

                $self->{fusionClient}->send(
                    "url" => $remoteUrl,
                    args  => {
                        action    => "setStatus",
                        machineid => $self->{deviceid},
                        uuid      => $job->{uuid},
                        log       => $ret->{log},
                        actionnum => $actionnum,
                    }
                );

                $self->{fusionClient}->send(
                    "url" => $remoteUrl,
                    args  => {
                        action      => "setStatus",
                        machineid   => $self->{deviceid},
                        part        => 'job',
                        uuid        => $job->{uuid},
                        currentStep => 'processing',
                        status      => 'ko',
                        actionnum   => $actionnum,
                        msg         => 'action processing failure'
                    }
                );

                next JOB;
            }
            $self->{fusionClient}->send(
                "url" => $remoteUrl,
                args  => {
                    action      => "setStatus",
                    machineid   => $self->{deviceid},
                    part        => 'job',
                    uuid        => $job->{uuid},
                    currentStep => 'processing',
                    status      => 'ok',
                    actionnum   => $actionnum
                }
            );

            $actionnum++;
        }

        $self->{fusionClient}->send(
            "url" => $remoteUrl,
            args  => {
                action    => "setStatus",
                machineid => $self->{deviceid},
                part      => 'job',
                uuid      => $job->{uuid},
                status    => 'ok'
            }
        );
    }

#    $datastore->cleanUp();
    1;
}


sub run {
    my ($self) = @_;

    if ( !$self->{target}->isa('FusionInventory::Agent::Target::Server') ) {
        $self->{logger}->debug("No server. Exiting...");
        return;
    }

    my $globalRemoteConfig = $self->{fusionClient}->send(
        "url" => $self->{target}->{url},
        args  => {
            action    => "getConfig",
            machineid => $self->{deviceid},
            task      => { Deploy => $VERSION },
        }
    );

    return unless $globalRemoteConfig->{schedule};
    return unless ref( $globalRemoteConfig->{schedule} ) eq 'ARRAY';

    my $deployRemote;
    foreach my $job ( @{ $globalRemoteConfig->{schedule} } ) {
        next unless $job->{task} eq "Deploy";
        $self->processRemote($job->{remote});
    }

    return 1;
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
