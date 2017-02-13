package FusionInventory::Agent::Task::Deploy::CheckProcessor::WinKeyEquals;

use strict;
use warnings;

use English qw(-no_match_vars);
use UNIVERSAL::require;

use base "FusionInventory::Agent::Task::Deploy::CheckProcessor";

sub prepare {
    my ($self) = @_;

    $self->{path} =~ s{\\}{/}g;

    $self->on_success("Found expected winkey value");
}

sub success {
    my ($self) = @_;

    $self->on_failure("Not on MSWin32");
    return 0 unless $OSNAME eq 'MSWin32';

    $self->on_failure("No value to check again provided");
    my $expected = $self->{value};
    return 0 unless (defined($expected));

    FusionInventory::Agent::Tools::Win32->require();
    if ($EVAL_ERROR) {
        $self->on_failure("Failed to load Win32 tools: $EVAL_ERROR");
        return 0;
    }

    my $regValue = FusionInventory::Agent::Tools::Win32::getRegistryValue(
        path => $self->{path}
    );

    $self->on_failure("missing winkey");
    return 0 unless (defined($regValue));

    $self->on_failure("bad winkey content: found $regValue vs $expected");
    return ( $regValue eq $expected );
}

1;
