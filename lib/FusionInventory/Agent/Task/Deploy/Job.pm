package FusionInventory::Agent::Task::Deploy::Job;

use strict;
use warnings;

use English qw(-no_match_vars);

sub new {
    my ($class, %params) = @_;

    my $self = {
        _remoteUrl      => $params{remoteUrl},
        _client         => $params{client},
        _machineid      => $params{machineid},
        _currentStep    => 'init',
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

1;
