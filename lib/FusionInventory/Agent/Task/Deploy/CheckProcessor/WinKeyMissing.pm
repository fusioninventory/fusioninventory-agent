package FusionInventory::Agent::Task::Deploy::CheckProcessor::WinKeyMissing;

use strict;
use warnings;

use English qw(-no_match_vars);
use UNIVERSAL::require;

use base "FusionInventory::Agent::Task::Deploy::CheckProcessor";

sub prepare {
    my ($self) = @_;

    $self->{path} =~ s{\\}{/}g;

    $self->on_success("missing winkey: ".$self->{path});
}

sub success {
    my ($self) = @_;

    $self->on_failure("check only available on windows");
    return 0 unless $OSNAME eq 'MSWin32';

    FusionInventory::Agent::Tools::Win32->require();
    if ($EVAL_ERROR) {
        $self->on_failure("failed to load Win32 tools: $EVAL_ERROR");
        return 0;
    }

    $self->on_failure("winkey found: ".$self->{path});
    return ! defined(FusionInventory::Agent::Tools::Win32::getRegistryKey(
            path => $self->{path}
        )
    );
}

1;
