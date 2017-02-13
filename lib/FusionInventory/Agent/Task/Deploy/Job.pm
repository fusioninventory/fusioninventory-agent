package FusionInventory::Agent::Task::Deploy::Job;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Task::Deploy::CheckProcessor;

sub new {
    my ($class, %params) = @_;

    my $self = {
        _remoteUrl      => $params{remoteUrl},
        _client         => $params{client},
        _machineid      => $params{machineid},
        _currentStep    => 'init',
        logger          => $params{logger},
        uuid            => $params{data}->{uuid},
        requires        => $params{data}->{requires},
        checks          => $params{data}->{checks},
        actions         => $params{data}->{actions},
        associatedFiles => $params{associatedFiles}
    };

    bless $self, $class;

    return $self;
}


sub checkWinkey {
    my ($self) = @_;

    return 1 unless $self->{requires}{winkey};

    return unless $OSNAME eq 'MSWin32'
}

sub checkFreespace {
    my ($self) = @_;

    return 1;
}

sub getNextToProcess {
    my ($self) = @_;

    return unless $self->{actions};

    shift @{$self->{actions}};
}

sub currentStep {
    my ($self, $step) = @_;
    return $self->{_currentStep} = $step eq 'end' ? '' : $step;
}

sub setStatus {
    my ($self, %params) = @_;

    return unless $self->{_remoteUrl};

    # Base action hash we wan't to send back to server as job status
    my $action ={
        action      => "setStatus",
        machineid   => $self->{_machineid},
        part        => 'job',
        uuid        => $self->{uuid},
    };

    # Specific case where we want to send a file status
    if (exists($params{file}) && $params{file}) {
        $action->{part}   = 'file';
        $action->{sha512} = $params{file}->{sha512};
    }

    # Map other optional and set params to action
    map { $action->{$_} = $params{$_} }
        grep { exists($params{$_}) && $params{$_} } qw(
            status actionnum checknum msg
    );

    # Include currentStep if defined
    $action->{currentStep} = $self->{_currentStep} if $self->{_currentStep};

    # Send back the job status
    $self->{_client}->send(
        url  => $self->{_remoteUrl},
        args => $action
    );
}

sub skip_on_check_failure {
    my ($self, %params) = @_;

    my $logger = $self->{logger};
    my $checks = $params{checks} || $self->{checks};
    my $level  = $params{level} || 'job';

    if ( ref( $checks ) eq 'ARRAY' ) {
        my $checknum = 0;
        while ( @{$checks} ) {
            $checknum ++;

            my $check = shift @{$checks}
                or next;
            my $type = $check->{type} || 'unsupported';

            # Bless check object as CheckProcessor
            FusionInventory::Agent::Task::Deploy::CheckProcessor->new(
                check  => $check,
                logger => $logger,
            );

            my $checkStatus = $check->process();

            if ($check->is("skip")) {
                if ($checkStatus eq 'ok') {
                    $logger->info("Skipping $level because $type check #$checknum passed") if $logger;

                    $self->setStatus(
                        status   => 'ok',
                        msg      => "check #$checknum: $type, skipping",
                        checknum => $checknum-1
                    );

                    $self->setStatus(
                        status   => 'ok',
                        msg      => "$level skipped",
                        checknum => $checknum-1
                    );
                    return 1;
                }
                $logger->debug("$type check #$checknum: Skip $level condition not reached") if $logger;
                next;

            } elsif ($checkStatus eq 'ko') {
                $logger->info("Skipping $level because $type check #$checknum failed") if $logger;

                $self->setStatus(
                    status   => 'ko',
                    msg      => "failure of $type check #$checknum",
                    checknum => $checknum-1
                );

                return 1;
            }

            my $info = $check->is() . ": " . $check->message();
            $logger->debug("$type check #$checknum, $checkStatus, $info") if $logger;
            if ( $check->is("warning") || $check->is("info") ) {
                $self->setStatus(
                    status   => $checkStatus,
                    msg      => "check #$checknum: $type, $info",
                    checknum => $checknum-1
                );
            }
        }
    }

    return 0;
}

1;
