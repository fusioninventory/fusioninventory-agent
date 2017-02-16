package FusionInventory::Agent::Task::Deploy::CheckProcessor::WinKeyEquals;

use strict;
use warnings;

use English qw(-no_match_vars);
use UNIVERSAL::require;

use base "FusionInventory::Agent::Task::Deploy::CheckProcessor";

sub prepare {
    my ($self) = @_;

    $self->{path} =~ s{\\}{/}g;

    $self->on_success("found expected winkey value: ".($self->{value}||'n/a')." in ".$self->{path});
}

sub success {
    my ($self) = @_;

    $self->on_failure("check only available on windows");
    return 0 unless $OSNAME eq 'MSWin32';

    $self->on_failure("no value provided to check winkey value against");
    my $expected = $self->{value};
    return 0 unless (defined($expected));

    FusionInventory::Agent::Tools::Win32->require();
    if ($EVAL_ERROR) {
        $self->on_failure("failed to load Win32 tools: $EVAL_ERROR");
        return 0;
    }

    my $regValue = FusionInventory::Agent::Tools::Win32::getRegistryValue(
        path => $self->{path}
    );

    $self->on_failure("missing winkey: ".$self->{path});
    return 0 unless (defined($regValue));

    $self->on_failure("bad winkey content: found $regValue vs $expected in ".$self->{path});
    return ( $regValue eq $expected );
}

1;
