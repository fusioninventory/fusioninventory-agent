package FusionInventory::Agent::Task::Deploy;
our $VERSION = '1.0.3';

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

sub isEnabled {
    my ($self, $response) = @_;

    return $self->{target}->isa('FusionInventory::Agent::Target::Server');

}

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
    $datastore->cleanUp();

    my $ret = {};
    my $jobList = [];
    my $files;

    my $answer = $self->{client}->send(
        "url" => $remoteUrl,
        args  => {
            action    => "getJobs",
            machineid => $self->{deviceid},
        }
    );

use Data::Dumper;
print Dumper($answer);
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
                client    => $self->{client},
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
        $self->{client}->send(
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

                    $self->{client}->send(
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

        $self->{client}->send(
            "url" => $remoteUrl,
            args  => {
                action      => "setStatus",
                machineid   => $self->{deviceid},
                part        => 'job',
                uuid        => $job->{uuid},
                currentStep => 'checking',
                status    => 'ok'
            }
        );


        # DOWNLOADING

        $self->{client}->send(
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
            if ( $file->filePartsExists() ) {
                $self->{client}->send(
                    "url" => $remoteUrl,
                    args  => {
                        action    => "setStatus",
                        machineid   => $self->{deviceid},
                        part      => 'file',
                        uuid        => $job->{uuid},
                        sha512      => $file->{sha512},
                        status    => 'ok',
                        currentStep => 'downloading'
                    }
                );

                $workdir->addFile($file);
                next;
            }
            $self->{client}->send(
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
            if ( $file->filePartsExists() ) {

                $self->{client}->send(
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

                $self->{client}->send(
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
        $self->{client}->send(
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

        if (!$workdir->prepare()) {
            $self->{client}->send(
                "url" => $remoteUrl,
                args  => {
                action      => "setStatus",
                machineid   => $self->{deviceid},
                part        => 'job',
                uuid        => $job->{uuid},
                currentStep => 'prepare',
                status      => 'ko',
                msg         => 'failed to prepare work dir'
                }
            );
            next JOB;
        } else {
            $self->{client}->send(
                "url" => $remoteUrl,
                args  => {
                action      => "setStatus",
                machineid   => $self->{deviceid},
                part        => 'job',
                uuid        => $job->{uuid},
                currentStep => 'prepare',
                status      => 'ok',
                }
            );
        }

        # PROCESSING
#        $self->{client}->send(
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
use Data::Dumper;
print Dumper($action);
        my ($actionName, $params) = %$action;
            if ( $params && (ref( $params->{checks} ) eq 'ARRAY') ) {
                my $checkProcessor =
                    FusionInventory::Agent::Task::Deploy::CheckProcessor->new();
                foreach my $checknum ( 0 .. @{ $params->{checks} } ) {
                    next unless $job->{checks}[$checknum];
                    my $checkStatus = $checkProcessor->process( $params->{checks}[$checknum] );
                    if ( $checkStatus ne 'ok') {

                        $self->{client}->send(
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


            my $ret;
            eval { $ret = $actionProcessor->process($actionName, $params); };
            $ret->{msg} = [] unless $ret->{msg};
            push @{$ret->{msg}}, $@ if $@;
            if ( !$ret->{status} ) {
                $self->{client}->send(
                    "url" => $remoteUrl,
                    args  => {
                        action    => "setStatus",
                        machineid => $self->{deviceid},
                        uuid      => $job->{uuid},
                        msg       => $ret->{msg},
                        actionnum => $actionnum,
                    }
                );

                $self->{client}->send(
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
            $self->{client}->send(
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

        $self->{client}->send(
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

    $datastore->cleanUp();
    1;
}


sub run {
    my ($self, %params) = @_;

    $self->{client} = FusionInventory::Agent::HTTP::Client::Fusion->new(
            logger       => $self->{logger},
            user         => $params{user},
            password     => $params{password},
            proxy        => $params{proxy},
            ca_cert_file => $params{ca_cert_file},
            ca_cert_dir  => $params{ca_cert_dir},
            no_ssl_check => $params{no_ssl_check},
            debug        => $self->{debug}
    );

    my $globalRemoteConfig = $self->{client}->send(
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

FusionInventory::Agent::Task::Deploy - Software deployment support for FusionInvnetory Agent

=head1 DESCRIPTION

With this module, F<FusionInventory> can accept software deployment
request from an GLPI server with the FusionInventory plugin.

This module uses SSL certificat to authentificat the server. You may have
to point F<--ca-cert-file> or F<--ca-cert-dir> to your public certificat.

If the P2P option is turned on, the agent will looks for peer in its network. The network size will be limited at 255 machines.

=cut
