package FusionInventory::Agent::Task::Deploy;

# Full protocol documentation available here:
#  http://forge.fusioninventory.org/projects/fusioninventory-agent/wiki/API-REST-deploy

use strict;
use warnings;
use base 'FusionInventory::Agent::Task';

use JSON;
use LWP;
use URI::Escape;

use FusionInventory::Agent::Storage;
use FusionInventory::Agent::Task::Deploy::ActionProcessor;
use FusionInventory::Agent::Task::Deploy::CheckProcessor;
use FusionInventory::Agent::Task::Deploy::Datastore;
use FusionInventory::Agent::Task::Deploy::File;
use FusionInventory::Agent::Task::Deploy::Job;

our $VERSION = $FusionInventory::Agent::VERSION;

sub getConfiguration {
    my ($self, %params) = @_;

    my $config = $params{spec}->{config};

    die "invalid server answer" unless ref $config eq 'HASH';

    die "missing files list" unless $config->{associatedFiles};
    die "invalid files list format" unless ref $config->{associatedFiles} eq 'HASH';

    foreach my $file_id (keys %{$config->{associatedFiles}}) {
        my $file = $config->{associatedFiles}->{$file_id};
        foreach my $key (qw/mirrors multiparts name p2p-retention-duration p2p uncompress/) {
            die "missing key '$key' in file $file_id" unless defined $file->{$key};
        }
    }

    die "missing jobs list" unless $config->{jobs};
    die "invalid jobs list format" unless ref $config->{jobs} eq 'ARRAY';

    my $count = 0;
    foreach my $job (@{$config->{jobs}}) {
        $count++;
        foreach my $key (qw/uuid associatedFiles actions checks/) {
            die "missing key '$key' in job #$count" unless defined $job->{$key};
        }
        die "invalid actions list format" unless ref $job->{actions} eq 'ARRAY';
    }

    return (
        jobs  => $config->{jobs},
        files => $config->{associatedFiles},
        url   => $params{spec}->{url}
    );
}

sub run {
    my ($self, %params) = @_;

    # Turn off localised output for commands
    $ENV{LC_ALL} = 'C'; # Turn off localised output for commands
    $ENV{LANG} = 'C'; # Turn off localised output for commands

    my @jobs = @{$self->{config}->{jobs}}
        or die "no jobs provided, aborting";
    my %files = @{$self->{config}->{files}}
        or die "no files provided, aborting";
    my $url = $self->{config}->{url}
        or die "no url provided, aborting";
    my $client = $params{client};

    my $datastore = FusionInventory::Agent::Task::Deploy::Datastore->new(
        path => $self->{target}{storage}{directory}.'/deploy',
        logger => $self->{logger}
    );
    $datastore->cleanUp();

    my $jobList = [];
    my $files;

    foreach my $sha512 (keys %files) {
        $files->{$sha512} = FusionInventory::Agent::Task::Deploy::File->new(
            client    => $client,
            sha512    => $sha512,
            data      => $files{$sha512},
            datastore => $datastore,
            logger    => $self->{logger}
        );
    }

    foreach (@jobs) {
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
        $client->sendJSON(
            url  => $url,
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

                $client->sendJSON(
                    url  => $url,
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

        $client->sendJSON(
            url  => $url,
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

        $client->sendJSON(
            url  => $url,
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
                $client->sendJSON(
                    url  => $url,
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
            $client->sendJSON(
                url  => $url,
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

                $client->sendJSON(
                    url  => $url,
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
                    $client->sendJSON(
                        url  => $url,
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

                    $client->sendJSON(
                        url  => $url,
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


        $client->sendJSON(
            url  => $url,
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
            $client->sendJSON(
                url  => $url,
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
            $client->sendJSON(
                url  => $url,
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
#        $client->sendJSON(
#            url  => $url,
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

                        $client->sendJSON(
                            url  => $url,
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
                $client->sendJSON(
                    url  => $url,
                    args => {
                        action    => "setStatus",
                        machineid => $self->{deviceid},
                        uuid      => $job->{uuid},
                        msg       => $ret->{msg},
                        actionnum => $actionnum,
                    }
                );

                $client->sendJSON(
                    url  => $url,
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
            $client->sendJSON(
                url  => $url,
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

        $client->sendJSON(
            url  => $url,
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
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Task::Deploy - Software deployment support

=head1 DESCRIPTION

This module allows the FusionInventory agent to deploy software on
its own host.
