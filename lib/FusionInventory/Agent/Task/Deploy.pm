package FusionInventory::Agent::Task::Deploy;

# Full protocol documentation available here:
#  http://forge.fusioninventory.org/projects/fusioninventory-agent/wiki/API-REST-deploy

use strict;
use warnings;
use base 'FusionInventory::Agent::Task';

use JSON;
use LWP;
use URI::Escape;

use FusionInventory::Agent::HTTP::Client::Fusion;
use FusionInventory::Agent::Storage;
use FusionInventory::Agent::Task::Deploy::ActionProcessor;
use FusionInventory::Agent::Task::Deploy::CheckProcessor;
use FusionInventory::Agent::Task::Deploy::Datastore;
use FusionInventory::Agent::Task::Deploy::File;
use FusionInventory::Agent::Task::Deploy::Job;

our $VERSION = '2.0.4';

sub isEnabled {
    my ($self) = @_;

    if (!$self->{target}->isa('FusionInventory::Agent::Target::Server')) {
        $self->{logger}->debug("Deploy task not compatible with local target");
        return;
    }

    return 1;
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
        foreach (qw/mirrors multiparts name p2p-retention-duration p2p uncompress/) {
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
        path => $self->{target}{storage}{directory}.'/deploy',
        logger => $self->{logger}
    );
    $datastore->cleanUp();

    my $jobList = [];
    my $files;

    my $answer = $self->{client}->send(
        url  => $remoteUrl,
        args => {
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
            client    => $self->{client},
            sha512    => $sha512,
            data      => $answer->{associatedFiles}{$sha512},
            datastore => $datastore,
            logger    => $self->{logger}
        );
    }

    foreach ( @{ $answer->{jobs} } ) {
        my $associatedFiles = [];
        if ( $_->{associatedFiles} ) {
            foreach my $uuid ( @{ $_->{associatedFiles} } ) {
                if ( !$files->{$uuid} ) {
                    die "unknow file: `" . $uuid
                      . "'. Not found in JSON answer!";
                }
                push @$associatedFiles, $files->{$uuid};
            }
        }
        push @$jobList,
          FusionInventory::Agent::Task::Deploy::Job->new(
            data            => $_,
            associatedFiles => $associatedFiles
          );
    }

  JOB: foreach my $job (@$jobList) {

        # RECEIVED
        $self->{client}->send(
            url  => $remoteUrl,
            args => {
                action      => "setStatus",
                machineid   => $self->{deviceid},
                part        => 'job',
                uuid        => $job->{uuid},
                currentStep => 'checking',
                msg         => 'starting'
            }
        );

        # CHECKING
        if ( ref( $job->{checks} ) eq 'ARRAY' ) {
            foreach my $checknum ( 0 .. @{ $job->{checks} } ) {
                next unless $job->{checks}[$checknum];
                my $checkStatus = FusionInventory::Agent::Task::Deploy::CheckProcessor->process(
                    check => $job->{checks}[$checknum],
                    logger => $self->{logger}
                );
                next if $checkStatus eq "ok";
                next if $checkStatus eq "ignore";

                $self->{client}->send(
                    url  => $remoteUrl,
                    args => {
                        action      => "setStatus",
                        machineid   => $self->{deviceid},
                        part        => 'job',
                        uuid        => $job->{uuid},
                        currentStep => 'checking',
                        status      => 'ko',
                        msg         => "failure of check #".($checknum+1)." ($checkStatus)",
                        cheknum     => $checknum
                    }
                );

                next JOB;
            }
        }

        $self->{client}->send(
            url  => $remoteUrl,
            args => {
                action      => "setStatus",
                machineid   => $self->{deviceid},
                part        => 'job',
                uuid        => $job->{uuid},
                currentStep => 'checking',
                status      => 'ok',
                msg         => 'all checks are ok'
            }
        );


        # DOWNLOADING

        $self->{client}->send(
            url  => $remoteUrl,
            args => {
                action      => "setStatus",
                machineid   => $self->{deviceid},
                part        => 'job',
                uuid        => $job->{uuid},
                currentStep => 'downloading',
                msg         => 'downloading files'
            }
        );

        my $retry = 5;
        my $workdir = $datastore->createWorkDir( $job->{uuid} );
        FETCHFILE: foreach my $file ( @{ $job->{associatedFiles} } ) {

            # File exists, no need to download
            if ( $file->filePartsExists() ) {
                $self->{client}->send(
                    url  => $remoteUrl,
                    args => {
                        action     => "setStatus",
                        machineid  => $self->{deviceid},
                        part       => 'file',
                        uuid       => $job->{uuid},
                        sha512     => $file->{sha512},
                        status     => 'ok',
                        currentStep=> 'downloading',
                        msg        => $file->{name}.' already downloaded'
                    }
                );

                $workdir->addFile($file);
                next;
            }

            # File doesn't exist, lets try or retry a download
            $self->{client}->send(
                url  => $remoteUrl,
                args => {
                    action      => "setStatus",
                    machineid   => $self->{deviceid},
                    part        => 'file',
                    uuid        => $job->{uuid},
                    sha512      => $file->{sha512},
                    currentStep => 'downloading',
                    msg         => 'fetching '.$file->{name}
                }
            );

            $file->download();

            # Are all the fileparts here?
            my $downloadIsOK = $file->filePartsExists();

            if ( $downloadIsOK ) {

                $self->{client}->send(
                    url  => $remoteUrl,
                    args => {
                        action      => "setStatus",
                        machineid   => $self->{deviceid},
                        part        => 'file',
                        uuid        => $job->{uuid},
                        sha512      => $file->{sha512},
                        currentStep => 'downloading',
                        status      => 'ok',
                        msg         => $file->{name}.' downloaded'
                    }
                );

                $workdir->addFile($file);
                next;
            }

            # Retry the download 5 times in a row and then give up
            if ( !$downloadIsOK ) {

                if ($retry--) { # Retry
# OK, retry!
                    $self->{client}->send(
                        url  => $remoteUrl,
                        args => {
                            action      => "setStatus",
                            machineid   => $self->{deviceid},
                            part        => 'file',
                            uuid        => $job->{uuid},
                            sha512      => $file->{sha512},
                            currentStep => 'downloading',
                            msg         => 'retrying '.$file->{name}
                        }
                    );

                    redo FETCHFILE;
                } else { # Give up...

                    $self->{client}->send(
                        url  => $remoteUrl,
                        args => {
                            action      => "setStatus",
                            machineid   => $self->{deviceid},
                            part        => 'file',
                            uuid        => $job->{uuid},
                            sha512      => $file->{sha512},
                            currentStep => 'downloading',
                            status      => 'ko',
                            msg         => $file->{name}.' download failed'
                        }
                    );

                    next JOB;
                }
            }

        }


        $self->{client}->send(
            url  => $remoteUrl,
            args => {
                action      => "setStatus",
                machineid   => $self->{deviceid},
                part        => 'job',
                uuid        => $job->{uuid},
                currentStep => 'downloading',
                status      => 'ok',
                msg         => 'success'
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
                url  => $remoteUrl,
                args => {
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
                url  => $remoteUrl,
                args => {
                    action      => "setStatus",
                    machineid   => $self->{deviceid},
                    part        => 'job',
                    uuid        => $job->{uuid},
                    currentStep => 'prepare',
                    status      => 'ok',
                    msg         => 'success'
                }
            );
        }

        # PROCESSING
#        $self->{client}->send(
#            url  => $remoteUrl,
#            args => {
#                action      => "setStatus",
#                machineid   => 'DEVICEID',
#                part        => 'job',
#                uuid        => $job->{uuid},
#                currentStep => 'processing'
#            }
#        );
        my $actionProcessor =
          FusionInventory::Agent::Task::Deploy::ActionProcessor->new(
            workdir => $workdir
        );
        my $actionnum = 0;
        ACTION: while ( my $action = $job->getNextToProcess() ) {
        my ($actionName, $params) = %$action;
            if ( $params && (ref( $params->{checks} ) eq 'ARRAY') ) {
                foreach my $checknum ( 0 .. @{ $params->{checks} } ) {
                    next unless $job->{checks}[$checknum];
                    my $checkStatus = FusionInventory::Agent::Task::Deploy::CheckProcessor->process(
                        check => $params->{checks}[$checknum],
                        logger => $self->{logger}

                    );
                    if ( $checkStatus ne 'ok') {

                        $self->{client}->send(
                            url  => $remoteUrl,
                            args => {
                                action      => "setStatus",
                                machineid   => $self->{deviceid},
                                part        => 'job',
                                uuid        => $job->{uuid},
                                currentStep => 'checking',
                                status      => $checkStatus,
                                msg         => "failure of check #".($checknum+1)." ($checkStatus)",
                                actionnum   => $actionnum,
                                cheknum     => $checknum
                            }
                        );

                        next ACTION;
                    }
                }
            }


            my $ret;
            eval { $ret = $actionProcessor->process($actionName, $params, $self->{logger}); };
            $ret->{msg} = [] unless $ret->{msg};
            push @{$ret->{msg}}, $@ if $@;
            if ( !$ret->{status} ) {
                $self->{client}->send(
                    url  => $remoteUrl,
                    args => {
                        action    => "setStatus",
                        machineid => $self->{deviceid},
                        uuid      => $job->{uuid},
                        msg       => $ret->{msg},
                        actionnum => $actionnum,
                    }
                );

                $self->{client}->send(
                    url  => $remoteUrl,
                    args => {
                        action      => "setStatus",
                        machineid   => $self->{deviceid},
                        part        => 'job',
                        uuid        => $job->{uuid},
                        currentStep => 'processing',
                        status      => 'ko',
                        actionnum   => $actionnum,
                        msg         => "action #".($actionnum+1)." processing failure"
                    }
                );

                next JOB;
            }
            $self->{client}->send(
                url  => $remoteUrl,
                args => {
                    action      => "setStatus",
                    machineid   => $self->{deviceid},
                    part        => 'job',
                    uuid        => $job->{uuid},
                    currentStep => 'processing',
                    status      => 'ok',
                    actionnum   => $actionnum,
                    msg         => "action #".($actionnum+1)." processing success"
                }
            );

            $actionnum++;
        }

        $self->{client}->send(
            url  => $remoteUrl,
            args => {
                action    => "setStatus",
                machineid => $self->{deviceid},
                part      => 'job',
                uuid      => $job->{uuid},
                status    => 'ok',
                msg       => "job successfully completed"
            }
        );
    }

    $datastore->cleanUp();
    1;
}


sub run {
    my ($self, %params) = @_;

    # Turn off localised output for commands
    $ENV{LC_ALL} = 'C'; # Turn off localised output for commands
    $ENV{LANG} = 'C'; # Turn off localised output for commands

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
        url  => $self->{target}->{url},
        args => {
            action    => "getConfig",
            machineid => $self->{deviceid},
            task      => { Deploy => $VERSION },
        }
    );

    return unless $globalRemoteConfig->{schedule};
    return unless ref( $globalRemoteConfig->{schedule} ) eq 'ARRAY';

    foreach my $job ( @{ $globalRemoteConfig->{schedule} } ) {
        next unless $job->{task} eq "Deploy";
        $self->processRemote($job->{remote});
    }

    return 1;
}

__END__

=head1 NAME

FusionInventory::Agent::Task::Deploy - Software deployment support for FusionInventory Agent

=head1 DESCRIPTION

With this module, F<FusionInventory> can accept software deployment
request from an GLPI server with the FusionInventory plugin.

This module uses SSL certificat to authentificat the server. You may have
to point F<--ca-cert-file> or F<--ca-cert-dir> to your public certificat.

If the P2P option is turned on, the agent will looks for peer in its network. The network size will be limited at 255 machines.

=head1 FUNCTIONS

=head2 isEnabled ( $self )

Returns true if the task is enabled.

=head2 processRemote ( $self, $remoteUrl )

Process orders from a remote server.

=head2 run ( $self, %params )

Run the task.
